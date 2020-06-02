function [hosplist] = getListOfBreatheHospitals()

% getListOfBreatheHospitals - returns a table containing the acronyms
% for the breathe hospitals and their full name

hosplist = table('Size',[1 3], ...
    'VariableTypes', {'cell',   'cell', 'cell'}, ...
    'VariableNames', {'Acronym', 'Name', 'Location'});

hosplist.Acronym{1} = 'PAP';
hosplist.Name{1} = 'Royal Papworth';
hosplist.Location(:) = cellstr('UK');

end

