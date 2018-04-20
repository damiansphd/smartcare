clear; clc; close all;

scdatafile = 'mydata.csv';
patientidfile = 'patientid.xlsx';
detaillog = false;
doupdates = true;

% load patient id file + corrections
patientid = loadAndCorrectPatientIDData(patientidfile);


% load SmartCare measurement data + corrections
[physdata, physdata_original, offset] = loadAndCorrectSmartCareData(scdatafile, patientid, detaillog);

% calc and print overall data demographics before data anomaly fixes
printDataDemographics(physdata,0);

physdata = correctSmartCareDataAnomalies(physdata);

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

% handle duplicates
physdata = handleDuplicateMeasures(physdata, doupdates, detaillog);

% calc and print overall data demographics after data anomaly fixes
printDataDemographics(physdata,0);

% populate ScaledDateNum with the days from first measurement (by patient)
physdata = scaleDaysByPatient(physdata, doupdates);

physdata_predateoutlierhandling = physdata;

% analyse measurement date outliers and handle as appropriate
physdata = analyseAndHandleDateOutliers(physdata, doupdates);

tic
fprintf('Loading Clinical data\n');
load('clinicaldata.mat');
toc

createMeasuresHeatmapWithStudyPeriod(physdata, offset, cdPatient);

% calc and print overall data demographics after data anomaly fixes
printDataDemographics(physdata,0);

tic
outputfilename = 'smartcaredata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(outputfilename, 'patientid', 'physdata', 'offset','physdata_original', 'physdata_predupehandling', 'physdata_predateoutlierhandling');
toc
