% 1st Breathe data processing step and analysis from raw measurements
% takes the raw home measurement files, along with the GUID to 
% study email mapping file and processes them. The main steps performed are: 
% i) Filtering
%     a. removing patients with no measurement data
%     b. removing measurement data for unknown patients or those with no clinical data
%     c. removing records marked as deleted
%     d. removing measurement records before the study start date for each patient
%     e. removing measurement records after the last clinical data update date for each patient
% ii) Removing data anomalies - upper and lower treshold 
% iii) Handling duplicate records
% #not for Breathe iv)	Handling patients with small amounts of data or very sparse data
% v) Creates various plots visualise the study data and spreadsheets to allow results of the 
% processing to analysed in more detail (ie which records where deleted and why).
% 
% Input:
% ------
% latest Breathe measdate from eponym function
% raw measurements data
% breatheclinicaldata.mat               contains clinical data and patient master file
%
% Output:
% -------
% breathedata.mat with the following variables (sorted from earliest to latest processed):
% - broffset                            date of the study's first recorded measurement
% - brphysdata_original                 raw measures
% - brphysdata_deleted                  deleted measures
% - brphysdata_predupehandling          measures before handling duplicates 
% - brphysdata_predateoutlierhandling   same as final data since no outliers handling here
% - brphysdata                          final data table
% * NB * brphysdata features contain:
%     - DateNum                         #days since broffset
%     - ScaleDateNum                    #days since patient 's 1st recorded measure
% 
% HeatmapAllPatientsWithStudyPeriod     Plots the temporal data count heatmap
% datademographicsbypatient             .mat and Excel files with boxchart like statistics
% BreatheDeletedMeasurementData         Excel containing brphysdata_deleted

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

fprintf('Loading Project Breathe measurement data\n');
fprintf('----------------------------------------\n');

brphysdata = createBreatheMeasuresTable(0);
brphysdata_deleted = brphysdata;
brphysdata_deleted.Reason(:) = {''};

% don't need this anymore as the patient master is loaded along with the
% clinical data above

% get list of Project Breathe hospitals
%brhosp = getListOfBreatheHospitals();

% create concatenated guidmap file over all hospital
%guidmap = [];
%for h = 1:size(brhosp, 1)
%
%    fprintf('Getting GUID mappings for %s\n', brhosp.Name{h});
%    [~, guidmapdate] = getLatestBreatheDatesForHosp(brhosp.Acronym{h});
%    [hospguidmap] = loadGUIDFileForHosp(study, brhosp(h, :), guidmapdate);
    
%    guidmap = [guidmap; hospguidmap];
%end

measfileprefix = 'Breathe_';
measdate       = getLatestBreatheMeasDate();
measfilesuffix = '.csv';
basedir        = setBaseDir();
subfolder      = sprintf('DataFiles/%s/MeasurementData', study);

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
    %measdata = outerjoin(measdata, guidmap, 'LeftKeys', {'PartitionKey'}, 'RightKeys', {'PartitionKey'}, 'RightVariables', {'StudyNumber'});
    measdata = outerjoin(measdata, patientmaster, 'LeftKeys', {'PartitionKey'}, 'RightKeys', {'PartitionKey'}, 'RightVariables', {'StudyNumber'});
    measdata = outerjoin(measdata, brPatient, 'LeftKeys', {'StudyNumber'}, 'RightKeys', {'StudyNumber'}, 'RightVariables', {'ID', 'StudyDate', 'PatClinDate'});
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
    idx = ismember(measdata.StudyNumber, '');
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
    % remove records after last patient clinical update date
    idx = measdata.DateDt > measdata.PatClinDate;
    if sum(idx) > 0
        fprintf('*** Deleting %d measures after last clinical update by patient ***\n', sum(idx));
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
            [brphysdata] = addBreatheRowsForLungFcn(brphysdata, brPatient);
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
