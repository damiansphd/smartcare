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
subfolder = 'DataFiles/ProjectClimb';


physdata = createClimbMeasuresTable(0);

% create list of measures/measures files
% create measures table
% loop over each measure file
%   load file and add rows to physdata table
%   remember to use different columns for date/time for canada hospitals
% endloop
% remove duplicates
% look for data anomalies
% populate scaled days by patient in the measures file
% remove patients with insufficient duration or measures (or sparsity of
% measures)

% load patient id file + corrections
patientid = loadAndCorrectPatientIDData(fullfile(basedir, subfolder, patientidfile));

% load SmartCare measurement data + corrections
[physdata, physdata_original, offset] = loadAndCorrectSmartCareData(fullfile(basedir, subfolder, scdatafile), patientid, detaillog);

% calc and print overall data demographics before data anomaly fixes
printDataDemographics(physdata,0);

physdata = correctSmartCareDataAnomalies(physdata);

physdata = addCalculatedFEV1percentage(physdata, cdPatient);

% calc and print overall data demographics after data anomaly fixes
printDataDemographics(physdata,0);

tic
%sort patientid and physdata tables
patientid = sortrows(patientid,'SmartCareID','ascend');
physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');

% plot histograms of numher of measures recorded by hour for each
% measurement
plotMeasuresByHour(physdata, 0, 'measuresbyhourhistograms');

% analyse overnight measures (activity and non-activity)
% update DateNum to prior day for logic contained within the function
% (following analysis performed)
physdata = analyseOvernightMeasures(physdata,0, doupdates, detaillog);

physdata_predupehandling = physdata;

% generate data demographics by patient
generateDataDemographicsByPatientFn(physdata, cdPatient, study);

% handle duplicates
physdata = handleDuplicateMeasures(physdata, doupdates, detaillog);

% calc and print overall data demographics after data anomaly fixes
printDataDemographics(physdata,0);

% populate ScaledDateNum with the days from first measurement (by patient)
physdata = scaleDaysByPatient(physdata, doupdates);

physdata_predateoutlierhandling = physdata;

% analyse measurement date outliers and handle as appropriate
physdata = analyseAndHandleDateOutliers(physdata, doupdates);

createMeasuresHeatmapWithStudyPeriod(physdata, offset, cdPatient);

% calc and print overall data demographics after data anomaly fixes
printDataDemographics(physdata,0);

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = 'smartcaredata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder, outputfilename), 'patientid', 'physdata', 'offset','physdata_original', 'physdata_predupehandling', 'physdata_predateoutlierhandling');
toc
