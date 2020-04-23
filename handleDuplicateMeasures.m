function [physdata] = handleDuplicateMeasures(physdata, study, doupdates, detaillog)

% handleDuplicateMeasures -  Analyse and correct for duplicate measures
% Duplicates are of three types - for a given patient ID and recordingtype :-
%           1) multiple rows with exactly the same date/time
%           2) multiple rows within a few minutes
%           3) multiple rows for the same day

nadupefile = sprintf('%sNonActivityDuplicates.xlsx', study);

fprintf('Handling Duplicates\n');
fprintf('-------------------\n');
tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
demographicsmatfile = sprintf('%sdatademographicsbypatient.mat', study);
fprintf('Loading demographic data by patient\n');
load(fullfile(basedir, subfolder, demographicsmatfile));
toc
fprintf('\n');

tic
% 1a) fix non-activity dupes - 
fprintf('1a) Exact date/time duplicates - Non-Activity\n');

% first ensure physdata is sorted correctly
physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');

% create indexes for Activity vs Non-Activity rows
idxna = find(~ismember(physdata.RecordingType,'ActivityRecording'));
idxa = find(ismember(physdata.RecordingType,'ActivityRecording'));

% create index of all sequential rows with date/time diff == 0
exactidx = find(diff(physdata.Date_TimeRecorded)==0);

% build idx of non-activity rows with exact same date/time
naexactidx = intersect(exactidx, idxna);

% need to eliminate those rows with exactly the same time, but the
% Smart Care ID or RecordingType isn't the same between rows - ie they aren't real dupes
invalididx = find(physdata.SmartCareID(naexactidx) ~= physdata.SmartCareID(naexactidx+1) | ...
    string([physdata.RecordingType(naexactidx)]) ~= string([physdata.RecordingType(naexactidx+1)]));
naexactidx(invalididx) = [];

fprintf('Found %d pairs of non-activity exact matches - delete one row of each pair\n', size(naexactidx,1));

temp = physdata(naexactidx, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded', 'DateNum'});
temp2 = varfun(@mean, temp, 'GroupingVariables', {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'});
temp2.GroupCount = temp2.GroupCount * 2; % each row is a pair of dupes for this set
writetable(temp2(:, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded', 'GroupCount'}), fullfile(basedir, 'ExcelFiles', nadupefile), 'Sheet', 'ExactTimeDupes');

% from analysing, all non-activity exact dupes have same values 
% => therefore just need to keep one of the pairs of rows
% naexactpairidx = unique([naexactidx; naexactidx+1]);
% temp = varfun(@std, physdata(intersect(exactpairidx,idxna),:),'GroupingVariables', {'SmartCareID','DateNum','UserName','RecordingType','Date_TimeRecorded'});

% 1b) next deal with activity dupes
fprintf('\n');
fprintf('1b) Exact date/time duplicates - Activity\n');

% build idx of activity rows with exact same date/time
aexactidx = intersect(exactidx, idxa);

% need to eliminate those rows where the Smart Care ID or RecordingType
% isn't the same between rows - ie they aren't real dupes
invalididx = find(physdata.SmartCareID(aexactidx) ~= physdata.SmartCareID(aexactidx+1) | ...
    string([physdata.RecordingType(aexactidx)]) ~= string([physdata.RecordingType(aexactidx+1)]));
aexactidx(invalididx) = [];

% now create index including the next row for each set of the activity
% exact match rows
aexactpairidx = unique([aexactidx; aexactidx+1]);

fprintf('Found %d exact duplicate rows of activity measures - to be deleted\n', size(aexactpairidx,1)); 

% create table of activity rows to add back - single row for each exact dupe set
% with the mode of the activity steps for each. Only include rows where the
% std dev of the dupe set is < 10 (ie every row almost exactly matches)
temp = varfun(@std, physdata(aexactpairidx,:), 'GroupingVariables', {'SmartCareID','DateNum','UserName','RecordingType','Date_TimeRecorded'}, 'InputVariables', {'Activity_Steps'});
goodrowidx = find(temp.std_Activity_Steps < 10);
fprintf('Of those dupes, found %d sets that have identical or near-identical values - add back the mode of each\n', size(goodrowidx,1)); 
goodrows = temp(goodrowidx, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'});

addexactrows = physdata(1:1,:);
addexactrows = [];

for i = 1:size(goodrows,1)
    tempidx = find(physdata.SmartCareID == goodrows.SmartCareID(i) & physdata.Date_TimeRecorded == goodrows.Date_TimeRecorded(i));
    setmode = mode(physdata.Activity_Steps(tempidx));
    rowtoadd = physdata(tempidx(1),:);
    rowtoadd.Activity_Steps = setmode;
    addexactrows = [addexactrows ; rowtoadd];
end

% make the updates
% - non-activity - delete one of the pairs of identical rows
% - activity - delete all the dupe rows and add back a row with the most
% common value (mode)

if doupdates
    fprintf('\n');
    fprintf('1c) Making updates to data table\n');
    delrowsidx = [naexactidx ; aexactpairidx];
    fprintf('Deleting %d + %d = %d exact dupe rows\n', size(naexactidx,1), size(aexactpairidx,1), size(delrowsidx,1)); 
    physdata(delrowsidx,:) = [];
    fprintf('Adding back %d replacements\n', size(addexactrows,1)); 
    physdata = [physdata ; addexactrows];
    physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
    fprintf('SmartCare data now has %d rows\n', size(physdata,1));
end
toc
fprintf('\n');

% 2a) fix duplicates within 12 min window 0 Activity
tic
fprintf('2a) Duplicate measures within 12mins - Activity\n');

% create index for Activity rows
idxa = find(ismember(physdata.RecordingType,'ActivityRecording'));

% create index of all sequential rows with date/time diff < 12mins
timewindow = '00:12:00';
diffDTR = diff(physdata.Date_TimeRecorded);
similaridx = find(diffDTR > '00:00:00' & diffDTR < timewindow);

% build idx of activity rows with date/time diff < 12mins
asimilaridx = intersect(similaridx, idxa);

% need to eliminate those rows where the Smart Care ID or RecordingType
% isn't the same between rows - ie they aren't real dupes
invalididx = find(physdata.SmartCareID(asimilaridx) ~= physdata.SmartCareID(asimilaridx+1) | ...
    string([physdata.RecordingType(asimilaridx)]) ~= string([physdata.RecordingType(asimilaridx+1)]));
asimilaridx(invalididx) = [];

% create table of activity rows to add back - single row for each dupe set
% with the max of the activity steps for each.
% with detaillogging on, compare toe mean and std of activity for patient
% to ensure max is reasonable
addsimrows = physdata(1:1,:);
addsimrows = [];
priorscid = 0;
priorrectype = ' ';
priorenddtr = '';
asimilarpairidx = [];
for i = 1:size(asimilaridx,1)
    pidx = asimilaridx(i);
    scid = physdata.SmartCareID(pidx);
    dtnum = physdata.DateNum(pidx);
    rectype = physdata.RecordingType(pidx);
    startdtr = physdata.Date_TimeRecorded(pidx);
    enddtr = startdtr + timewindow;
    patientddidx = find(demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType,rectype));
    if (size(patientddidx,1) > 0)
        patientmean = demographicstable(patientddidx,:).Fun_Activity_Steps(1);
        patientstd = demographicstable(patientddidx,:).Fun_Activity_Steps(2);
    else
        patientmean = 0;
        patientstd = 0;
    end
    if detaillog
        %fprintf('Dupe %3d, scid = %3d, rectype = %22s, startdtr = %20s, enddtr = %20s\n', i, scid, string(rectype), startdtr, enddtr);
    end
    if (scid ~= priorscid | ~ismember(rectype, priorrectype) | startdtr > priorenddtr)
        ntidx = find(physdata.SmartCareID == scid & ismember(physdata.RecordingType,rectype) & physdata.Date_TimeRecorded >= startdtr & physdata.Date_TimeRecorded < enddtr);
        setmax = max(physdata.Activity_Steps(ntidx));
        if detaillog    
            if ((setmax < patientmean-2*patientstd) | (setmax > patientmean+2*patientstd))
                fprintf('Max of similar dupe set (size %3d) is %3d, patient: -2SD = %.2f, mean = %.2f, +2SD = %.2f\n', size(ntidx,1), setmax, patientmean - 2*patientstd, patientmean, patientmean + 2*patientstd);
                %physdata(ntidx,:)
            end
        end
        rowtoadd = physdata(ntidx(1),:);
        rowtoadd.Activity_Steps = setmax;
        addsimrows = [addsimrows ; rowtoadd];
        asimilarpairidx = [asimilarpairidx; ntidx];
    end
    priorscid = scid;
    priorrectype = rectype;
    priorenddtr = enddtr;
end

fprintf('There are %d sets of Activity similar dupes (< 12mins)\n', size(addsimrows,1));

if doupdates
    fprintf('Deleting %d Activity similar dupe rows\n', size(asimilarpairidx,1)); 
    physdata(asimilarpairidx,:) = [];
    fprintf('Adding back %d replacements\n', size(addsimrows,1)); 
    physdata = [physdata ; addsimrows];
    physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
    fprintf('SmartCare data now has %d rows\n', size(physdata,1));
end
toc
fprintf('\n');

tic
fprintf('2b) Duplicate measures within 30 mins - Non-Activity\n');
% recreate indexes after deletions
% create index for Activity rows
idxna = find(~ismember(physdata.RecordingType,'ActivityRecording'));
% create index of all sequential rows with date/time diff < 30mins
timewindow = '00:30:00';
diffDTR = diff(physdata.Date_TimeRecorded);
similaridx = find(diffDTR > '00:00:00' & diffDTR < timewindow);

% build idx of non-activity rows with date/time diff < 30mins
nasimidx = intersect(similaridx, idxna);

% need to eliminate those rows where the Smart Care ID or RecordingType
% isn't the same between rows - ie they aren't real dupes
invalididx = find(physdata.SmartCareID(nasimidx) ~= physdata.SmartCareID(nasimidx+1) | ...
    string([physdata.RecordingType(nasimidx)]) ~= string([physdata.RecordingType(nasimidx+1)]));
nasimidx(invalididx) = [];

% create table of non-activity rows to add back - single row for dupe set
% for lung function, with the max, for others with the chronologically last
addsimrows = physdata(1:1,:);
addsimrows = [];
priorscid = 0;
priorrectype = ' ';
priorenddtr = '';
nasimpairidx = [];
for i = 1:size(nasimidx,1)
    pidx = nasimidx(i);
    scid = physdata.SmartCareID(pidx);
    dtnum = physdata.DateNum(pidx);
    rectype = physdata.RecordingType(pidx);
    startdtr = physdata.Date_TimeRecorded(pidx);
    enddtr = startdtr + timewindow;
    if detaillog
        fprintf('Dupe %3d, scid = %3d, rectype = %22s, startdtr = %20s, enddtr = %20s\n', i, scid, string(rectype), startdtr, enddtr);
    end
    if (scid ~= priorscid | ~ismember(rectype, priorrectype) | startdtr > priorenddtr)
        ntidx = find(physdata.SmartCareID == scid & ismember(physdata.RecordingType,rectype) & physdata.Date_TimeRecorded >= startdtr & physdata.Date_TimeRecorded < enddtr);
        if ismember(rectype, {'LungFunctionRecording', 'FEV1Recording'})
            % for Lung Function, some patients mirror clinical procedure
            % so take the best of 3 measures for this
            if ismember(study, {'SC', 'TM'})
                [fevmax fevmaxidx] = max(physdata.FEV1_(ntidx));
            elseif ismember(study, {'CL'})
                [fevmax fevmaxidx] = max(physdata.FEV1(ntidx));
            else
                fprintf('Unknown study\n');
            end
            rowtoadd = physdata(ntidx(fevmaxidx),:);
            addsimrows = [addsimrows ; rowtoadd];
            nasimpairidx = [nasimpairidx; ntidx];
            if detaillog    
                physdata(ntidx,:)
                rowtoadd
            end
        else
            % for other measures, multiple entries in a short space of time 
            % indicates a mistake that has been corrected so for these, keep 
            % the chronologically last row of the set
            rowtoadd = physdata(ntidx(size(ntidx,1)),:);
            addsimrows = [addsimrows ; rowtoadd];
            nasimpairidx = [nasimpairidx; ntidx];
            if detaillog    
                physdata(ntidx,:)
                rowtoadd
            end
        end
    end
    priorscid = scid;
    priorrectype = rectype;
    priorenddtr = enddtr;
end

fprintf('There are %d sets of Non-Activity similar dupes (< 30mins)\n', size(addsimrows,1));

temp = physdata(nasimpairidx, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded', 'DateNum'});
temp2 = varfun(@mean, temp, 'GroupingVariables', {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'});
writetable(temp2(:, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded', 'GroupCount'}), fullfile(basedir, 'ExcelFiles', nadupefile), 'Sheet', 'SimilarTimeDupes');

if doupdates
    fprintf('Deleting %d Activity similar dupe rows\n', size(nasimpairidx,1)); 
    physdata(nasimpairidx,:) = [];
    fprintf('Adding back %d replacements\n', size(addsimrows,1)); 
    physdata = [physdata ; addsimrows];
    physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
    fprintf('SmartCare data now has %d rows\n', size(physdata,1));
end

toc
fprintf('\n');

tic
fprintf('3a) Duplicate measures on same day - Activity\n');

physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'DateNum'}, 'ascend');
% recreate indexes after deletions
idxa = find(ismember(physdata.RecordingType,'ActivityRecording'));
samedayidx = find(diff(physdata.DateNum)==0);

% build idx of activity rows with date/time diff < 12mins
asamedayidx = intersect(samedayidx, idxa);

% need to eliminate those rows where the Smart Care ID or RecordingType
% isn't the same between rows - ie they aren't real dupes
invalididx = find(physdata.SmartCareID(asamedayidx) ~= physdata.SmartCareID(asamedayidx+1) | ...
    string([physdata.RecordingType(asamedayidx)]) ~= string([physdata.RecordingType(asamedayidx+1)]));
asamedayidx(invalididx) = [];

% create table of activity rows to add back - single row for each dupe set
% with the sum of the activity steps for each.
% with detaillogging on, compare toe mean and std of activity for patient
% to ensure max is reasonable
addsamerows = physdata(1:1,:);
addsamerows = [];
priorscid = 0;
priordtnum = 0;
priorrectype = ' ';
asamedaypairidx = [];
for i = 1:size(asamedayidx,1)
    pidx = asamedayidx(i);
    scid = physdata.SmartCareID(pidx);
    dtnum = physdata.DateNum(pidx);
    rectype = physdata.RecordingType(pidx);
    patientddidx = find(demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType,rectype));
    if (size(patientddidx,1) > 0)
        patientmean = demographicstable(patientddidx,:).Fun_Activity_Steps(1);
        patientstd = demographicstable(patientddidx,:).Fun_Activity_Steps(2);
    else
        patientmean = 0;
        patientstd = 0;
    end
    if detaillog
        fprintf('Dupe %3d, scid = %3d, rectype = %22s, dtnum = %3d\n', i, scid, string(rectype), dtnum);
    end
    if (scid ~= priorscid | dtnum ~= priordtnum | ~ismember(rectype, priorrectype))
        ntidx = find(physdata.SmartCareID == scid & physdata.DateNum == dtnum & ismember(physdata.RecordingType,rectype));
        setsum = sum(physdata.Activity_Steps(ntidx));
        if detaillog
            if ((setsum < patientmean-2*patientstd) | (setsum > patientmean+2*patientstd))
                fprintf('Sum of same day dupe set (size %3d) is %3d, patient: -2SD = %.2f, mean = %.2f, +2SD = %.2f\n',size(ntidx,1), setsum , patientmean - 2*patientstd, patientmean, patientmean + 2*patientstd);
                %physdata(ntidx,:)
                
            end
            sortrows(getMeasuresForPatientAndDateRange(physdata(idxa,:),scid,dtnum, 1, rectype, true),{'SmartCareID', 'RecordingType','Date_TimeRecorded'}, 'ascend')
        end
        rowtoadd = physdata(ntidx(1),:);
        rowtoadd.Activity_Steps = setsum;
        addsamerows = [addsamerows ; rowtoadd];
        asamedaypairidx = [asamedaypairidx; ntidx];
    end
    priorscid = scid;
    priordtnum = dtnum;
    priorrectype = rectype;
end

fprintf('There are %d sets of Activity same day dupes\n', size(addsamerows,1));

if doupdates
    fprintf('Deleting %d Activity similar dupe rows\n', size(asamedaypairidx,1)); 
    physdata(asamedaypairidx,:) = [];
    fprintf('Adding back %d replacements\n', size(addsamerows,1)); 
    physdata = [physdata ; addsamerows];
    physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
    fprintf('SmartCare data now has %d rows\n', size(physdata,1));
end
toc
fprintf('\n');

tic
fprintf('3b) Duplicate measures on same day - Non-Activity\n');
physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'DateNum'}, 'ascend');

% recreate indexes after deletions
idxna = find(~ismember(physdata.RecordingType,'ActivityRecording'));
samedayidx = find(diff(physdata.DateNum)==0);

% build idx of activity rows with date/time diff < 12mins
nasamedayidx = intersect(samedayidx, idxna);

% need to eliminate those rows where the diff is in the window, but the
% Smart Care ID or RecordingType isn't the same between rows - ie they aren't real dupes
invalididx = find(physdata.SmartCareID(nasamedayidx) ~= physdata.SmartCareID(nasamedayidx+1) | ...
    string([physdata.RecordingType(nasamedayidx)]) ~= string([physdata.RecordingType(nasamedayidx+1)]));
nasamedayidx(invalididx) = [];

addsamerows = physdata(1:1,:);
addsamerows = [];
priorscid = 0;
priordtnum = 0;
priorrectype = ' ';
nasamedaypairidx = [];
for i = 1:size(nasamedayidx,1)
    pidx = nasamedayidx(i);
    scid = physdata.SmartCareID(pidx);
    dtnum = physdata.DateNum(pidx);
    rectype = physdata.RecordingType(pidx);
    if detaillog
        fprintf('Dupe %3d, scid = %3d, rectype = %22s, dtnum = %3d\n', i, scid, string(rectype), dtnum);
    end
    if (scid ~= priorscid | dtnum ~= priordtnum | ~ismember(rectype, priorrectype))
        ntidx = find(physdata.SmartCareID == scid & physdata.DateNum == dtnum & ismember(physdata.RecordingType,rectype));
        temp = physdata(ntidx,:);
        if ismember(study, 'CL')
            temp.SputumColour = [];
        end
        %meantable = varfun(@mean, physdata(ntidx,:), 'GroupingVariables', {'SmartCareID','DateNum','UserName','RecordingType'});
        meantable = varfun(@mean, temp, 'GroupingVariables', {'SmartCareID','DateNum','UserName','RecordingType'});
        if (size(meantable,1) >1)
            fprintf('Multiple rows returned from mean calc !! dupe %3d, scid %3d, dtnum %3d dupe set size = %d\n', i, scid, dtnum, size(ntidx,1));
        end
        rowtoadd = physdata(ntidx(end),:);
        rowtoadd.WeightInKg = meantable.mean_WeightInKg;
        rowtoadd.O2Saturation = meantable.mean_O2Saturation;
        rowtoadd.Pulse_BPM_ = meantable.mean_Pulse_BPM_;
        rowtoadd.Rating = meantable.mean_Rating;
        rowtoadd.Temp_degC_ = meantable.mean_Temp_degC_;
        if ismember(study, {'SC', 'TM'})
            rowtoadd.FEV1 = meantable.mean_FEV1;
            rowtoadd.PredictedFEV = meantable.mean_PredictedFEV;
            rowtoadd.FEV1_ = meantable.mean_FEV1_;
            rowtoadd.CalcFEV1SetAs = meantable.mean_CalcFEV1SetAs;
            rowtoadd.ScalingRatio = meantable.mean_ScalingRatio;
            rowtoadd.CalcFEV1_ = meantable.mean_CalcFEV1_;
        end
        if ismember(study, 'CL')
            rowtoadd.FEV = meantable.mean_FEV;
            rowtoadd.NumSleepDisturb = meantable.mean_NumSleepDisturb;
            rowtoadd.BreathsPerMin = meantable.mean_BreathsPerMin;
        end
        addsamerows = [addsamerows ; rowtoadd];
        nasamedaypairidx = [nasamedaypairidx; ntidx];
        if detaillog
            %physdata(ntidx,:)
            sortrows(getMeasuresForPatientAndDateRange(physdata(idxna,:),scid,dtnum, 1, rectype, true),{'SmartCareID', 'RecordingType','Date_TimeRecorded'}, 'ascend')
        end
    end
    priorscid = scid;
    priordtnum = dtnum;
    priorrectype = rectype;
end

fprintf('There are %d sets of Non-Activity same day dupes\n', size(addsamerows,1));

temp = physdata(nasamedaypairidx, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded', 'DateNum'});
temp2 = varfun(@mean, temp, 'GroupingVariables', {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'});
writetable(temp2(:, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded', 'GroupCount'}), fullfile(basedir, 'ExcelFiles', nadupefile), 'Sheet', 'SameDayDupes');

if doupdates
    fprintf('Deleting %d Activity similar dupe rows\n', size(nasamedaypairidx,1)); 
    physdata(nasamedaypairidx,:) = [];
    fprintf('Adding back %d replacements\n', size(addsamerows,1)); 
    physdata = [physdata ; addsamerows];
    physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
    fprintf('SmartCare data now has %d rows\n', size(physdata,1));
    
end
toc
fprintf('\n');

end

