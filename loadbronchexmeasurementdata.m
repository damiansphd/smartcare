% BronchEx measurement data processing step and analysis from raw measurements
% takes the raw home measurement files, along with the partition key to 
% study id mapping file and processes them. The main steps performed are: 
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
% iv) Creates various plots visualise the study data and spreadsheets to allow results of the 
% processing to analysed in more detail (ie which records where deleted and why).
% 
% Input:
% ------
% latest BronchEx measdate from eponym function
% raw measurements data (meas files are shared between Breathe, Ace-CF, and
% BronchEx studies
% bronchexclinicaldata.mat contains clinical data
%
% Output:
% -------
% bronchexdata.mat with the following variables (sorted from earliest to latest processed):
% - beoffset                            date of the study's first recorded measurement
% - bephysdata_original                 raw measures
% - bephysdata_deleted                  deleted measures
% - bephysdata_predupehandling          measures before handling duplicates 
% - bephysdata_predateoutlierhandling   same as final data since no outliers handling here
% - bephysdata                          final data table
% * NB * bephysdata features contain:
%     - DateNum                         #days since broffset
%     - ScaleDateNum                    #days since patient 's 1st recorded measure
% 
% HeatmapAllPatientsWithStudyPeriod     Plots the temporal data count heatmap
% datademographicsbypatient             .mat and Excel files with boxchart like statistics
% BronchExDeletedMeasurementData        Excel containing brphysdata_deleted

clear; clc; close all;

% choose filter method for measurement data
% measdatafiltmthd = selectMeasDataFiltMthd();

study = 'BE';
[measmatfilename, clinicalmatfilename, ~] = getRawDataFilenamesForStudy(study);

tic
fprintf('Loading BronchEx Clinical Data\n');
fprintf('-----------------------------\n');
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
load(fullfile(basedir, subfolder, clinicalmatfilename));
fprintf('Done\n');
toc
fprintf('\n');

% Magic Bullet changed to store upper case equivalent of partition key in
% the measurement files from 20240925. Now changing to convert both REDCap
% and measurement data partition keys to upper case so it will be
% backwardly compatible
bePatient.PartitionKey = upper(bePatient.PartitionKey);

fprintf('Loading BronchEx measurement data\n');
fprintf('----------------------------------------\n');

bephysdata = createBreatheMeasuresTable(0);
bephysdata_deleted = bephysdata;
bephysdata_deleted.Reason(:) = {''};

measfileprefix = 'Breathe_';
measdate       = getLatestBronchExMeasDate();
measdatedt     = datetime(str2double(measdate), 'ConvertFrom', 'yyyymmdd');
measfilesuffix = '.csv';
basedir        = setBaseDir();
subfolder      = sprintf('DataFiles/%s/MeasurementData', study);

% Magic Bullet changed the file name format on Sept 25th 2024 so updating
% logic to allow for backward compatibility
% Due to issue with data being removed for withdrawn patients, this was
% reverted on 7th Jan 2025 - so now adding an end date to this filename
% format change
if measdatedt >= datetime(2024,09,24) && measdatedt <= datetime(2025,01,05)
    measdate = sprintf('%s-%s-%s', measdate(1:4), measdate(5:6), measdate(7:8));
end
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
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'IsDeleted'}))    = {'logical'};
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'HasColdOrFlu'})) = {'logical'};
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'HasHayFever'}))  = {'logical'};
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'FEV1'}))         = {'double'};
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'FEF2575'}))      = {'double'};
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'FEV075'}))       = {'double'};
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'FEV1DivFEV6'}))  = {'double'};
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'FEV6'}))         = {'double'};

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

    % see note above, from 20240925, measurement files now contain upper
    % case equivalent of PartitionKey. So updating to be uppercase in both
    % REDCap and measurement files to allow backward compatibility over all
    % time
    measdata.PartitionKey = upper(measdata.PartitionKey);
    
    norigrows = size(measdata, 1);
    fprintf('%d measurements\n', norigrows);
    measdata = outerjoin(measdata, bePatient, 'LeftKeys', {'PartitionKey'}, 'RightKeys', {'PartitionKey'}, 'RightVariables', {'ID', 'StudyNumber', 'StudyDate', 'PatClinDate'});
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
        case {'Activity', 'Activities'}
            recordingtype = 'CalorieRecording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, delzero);
        case 'Coughing'
            recordingtype = 'CoughRecording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, delzero);
        case {'HeartRate', 'HeartRates'}
            recordingtype = 'RestingHRRecording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, delzero);
        case {'Oximeter', 'Oximeters'}
            recordingtype = 'O2SaturationRecording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'PulseRateRecording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, delzero);
        case {'Sleep', 'Sleeps'}
            recordingtype = 'MinsAsleepRecording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, dontdelzero);
            recordingtype = 'MinsAwakeRecording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, dontdelzero);
        case {'Spirometer', 'Spirometers'}
            recordingtype = 'FEV1Recording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, delzero);
            [bephysdata] = addBreatheRowsForLungFcn(bephysdata, bePatient);
            recordingtype = 'FEF2575Recording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'FEV075Recording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'FEV1DivFEV6Recording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'FEV6Recording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, delzero);
        case {'Temperature', 'Temperatures'}
            recordingtype = 'TemperatureRecording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, delzero);
        case {'Weight', 'Weights'}
            recordingtype = 'WeightRecording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, delzero);
        case {'Wellbeing', 'Wellbeings'}
            recordingtype = 'WellnessRecording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, delzero);
            recordingtype = 'HasColdOrFluRecording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, dontdelzero);
            recordingtype = 'HasHayFeverRecording';
            [bephysdata, bephysdata_deleted] = addBreatheRowsForMeasure(bephysdata, bephysdata_deleted, measdata, filetype, recordingtype, dontdelzero);

        otherwise
            fprintf('*** Unknown file type %s ***\n', filetype)
    end

    toc
    fprintf('\n');
end

bephysdata_original = bephysdata;
fprintf('BronchEx data has %d rows\n', size(bephysdata, 1));
fprintf('\n');

% set study offset 
minmdate = min(bephysdata.Date_TimeRecorded);
beoffset = datenum(datetime(year(minmdate), month(minmdate), day(minmdate)));
bephysdata.DateNum = ceil(datenum(datetime(bephysdata.Date_TimeRecorded)+seconds(1)) - beoffset);

% calc and print overall data demographics before data anomaly fixes
printDataDemographics(bephysdata, 0);
fprintf('\n');

[bephysdata, bephysdata_deleted] = correctBreatheDataAnomalies(bephysdata, bephysdata_deleted);

% sort measurement data
bephysdata = sortrows(bephysdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');

printDataDemographics(bephysdata, 0);

plotMeasuresByHour(bephysdata, 0, sprintf('%s - Measures By Hour Histograms', study), study);

bephysdata_predupehandling = bephysdata;

% generate data demographics by patient
generateDataDemographicsByPatientFn(bephysdata, bePatient, study);

% handle duplicates
doupdates = true;
detaillog = false;
bephysdata = handleBreatheDuplicateMeasures(bephysdata, study, doupdates, detaillog);

% calc and print overall data demographics after data anomaly fixes
printDataDemographics(bephysdata, 0);

% populate ScaledDateNum with the days from first measurement (by patient)
bephysdata = scaleDaysByPatient(bephysdata, doupdates);

bephysdata_predateoutlierhandling = bephysdata;

createMeasuresHeatmapWithStudyPeriod(bephysdata, beoffset, bePatient, study);

% calc and print overall data demographics after data anomaly fixes
%printDataDemographics(brphysdata, 0);

% generate data demographics by patient
generateDataDemographicsByPatientFn(bephysdata, bePatient, study);

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
fprintf('Saving output variables to file %s\n', measmatfilename);
save(fullfile(basedir, subfolder, measmatfilename), 'bephysdata', 'beoffset', 'bephysdata_deleted', ...
    'bephysdata_original', 'bephysdata_predupehandling', 'bephysdata_predateoutlierhandling');

subfolder = 'ExcelFiles';

delrowfilename = 'BronchExDeletedMeasurementData.xlsx';

writetable(bephysdata_deleted(~ismember(bephysdata_deleted.Reason, {'NULL Measurement'}),:), fullfile(basedir, subfolder, delrowfilename));
toc
