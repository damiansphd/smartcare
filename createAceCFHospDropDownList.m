function hospdropdown = createAceCFHospDropDownList(hosplist)

% create the hospital drop down string to override the REDCap version
nhosp = size(hosplist, 1);
hospstr = '';
for i = 1:nhosp
    hospstr = strcat(hospstr, sprintf('%d, %s', i, hosplist.Acronym{i}));
    if i ~= nhosp
        hospstr = strcat(hospstr, '|');
    end
end
hospdropdown = cellstr(hospstr);

end

