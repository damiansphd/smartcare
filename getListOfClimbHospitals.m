function [hosplist] = getListofClimbHospitals()

% getListofClimbHospitals - returns a table containing the acronyms
% for the climb hospitals and their full name

hosplist = table('Size',[8 3], ...
    'VariableTypes', {'cell',   'cell', 'cell'}, ...
    'VariableNames', {'Acronym', 'Name', 'Location'});

hosplist.Acronym{1} = 'ALD';
hosplist.Acronym{2} = 'BRN';
hosplist.Acronym{3} = 'GOS';
hosplist.Acronym{4} = 'IWK';
hosplist.Acronym{5} = 'LON';
hosplist.Acronym{6} = 'NEW';
hosplist.Acronym{7} = 'RBH';
hosplist.Acronym{8} = 'SCT';

hosplist.Name{1} = 'Alder Hay';
hosplist.Name{2} = 'Royal Alexandra';
hosplist.Name{3} = 'Great Ormond St';
hosplist.Name{4} = 'IWK Halifax';
hosplist.Name{5} = 'London Ontario';
hosplist.Name{6} = 'Great Northern';
hosplist.Name{7} = 'Royal Brompton';
hosplist.Name{8} = 'North of Scotland';

hosplist.Location(:) = cellstr('UK');
hosplist.Location{4} = 'Canada';
hosplist.Location{5} = 'Canada';

end

