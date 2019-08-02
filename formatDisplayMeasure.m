function [displaynameformatted] = formatDisplayMeasure(displaymeasure)

% formatDisplayMeasure - adds final formatting for displaying measure name
% for use in plots/labels.


if ismember(displaymeasure, {'Clinical CRP'})
    displaynameformatted = 'C-reactive protein';
elseif ismember(displaymeasure, {'Clinical FEV1', 'LungFunction'})
    displaynameformatted = 'FEV_1';
elseif ismember(displaymeasure, {'O2Saturation'})
    displaynameformatted = 'O_2 saturation';
elseif ismember(displaymeasure, {'PulseRate'})
    displaynameformatted = 'Pulse rate';
elseif ismember(displaymeasure, {'SleepActivity'})
    displaynameformatted = 'Sleep activity';
else
    displaynameformatted = displaymeasure;
end
