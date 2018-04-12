function [physdataout, physdupes, tunique] = handleDuplicateMeasures(physdata, smartcareID, doupdates, detaillog)

% handleDuplicateMeasures -  Analyse and correct for duplicate measures
% Duplicates are of three types - for a given patient ID and recordingtype :-
%           1) multiple rows with exactly the same date/time
%           2) multiple rows within a few minutes
%           3) multiple rows for the same day


fprintf('Handling Duplicates\n');
fprintf('-------------------\n');
tic
fprintf('Loading demographic data by patient\n');
load('datademographicsbypatient.mat');
toc
fprintf('\n');

tic
% first deal with duplicates with exactly the same date/time
fprintf('1a) Exact date/time duplicates - Non-Activity\n');

% first ensure physdata is sorted correctly
physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');

idxna = find(~ismember(physdata.RecordingType,'ActivityRecording'));
idxa = find(ismember(physdata.RecordingType,'ActivityRecording'));

diffDTR = diff(physdata.Date_TimeRecorded);
exactidx = find(diffDTR == 0);
exactpairidx = unique([ exactidx ; exactidx+1 ]); % need to add next row for each diff of zero

% 1a) fix non-activity dupes - all exact dupes have same values. 
% temp = varfun(@std, physdata(intersect(exactpairidx,idxna),:), 'GroupingVariables', {'SmartCareID','DateNum','UserName','RecordingType','Date_TimeRecorded'})
% Collapse by removing just first row of dupe pair (exactidx)
% for now just build idx of rows to delete
delexactnaidx = intersect(exactidx, idxna);

% remove rows where exact date/time dupes are for different measures
temp = string([physdata.RecordingType(delexactnaidx) physdata.RecordingType(delexactnaidx+1)]);
delexactnaidx(find(temp(:,1) ~= temp(:,2))) = [];
fprintf('Found %d pairs of non-activity exact matches - delete one row of each pair\n', size(delexactnaidx,1)); 


% 1b) next deal with activity dupes
fprintf('\n');
fprintf('1b) Exact date/time duplicates - Activity\n');

% create index of rows to delete
delexactpairaidx = intersect(exactpairidx,idxa);
fprintf('Found %d exact duplicate rows of activity measures - to be deleted\n', size(delexactpairaidx,1)); 

% create table of rows to add back - single row for each exact dupe set
% with the mode of the activity steps for each. Only include rows where the
% std dev of the dupe set is < 10 (ie every row almost exactly matches)
temp = varfun(@std, physdata(delexactpairaidx,:), 'GroupingVariables', {'SmartCareID','DateNum','UserName','RecordingType','Date_TimeRecorded'}, 'InputVariables', {'Activity_Steps'});
goodrowidx = find(temp.std_Activity_Steps < 10);
fprintf('Of those dupes, found %d sets that have identical or near-identical values - add back the mode of each\n', size(goodrowidx,1)); 
goodrows = temp(goodrowidx, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'});

addexactrows = physdata(1:10,:);
addexactrows = [];

for i = 1:size(goodrows,1)
    tempidx = find(physdata.SmartCareID == goodrows.SmartCareID(i) & physdata.Date_TimeRecorded == goodrows.Date_TimeRecorded(i));
    setmode = mode(physdata.Activity_Steps(tempidx));
    rowtoadd = physdata(tempidx(1),:);
    rowtoadd.Activity_Steps = setmode;
    addexactrows = [addexactrows ; rowtoadd];
end

if doupdates
    fprintf('\n');
    fprintf('1c) Making updates to data table\n');
    delrowsidx = [delexactnaidx ; delexactpairaidx];
    fprintf('Deleting %d + %d = %d exact dupe rows\n', size(delexactnaidx,1), size(delexactpairaidx,1), size(delrowsidx,1)); 
    physdata(delrowsidx,:) = [];
    fprintf('Adding back %d replacements\n', size(addexactrows,1)); 
    physdata = [physdata ; addexactrows];
    physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
end
toc
fprintf('\n');


% 2a) fix duplicates within 10 min window 0 Activity
tic
fprintf('2a) Duplicate measures within 10mins - Activity\n');

idxa = find(ismember(physdata.RecordingType,'ActivityRecording'));
timewindow = '00:10:00';
diffDTR = diff(physdata.Date_TimeRecorded);
similaridx = find(diffDTR > '00:00:00' & diffDTR < timewindow);
similarpairidx = unique([ similaridx ; similaridx+1 ]); % need to add next row for each diff of < 10min

% delete those with < 100 steps
delzeroaidx = intersect(similarpairidx, idxa);
tempidx = find(physdata.Activity_Steps < 100);
delzeroaidx = intersect(delzeroaidx,tempidx);

if doupdates
    fprintf('Deleting %3d rows with < 100 Activity Steps in the similar dupe sets\n', size(delzeroaidx,1));
    physdata(delzeroaidx,:) = [];
end

% recreate indexes after deletions
idxa = find(ismember(physdata.RecordingType,'ActivityRecording'));

diffDTR = diff(physdata.Date_TimeRecorded);
similaridx = find(diffDTR > '00:00:00' & diffDTR < timewindow);
similarpairidx = unique([ similaridx ; similaridx+1 ]); % need to add next row for each diff of < 5min

asimidx = intersect(similaridx, idxa);
asimpairidx = intersect(similarpairidx, idxa);
fprintf('There are %d remaining Activity similar dupes\n', size(asimpairidx,1)); 

addsimrows = physdata(1:1,:);
addsimrows = [];
priorscid = 0;
priorrectype = ' ';
priorenddtr = '';
for i = 1:size(asimidx,1)
    pidx = asimidx(i);
    scid = physdata.SmartCareID(pidx);
    dtnum = physdata.DateNum(pidx);
    rectype = physdata.RecordingType(pidx);
    startdtr = physdata.Date_TimeRecorded(pidx);
    enddtr = startdtr + timewindow;
    patientddidx = find(demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType,rectype));
    patientmean = demographicstable(patientddidx,:).Fun_Activity_Steps(1);
    patientstd = demographicstable(patientddidx,:).Fun_Activity_Steps(2);
    
    if detaillog
        fprintf('Dupe %3d, scid = %3d, rectype = %22s, startdtr = %20s, enddtr = %20s\n', i, scid, string(rectype), startdtr, enddtr);
    end
    if (scid ~= priorscid | ~ismember(rectype, priorrectype) | startdtr > priorenddtr)
        ntidx = find(physdata.SmartCareID == scid & ismember(physdata.RecordingType,rectype) & physdata.Date_TimeRecorded >= startdtr & physdata.Date_TimeRecorded < enddtr);
        setmax = max(physdata.Activity_Steps(ntidx));
        if detaillog    
            %if ((setmax < patientmean-2*patientstd) | (setmax > patientmean+2*patientstd))
                fprintf('Max of similar dupe set (size %3d) is %3d, patient: -2SD = %3d, mean = %3d, +2SD = %3d\n',setmax, size(ntidx,1), patientmean - 2*patientstd, patientmean, patientmean + 2*patientstd);
                physdata(ntidx,:)
            %end
        end
        rowtoadd = physdata(ntidx(1),:);
        rowtoadd.Activity_Steps = setmax;
        addsimrows = [addsimrows ; rowtoadd];
    end
    priorscid = scid;
    priorrectype = rectype;
    priorenddtr = enddtr;
end

if doupdates
    fprintf('Deleting %d Activity similar dupe rows\n', size(asimpairidx,1)); 
    physdata(asimpairidx,:) = [];
    fprintf('Adding back %d replacements\n', size(addsimrows,1)); 
    physdata = [physdata ; addsimrows];
    physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
end


toc
fprintf('\n');

tic
fprintf('2b) Duplicate measures within 30 mins - Non-Activity\n');

% recreate indexes after deletions
idxna = find(~ismember(physdata.RecordingType,'ActivityRecording'));
timewindow = '00:30:00';
diffDTR = diff(physdata.Date_TimeRecorded);
similaridx = find(diffDTR > '00:00:00' & diffDTR < timewindow);
similarpairidx = unique([ similaridx ; similaridx+1 ]); % need to add next row for each diff of < 5min
nasimidx = intersect(similaridx, idxna);
nasimpairidx = intersect(similarpairidx, idxna);

fprintf('There are %d Non-Activity similar dupes\n', size(nasimpairidx,1));

addsimrows = physdata(1:1,:);
addsimrows = [];
priorscid = 0;
priorrectype = ' ';
priorenddtr = '';
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
        rowtoadd = physdata(ntidx(size(ntidx,1)),:);
        if detaillog    
            physdata(ntidx,:)
            rowtoadd
        end
        addsimrows = [addsimrows ; rowtoadd];
    end
    priorscid = scid;
    priorrectype = rectype;
    priorenddtr = enddtr;
end

if doupdates
    fprintf('Deleting %d Activity similar dupe rows\n', size(nasimpairidx,1)); 
    physdata(nasimpairidx,:) = [];
    fprintf('Adding back %d replacements\n', size(addsimrows,1)); 
    physdata = [physdata ; addsimrows];
    physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
end

toc
fprintf('\n');

tic
fprintf('3a) Duplicate measures on same day - Activity\n');

physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'DateNum'}, 'ascend');
% recreate indexes after deletions
idxa = find(ismember(physdata.RecordingType,'ActivityRecording'));
samedayidx = find(diff(physdata.DateNum)==0);
samedaypairidx = unique([ samedayidx ; samedayidx+1 ]); % need to add next row for each same day dupe
asamedayidx = intersect(samedayidx, idxa);
asamedaypairidx = intersect(samedaypairidx, idxa);

addsamerows = physdata(1:1,:);
addsamerows = [];
priorscid = 0;
priordtnum = 0;
priorrectype = ' ';
for i = 1:size(asamedayidx,1)
    pidx = asamedayidx(i);
    scid = physdata.SmartCareID(pidx);
    dtnum = physdata.DateNum(pidx);
    rectype = physdata.RecordingType(pidx);
    patientddidx = find(demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType,rectype));
    patientmean = demographicstable(patientddidx,:).Fun_Activity_Steps(1);
    patientstd = demographicstable(patientddidx,:).Fun_Activity_Steps(2);
    if detaillog
        fprintf('Dupe %3d, scid = %3d, rectype = %22s, dtnum = %3d\n', i, scid, string(rectype), dtnum);
    end
    if (scid ~= priorscid | dtnum ~= priordtnum | ~ismember(rectype, priorrectype))
        ntidx = find(physdata.SmartCareID == scid & physdata.DateNum == dtnum & ismember(physdata.RecordingType,rectype));
        setsum = sum(physdata.Activity_Steps(ntidx));
        if detaillog
            if ((setsum < patientmean-2*patientstd) | (setsum > patientmean+2*patientstd))
                fprintf('Sum of same day dupe set (size %3d) is %3d, patient: -2SD = %3d, mean = %3d, +2SD = %3d\n',setsum, size(ntidx,1), patientmean - 2*patientstd, patientmean, patientmean + 2*patientstd);
                physdata(ntidx,:)
                sortrows(getMeasuresForPatientAndDateRange(physdata(idxa,:),scid,dtnum, 1, true),{'SmartCareID', 'RecordingType','Date_TimeRecorded'}, 'ascend')
            end
        end
        rowtoadd = physdata(ntidx(1),:);
        rowtoadd.Activity_Steps = setsum;
        addsamerows = [addsamerows ; rowtoadd];
    end
    priorscid = scid;
    priordtnum = dtnum;
    priorrectype = rectype;
end

if doupdates
    fprintf('Deleting %d Activity similar dupe rows\n', size(asamedaypairidx,1)); 
    physdata(asamedaypairidx,:) = [];
    fprintf('Adding back %d replacements\n', size(addsamerows,1)); 
    physdata = [physdata ; addsamerows];
    physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
end
toc
fprintf('\n');

tic
fprintf('3b) Duplicate measures on same day - Activity\n');

physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'DateNum'}, 'ascend');
% recreate indexes after deletions
idxna = find(~ismember(physdata.RecordingType,'ActivityRecording'));
samedayidx = find(diff(physdata.DateNum)==0);
samedaypairidx = unique([ samedayidx ; samedayidx+1 ]); % need to add next row for each same day dupe
nasamedayidx = intersect(samedayidx, idxna);
nasamedaypairidx = intersect(samedaypairidx, idxna);

addsamerows = physdata(1:1,:);
addsamerows = [];
priorscid = 0;
priordtnum = 0;
priorrectype = ' ';

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
        meantable = varfun(@mean, physdata(ntidx,:), 'GroupingVariables', {'SmartCareID','DateNum','UserName','RecordingType','Date_TimeRecorded'}, 'InputVariables');
        if detaillog
            fprintf('Sum of same day dupe set (size %3d) is %3d\n',setsum, size(ntidx,1));
            physdata(ntidx,:)
            sortrows(getMeasuresForPatientAndDateRange(physdata(idxa,:),scid,dtnum, 1, true),{'SmartCareID', 'RecordingType','Date_TimeRecorded'}, 'ascend')
        end

        addsamerows = [addsamerows ; rowtoadd];
    end
    priorscid = scid;
    priordtnum = dtnum;
    priorrectype = rectype;
end


fprintf('SmartCare data now has %d rows\n', size(physdata,1));
fprintf('\n');

% handle duplicates - first analyse how many by recording type
%fprintf('Handling duplicates - first look at demographics of duplicates\n');
%physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'DateNum'}, 'ascend');
t = physdata(:,:);
%[tunique, tI, tJ] = unique(t(:,{'SmartCareID', 'RecordingType', 'DateNum', 'Date_TimeRecorded'}));
[tunique, tI, tJ] = unique(t(:,{'SmartCareID', 'RecordingType', 'DateNum'}));

number = zeros(size(tunique,1),5);
number = array2table(number);
number.Properties.VariableNames{1} = 'Count';
number.Properties.VariableNames{2} = 'Mean';
number.Properties.VariableNames{3} = 'Std';
number.Properties.VariableNames{4} = 'Min';
number.Properties.VariableNames{5} = 'Max';
tunique = [tunique number];

physdupes = physdata;
physdupes(:,:) = [];
%for i = 1:size(tunique,1)
for i = 1:1
    idx = find(tJ==i);
    tunique.Count(i) = size(idx,1);
    if size(idx,1) > 1
        switch tunique.RecordingType{i}
            case 'ActivityRecording'
                tunique.Mean(i) = mean(t.Activity_Steps(idx));
                tunique.Std(i) = std(t.Activity_Steps(idx));
                tunique.Min(i) = min(t.Activity_Steps(idx));
                tunique.Max(i) = max(t.Activity_Steps(idx));
            case {'CoughRecording','SleepActivityRecording','WellnessRecording'}
                tunique.Mean(i) = mean(t.Rating(idx));
                tunique.Std(i) = std(t.Rating(idx));
                tunique.Min(i) = min(t.Rating(idx));
                tunique.Max(i) = max(t.Rating(idx));
            case 'LungFunctionRecording'
                tunique.Mean(i) = mean(t.FEV1_(idx));
                tunique.Std(i) = std(t.FEV1_(idx));
                tunique.Min(i) = min(t.FEV1_(idx));
                tunique.Max(i) = max(t.FEV1_(idx));
            case 'O2SaturationRecording'
                tunique.Mean(i) = mean(t.O2Saturation(idx));
                tunique.Std(i) = std(t.O2Saturation(idx));
                tunique.Min(i) = min(t.O2Saturation(idx));
                tunique.Max(i) = max(t.O2Saturation(idx));
            case 'PulseRateRecording'
                tunique.Mean(i) = mean(t.Pulse_BPM_(idx));
                tunique.Std(i) = std(t.Pulse_BPM_(idx));
                tunique.Min(i) = min(t.Pulse_BPM_(idx));
                tunique.Max(i) = max(t.Pulse_BPM_(idx));
            case 'SputumSampleRecording'
                tunique.Mean(i) = 0;
                tunique.Std(i) = 0;
                tunique.Min(i) = 0;
                tunique.Max(i) = 0;
            case 'TemperatureRecording'
                tunique.Mean(i) = mean(t.Temp_degC_(idx));
                tunique.Std(i) = std(t.Temp_degC_(idx));
                tunique.Min(i) = min(t.Temp_degC_(idx));
                tunique.Max(i) = max(t.Temp_degC_(idx));
            case 'WeightRecording'
                tunique.Mean(i) = mean(t.WeightInKg(idx));
                tunique.Std(i) = std(t.WeightInKg(idx));
                tunique.Min(i) = min(t.WeightInKg(idx));
                tunique.Max(i) = max(t.WeightInKg(idx));
            otherwise
                mmean = -1;
                mstd = -1;
                mmin = -1;
                mmax = -1; 
        end
        physdupes = [physdupes;t(idx,:)];
    end
    if (round(i/1000) == i/1000)
            fprintf('Processed %5d rows\n', i);
    end 
end
toc
fprintf('\n'); 




physdataout = physdata;
end

