function [physdataout] = analyseAndHandleDateOutliers(physdata, doupdates)

% analyseAndHandleDateOutliers - function to do the following :-
%
% 1) visualise heatmaps of patients and measures - all patients, 
%    plus those with long and short durations of measurements
% 2) deletes rows for patients with < 30 days
% 3) removes outlier measures (long gap before active study period or
%    sporadic measures after active study period
% 4) recreate heatmaps and observe results

tic

fprintf('Analysing and Handling Date Outliers in the Measurement data\n');
fprintf('------------------------------------------------------------\n');

filenameappend = 'PreDateOutlierHandling';
fullfilename = strcat('HeatmapAllPatients', filenameappend, '.png');

% ensure physdata is sorted correctly
physdata = sortrows(physdata, {'SmartCareID', 'DateNum', 'RecordingType'}, 'ascend');

% patientmeasures = physdata(:,{'SmartCareID','ScaledDateNum'});
allpatients = unique(physdata.SmartCareID);

% create colormap
temp = hsv;
colors(1,:)  = [0 0 0];     % black for no measures
colors(2,:)  = temp(4,:);
colors(3,:)  = temp(6,:);
colors(4,:)  = temp(8,:);
colors(5,:)  = temp(10,:);
colors(6,:)  = temp(12,:);
colors(7,:)  = temp(14,:);
colors(8,:)  = temp(16,:);
colors(9,:)  = temp(18,:);

% create heatmap for all patients and measures
fprintf('Creating heatmap for all patients\n');
f = createHeatmapOfPatientsAndMeasures(physdata(:,{'SmartCareID','ScaledDateNum'}), colors, 'Heatmap of Patient Measures', 1, 1, 'a3');
saveas(f,fullfilename);

% handle outlier first/second measurements
fprintf('Handline outlier first/second measurements across all patients\n');
pdcountmtable = varfun(@max, physdata(:, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});
deltable = physdata(1:1,{'SmartCareID','ScaledDateNum'});
rowtoadd = deltable;
rowtoadd.SmartCareID = 0;
rowtoadd.ScaledDateNum = 0;
deltable = [];
for i = 1:size(allpatients,1)
    scid = allpatients(i);
    idx = find(pdcountmtable.SmartCareID == scid);
    firstdate = pdcountmtable.ScaledDateNum(idx(1));
    if (size(idx,1) >= 3)
        seconddate = pdcountmtable.ScaledDateNum(idx(2));
        thirddate = pdcountmtable.ScaledDateNum(idx(3));
        if (seconddate - firstdate > 5)
            rowtoadd.SmartCareID = scid;
            rowtoadd.ScaledDateNum = firstdate;
            deltable = [deltable;rowtoadd];
        end
        if (thirddate - seconddate > 5 & seconddate - firstdate < 2)
            rowtoadd.SmartCareID = scid;
            rowtoadd.ScaledDateNum = firstdate;
            deltable = [deltable;rowtoadd];
            rowtoadd.SmartCareID = scid;
            rowtoadd.ScaledDateNum = seconddate;
            deltable = [deltable;rowtoadd];
        end
    end
end
 
if doupdates
    idx = [];
    for i = 1:size(deltable,1)
        idx1 = find(physdata.SmartCareID == deltable.SmartCareID(i) & physdata.ScaledDateNum == deltable.ScaledDateNum(i));
        idx = [idx;idx1];
    end
    fprintf('Removing %4d outlier first measures for %2d patients\n', size(idx,1), size(deltable,1));
    physdata(idx,:) = [];
end
toc
fprintf('\n');

tic
% recalc ScaledDateNum with the days from first measurement (by patient)
physdata = scaleDaysByPatient(physdata, doupdates);

filenameappend = 'PostOutlierFirstDateHandling';
fullfilename = strcat('HeatmapAllPatients', filenameappend, '.png');
shortfilename = strcat('HeatmapShortDurationPatients', filenameappend, '.png');

% re-create heatmap for all patients and measures
fprintf('Re-creating heatmap for all patients\n');
f = createHeatmapOfPatientsAndMeasures(physdata(:,{'SmartCareID','ScaledDateNum'}), colors, 'Heatmap of Patient Measures', 1, 1, 'a3');
saveas(f,fullfilename);

% handling short duration patients (< 30 day duration of measures)
fprintf('Handling short duration patients (< 30 day duration of measures\n');

%create heatmap for short duration patients
fprintf('Creating heatmap for short duration patients\n');
pmaxdtable = varfun(@max, physdata(:,{'SmartCareID', 'ScaledDateNum'}), 'GroupingVariables', {'SmartCareID'});
sdidx = find(pmaxdtable.max_ScaledDateNum <40);
shortdurationpatients = unique(pmaxdtable.SmartCareID(sdidx));
sdpidx = find(ismember(physdata.SmartCareID, shortdurationpatients));
f3 = createHeatmapOfPatientsAndMeasures(physdata(sdpidx,{'SmartCareID','ScaledDateNum'}), colors, 'Heatmap of Short Duration Patients', 0.8, 0.25, 'a4');
saveas(f3,shortfilename);

if doupdates
    % remove all measures for patients with < 30 days of measurements
    fprintf('Removing %4d measures for %2d patients with < 30 days of data\n', size(sdpidx,1), size(shortdurationpatients,1));
    physdata(sdpidx,:) = [];
end
toc
fprintf('\n');

filenameappend = 'PostShortDurationHandling';
fullfilename = strcat('HeatmapAllPatients', filenameappend, '.png');
longfilename = strcat('HeatmapLongDurationPatients', filenameappend, '.png');

% re-create heatmap for all patients and measures
fprintf('Re-creating heatmap for all patients\n');
f = createHeatmapOfPatientsAndMeasures(physdata(:,{'SmartCareID','ScaledDateNum'}), colors, 'Heatmap of Patient Measures', 1, 1, 'a3');
saveas(f,fullfilename);

% create heatmap for long duration patients
fprintf('Creating heatmap for long duration patients\n');
ldidx = find(physdata.ScaledDateNum > 200);
longdurationpatients = unique(physdata.SmartCareID(ldidx));
ldpidx = find(ismember(physdata.SmartCareID, longdurationpatients));
f2 = createHeatmapOfPatientsAndMeasures(physdata(ldpidx,{'SmartCareID','ScaledDateNum'}), colors, 'Heatmap of Long Duration Patients', 1, 0.4, 'a4');
saveas(f2,longfilename);

% handling of sporadic measures after active study period
fprintf('Handline long duration patients with sporadic measurements after active period\n');
pdcountmtable = varfun(@max, physdata(:, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});
pmaxdtable = varfun(@max, physdata(:,{'SmartCareID', 'ScaledDateNum'}), 'GroupingVariables', {'SmartCareID'});
pmaxdtable.Properties.VariableNames{'GroupCount'} = 'MeasureCount';

deltable = physdata(1:1,{'SmartCareID','ScaledDateNum'});
deltable = [];
for i = 1:size(longdurationpatients,1)
    scid = longdurationpatients(i);
    maxmd = pmaxdtable.max_ScaledDateNum(pmaxdtable.SmartCareID==scid);
    idx = find(pdcountmtable.SmartCareID == scid & pdcountmtable.GroupCount > 2);
    max2md = pdcountmtable.ScaledDateNum(idx(size(idx,1)));
    if (max2md < maxmd)
        deltable = [deltable;pdcountmtable(pdcountmtable.SmartCareID==scid & pdcountmtable.ScaledDateNum > max2md, {'SmartCareID','ScaledDateNum'})];
    end
end

if doupdates
    idx = [];
    for i = 1:size(deltable,1)
        idx1 = find(physdata.SmartCareID == deltable.SmartCareID(i) & physdata.ScaledDateNum == deltable.ScaledDateNum(i));
        idx = [idx;idx1];
    end
    fprintf('Removing %4d sporadic measures after active study period for %2d patients\n', size(idx,1), size(unique(deltable.SmartCareID),1));
    physdata(idx,:) = [];
end
toc
fprintf('\n');

filenameappend = 'PostLongDurationHandling';
fullfilename = strcat('HeatmapAllPatients', filenameappend, '.png');
longfilename = strcat('HeatmapLongDurationPatients', filenameappend, '.png');

% re-create heatmap for all patients and measures
fprintf('Re-creating heatmap for all patients\n');
f = createHeatmapOfPatientsAndMeasures(physdata(:,{'SmartCareID','ScaledDateNum'}), colors, 'Heatmap of Patient Measures', 1, 1, 'a3');
saveas(f,fullfilename);

% re-create heatmap for long duration patients
fprintf('Creating heatmap for long duration patients\n');
ldidx = find(physdata.ScaledDateNum > 200);
longdurationpatients = unique(physdata.SmartCareID(ldidx));
ldpidx = find(ismember(physdata.SmartCareID, longdurationpatients));
f2 = createHeatmapOfPatientsAndMeasures(physdata(ldpidx,{'SmartCareID','ScaledDateNum'}), colors, 'Heatmap of Long Duration Patients', 1, 0.4, 'a4');
saveas(f2,longfilename);


% add handling for 'sparse' patients here
fprintf('Handline patients with sparse measurements\n');
pdcountmtable = varfun(@max, physdata(:, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});
pcountdtable = varfun(@max, pdcountmtable(:, {'SmartCareID'}), 'GroupingVariables', {'SmartCareID'});
pcountdtable.Properties.VariableNames{'GroupCount'} = 'DayCount';
pmaxdtable = varfun(@max, physdata(:,{'SmartCareID', 'ScaledDateNum'}), 'GroupingVariables', {'SmartCareID'});
pmaxdtable.Properties.VariableNames{'GroupCount'} = 'MeasureCount';
pdensitymtable = innerjoin(pmaxdtable,pcountdtable);

deltable = physdata(1:1,{'SmartCareID','ScaledDateNum'});
rowtoadd = deltable;
rowtoadd.SmartCareID = 0;
rowtoadd.ScaledDateNum = 0;
deltable = [];
delidx = find(pdensitymtable.DayCount./pdensitymtable.max_ScaledDateNum <0.5 & pdensitymtable.DayCount <= 40);
for i = 1:size(pdensitymtable)
end




toc
fprintf('\n');

physdataout = physdata;

end

