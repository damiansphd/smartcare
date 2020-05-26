function [exnormmeasarray] = getExNormMeasures(study)

% getExNormMeasures - returns an array of measure display names that need
% to be excluded from normalisation

if ismember(study, {'BR'})
    exnormmeasarray = {'HasColdOrFlu', 'HasHayFever'};
else
    exnormmeasarray = {''};
end

end

