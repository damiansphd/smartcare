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
longfilename = strcat('HeatmapLongDurationPatients', filenameappend, '.png');
shortfilename = strcat('HeatmapShortDurationPatients', filenameappend, '.png');

patientmeasures = physdata(:,{'SmartCareID','ScaledDateNum'});

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
f = createHeatmapOfPatientsAndMeasures(patientmeasures, colors, 'Heatmap of Patient Measures', 1, 1, 'a3');
saveas(f,fullfilename);

%create heatmap for long duration patients
ldidx = find(patientmeasures.ScaledDateNum > 200);
longdurationpatients = unique(patientmeasures.SmartCareID(ldidx));
ldpidx = find(ismember(patientmeasures.SmartCareID, longdurationpatients));
f2 = createHeatmapOfPatientsAndMeasures(patientmeasures(ldpidx,:), colors, 'Heatmap of Long Duration Patients', 1, 0.4, 'a4');
saveas(f2,longfilename);

pdcounttable = varfun(@max, physdata(:, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});

deltable = 
for i = 1:size(longdurationpatients,1)
    scid = longdurationpatients(i);
    idx = find(pdcounttable.SmartCareID == scid);
    firstdate = pdcounttable.ScaledDateNum(idx(1));
    nextdate = pdcounttable.ScaledDateNum(idx(1)+1);
    if (nextdate - firstdate > 5)
        
    
    
if doupdates
    

%create heatmap for short duration patients
mdtable = varfun(@max, patientmeasures, 'GroupingVariables', {'SmartCareID'});
sdidx = find(mdtable.max_ScaledDateNum <40);
shortdurationpatients = unique(mdtable.SmartCareID(sdidx));
sdpidx = find(ismember(patientmeasures.SmartCareID, shortdurationpatients));
f3 = createHeatmapOfPatientsAndMeasures(patientmeasures(sdpidx,:), colors, 'Heatmap of Short Duration Patients', 0.8, 0.25, 'a4');
saveas(f3,shortfilename);

toc
fprintf('\n');
if doupdates
    % remove all measures for patients with < 30 days of measurements
    fprintf('Removing %4d measures for %2d patients with < 30 days of data\n', size(sdpidx,1), size(shortdurationpatients,1));
    physdata(sdpidx,:) = [];
    patientmeasures(sdpidx,:) = [];
end

physdataout = physdata;

end

