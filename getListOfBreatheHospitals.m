function [hosplist] = getListOfBreatheHospitals()

% getListOfBreatheHospitals - returns a table containing the acronyms
% for the breathe hospitals and their full name

hosplist = table('Size',[1 4], ...
    'VariableTypes', {'cell',    'cell', 'cell',     'cell'}, ...
    'VariableNames', {'Acronym', 'Name', 'FullName', 'Location'});

hosplist.Acronym{1} = 'PAP';
hosplist.Name{1} = 'Papworth';
hosplist.FullName{1} = 'Royal Papworth Hospital';
hosplist.Location(:) = cellstr('UK');

end

