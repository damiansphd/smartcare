function relrows = getMeasuresForPatientAndDateRange(physdata,smartcareID, daymid, range, rectype, includeActivity)

% getMeasuresForPatientDateRange - returns table containing the measurements 
% for a given patient with +/- days around a specified date

if ismember(rectype,'All')
    if includeActivity
        % dummy index of all rows in physdata
        idxm = find(physdata.SmartCareID);
    else
        % index rows of all measurment types except ActivityRecording
        idxm = find(~ismember(physdata.RecordingType, 'ActivityRecording'));
    end
else
    idxm = find(ismember(physdata.RecordingType, rectype));
end

dayfrom = daymid - range;
dayto = daymid + range;

idx1 = find(physdata.SmartCareID==smartcareID);
idx2 = find(physdata.DateNum >= dayfrom & physdata.DateNum <= dayto);
idx = intersect(idx1,idx2);
idx = intersect(idxm, idx);

relrows = sortrows(physdata(idx,:), {'RecordingType','DateNum'}, 'ascend');

end

