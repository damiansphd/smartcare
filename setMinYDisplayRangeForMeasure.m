function [range] = setMinYDisplayRangeForMeasure(measure)

% setMinYDisplayRangeForMeasure - sets the minimum range for Y axis for
% various measures

switch measure
    case 'ActivityRecording'
        range = 5000;
    case 'CalorieRecording'
        range = 1000;
    case {'AppetiteRecording', 'BreathlessnessRecording', 'CoughRecording','SleepActivityRecording', ...
            'SleepDisturbanceRecording', 'SputumVolumeRecording', 'TirednessRecording', 'WellnessRecording'}
        range = 50;
    case {'FEV1Recording', 'FEF2575Recording', 'FEV075Recording', 'FEV6Recording'}
        range = 0.2;
    case {'FEV1DivFEV6Recording'}
        range = 0.2;
    case {'HasColdOrFluRecording', 'HasHayFeverRecording'}
        range = 1;
    case {'LungFunctionRecording'}
        range = 20;
    case {'MinsAsleepRecording'}
        range = 200;
    case {'MinsAwakeRecording'}
        range = 20;
    case {'PulseRateRecording'}
        range = 30;
    case {'RestingHRRecording'}
        range = 10;
    case {'RespiratoryRateRecording'}
        range = 20;    
    case 'O2SaturationRecording'
        range = 4;
    case 'TemperatureRecording'
        range = 1;
    case 'WeightRecording'
        range = 5;
    case 'ClinicalCRP'
        range = 20;
    case 'ClinicalFEV1'
        range = 20; 
    otherwise
        range = 100;
end

end

