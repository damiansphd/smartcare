function [displaynameformatted] = formatTexDisplayMeasure(displaymeasure)

% formatTexDisplayMeasure - adds final formatting for displaying measure name
% for use in text boxes


if ismember(displaymeasure, {'Clinical CRP'})
    displaynameformatted = 'C-reactive protein';
elseif ismember(displaymeasure, {'Clinical FEV1'})
    displaynameformatted = 'Clinic FEV_{1}';
elseif ismember(displaymeasure, {'LungFunction', 'FEV1'})
    displaynameformatted = 'FEV_{1}';
elseif ismember(displaymeasure, {'FEV6'})
    displaynameformatted = 'FEV_{6}';
elseif ismember(displaymeasure, {'FEV075'})
    displaynameformatted = 'FEV_{0-75}';
elseif ismember(displaymeasure, {'FEF2575'})
    displaynameformatted = 'FEF_{25-75}';
elseif ismember(displaymeasure, {'MinsAsleep'})
    displaynameformatted = 'Mins Asleep';
elseif ismember(displaymeasure, {'MinsAwake'})
    displaynameformatted = 'Mins Awake';
elseif ismember(displaymeasure, {'O2Saturation'})
    displaynameformatted = 'O_{2} saturation';
elseif ismember(displaymeasure, {'PulseRate'})
    displaynameformatted = 'Pulse rate';
elseif ismember(displaymeasure, {'RestingHR'})
    displaynameformatted = 'Resting HR';
elseif ismember(displaymeasure, {'SleepActivity'})
    displaynameformatted = 'Sleep';
else
    displaynameformatted = displaymeasure;
end

displaynameformatted = sprintf('\\bf %s\\rm', displaynameformatted);

end