function [mltable] = populateMLTableFromREDCapData(trcdata, mltable, tfieldmap)

% populateMLTableFromREDCapData - given a subset of the redcap data
% relating to a single instrument, and the field mappings between redcap
% and matlab for that instrument, populate the corresponding matlab table

nfields = size(tfieldmap, 1);

% first populate ID, Hospital, and Study Number fields - these are required 
% for all tables but aren't in the redcap mapping table
mltable.ID = trcdata.ID;
mltable.Hospital = trcdata.Hospital;
mltable.StudyNumber = trcdata.StudyNumber;

% now copy over all columns using the field mapping info
for f = 1:nfields
    rcfield = tfieldmap.redcap_fieldname(f);
    mlcol = tfieldmap.matlab_column(f);
    
    mltable(:, mlcol) = trcdata(:, rcfield);    
end
    
end

