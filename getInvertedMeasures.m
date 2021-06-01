function [invmeasarray] = getInvertedMeasures(study)

% getInvertedMeasures - returns an array of measure display names that need
% to be inverted

if ismember(study, {'SC'})
    invmeasarray = {'PulseRate'};
elseif ismember(study, {'BR'})
    invmeasarray = {'PulseRate', 'MinsAwake', 'RestingHR', 'Temperature'};
elseif ismember(study, {'CL'})
    invmeasarray = {'PulseRate', 'RespiratoryRate', 'SleepDisturbance', 'Temperature'};
else
    invmeasarray = {'PulseRate'};
end
    

end

