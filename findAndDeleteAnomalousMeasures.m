function [brphysdata, brphysdata_deleted] = findAndDeleteAnomalousMeasures(brphysdata, brphysdata_deleted, recordingtype, lowerthresh, upperthresh)

% findAndDeleteAnomalousMeasures - finds anomalous values and deletes them

outputcolname = getColumnForMeasure(recordingtype);

idx1 = ismember(brphysdata.RecordingType, recordingtype);
idx2 = table2array(brphysdata(:, {outputcolname})) < lowerthresh | table2array(brphysdata(:, {outputcolname})) > upperthresh;
idx  = idx1 & idx2;

fprintf('Removing %4d %25s entries < %7.2f or > %7.2f\n', sum(idx), recordingtype, lowerthresh, upperthresh);

brphysdata_deleted = appendDeletedRows(brphysdata(idx, :), brphysdata_deleted, {'Anomalous Value'});
brphysdata(idx, :) = [];

end

