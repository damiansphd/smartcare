function [physdata, physdata_deleted] = correctClimbDataAnomalies(physdata, physdata_deleted)

% correctClimbDataAnomalies - looks at various outliers in the measures
% and corrects as appropriate. 

tic
% handle anomalies in the data
fprintf('Correcting anomalies in the data\n');
fprintf('--------------------------------\n');

% Activity Reading - > 30,000 steps
idx1 = ismember(physdata.RecordingType, 'ActivityRecording');
idx2 = physdata.Activity_Steps > 30000;
idx  = idx1 & idx2;
fprintf('Removing %4d Activity measurements > 30,000\n', sum(idx));
physdata_deleted = appendDeletedRows(physdata(idx, :), physdata_deleted, {'Anomalous Value'});
physdata(idx, :) = [];

% Lung Function - FEV1 < 0.25l or > 4l
idx1 = ismember(physdata.RecordingType, 'FEV1Recording');
idx2 = physdata.FEV < 0.25 | physdata.FEV > 4;
idx  = idx1 & idx2;
fprintf('Removing %4d Lung Function measurements < 0.25l or > 4.0l\n', sum(idx));
physdata_deleted = appendDeletedRows(physdata(idx, :), physdata_deleted, {'Anomalous Value'});
physdata(idx, :) = [];

% O2 Saturation - remove bogus 127 values
idx1 = ismember(physdata.RecordingType, 'O2SaturationRecording');
idx2 = physdata.O2Saturation == 127;
idx  = idx1 & idx2;
fprintf('Removing %4d O2 Saturation measurements = 127\n', sum(idx));
physdata_deleted = appendDeletedRows(physdata(idx, :), physdata_deleted, {'Anomalous Value'});
physdata(idx, :) = [];

% O2 Saturation < 70% or > 100%
idx1 = ismember(physdata.RecordingType, 'O2SaturationRecording');
idx2 = physdata.O2Saturation < 70 | physdata.O2Saturation > 100;
idx  = idx1 & idx2;
fprintf('Removing %4d O2 Saturation measurements < 70%% or > 100%%\n', sum(idx));
physdata_deleted = appendDeletedRows(physdata(idx, :), physdata_deleted, {'Anomalous Value'});
physdata(idx, :) = [];

% Pulse Rate (BPM) - remove bogus 511 values
idx1 = ismember(physdata.RecordingType, 'PulseRateRecording');
idx2 = physdata.Pulse_BPM_ == 511;
idx  = idx1 & idx2;
fprintf('Removing %4d Pulse Rate measurements = 511\n', sum(idx));
physdata_deleted = appendDeletedRows(physdata(idx, :), physdata_deleted, {'Anomalous Value'});
physdata(idx, :) = [];

% Pulse Rate (BPM) < 50 or > 200
idx1 = ismember(physdata.RecordingType, 'PulseRateRecording');
idx2 = physdata.Pulse_BPM_ < 50 | physdata.Pulse_BPM_ > 200;
idx  = idx1 & idx2;
fprintf('Removing %4d Pulse Rate measurements < 50 or > 200\n', sum(idx));
physdata_deleted = appendDeletedRows(physdata(idx, :), physdata_deleted, {'Anomalous Value'});
physdata(idx, :) = [];

% Respiratory Rate (Breaths per Min) < 10 or > 100
idx1 = ismember(physdata.RecordingType, 'RespiratoryRateRecording');
idx2 = physdata.BreathsPerMin < 10 | physdata.BreathsPerMin > 100;
idx  = idx1 & idx2;
fprintf('Removing %4d Respiratory Rate measurements < 10 or > 100\n', sum(idx));
physdata_deleted = appendDeletedRows(physdata(idx, :), physdata_deleted, {'Anomalous Value'});
physdata(idx, :) = [];

% Sleep Disturbances > 35
idx1 = ismember(physdata.RecordingType, 'SleepDisturbanceRecording');
idx2 = physdata.NumSleepDisturb > 35;
idx  = idx1 & idx2;
fprintf('Removing %4d Sleep Disturbance measurements > 35\n', sum(idx));
physdata_deleted = appendDeletedRows(physdata(idx, :), physdata_deleted, {'Anomalous Value'});
physdata(idx, :) = [];

% Temperature Recording - fix deg C measurements factor of 10 too small
idx1 = ismember(physdata.RecordingType, 'TemperatureRecording');
idx2 = physdata.Temp_degC_ > 3.0 & physdata.Temp_degC_ < 4.5;
idx  = idx1 & idx2;
fprintf('Scaling %2d degC Temperature measurements up by factor of 10\n', sum(idx));
physdata.Temp_degC_(idx) = physdata.Temp_degC_(idx) * 10;

% Temperature Recording - fix deg F measurements factor of 10 too large
idx1 = ismember(physdata.RecordingType, 'TemperatureRecording');
idx2 = physdata.Temp_degC_ > 950 & physdata.Temp_degC_ < 1020;
idx  = idx1 & idx2;
fprintf('Scaling %2d degF Temperature measurements down by factor of 10\n', sum(idx));
physdata.Temp_degC_(idx) = physdata.Temp_degC_(idx) / 10;

% Temperature Recording - fix deg C measurements factor of 10 too large
idx1 = ismember(physdata.RecordingType, 'TemperatureRecording');
idx2 = physdata.Temp_degC_ > 300 & physdata.Temp_degC_ < 450;
idx  = idx1 & idx2;
fprintf('Scaling %2d degC Temperature measurements down by factor of 10\n', sum(idx));
physdata.Temp_degC_(idx) = physdata.Temp_degC_(idx) / 10;

% Temperature Recording - convert readings taken in degF to degC
idx1 = ismember(physdata.RecordingType, 'TemperatureRecording');
idx2 = physdata.Temp_degC_ > 95 & physdata.Temp_degC_ < 102;
idx  = idx1 & idx2;
fprintf('Converting %2d Temperature measurements in degF to degC\n', sum(idx));
physdata.Temp_degC_(idx) = (physdata.Temp_degC_(idx) - 32) / 1.8;

% Temperature Recording < 30 or > 45
idx1 = ismember(physdata.RecordingType, 'TemperatureRecording');
idx2 = physdata.Temp_degC_ < 30 | physdata.Temp_degC_ > 45;
idx  = idx1 & idx2;
fprintf('Removing %4d Temperature measurements < 30 or > 45\n', sum(idx));
physdata_deleted = appendDeletedRows(physdata(idx, :), physdata_deleted, {'Anomalous Value'});
physdata(idx, :) = [];

% Weight < 10 or > 100
idx1 = ismember(physdata.RecordingType, 'WeightRecording');
idx2 = physdata.WeightInKg < 9 | physdata.WeightInKg > 80;
idx  = idx1 & idx2;
fprintf('Removing %4d Weight measurements < 9 or > 80\n', sum(idx));
physdata_deleted = appendDeletedRows(physdata(idx, :), physdata_deleted, {'Anomalous Value'});
physdata(idx, :) = [];

fprintf('Climb data now has %d rows\n', size(physdata,1));
toc
fprintf('\n');

end

