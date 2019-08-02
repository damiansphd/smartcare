function [displaynameformatted] = formatTexDisplayMeasure(displaymeasure)

% formatTexDisplayMeasure - adds final formatting for displaying measure name
% for use in text boxes


if ismember(displaymeasure, {'Clinical CRP'})
    displaynameformatted = 'C-reactive protein';
elseif ismember(displaymeasure, {'Clinical FEV1'})
    displaynameformatted = 'Clinic FEV_{1}';
elseif ismember(displaymeasure, {'LungFunction'})
    displaynameformatted = 'FEV_{1}';
elseif ismember(displaymeasure, {'O2Saturation'})
    displaynameformatted = 'O_{2} saturation';
elseif ismember(displaymeasure, {'PulseRate'})
    displaynameformatted = 'Pulse rate';
elseif ismember(displaymeasure, {'SleepActivity'})
    displaynameformatted = 'Sleep';
else
    displaynameformatted = displaymeasure;
end

displaynameformatted = sprintf('\\bf %s\\rm', displaynameformatted);

end