function [physdata, physdata_deleted] = addBreatheRowsForMeasure(physdata, physdata_deleted, measdata, filetype, recordingtype, delzero)

% addBreatheRowsForMeasure - adds the rows to physdata (and
% physdata_deleted) for each raw ingested measures file and recording type

nmeas = size(measdata, 1);
fprintf('Processing %s data\n', recordingtype);
if nmeas > 0
    mbrphysdata                   = createBreatheMeasuresTable(nmeas);
    mbrphysdata.SmartCareID       = measdata.ID;
    mbrphysdata.UserName          = measdata.StudyNumber;
    mbrphysdata.Date_TimeRecorded = measdata.DateDt;
    ctcolumn = getColumnForRawBreatheCaptureType(filetype);
    mbrphysdata(:, {'CaptureType'}) = measdata(:, {ctcolumn});
    mbrphysdata.RecordingType(:) = {recordingtype};
 
    % ingest the measurements using column mapping functions
    inputcolname  = getColumnForRawBreatheMeasure(recordingtype);
    outputcolname = getColumnForMeasure(recordingtype);
    mbrphysdata(:, {outputcolname}) = measdata(:, {inputcolname});
    
    % scale up cough and wellness by a factor of 10 to make consistent with
    % other studies
    if ismember(recordingtype, {'CoughRecording', 'WellnessRecording'})
        mbrphysdata(:, {outputcolname}) = array2table(table2array(mbrphysdata(:, {outputcolname})) * 10);
    end
    % invert cough scale so it is consistent with other subjective scores
    if ismember(recordingtype, {'CoughRecording'})
        mbrphysdata(:, {outputcolname}) = array2table(100 - table2array(mbrphysdata(:, {outputcolname})));
    end
    % only include non-null measurements
    if ismember(class(table2array(mbrphysdata(:, {outputcolname}))), {'double'})
        if delzero
            nullidx = isnan(table2array(mbrphysdata(:, {outputcolname}))) | table2array(mbrphysdata(:, {outputcolname})) == 0;
            delreason = 'NULL or Zero';
            deltext   = 'Non-NULL and Non-Zero';
        else
            nullidx = isnan(table2array(mbrphysdata(:, {outputcolname})));
            delreason = 'Null';
            deltext   = 'Non-NULL';
        end
    elseif ismember(class(table2array(mbrphysdata(:, {outputcolname}))), {'cell'})
        nullidx = ismember(table2array(mbrphysdata(:, {outputcolname})), {'NULL'});
    else
        fprintf('Unknown data type for measurement column\n');
    end
    nonnullmeasurements = sum(~nullidx);
    if sum(nullidx) > 0
        physdata_deleted = appendDeletedRows(mbrphysdata(nullidx, :), physdata_deleted, {sprintf('%s Measurement', delreason)});
    end
    physdata = [physdata; mbrphysdata(~nullidx,:)];
    fprintf('%d Raw Measurements, %d %s measurements\n', nmeas, nonnullmeasurements, deltext);
else
    fprintf('%d Raw Measurements\n', nmeas);
end


end

