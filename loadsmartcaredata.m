clear; clc; close all;

scdatafile = 'mydata.csv';
patientidfile = 'patientid.xlsx';
detaillog = false;
doupdates = true;

% load patient id file + corrections
patientid = loadAndCorrectPatientIDData(patientidfile);

% load SmartCare measurement data + corrections
[physdata, physdata1_original] = loadAndCorrectSmartCareData(scdatafile, patientid);

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
 
physdata = handleDuplicateMeasures(physdata,0,doupdates, detaillog);

% calc and print overall data demographics after data anomaly fixes
printDataDemographics(physdata,0);

tic
outputfilename = 'smartcaredata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(outputfilename, 'physdata', 'physdata1_original', 'patientid');
toc

%tunique = unique(t(:,{'DateNum','RecordingType','SmartCareID'}));
%number = zeros(size(tunique,1),2);
%number = array2table(number);
%number.Properties.VariableNames{1} = 'Total';
%number.Properties.VariableNames{2} = 'Count';
%tunique = [tunique number];



%patientlist = unique(patientid.SmartCareID(:));
%for i = 1:size(patientlist,1)
%    scid = patientlist(i);
%   
%end


