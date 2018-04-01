%clear; clc; close;

scmatlab = 'smartcaredata.mat';
load(scmatlab);

scid = 236;
measure = 'WeightRecording';

idx1 = find(ismember(physdata.RecordingType, measure));
idx2 = find(physdata.SmartCareID==scid);
idx = intersect(idx1,idx2);
temp = sortrows(physdata(idx,:), {'DateNum'}, 'ascend');
switch measure
    case 'ActivityRecording'
            columns = {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','Activity_Steps'};
    case {'CoughRecording','SleepActivityRecording','WellnessRecording'}
            columns = {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','Rating'};
    case 'LungFunctionRecording'
            columns = {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','FEV1','PredictedFEV','FEV1_'};
    case 'O2SaturationRecording'
            columns = {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','O2Saturation'};
    case 'PulseRateRecording'
            columns = {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','Pulse_BPM_'};
    case 'SputumSampleRecording'
            columns = {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','SputumSampleTaken'};
    case 'TemperatureRecording'
            columns = {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','Temp_degC_'};
    case 'WeightRecording'
            columns = {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','WeightInKg'};
    otherwise
            columns = {'SmartCareID','UserName','RecordingType','Date_TimeRecorded'};
end

temp(:,columns)
