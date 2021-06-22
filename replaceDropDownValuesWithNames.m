function [redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, colname)

% replaceDropDownValuesWithNames - replaces the index values in the drop
% down columns with their corresponding names

ddlookup = getDropdownLookupValsFromDict(redcapdict, colname);
idxcolname = ddlookup.Properties.VariableNames{1};
lookupcolname = ddlookup.Properties.VariableNames{2};

redcapdata = outerjoin(redcapdata, ddlookup, 'LeftKeys', colname, 'RightKeys', idxcolname, 'RightVariables', lookupcolname, 'Type', 'left');

redcapdata(:, {colname}) = [];
redcapdata.Properties.VariableNames{lookupcolname} = colname;

end

