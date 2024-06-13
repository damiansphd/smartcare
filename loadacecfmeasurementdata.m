% 1st Ace-CF data processing step and analysis from raw measurements
% takes the raw home measurement files, along with the GUID to 
% study email mapping file and processes them. The main steps performed are: 
% i) Filtering
%     a. removing patients with no measurement data
%     b. removing measurement data for unknown patients or those with no clinical data
%     c. removing records marked as deleted
%     d. removing measurement records before the study start date for each patient
%     e. removing measurement records after the last clinical data update
%     date for each patient (note - adding the ability to keep this
%     filtering, or load all measurement data regardless of clinical data
%     update date - for adhoc analysis purposes rather than ML model
%     usage).
% ii) Removing data anomalies - upper and lower treshold 
% iii) Handling duplicate records
% #not for Ace-CF iv)	Handling patients with small amounts of data or very sparse data
% v) Creates various plots visualise the study data and spreadsheets to allow results of the 
% processing to analysed in more detail (ie which records where deleted and why).
% 
% Input:
% ------
% latest Breathe measdate from eponym function
% raw measurements data (meas files are shared between Breathe and Ace-CF
% studies
% acecfclinicaldata.mat               contains clinical data and patient master file
%
% Output:
% -------
% acecfdata.mat with the following variables (sorted from earliest to latest processed):
% - acoffset                            date of the study's first recorded measurement
% - acphysdata_original                 raw measures
% - acphysdata_deleted                  deleted measures
% - acphysdata_predupehandling          measures before handling duplicates 
% - acphysdata_predateoutlierhandling   same as final data since no outliers handling here
% - acphysdata                          final data table
% * NB * acphysdata features contain:
%     - DateNum                         #days since broffset
%     - ScaleDateNum                    #days since patient 's 1st recorded measure
% 
% HeatmapAllPatientsWithStudyPeriod     Plots the temporal data count heatmap
% datademographicsbypatient             .mat and Excel files with boxchart like statistics
% AceCFDeletedMeasurementData         Excel containing brphysdata_deleted

clear; clc; close all;

% choose filter method for measurement data
measdatafiltmthd = selectMeasDataFiltMthd();

tic
fprintf('Loading Ace-CF Clinical Data\n');
fprintf('-----------------------------\n');
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'acecfclinicaldata.mat';
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Done\n');
toc
fprintf('\n');

study = 'AC';

fprintf('Loading Ace-CF measurement data\n');
fprintf('----------------------------------------\n');

acphysdata = createBreatheMeasuresTable(0);
acphysdata_deleted = acphysdata;
acphysdata_deleted.Reason(:) = {''};

measfileprefix = 'Breathe_';
measdate       = getLatestAceCFMeasDate();
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
    if any(ismember(measdata.Properties.VariableNames, {'UserId'}))
        measdata = renamevars(measdata, 'UserId', 'PartitionKey');
    end
    if any(ismember(measdata.Properties.VariableNames, {'EntityId'}))
        measdata = renamevars(measdata, 'EntityId', 'RowKey');
    end
    if any(ismember(measdata.Properties.VariableNames, {'ClientTimestamp'}))
        measdata = renamevars(measdata, 'ClientTimestamp', 'Date');
    end
    %measdata = renamevars(measdata, ["UserId", "EntityId", "ClientTimestamp"], ["PartitionKey", "RowKey", "Date"]);
    if ~any(ismember(measdata.Properties.VariableNames, {'CaptureType'}))
        measdata.CaptureType(:) = {'Manual'};
    end
    
    norigrows = size(measdata, 1);
    fprintf('%d measurements\n', norigrows);
    measdata = outerjoin(measdata, acPatient, 'LeftKeys', {'PartitionKey'}, 'RightKeys', {'PartitionKey'}, 'RightVariables', {'ID', 'StudyNumber', 'StudyDate', 'PatClinDate'});
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
    if measdatafiltmthd == 1
        % remove records after last patient clinical update date
        idx = measdata.DateDt > measdata.PatClinDate;
        if sum(idx) > 0
            fprintf('*** Deleting %d measures after last clinical update by patient ***\n', sum(idx));
            measdata(idx, :) = [];
        end
    elseif measdatafiltmthd == 2
        fprintf('*** Not filtering measures after last clinical update by patient ***\n');
    else
        fprintf('*** Unknown filtering method ***\n');
    end
        
    delzero = 1;
    dontdelzero = 0;
    switch filetype
        case 'Activity'
            recordingtype = 'CalorieRecording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, delzero);
        case 'Coughing'
            recordingtype = 'CoughRecording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, delzero);
        case 'HeartRate'
            recordingtype = 'RestingHRRecording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, delzero);
        case 'Oximeter'
            recordingtype = 'O2SaturationRecording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'PulseRateRecording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, delzero);
        case 'Sleep'
            recordingtype = 'MinsAsleepRecording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, dontdelzero);
            recordingtype = 'MinsAwakeRecording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, dontdelzero);
        case 'Spirometer'
            recordingtype = 'FEV1Recording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, delzero);
            [acphysdata] = addBreatheRowsForLungFcn(acphysdata, acPatient);
            recordingtype = 'FEF2575Recording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'FEV075Recording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'FEV1DivFEV6Recording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'FEV6Recording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, delzero);
        case 'Temperature'
            recordingtype = 'TemperatureRecording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, delzero);
        case 'Weight'
            recordingtype = 'WeightRecording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, delzero);
        case 'Wellbeing'
            recordingtype = 'WellnessRecording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'HasColdOrFluRecording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, dontdelzero);
            recordingtype = 'HasHayFeverRecording';
            [acphysdata, acphysdata_deleted] = addBreatheRowsForMeasure(acphysdata, acphysdata_deleted, measdata, filetype, recordingtype, dontdelzero);

        otherwise
            fprintf('*** Unknown file type %s ***\n', filetype)
    end

    toc
    fprintf('\n');
end

acphysdata_original = acphysdata;
fprintf('Ace-CF data has %d rows\n', size(acphysdata, 1));
fprintf('\n');

% set study offset 
minmdate = min(acphysdata.Date_TimeRecorded);
acoffset = datenum(datetime(year(minmdate), month(minmdate), day(minmdate)));
acphysdata.DateNum = ceil(datenum(datetime(acphysdata.Date_TimeRecorded)+seconds(1)) - acoffset);

% calc and print overall data demographics before data anomaly fixes
printDataDemographics(acphysdata, 0);
fprintf('\n');

[acphysdata, acphysdata_deleted] = correctBreatheDataAnomalies(acphysdata, acphysdata_deleted);

% sort measurement data
acphysdata = sortrows(acphysdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');

printDataDemographics(acphysdata, 0);

plotMeasuresByHour(acphysdata, 0, 'AC - Measures By Hour Histograms', study);

acphysdata_predupehandling = acphysdata;

% generate data demographics by patient
generateDataDemographicsByPatientFn(acphysdata, acPatient, study);

% handle duplicates
doupdates = true;
detaillog = false;
acphysdata = handleBreatheDuplicateMeasures(acphysdata, study, doupdates, detaillog);

% calc and print overall data demographics after data anomaly fixes
printDataDemographics(acphysdata, 0);

% populate ScaledDateNum with the days from first measurement (by patient)
acphysdata = scaleDaysByPatient(acphysdata, doupdates);

acphysdata_predateoutlierhandling = acphysdata;

% don't do this for project breathe or ace-cf
% analyse measurement date outliers and handle as appropriate
%acphysdata = analyseAndHandleDateOutliers(acphysdata, study, doupdates);

createMeasuresHeatmapWithStudyPeriod(acphysdata, acoffset, acPatient, study);

% calc and print overall data demographics after data anomaly fixes
%printDataDemographics(brphysdata, 0);

% generate data demographics by patient
generateDataDemographicsByPatientFn(acphysdata, acPatient, study);

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

if measdatafiltmthd == 2
    outputfilename = 'acecfdata-nofilt.mat';
else
    [outputfilename, ~, ~] = getRawDataFilenamesForStudy(study);
end
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder, outputfilename), 'acphysdata', 'acoffset', 'acphysdata_deleted', ...
    'acphysdata_original', 'acphysdata_predupehandling', 'acphysdata_predateoutlierhandling');

subfolder = 'ExcelFiles';
if measdatafiltmthd == 2
    delrowfilename = 'AceCFDeletedMeasurementData-nofilt.xlsx';
else
    delrowfilename = 'AceCFDeletedMeasurementData.xlsx';
end
writetable(acphysdata_deleted(~ismember(acphysdata_deleted.Reason, {'NULL Measurement'}),:), fullfile(basedir, subfolder, delrowfilename));
toc
