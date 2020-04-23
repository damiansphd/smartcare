function [column] = getColumnForMeasure(measure)

% getColumnForMeasure - returns the column name from physdata for the
% measure passed in

switch measure
    case 'ActivityRecording'
        column = 'Activity_Steps';
    case {'AppetiteRecording', 'BreathlessnessRecording', 'CoughRecording','SleepActivityRecording', 'SputumVolumeRecording', 'TirednessRecording', 'WellnessRecording'}
        column = 'Rating';
    case 'CalorieRecording'
        column = 'Calories';
    case {'FEV1Recording', 'FEF2575Recording', 'FEV075Recording', 'FEV1DivFEV6Recording', 'FEV6Recording', 'InterpFEV1Recording'}
        column = 'FEV';
    case {'HasColdOrFluRecording', 'HasHayFeverRecording'}
        column = 'HasCondition';
    case 'LungFunctionRecording'
        column = 'CalcFEV1_';
    case {'MinsAsleepRecording', 'MinsAwakeRecording'}
        column = 'Sleep';
    case 'O2SaturationRecording'
        column = 'O2Saturation';
    case {'PulseRateRecording', 'RestingHRRecording'}
        column = 'Pulse_BPM_';
    case 'RespiratoryRateRecording'
        column = 'BreathsPerMin';
    case 'SleepDisturbanceRecording'
        column = 'NumSleepDisturb';
    case {'SputumColorRecording', 'SputumColourRecording'}
        column = 'SputumColour';
    case {'SputumSampleRecording'}
        column = 'SputumSampleTaken_';
    case 'TemperatureRecording'
        column = 'Temp_degC_';
    case {'WeightRecording', 'InterpWeightRecording'}
        column = 'WeightInKg';
    otherwise
        fprintf('*** Unknown measure %s ***\n', measure);
        column = '';
end

end

