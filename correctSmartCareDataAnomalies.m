function [physdataout] = correctSmartCareDataAnomalies(physdata)

% correctSmartCareDataAnomalies - looks at various outliers in the measures
% and corrects as appropriate. See associated OneNote page 'SmartCare Data 
% - Anomalies Found' for details

tic
% handle anomalies in the data
fprintf('Correcting anomalies in the data\n');
fprintf('--------------------------------\n');

% Activity Reading - > 30,000 steps
idx1 = find(ismember(physdata.RecordingType, 'ActivityRecording'));
idx2 = find(physdata.Activity_Steps > 30000);
idx = intersect(idx1,idx2);
fprintf('Found    %4d Activity measurements > 30,000 - leave for now\n', size(idx,1));
%temp = sortrows(physdata(idx,:), {'SmartCareID', 'DateNum'}, 'ascend');
%temp(:, {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','Activity_Steps'})

% Lung Function - FEV1% < 10% or > 130%
idx1 = find(ismember(physdata.RecordingType, 'LungFunctionRecording'));
idx2 = find(physdata.FEV1_ < 10 | physdata.FEV1_ > 130);
idx3 = intersect(idx1,idx2);
idx4 = find(physdata.SmartCareID ~= 227);
idx = intersect(idx3,idx4);
fprintf('Removing %4d Lung Function measurements < 10%% or > 130%% (except patient 227)\n', size(idx,1));
%temp = sortrows(physdata(idx,:), {'SmartCareID', 'DateNum'}, 'ascend');
%temp(:, {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','FEV1_'})
physdata(idx,:) = [];

% note looked further at FEV1% < 20%, all seemed valid except patients 172
% and 197 who had multiple (2 or 3) readings within a couple of minutes and
% the low score was an outlier. When handling duplicates for FEV1%, propose
% to take max on a given day rather than average.

% O2 Saturation < 80% or > 100%
idx1 = find(ismember(physdata.RecordingType, 'O2SaturationRecording'));
idx2 = find(physdata.O2Saturation < 80 | physdata.O2Saturation > 100);
idx = intersect(idx1,idx2);
fprintf('Found    %4d O2 Saturation measurements > 100%% or < 80%%\n', size(idx,1));
%temp = sortrows(physdata(idx,:), {'SmartCareID', 'DateNum'}, 'ascend');
%temp(:, {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','O2Saturation'})

% O2 Saturation - update measures for patient 82 at 103% and 104% to be 100% (max allowable)
idx2 = find(physdata.O2Saturation == 103 | physdata.O2Saturation ==104);
idx = intersect(idx1,idx2);
fprintf('Updating %4d O2 Saturation measurements = 103%% and 104%% to be 100%%\n', size(idx,1));
physdata.O2Saturation(idx) = 100;

% O2 saturation - remove incorrect entries (=127% and < 80%)
idx2 = find(physdata.O2Saturation == 127 | physdata.O2Saturation < 80);
idx = intersect(idx1,idx2);
fprintf('Removing %4d O2 Saturation measurements = 127%% or < 80%%\n', size(idx,1));
physdata(idx,:) = [];

% Pulse Rate (BPM) < 50 or > 150
idx1 = find(ismember(physdata.RecordingType, 'PulseRateRecording'));
idx2 = find(physdata.Pulse_BPM_ < 50 | physdata.Pulse_BPM_ > 150);
idx = intersect(idx1,idx2);
fprintf('Found    %4d Pulse Rate measurements < 50 or > 150\n', size(idx,1));
%temp = sortrows(physdata(idx,:), {'SmartCareID', 'DateNum'}, 'ascend');
%temp(:, {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','Pulse_BPM_'})

% Pulse Rate (BPM) - remove those with < 48 and == 511
idx2 = find(physdata.Pulse_BPM_ < 48 | physdata.Pulse_BPM_ == 511);
idx = intersect(idx1,idx2);
fprintf('Removing %4d Pulse Rate measurements < 48 or == 511\n', size(idx,1));
physdata(idx,:) = [];

% Temperature Recording - convert 4 readings taken in degF to degC
idx1 = find(ismember(physdata.RecordingType, 'TemperatureRecording'));
idx2 = find(physdata.Temp_degC_ > 96 & physdata.Temp_degC_ < 99);
idx = intersect(idx1,idx2);
fprintf('Converting %2d Temperature measurements in degF to degC\n', size(idx,1));
physdata.Temp_degC_(idx) = (physdata.Temp_degC_(idx) - 32) / 1.8;

% Temperature Recording - remove illogical values (< 30 degC or > 50 degC)
idx1 = find(ismember(physdata.RecordingType, 'TemperatureRecording'));
idx2 = find(physdata.Temp_degC_ < 30 | physdata.Temp_degC_ > 50);
idx = intersect(idx1,idx2);
fprintf('Removing %4d Illogical Temperature measurements (>50degC or <30degC)\n', size(idx,1));
%temp = sortrows(physdata(idx,:), {'SmartCareID', 'DateNum'}, 'ascend');
%temp(:, {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','Temp_degC_'})
physdata(idx,:) = [];

% Weight Recording - < 35kg or > 125kg
idx1 = find(ismember(physdata.RecordingType, 'WeightRecording'));
idx2 = find(physdata.WeightInKg < 35 | physdata.WeightInKg > 125);
idx = intersect(idx1,idx2);
fprintf('Removing %4d Weight measurements < 35kg or > 125kg\n', size(idx,1));
%temp = sortrows(physdata(idx,:), {'SmartCareID', 'DateNum'}, 'ascend');
%temp(:, {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','WeightInKg'})
physdata(idx,:) = [];

fprintf('SmartCare data now has %d rows\n', size(physdata,1));
toc
fprintf('\n');

physdataout = physdata;

end

