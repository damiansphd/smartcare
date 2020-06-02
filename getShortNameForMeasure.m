function [shortname] = getShortNameForMeasure(measure)

% getShortNameForMeasure - returns the short name from physdata for the
% measure passed in

switch measure
    case {'ActivityRecording'}
        shortname = 'Ac';
    case {'AppetiteRecording'}
        shortname = 'Ap';
    case {'BreathlessnessRecording'}
        shortname = 'Br'; 
    case {'CalorieRecording'}
        shortname = 'Ca';
    case {'CoughRecording'}
        shortname = 'Co';
    case {'FEF2575Recording'}
        shortname = 'Ff';
    case {'FEV075Recording'}
        shortname = 'F7';
    case {'FEV1DivFEV6Recording'}
        shortname = 'Fd';
    case {'FEV1Recording'}
        shortname = 'F1';
    case {'FEV6Recording'}
        shortname = 'F6';
    case {'HasColdOrFluRecording'}
        shortname = 'Cf';
    case {'HasHayFeverRecording'}
        shortname = 'Hy';
    case {'InterpFEV1Recording'}
        shortname = 'If';
    case {'InterpWeightRecording'}
        shortname = 'Iw';    
    case {'LungFunctionRecording'}
        shortname = 'Lu';
    case {'MinsAsleepRecording'}
        shortname = 'Ms';
    case {'MinsAwakeRecording'}
        shortname = 'Ma';    
    case {'O2SaturationRecording'}
        shortname = 'O2';
    case {'PulseRateRecording'}
        shortname = 'Pu';
    case {'RespiratoryRateRecording'}
        shortname = 'Rr';
    case {'RestingHRRecording'}
        shortname = 'Hr';
    case {'SleepActivityRecording'}
        shortname = 'Sl';
    case {'SleepDisturbanceRecording'}
        shortname = 'Sd';
    case {'SputumVolumeRecording'}
        shortname = 'Sv';
    case {'TemperatureRecording'}
        shortname = 'Te';
    case {'TirednessRecording'}
        shortname = 'Ti';
    case {'WeightRecording'}
        shortname = 'Wt';
    case {'WellnessRecording'}
        shortname = 'We';    
    otherwise
        fprintf('**** Unknown measure ****\n');
        shortname = '';
end

end

