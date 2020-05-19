function [displaynameformatted] = formatDisplayMeasure(displaymeasure)

% formatDisplayMeasure - adds final formatting for displaying measure name
% for use in plots/labels.


if ismember(displaymeasure, {'Clinical CRP'})
    displaynameformatted = 'C-reactive protein';
elseif ismember(displaymeasure, {'Clinical FEV1'})
    displaynameformatted = 'Clinic FEV_1';
elseif ismember(displaymeasure, {'LungFunction', 'FEV1'})
    displaynameformatted = 'FEV_1';
elseif ismember(displaymeasure, {'FEV6'})
    displaynameformatted = 'FEV_6';
elseif ismember(displaymeasure, {'FEV075'})
    displaynameformatted = 'FEV_0-75';
elseif ismember(displaymeasure, {'FEF2575'})
    displaynameformatted = 'FEF_25-75';
elseif ismember(displaymeasure, {'MinsAsleep'})
    displaynameformatted = 'Mins Asleep';
elseif ismember(displaymeasure, {'MinsAwake'})
    displaynameformatted = 'Mins Awake';
elseif ismember(displaymeasure, {'O2Saturation'})
    displaynameformatted = 'O_2 saturation';
elseif ismember(displaymeasure, {'PulseRate'})
    displaynameformatted = 'Pulse rate';
elseif ismember(displaymeasure, {'RestingHR'})
    displaynameformatted = 'Resting HR';
elseif ismember(displaymeasure, {'SleepActivity'})
    displaynameformatted = 'Sleep';
elseif ismember(displaymeasure, {'SputumVolume'})
    displaynameformatted = 'Sputum vol';
elseif ismember(displaymeasure, {'Temperature'})
    displaynameformatted = 'Temp';
else
    displaynameformatted = displaymeasure;
end
