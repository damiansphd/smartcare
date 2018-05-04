clc; clear; close all;

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'clinicaldata.mat';
scmatfile = 'smartcaredata.mat';

fprintf('Loading Clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading SmartCare measurement data\n');
load(fullfile(basedir, subfolder, scmatfile));
toc

tic
basedir = './';
subfolder = 'Plots';
filenameprefix = 'ClinicalVsHomeWeight';

% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(physdata);

% extract study date and join with offsets to keep only those patients who
% have enough data (ie the patients left after outlier date handling
pstudydateweight = sortrows(cdPatient(:,{'ID', 'Hospital', 'StudyDate', 'Weight'}), 'ID', 'ascend');
pstudydateweight.Properties.VariableNames{'ID'} = 'SmartCareID';
pstudydateweight = innerjoin(patientoffsets, pstudydateweight);

% create a scaleddatenum to translate the study date to the same normalised
% scale as measurement data scaled date num
pstudydateweight.ScaledDateNum = datenum(pstudydateweight.StudyDate) - offset - pstudydateweight.PatientOffset + 1;

% extract just the weight measures from smartcare data
pmeasuresweight = physdata(ismember(physdata.RecordingType,'WeightRecording'),{'SmartCareID', 'ScaledDateNum', 'WeightInKg'});

% store min and max to scale x-axis of plot display
mindays = min([pmeasuresweight.ScaledDateNum ; pstudydateweight.ScaledDateNum]);
if mindays < -5
    mindays = -5;
end
maxdays = max([pmeasuresweight.ScaledDateNum ; pstudydateweight.ScaledDateNum + 183]);

% loop over all patients, create a plot for each of home weight measurements
% with the clinical weight overlaid as a horizontal line
% six plots per page

plotsacross = 2;
plotsdown = 4;
plotsperpage = plotsacross * plotsdown;
toc

tic
fprintf('Weight Plots for anomalous clinical weight measures\n');
filenameprefix = 'ClinicalVsHomeWeight - Clinical Anomalies';
figurearray = createAndSaveWeightPlots(pmeasuresweight, pstudydateweight(ismember(pstudydateweight.SmartCareID, [61,178,193,195,196,197,198,199,201]),:), ...
    mindays, maxdays, plotsacross, plotsdown, plotsperpage, basedir, subfolder, filenameprefix);
close all;
toc
tic
fprintf('Weight Plots for anomalous home weight measures\n');
filenameprefix = 'ClinicalVsHomeWeight - Home Anomalies';
figurearray = createAndSaveWeightPlots(pmeasuresweight, pstudydateweight(ismember(pstudydateweight.SmartCareID, [30, 35, 62, 80, 99. 100, 102, 134, 216, 241]),:), ...
    mindays, maxdays, plotsacross, plotsdown, plotsperpage, basedir, subfolder, filenameprefix);
close all;
toc
tic
fprintf('Weight Plots for all patients\n');
filenameprefix = 'ClinicalVsHomeWeight';
figurearray = createAndSaveWeightPlots(pmeasuresweight, pstudydateweight, ...
    mindays, maxdays, plotsacross, plotsdown, plotsperpage, basedir, subfolder, filenameprefix);
close all;
toc

