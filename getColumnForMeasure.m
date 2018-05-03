function [column] = getColumnForMeasure(measure)

% getColumnForMeasure - returns the column name from physdata for the
% measure passed in

switch measure
    case 'ActivityRecording'
        column = 'Activity_Steps';
    case {'CoughRecording','SleepActivityRecording','WellnessRecording'}
        column = 'Rating';
    case 'LungFunctionRecording'
        column = 'CalcFEV1_';
    case 'O2SaturationRecording'
        column = 'O2Saturation';
    case 'PulseRateRecording'
        column = 'Pulse_BPM_';
    case 'TemperatureRecording'
        column = 'Temp_degC_';
    case 'WeightRecording'
        column = 'WeightInKg';
    otherwise
        column = '';
end

end

