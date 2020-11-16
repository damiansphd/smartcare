function [hosplist] = getListOfBreatheHospitals()

% getListOfBreatheHospitals - returns a table containing the acronyms
% for the breathe hospitals and their full name

hosplist = table('Size',[2 5], ...
    'VariableTypes', {'cell',    'cell', 'cell',     'cell',     'double'}, ...
    'VariableNames', {'Acronym', 'Name', 'FullName', 'Location', 'StartID'});

hosplist.Acronym{1}  = 'PAP';
hosplist.Name{1}     = 'Papworth';
hosplist.FullName{1} = 'Royal Papworth Hospital';
hosplist.Location{1} = 'UK';
hosplist.StartID(1)  = 501;

hosplist.Acronym{2} = 'CDF';
hosplist.Name{2} = 'Cardiff';
hosplist.FullName{2} = 'Cardiff and Vale UHB';
hosplist.Location{2} = 'UK';
hosplist.StartID(2)  = 801;

% temporary until papworth sends through updated data.
%hosplist = table('Size',[1 5], ...
%    'VariableTypes', {'cell',    'cell', 'cell',     'cell',     'double'}, ...
%    'VariableNames', {'Acronym', 'Name', 'FullName', 'Location', 'StartID'});


%hosplist.Acronym{1} = 'CDF';
%hosplist.Name{1} = 'Cardiff';
%hosplist.FullName{1} = 'Cardiff and Vale UHB';
%hosplist.Location{1} = 'UK';
%hosplist.StartID(1)  = 801;

end

