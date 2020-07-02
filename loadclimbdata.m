clear; clc; close all;


tic
fprintf('Loading Clinical Data\n');
fprintf('---------------------\n');
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'climbclinicaldata.mat';
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Done\n');
toc
fprintf('\n');

study = 'CL';

basedir = setBaseDir();
subfolder = sprintf('DataFiles/%s/MeasurementDataFinal', study);

clphysdata = createClimbMeasuresTable(0);
clphysdata_deleted = clphysdata;
clphysdata_deleted.Reason(:) = {''};

measfilelisting = dir(fullfile(basedir, subfolder, '*.xls*'));
MeasFiles = cell(size(measfilelisting,1),1);
for a = 1:size(MeasFiles,1)
    MeasFiles{a} = measfilelisting(a).name;
end

nmeasfile = size(MeasFiles,1);
fprintf('Measurement files to ingest\n');
fprintf('---------------------------\n');
for i = 1:nmeasfile
    fprintf('%2d: %s\n', i, MeasFiles{i});
end
fprintf('\n');
fprintf('---------------------------\n');
fprintf('\n');

measdatasheetname = 'CFRemoteMonitoring-from-2017-01';
canadalungdsname = 'Canada data';

for i = 1:nmeasfile
    tic
    fprintf('Processing %2d: %s\n', i, MeasFiles{i});
    mfopts = detectImportOptions(fullfile(basedir, subfolder, MeasFiles{i}), 'Sheet', measdatasheetname);
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'StartDate', 'EndDate', 'DateRecorded', 'CorrectedCanadaDate'})) = {'datetime'};
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'TimeRecorded', 'CorrectedCanadaTime'})) = {'datetime'};
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'BreathsPerMinute', 'FEV1', 'NumberOfDisturbances', ...
        'O2Saturation', 'Pulse_BPM_', 'Rating', 'Temp_degC_', 'WeightInKg'})) = {'double'};
    
    tmpmeasdata = readtable(fullfile(basedir, subfolder, MeasFiles{i}), mfopts, 'Sheet', measdatasheetname);
    % special processing for sputum colour recordings to convert from text
    % labels to a numeric index equivalent
    if ismember(tmpmeasdata.RecordingType(1), 'SputumColorRecording')
        [tmpmeasdata, sputumcolouridx] = convertSputumColourToNumeric(tmpmeasdata);
    end 
    tmpmeasdata.UserID = upper(tmpmeasdata.UserID);
    
    
    % special processing for lung function file (canada data on separate
    % file)
    if startsWith(MeasFiles{i}, 'Lung')
        idx = startsWith(tmpmeasdata.UserID, {'IWK', 'LON'});
        fprintf('Deleting %d rows of canada data from main data sheet\n', sum(idx));
        tmpmeasdata(idx, :) = [];
        fprintf('Loading canadiana lung function data from %s sheet\n', canadalungdsname);
        mfopts = detectImportOptions(fullfile(basedir, subfolder, MeasFiles{i}), 'Sheet', canadalungdsname);
        mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'StartDate', 'EndDate', 'DateRecorded', 'CorrectedCanadaDate'})) = {'datetime'};
        mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'TimeRecorded', 'CorrectedCanadaTime'})) = {'datetime'};
        mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'BreathsPerMinute', 'FEV1', 'NumberOfDisturbances', ...
            'O2Saturation', 'Pulse_BPM_', 'Rating', 'Temp_degC_', 'WeightInKg'})) = {'double'};
    
        tmplfdata = readtable(fullfile(basedir, subfolder, MeasFiles{i}), mfopts, 'Sheet', canadalungdsname);
        fprintf('Loaded %d rows\n', size(tmplfdata, 1));
        tmpmeasdata = [tmpmeasdata; tmplfdata];
        
        fprintf('Updating recording type to be FEV1Recording\n');
        tmpmeasdata.RecordingType(:) = {'FEV1Recording'};
    end
    
    nmeasurements = size(tmpmeasdata, 1);
    if nmeasurements > 0
        mclphysdata = createClimbMeasuresTable(nmeasurements);
        % ingest user name (force uppercase for consistency) and recording type
        mclphysdata.UserName = upper(tmpmeasdata.UserID);
        mclphysdata.RecordingType = tmpmeasdata.RecordingType;
        % set the date time recorded from date and time columns in the raw
        % measurement file
        mclphysdata.Date_TimeRecorded = tmpmeasdata.DateRecorded;
        [tmph, tmpm, tmps] = hms(tmpmeasdata.TimeRecorded);
        mclphysdata.Date_TimeRecorded.Hour   = tmph;
        mclphysdata.Date_TimeRecorded.Minute = tmpm;
        mclphysdata.Date_TimeRecorded.Second = tmps;
        % override with the timezone corrected columns for the 2 canada
        % hospitals
        canidx = startsWith(tmpmeasdata.UserID, {'IWK', 'LON'});
        %canidx = ismember(extractBefore(tmpmeasdata.UserID,4), {'IWK', 'LON'});
        mclphysdata.Date_TimeRecorded(canidx) = tmpmeasdata.CorrectedCanadaDate(canidx);
        [tmph, tmpm, tmps] = hms(tmpmeasdata.CorrectedCanadaTime);
        mclphysdata.Date_TimeRecorded.Hour(canidx)   = tmph(canidx);
        mclphysdata.Date_TimeRecorded.Minute(canidx) = tmpm(canidx);
        mclphysdata.Date_TimeRecorded.Second(canidx) = tmps(canidx);
        % ingest the measurements using column mapping functions
        inputcolname = getColumnForRawClimbMeasure(tmpmeasdata.RecordingType{1});
        outputcolname = getColumnForMeasure(tmpmeasdata.RecordingType{1});
        mclphysdata(:, {outputcolname}) = tmpmeasdata(:, {inputcolname});
        % only includ non-null measurements
        if ismember(class(table2array(mclphysdata(:, {outputcolname}))), {'double'})
            nullidx = isnan(table2array(mclphysdata(:, {outputcolname})));
        elseif ismember(class(table2array(mclphysdata(:, {outputcolname}))), {'cell'})
            nullidx = ismember(table2array(mclphysdata(:, {outputcolname})), {'NULL'});
        else
            fprintf('Unknown data type for measurement column\n');
        end
        nonnullmeasurements = sum(~nullidx);
        clphysdata_deleted = appendDeletedRows(mclphysdata(nullidx, :), clphysdata_deleted, {'NULL Measurement'});
        clphysdata = [clphysdata; mclphysdata(~nullidx,:)];
        fprintf('%5d Raw Measurements, %5d Non-null measurements\n', nmeasurements, nonnullmeasurements);
    else
        fprintf('%d Raw Measurements\n', nmeasurements);
    end
    toc
    fprintf('\n');
end

clphysdata_original = clphysdata;
fprintf('Climb data has %d rows\n', size(clphysdata, 1));
fprintf('\n');

% remove dummy user entries
dummies = {'TEST1', 'TEST2', 'TESTDAVE'};
idx = ismember(clphysdata.UserName, dummies);
fprintf('Removing dummy users - %d rows\n', sum(idx));
clphysdata_deleted = appendDeletedRows(clphysdata(idx,:), clphysdata_deleted, {'Dummy User'});
clphysdata(idx,:) = [];

fprintf('Climb data now has %d rows\n', size(clphysdata, 1));
fprintf('\n');

% set study offset 
minmdate = min(clphysdata.Date_TimeRecorded);
cloffset = datenum(datetime(year(minmdate), month(minmdate), day(minmdate)));
clphysdata.DateNum = ceil(datenum(datetime(clphysdata.Date_TimeRecorded)+seconds(1)) - cloffset);

% update with ID
tic
fprintf('Adding ID to the measurement data table\n');
fprintf('--------------------------------------\n');
totupdates = 0;
for i = 1:size(clPatient,1)
    id = clPatient.StudyNumber{i};
    scid = clPatient.ID(i);
    idx = ismember(clphysdata.UserName, id);
    fprintf('Updating ID %3d for UserID %6s - %4d rows updated\n', scid, id, sum(idx));
    clphysdata.SmartCareID(idx) = scid;
    totupdates = totupdates + sum(idx);
end
fprintf('\n');
fprintf('Total rows updated = %d\n', totupdates);
fprintf('Rows with no ID match = %4d\n', size(clphysdata, 1) - totupdates);
fprintf('\n');


idx = (clphysdata.SmartCareID == 0);
missedids = unique(clphysdata.UserName(idx));

if (size(missedids, 1) > 0)
    fprintf('UserIDs not matched are :-\n');
    for i = 1:size(missedids,1)
        fprintf('%6s\n', missedids{i});
    end
end

fprintf('Removing %4d measurements with no patient ID match\n', sum(idx));
clphysdata_deleted = appendDeletedRows(clphysdata(idx, :), clphysdata_deleted, {'No Patient ID Match'});
clphysdata(idx, :) = [];
toc
fprintf('\n');

% remove blank/zero values 
idx1 = ismember(clphysdata.RecordingType, {'ActivityRecording'});
idx2 = isnan(clphysdata.Activity_Steps);
idx3 = clphysdata.Activity_Steps == 0;
idx = idx1 & (idx2 | idx3);
fprintf('Removing %4d blank or zero Activity measurements\n', sum(idx));
clphysdata_deleted = appendDeletedRows(clphysdata(idx,:), clphysdata_deleted, {'Zero Value'});
clphysdata(idx,:) = [];

idx1 = ismember(clphysdata.RecordingType, {'AppetiteRecording', 'BreathlessnessRecording', 'CoughRecording','SleepActivityRecording', 'SputumVolumeRecording', 'TirednessRecording', 'WellnessRecording'});
idx2 = isnan(clphysdata.Rating);
idx = idx1 & idx2;
fprintf('Removing %4d blank Rating measurements\n', sum(idx));
clphysdata_deleted = appendDeletedRows(clphysdata(idx,:), clphysdata_deleted, {'Zero Value'});
clphysdata(idx,:) = [];

idx1 = ismember(clphysdata.RecordingType, {'FEV1Recording'});
idx2 = isnan(clphysdata.FEV);
idx3 = clphysdata.FEV == 0;
idx = idx1 & (idx2 | idx3);
fprintf('Removing %4d blank or zero FEV1 measurements\n', sum(idx));
clphysdata_deleted = appendDeletedRows(clphysdata(idx,:), clphysdata_deleted, {'Zero Value'});
clphysdata(idx,:) = [];

idx1 = ismember(clphysdata.RecordingType, {'O2SaturationRecording'});
idx2 = isnan(clphysdata.O2Saturation);
idx3 = clphysdata.O2Saturation == 0;
idx = idx1 & (idx2 | idx3);
fprintf('Removing %4d blank or zero O2 Saturation measurements\n', sum(idx));
clphysdata_deleted = appendDeletedRows(clphysdata(idx,:), clphysdata_deleted, {'Zero Value'});
clphysdata(idx,:) = [];

idx1 = ismember(clphysdata.RecordingType, {'PulseRateRecording'});
idx2 = isnan(clphysdata.Pulse_BPM_);
idx3 = clphysdata.Pulse_BPM_ == 0;
idx = idx1 & (idx2 | idx3);
fprintf('Removing %4d blank or zero Pulse Rate measurements\n', sum(idx));
clphysdata_deleted = appendDeletedRows(clphysdata(idx,:), clphysdata_deleted, {'Zero Value'});
clphysdata(idx,:) = [];

idx1 = ismember(clphysdata.RecordingType, {'RespiratoryRateRecording'});
idx2 = isnan(clphysdata.BreathsPerMin);
idx3 = clphysdata.BreathsPerMin == 0;
idx = idx1 & (idx2 | idx3);
fprintf('Removing %4d blank or zero Resp Rate measurements\n', sum(idx));
clphysdata_deleted = appendDeletedRows(clphysdata(idx,:), clphysdata_deleted, {'Zero Value'});
clphysdata(idx,:) = [];

idx1 = ismember(clphysdata.RecordingType, {'SleepDisturbanceRecording'});
idx2 = isnan(clphysdata.NumSleepDisturb);
idx = idx1 & idx2;
fprintf('Removing %4d blank Sleep Disturb measurements\n', sum(idx));
clphysdata_deleted = appendDeletedRows(clphysdata(idx,:), clphysdata_deleted, {'Zero Value'});
clphysdata(idx,:) = [];

idx1 = ismember(clphysdata.RecordingType, {'TemperatureRecording'});
idx2 = isnan(clphysdata.Temp_degC_);
idx3 = clphysdata.Temp_degC_ == 0;
idx = idx1 & (idx2 | idx3);
fprintf('Removing %4d blank or zero Temperature measurements\n', sum(idx));
clphysdata_deleted = appendDeletedRows(clphysdata(idx,:), clphysdata_deleted, {'Zero Value'});
clphysdata(idx,:) = [];

idx1 = ismember(clphysdata.RecordingType, {'WeightRecording'});
idx2 = isnan(clphysdata.WeightInKg);
idx3 = clphysdata.WeightInKg == 0;
idx = idx1 & (idx2 | idx3);
fprintf('Removing %4d blank or zero Weight measurements\n', sum(idx));
clphysdata_deleted = appendDeletedRows(clphysdata(idx,:), clphysdata_deleted, {'Zero Value'});
clphysdata(idx,:) = [];

% update sputum colour to be lower case to ensure consistency and rename
% recording type to be english spelling
idx = ismember(clphysdata.RecordingType, {'SputumColorRecording'});
clphysdata.RecordingType(idx) = {'SputumColourRecording'};
fprintf('Updating %4d Sputum Colour to make recording type english spelling\n', sum(idx));
fprintf('\n');

% calc and print overall data demographics before data anomaly fixes
printDataDemographics(clphysdata, 0);
fprintf('\n');

[clphysdata, clphysdata_deleted] = correctClimbDataAnomalies(clphysdata, clphysdata_deleted);

% sort measurement data
clphysdata = sortrows(clphysdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');

printDataDemographics(clphysdata, 0);

plotMeasuresByHour(clphysdata, 0, 'CL - Measures By Hour Histograms', study);

doupdates = true;
detaillog = false;
clphysdata = analyseOvernightMeasures(clphysdata,0, doupdates, detaillog);

clphysdata_predupehandling = clphysdata;

% generate data demographics by patient
generateDataDemographicsByPatientFn(clphysdata, clPatient, study);

% handle duplicates
doupdates = true;
detaillog = false;
clphysdata = handleDuplicateMeasures(clphysdata, study, doupdates, detaillog);

% calc and print overall data demographics after data anomaly fixes
printDataDemographics(clphysdata, 0);

% populate ScaledDateNum with the days from first measurement (by patient)
clphysdata = scaleDaysByPatient(clphysdata, doupdates);

clphysdata_predateoutlierhandling = clphysdata;

% analyse measurement date outliers and handle as appropriate
clphysdata = analyseAndHandleDateOutliers(clphysdata, study, doupdates);

createMeasuresHeatmapWithStudyPeriod(clphysdata, cloffset, clPatient, study);

% create interpolated measures for FEV1 and Weight
clphysdata = createInterpMeasure(clphysdata, 'FEV1Recording', detaillog);
clphysdata = createInterpMeasure(clphysdata, 'WeightRecording', detaillog);

% calc and print overall data demographics after data anomaly fixes
printDataDemographics(clphysdata, 0);

% generate data demographics by patient
generateDataDemographicsByPatientFn(clphysdata, clPatient, study);


tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = 'climbdata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder, outputfilename), 'clphysdata', 'cloffset', 'sputumcolouridx', 'clphysdata_deleted', 'clphysdata_original', 'clphysdata_predupehandling', 'clphysdata_predateoutlierhandling');

subfolder = 'ExcelFiles';
delrowfilename = 'ClimbDeletedMeasurementData3.xlsx';
writetable(clphysdata_deleted(~ismember(clphysdata_deleted.Reason, {'NULL Measurement'}),:), fullfile(basedir, subfolder, delrowfilename));
toc
