clear; clc; close;

scdatafile = 'mydata.csv';
patientidfile = 'patientid.xlsx';

% load patient id file + corrections
patientid = loadAndCorrectPatientIDData(patientidfile);

% load SmartCare measurement data + corrections
[physdata, physdata1_original] = loadAndCorrectSmartCareData(scdatafile, patientid);

% calc and print overall data demographics before data anomaly fixes
printDataDemographics(physdata,0);

physdata = correctSmartCareDataAnomalies(physdata);

% calc and print overall data demographics before data anomaly fixes
printDataDemographics(physdata,0);

tic
%sort patientid and physdata tables
patientid = sortrows(patientid,'SmartCareID','ascend');
physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');

% update date offset to prior day for actiity measures uploaded between
% 00:00 and 05:59
fprintf('Updating Date offset for Activity measures overnight\n');
fprintf('----------------------------------------------------\n');
idx1 = find(ismember(physdata.RecordingType, 'ActivityRecording'));
figure;
fprintf('Histogram - activity measures by hour\n');
histogram(hour(datetime(physdata.Date_TimeRecorded(idx1))));
legend('Count of Activity Measures by Hour of Day', 'location', 'north');
idx2 = find(hour(datetime(physdata.Date_TimeRecorded))<6);
idx = intersect(idx1,idx2);
fprintf('Updating %4d date offsets to prior day for activity measures between 00:00 and 05:59\n', size(idx,1));
physdata.DateNum(idx) = physdata.DateNum(idx) - 1;
toc
fprintf('\n'); 

tic
% handle duplicates - first analyse how many by recording type
fprintf('Handling duplicates - first look at demographics of duplicates\n');
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
for i = 1:size(tunique,1)
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
end
toc
fprintf('\n'); 


tic
outputfilename = 'smartcaredata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(outputfilename, 'physdata', 'physdata1_original', 'patientid');
toc

%tunique = unique(t(:,{'DateNum','RecordingType','SmartCareID'}));
%number = zeros(size(tunique,1),2);
%number = array2table(number);
%number.Properties.VariableNames{1} = 'Total';
%number.Properties.VariableNames{2} = 'Count';
%tunique = [tunique number];



%patientlist = unique(patientid.SmartCareID(:));
%for i = 1:size(patientlist,1)
%    scid = patientlist(i);
%   
%end


