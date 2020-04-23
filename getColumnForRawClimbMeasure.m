function [column] = getColumnForRawClimbMeasure(measure)

% getColumnForRawClimbMeasure - returns the column name from the input
% files for project climbe measurement data

switch measure
    case 'ActivityRecording'
        column = 'Steps';
    case {'AppetiteRecording', 'BreathlessnessRecording', 'CoughRecording','SleepActivityRecording', 'SputumVolumeRecording', 'TirednessRecording', 'WellnessRecording'}
        column = 'Rating';
    case {'FEV1Recording', 'LungFunctionRecording'}
        column = 'FEV1';
    case 'O2SaturationRecording'
        column = 'O2Saturation';
    case 'PulseRateRecording'
        column = 'Pulse_BPM_';
    case 'RespiratoryRateRecording'
        column = 'BreathsPerMinute';
    case 'SleepDisturbanceRecording'
        column = 'NumberOfDisturbances';
    case 'SputumColorRecording'
        column = 'Colour';
    case 'TemperatureRecording'
        column = 'Temp_degC_';
    case 'WeightRecording'
        column = 'WeightInKg';
    otherwise
        column = '';
end

end

