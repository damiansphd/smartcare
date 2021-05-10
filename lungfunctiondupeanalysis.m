
temp = tunique(find(tunique.Count>1 & string(tunique.RecordingType) == 'LungFunctionRecording' & tunique.Std >5),:);

for i = 1:size(temp,1)
    temp2 = sortrows(getMeasuresForPatientAndDateRange(physdata, temp.SmartCareID(i), temp.DateNum(i), 0, temp.RecordingType(i), true), ...
        {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend')
    temp3 = sortrows(getMeasuresForPatientAndDateRange(physdata_predupehandling, temp.SmartCareID(i), temp.DateNum(i), 1, temp.RecordingType(i), true), ...
        {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend')
end