function [column] = getColumnForMeasure(measure)

% getColumnForMeasure - returns the column name from physdata for the
% measure passed in

switch measure
    case 'ActivityRecording'
        column = 'Activity_Steps';
    case {'AppetiteRecording', 'BreathlessnessRecording', 'CoughRecording','SleepActivityRecording', 'SputumVolumeRecording', 'TirednessRecording', 'WellnessRecording'}
        column = 'Rating';
    case 'LungFunctionRecording'
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
