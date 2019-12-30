function [brphysdata, brphysdata_deleted] = correctBreatheDataAnomalies(brphysdata, brphysdata_deleted)

% correctBreatheDataAnomalies - looks at various outliers in the measures
% and corrects as appropriate. 

tic
% handle anomalies in the data
fprintf('Correcting anomalies in the data\n');
fprintf('--------------------------------\n');

% Calorie Reading
recordingtype = 'CalorieRecording';
lowerthresh = -1;
upperthresh = 6000;
[brphysdata, brphysdata_deleted] = findAndDeleteAnomalousMeasures(brphysdata, brphysdata_deleted, recordingtype, lowerthresh, upperthresh);

% Lung Function
recordingtype = 'FEV1Recording';
lowerthresh = 0.1;
upperthresh = 6;
[brphysdata, brphysdata_deleted] = findAndDeleteAnomalousMeasures(brphysdata, brphysdata_deleted, recordingtype, lowerthresh, upperthresh);
recordingtype = 'FEV6Recording';
lowerthresh = 0.2;
upperthresh = 7;
[brphysdata, brphysdata_deleted] = findAndDeleteAnomalousMeasures(brphysdata, brphysdata_deleted, recordingtype, lowerthresh, upperthresh);

% O2 Saturation
recordingtype = 'O2SaturationRecording';
lowerthresh = 70;
upperthresh = 100;
[brphysdata, brphysdata_deleted] = findAndDeleteAnomalousMeasures(brphysdata, brphysdata_deleted, recordingtype, lowerthresh, upperthresh);

% Pulse Rate (BPM)
recordingtype = 'PulseRateRecording';
lowerthresh = 40;
upperthresh = 200;
[brphysdata, brphysdata_deleted] = findAndDeleteAnomalousMeasures(brphysdata, brphysdata_deleted, recordingtype, lowerthresh, upperthresh);

% Resting HR
recordingtype = 'RestingHRRecording';
lowerthresh = 40;
upperthresh = 120;
[brphysdata, brphysdata_deleted] = findAndDeleteAnomalousMeasures(brphysdata, brphysdata_deleted, recordingtype, lowerthresh, upperthresh);

% Sleep
recordingtype = 'MinsAsleepRecording';
lowerthresh = -1;
upperthresh = 1200;
[brphysdata, brphysdata_deleted] = findAndDeleteAnomalousMeasures(brphysdata, brphysdata_deleted, recordingtype, lowerthresh, upperthresh);
recordingtype = 'MinsAwakeRecording';
lowerthresh = -1;
upperthresh = 600;
[brphysdata, brphysdata_deleted] = findAndDeleteAnomalousMeasures(brphysdata, brphysdata_deleted, recordingtype, lowerthresh, upperthresh);

% Temperature Recording
recordingtype = 'TemperatureRecording';
lowerthresh = 34;
upperthresh = 40;
[brphysdata, brphysdata_deleted] = findAndDeleteAnomalousMeasures(brphysdata, brphysdata_deleted, recordingtype, lowerthresh, upperthresh);

% Weight Recording
recordingtype = 'WeightRecording';
lowerthresh = 30;
upperthresh = 120;
[brphysdata, brphysdata_deleted] = findAndDeleteAnomalousMeasures(brphysdata, brphysdata_deleted, recordingtype, lowerthresh, upperthresh);

fprintf('\n');
fprintf('Breathe data now has %d rows\n', size(brphysdata,1));
toc
fprintf('\n');

end

