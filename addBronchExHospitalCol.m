function [redcapdata] = addBronchExHospitalCol(redcapdata)

% addBronchExHospitalCol - adds a hardcoded hospital column to redcapdata
% for backward compatibility

redcapdata.hospital(:) = {'PAP'};

end