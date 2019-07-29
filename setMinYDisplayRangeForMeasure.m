function [range] = setMinYDisplayRangeForMeasure(measure)

% setMinYDisplayRangeForMeasure - sets the minimum range for Y axis for
% various measures

switch measure
    case 'ActivityRecording'
        range = 5000;
    case {'CoughRecording','SleepActivityRecording','WellnessRecording'}
        range = 50;
    case {'LungFunctionRecording'}
        range = 20;
    case {'PulseRateRecording'}
        range = 30;
    case 'O2SaturationRecording'
        range = 10;
    case 'TemperatureRecording'
        range = 2;
    case 'WeightRecording'
        range = 10;
    case 'ClinicalCRP'
        range = 20;
    case 'ClinicalFEV1'
        range = 30;
    otherwise
        range = 100;
end

end

