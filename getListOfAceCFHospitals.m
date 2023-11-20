function [hosplist] = getListOfAceCFHospitals()

% getListOfAceCFHospitals - returns a table containing the acronyms
% for the breathe hospitals and their full name

hosplist = table('Size',[6 4], ...
    'VariableTypes', {'cell',    'cell', 'cell',     'cell'}, ...
    'VariableNames', {'Acronym', 'Name', 'FullName', 'Location'});

hosplist.Acronym{1}  = 'PAP';
hosplist.Name{1}     = 'Papworth';
hosplist.FullName{1} = 'Royal Papworth Hospital';
hosplist.Location{1} = 'UK';

hosplist.Acronym{2}  = 'CDF';
hosplist.Name{2}     = 'Cardiff';
hosplist.FullName{2} = 'University Hospital Llandough';
hosplist.Location{2} = 'UK';

hosplist.Acronym{3}  = 'GGC';
hosplist.Name{3}     = 'Glasgow';
hosplist.FullName{3} = 'Queen Elizabeth University Hospital';
hosplist.Location{3} = 'UK';

hosplist.Acronym{4}  = 'EDB';
hosplist.Name{4}     = 'Edinburgh';
hosplist.FullName{4} = 'Western General Hospital';
hosplist.Location{4} = 'UK';

hosplist.Acronym{5}  = 'KCL';
hosplist.Name{5}     = 'Kings';
hosplist.FullName{5} = 'Kings College University Hospital';
hosplist.Location{5} = 'UK';

hosplist.Acronym{6}  = 'BEL';
hosplist.Name{6}     = 'Belfast';
hosplist.FullName{6} = 'Queens University Hospital';
hosplist.Location{6} = 'UK';


end

