function relrows = getMeasuresForPatientAndDateRange(physdata,smartcareID, daymid, range)

% getMeasuresForPatientDateRange - returns table containing the measurements 
% for a given patient with +/- days around a specified date

dayfrom = daymid - range;
dayto = daymid + range;

idx1 = find(physdata.SmartCareID==smartcareID);
idx2 = find(physdata.DateNum > dayfrom & physdata.DateNum < dayto);
idx = intersect(idx1,idx2);

relrows = sortrows(physdata(idx,:), {'RecordingType','DateNum'}, 'ascend');

end

