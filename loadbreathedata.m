clear; clc; close all;

tic
fprintf('Loading Breathe Clinical Data\n');
fprintf('-----------------------------\n');
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'breatheclinicaldata.mat';
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Done\n');
toc
fprintf('\n');

study = 'BR';

[~, measdate, guidmapdate] = getLatestBreatheDates();

measfileprefix = 'Breathe_';
measfilesuffix = '.csv';
basedir   = setBaseDir();
subfolder = 'DataFiles/ProjectBreathe';

tic
fprintf('Loading Breathe GUID Mapping info\n');
fprintf('---------------------------------\n');
guidfile  = sprintf('Project Breathe GUID to email address map %s.xlsx', guidmapdate);
guidmap = readtable(fullfile(basedir, subfolder, guidfile));
guidmap.Properties.VariableNames{1} = 'StudyID';
toc
fprintf('\n');

brphysdata = createBreatheMeasuresTable(0);
brphysdata_deleted = brphysdata;
brphysdata_deleted.Reason(:) = {''};

measfilelisting = dir(fullfile(basedir, subfolder, sprintf('%s*%s%s', measfileprefix, measdate, measfilesuffix)));
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

for i = 1:nmeasfile
    tic
    fprintf('Processing %2d: %s\n', i, MeasFiles{i});
    filetype = strrep(strrep(strrep(MeasFiles{i}, measfileprefix, ''), measfilesuffix, ''), sprintf('_%s', measdate), '');
    
    mfopts = detectImportOptions(fullfile(basedir, subfolder, MeasFiles{i}), 'FileType', 'Text', 'Delimiter', ',');
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'IsDeleted'})) = {'logical'};
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'HasColdOrFlu'})) = {'logical'};
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'HasHayFever'})) = {'logical'};
    
    measdata = readtable(fullfile(basedir, subfolder, MeasFiles{i}), mfopts);
    norigrows = size(measdata, 1);
    fprintf('%d measurements\n', norigrows);
    measdata = outerjoin(measdata, guidmap, 'LeftKeys', {'PartitionKey'}, 'RightKeys', {'PartitionKey'}, 'RightVariables', {'StudyID'});
    measdata = outerjoin(measdata, brPatient, 'LeftKeys', {'StudyID'}, 'RightKeys', {'StudyNumber'}, 'RightVariables', {'ID', 'StudyDate'});
    measdata.TimestampDt = datetime(measdata.Timestamp, 'TimeZone','UTC','Format','yyyy-MM-dd HH:mm:ss.SSSSSSS Z');
    measdata.DateDt      = datetime(measdata.Date,    'TimeZone','UTC','Format','yyyy-MM-dd HH:mm:ss.SSSSSSS Z');
    measdata.TimestampDt.TimeZone = '';
    measdata.DateDt.TimeZone = '';
    
    % remove rows with no measurements (added from outer join above
    idx = ismember(measdata.PartitionKey, '');
    if sum(idx) > 0
        fprintf('*** Deleting %d guids with no measurements ***\n', sum(idx));
        measdata(idx, :) = [];
    end
    % remove rows with unknown GUID
    idx = ismember(measdata.StudyID, '');
    if sum(idx) > 0
        fprintf('*** Deleting %d measures with unknown GUID ***\n', sum(idx));
        measdata(idx, :) = [];
    end
    % remove rows with no corresponding clinical records
    idx = isnan(measdata.ID);
    if sum(idx) > 0
        fprintf('*** Deleting %d measures with no corresponding clinical records ***\n', sum(idx));
        measdata(idx, :) = [];
    end
    % remove records marked as deleted in the file
    idx = measdata.IsDeleted;
    if sum(idx) > 0
        fprintf('*** Deleting %d measures marked as deleted ***\n', sum(idx));
        measdata(idx, :) = [];
    end
    % remove records before study start date
    idx = measdata.DateDt < measdata.StudyDate;
    if sum(idx) > 0
        fprintf('*** Deleting %d measures before study start date ***\n', sum(idx));
        measdata(idx, :) = [];
    end
    delzero = 1;
    dontdelzero = 0;
    switch filetype
        case 'Activity'
            recordingtype = 'CalorieRecording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, delzero);
        case 'Coughing'
            recordingtype = 'CoughRecording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, delzero);
        case 'HeartRate'
            recordingtype = 'RestingHRRecording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, delzero);
        case 'Oximeter'
            recordingtype = 'O2SaturationRecording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'PulseRateRecording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, delzero);
        case 'Sleep'
            recordingtype = 'MinsAsleepRecording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, dontdelzero);
            recordingtype = 'MinsAwakeRecording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, dontdelzero);
        case 'Spirometer'
            recordingtype = 'FEV1Recording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'FEF2575Recording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'FEV075Recording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'FEV1DivFEV6Recording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'FEV6Recording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, delzero);
        case 'Temperature'
            recordingtype = 'TemperatureRecording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, delzero);
        case 'Weight'
            recordingtype = 'WeightRecording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, delzero);
        case 'Wellbeing'
            recordingtype = 'WellnessRecording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'HasColdOrFluRecording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, dontdelzero);
            recordingtype = 'HasHayFeverRecording';
            [brphysdata, brphysdata_deleted] = addBreatheRowsForMeasure(brphysdata, brphysdata_deleted, measdata, filetype, recordingtype, dontdelzero);
            
        otherwise
            fprintf('*** Unknown file type %s ***\n', filetype)
    end
    
    toc
    fprintf('\n');
end

brphysdata_original = brphysdata;
fprintf('Breathe data has %d rows\n', size(brphysdata, 1));
fprintf('\n');

% set study offset 
minmdate = min(brphysdata.Date_TimeRecorded);
broffset = datenum(datetime(year(minmdate), month(minmdate), day(minmdate)));
brphysdata.DateNum = ceil(datenum(datetime(brphysdata.Date_TimeRecorded)+seconds(1)) - broffset);

% calc and print overall data demographics before data anomaly fixes
printDataDemographics(brphysdata, 0);
fprintf('\n');

[brphysdata, brphysdata_deleted] = correctBreatheDataAnomalies(brphysdata, brphysdata_deleted);

% sort measurement data
brphysdata = sortrows(brphysdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');

printDataDemographics(brphysdata, 0);

plotMeasuresByHour(brphysdata, 0, 'BR - Measures By Hour Histograms', study);

brphysdata_predupehandling = brphysdata;

% generate data demographics by patient
generateDataDemographicsByPatientFn(brphysdata, brPatient, study);

% handle duplicates
doupdates = true;
detaillog = false;
brphysdata = handleBreatheDuplicateMeasures(brphysdata, study, doupdates, detaillog);

% calc and print overall data demographics after data anomaly fixes
printDataDemographics(brphysdata, 0);

% populate ScaledDateNum with the days from first measurement (by patient)
brphysdata = scaleDaysByPatient(brphysdata, doupdates);

brphysdata_predateoutlierhandling = brphysdata;

% don't do this for project breathe
% analyse measurement date outliers and handle as appropriate
%brphysdata = analyseAndHandleDateOutliers(brphysdata, study, doupdates);

createMeasuresHeatmapWithStudyPeriod(brphysdata, broffset, brPatient, study);

% calc and print overall data demographics after data anomaly fixes
%printDataDemographics(brphysdata, 0);

% generate data demographics by patient
generateDataDemographicsByPatientFn(brphysdata, brPatient, study);

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = 'breathedata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder, outputfilename), 'brphysdata', 'broffset', 'brphysdata_deleted', ...
    'brphysdata_original', 'brphysdata_predupehandling', 'brphysdata_predateoutlierhandling');

subfolder = 'ExcelFiles';
delrowfilename = 'BreatheDeletedMeasurementData.xlsx';
writetable(brphysdata_deleted(~ismember(brphysdata_deleted.Reason, {'NULL Measurement'}),:), fullfile(basedir, subfolder, delrowfilename));
toc
