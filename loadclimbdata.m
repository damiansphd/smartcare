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
subfolder = 'DataFiles/ProjectClimb/MeasurementData';

clphysdata = createClimbMeasuresTable(0);
%rowtoadd   = createClimbMeasuresTable(1);

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

for i = 1:nmeasfile
    tic
    fprintf('Processing %2d: %s\n', i, MeasFiles{i});
    mfopts = detectImportOptions(fullfile(basedir, subfolder, MeasFiles{i}), 'Sheet', measdatasheetname);
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'StartDate', 'EndDate', 'DateRecorded', 'CorrectedCanadaDate'})) = {'datetime'};
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'TimeRecorded', 'CorrectedCanadaTime'})) = {'datetime'};
    mfopts.VariableTypes(:, ismember(mfopts.VariableNames, {'BreathsPerMinute', 'FEV1', 'NumberOfDisturbances', 'O2Saturation', 'Pulse_BPM_', 'Rating', 'Temp_degC_'})) = {'double'};
    
    tmpmeasdata = readtable(fullfile(basedir, subfolder, MeasFiles{i}), mfopts, 'Sheet', measdatasheetname);
    nmeasurements = size(tmpmeasdata, 1);
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
    canidx = ismember(extractBefore(tmpmeasdata.UserID,4), {'IWK', 'LON'});
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
    clphysdata = [clphysdata; mclphysdata(~nullidx,:)];
    fprintf('%5d Raw Measurements, %5d Non-null measurements\n', nmeasurements, nonnullmeasurements);
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
toc
fprintf('\n');

% followed up with Claire re the 28 missing users - ALD016 + RBH031-068

% remove blank/zero values
idx1 = ismember(clphysdata.RecordingType, {'AppetiteRecording', 'BreathlessnessRecording', 'CoughRecording','SleepActivityRecording', 'SputumVolumeRecording', 'TirednessRecording', 'WellnessRecording'});
idx2 = isnan(clphysdata.Rating);
idx = idx1 & idx2;
fprintf('Removing %4d blank Rating measurements\n', sum(idx));
clphysdata(idx,:) = [];

idx1 = ismember(clphysdata.RecordingType, {'LungFunctionRecording'});
idx2 = isnan(clphysdata.CalcFEV1_);
idx = idx1 & idx2;
fprintf('Removing %4d blank FEV1 measurements\n', sum(idx));
clphysdata(idx,:) = [];

idx1 = ismember(clphysdata.RecordingType, {'O2SaturationRecording'});
idx2 = isnan(clphysdata.O2Saturation);
idx = idx1 & idx2;
fprintf('Removing %4d blank O2 Saturation measurements\n', sum(idx));
clphysdata(idx,:) = [];

idx1 = ismember(clphysdata.RecordingType, {'PulseRateRecording'});
idx2 = isnan(clphysdata.Pulse_BPM_);
idx = idx1 & idx2;
fprintf('Removing %4d blank Pulse Rate measurements\n', sum(idx));
clphysdata(idx,:) = [];

idx1 = ismember(clphysdata.RecordingType, {'RespiratoryRateRecording'});
idx2 = isnan(clphysdata.BreathsPerMin);
idx = idx1 & idx2;
fprintf('Removing %4d blank Resp Rate measurements\n', sum(idx));
clphysdata(idx,:) = [];

idx1 = ismember(clphysdata.RecordingType, {'SleepDisturbanceRecording'});
idx2 = isnan(clphysdata.NumSleepDisturb);
idx = idx1 & idx2;
fprintf('Removing %4d blank Sleep Disturb measurements\n', sum(idx));
clphysdata(idx,:) = [];

idx1 = ismember(clphysdata.RecordingType, {'TemperatureRecording'});
idx2 = isnan(clphysdata.Temp_degC_);
idx = idx1 & idx2;
fprintf('Removing %4d blank Temperature measurements\n', sum(idx));
clphysdata(idx,:) = [];

% update sputum colour to be lower case to ensure consistency and rename
% recording type to be english spelling
idx = ismember(clphysdata.RecordingType, {'SputumColorRecording'});
clphysdata.SputumColour(idx) = lower(clphysdata.SputumColour(idx));
clphysdata.RecordingType(idx) = {'SputumColourRecording'};
fprintf('Updating %4d Sputum Colour to be lower case and making recording type english spelling\n', sum(idx));



% calc and print overall data demographics before data anomaly fixes
printDataDemographics(clphysdata,0);

% remove duplicates
% look for data anomalies
% populate scaled days by patient in the measures file
% remove patients with insufficient duration or measures (or sparsity of
% measures)

clphysdata = correctClimbDataAnomalies(clphysdata);

% sort measurement data
clphysdata = sortrows(clphysdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');

printDataDemographics(clphysdata,0);

plotMeasuresByHour(physdata, 0, 'measuresbyhourhistograms');

physdata = analyseOvernightMeasures(physdata,0, doupdates, detaillog);


% plot histograms of numher of measures recorded by hour for each
% measurement
%plotMeasuresByHour(physdata, 0, 'measuresbyhourhistograms');

% analyse overnight measures (activity and non-activity)
% update DateNum to prior day for logic contained within the function
% (following analysis performed)
%physdata = analyseOvernightMeasures(physdata,0, doupdates, detaillog);

%physdata_predupehandling = physdata;

% generate data demographics by patient
%generateDataDemographicsByPatientFn(physdata, cdPatient, study);

% handle duplicates
%physdata = handleDuplicateMeasures(physdata, doupdates, detaillog);

% calc and print overall data demographics after data anomaly fixes
%printDataDemographics(physdata,0);

% populate ScaledDateNum with the days from first measurement (by patient)
%physdata = scaleDaysByPatient(physdata, doupdates);

%physdata_predateoutlierhandling = physdata;

% analyse measurement date outliers and handle as appropriate
%physdata = analyseAndHandleDateOutliers(physdata, doupdates);

%createMeasuresHeatmapWithStudyPeriod(physdata, offset, cdPatient);

% calc and print overall data demographics after data anomaly fixes
%printDataDemographics(physdata,0);

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = 'climbdata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
%save(fullfile(basedir, subfolder, outputfilename), 'clphysdata', 'cloffset','clphysdata_original', 'clphysdata_predupehandling', 'clphysdata_predateoutlierhandling');
save(fullfile(basedir, subfolder, outputfilename), 'clphysdata', 'cloffset');
toc
