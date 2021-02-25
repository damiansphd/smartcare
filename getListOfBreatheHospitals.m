function [hosplist] = getListOfBreatheHospitals()

% getListOfBreatheHospitals - returns a table containing the acronyms
% for the breathe hospitals and their full name

hosplist = table('Size',[2 5], ...
    'VariableTypes', {'cell',    'cell', 'cell',     'cell',     'double'}, ...
    'VariableNames', {'Acronym', 'Name', 'FullName', 'Location', 'IDOffset'});

hosplist.Acronym{1}  = 'PAP';
hosplist.Name{1}     = 'Papworth';
hosplist.FullName{1} = 'Royal Papworth Hospital';
hosplist.Location{1} = 'UK';
hosplist.IDOffset(1)  = 500;

hosplist.Acronym{2} = 'CDF';
hosplist.Name{2} = 'Cardiff';
hosplist.FullName{2} = 'Cardiff and Vale UHB';
hosplist.Location{2} = 'UK';
hosplist.IDOffset(2)  = 800;

end

