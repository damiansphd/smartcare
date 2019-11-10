function [column] = getColumnForRawBreatheMeasure(measure)

% getColumnForRawBreatheMeasure - returns the column name from the input
% files for project breathe measurement data

switch measure
    case {'CoughRecording', 'TemperatureRecording', 'WeightRecording', 'WellnessRecording'}
        column = 'Value';
    case {'CalorieRecording'}
        column = 'Calories';
    case {'FEV1Recording'}
        column = 'FEV1';
    case {'FEF2575Recording'}
        column = 'FEF2575';
    case {'FEV075Recording'}
        column = 'FEV075';
    case {'FEV1DivFEV6Recording'}
        column = 'FEV1DivFEV6';
    case {'FEV6Recording'}
        column = 'FEV6';
    case {'HasColdOrFluRecording'}
        column = 'HasColdOrFlu';
    case {'HasHayFeverRecording'}
        column = 'HasHayFever';
    case {'MinsAsleepRecording'}
        column = 'TotalMinutesAsleep';
    case {'MinsAwakeRecording'}
        column = 'Wake';
    case {'O2SaturationRecording'}
        column = 'SpO2';
    case {'PulseRateRecording'}
        column = 'HeartRate';
    case {'RestingHRRecording'}
        column = 'RestingHeartRate';    
    otherwise
        column = '';
end
end

