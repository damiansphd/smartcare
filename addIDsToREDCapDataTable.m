function [redcapdata] = addIDsToREDCapDataTable(redcapdata, redcapidmap, redcapfieldmap)

% addIDsToREDCapDataTable - adds internal id, hospital, and study number to
% all records in REDCap data table (needed to populate those columns in all
% clinical tables)

% add internal_id to redcap data table
redcapdata = outerjoin(redcapdata, redcapidmap, 'LeftKeys', {'study_id'}, 'RightKeys', {'redcap_id'}, 'RightVariables', {'ID'}, 'Type', 'left');


% add hospital and study number to all records in the redcap data table
tmpids = redcapdata(ismember(redcapdata.redcap_repeat_instrument, {'patient_info'}), {'study_id', 'hospital', 'study_number'});
rchospfld    = 'hospital';
rcstdynbrfld = 'study_number';
mlhospcol    = redcapfieldmap.matlab_column{ismember(redcapfieldmap.redcap_fieldname, rchospfld)};
mlstdynbrcol = redcapfieldmap.matlab_column{ismember(redcapfieldmap.redcap_fieldname, rcstdynbrfld)};
tmpids.Properties.VariableNames{rchospfld} = mlhospcol;
tmpids.Properties.VariableNames{rcstdynbrfld} = mlstdynbrcol;

redcapdata = outerjoin(redcapdata, tmpids, 'LeftKeys', {'study_id'}, 'RightKeys', {'study_id'}, 'RightVariables', {mlhospcol, mlstdynbrcol}, 'Type', 'left');

end

