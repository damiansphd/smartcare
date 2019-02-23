clc; clear; close all;

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'telemedclinicaldata.mat';
scmatfile = 'telemeddata.mat';

fprintf('Loading Clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading TeleMed measurement data\n');
load(fullfile(basedir, subfolder, scmatfile));
toc

tic
% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(tmphysdata);

% extract clinical FEV1 measures and join with offsets to keep only those patients who
% have enough data (ie the patients left after outlier date handling
pclinicalfev = sortrows(tmPFT(:,{'ID', 'LungFunctionDate', 'FEV1_'}), {'ID', 'LungFunctionDate'}, 'ascend');
pclinicalfev.Properties.VariableNames{'ID'} = 'SmartCareID';
pclinicalfev = innerjoin(pclinicalfev, patientoffsets);

% create a scaleddatenum to translate the study date to the same normalised
% scale as measurement data scaled date num
pclinicalfev.ScaledDateNum = datenum(pclinicalfev.LungFunctionDate) - tmoffset - pclinicalfev.PatientOffset + 1;

% extract study date and join with offsets to keep only those patients who
% have enough data (ie the patients left after outlier date handling
pstudydate = sortrows(tmPatient(:,{'ID', 'Hospital', 'StudyDate'}), 'ID', 'ascend');
pstudydate.Properties.VariableNames{'ID'} = 'SmartCareID';
pstudydate = innerjoin(patientoffsets, pstudydate);

% create a scaleddatenum to translate the study date to the same normalised
% scale as measurement data scaled date num
pstudydate.ScaledDateNum = round(datenum(pstudydate.StudyDate) - tmoffset - pstudydate.PatientOffset);


% extract just the weight measures from smartcare data
pmeasuresfev = tmphysdata(ismember(tmphysdata.RecordingType,'LungFunctionRecording'),{'SmartCareID', 'ScaledDateNum', 'FEV1_'});

% store min and max to scale x-axis of plot display. Set min to -5 if less
% than, to avoid wasting plot space for the one patient with a larger delay
% between study date and active measurement period
mindays = min([pmeasuresfev.ScaledDateNum ; pstudydate.ScaledDateNum]);
if mindays < -5
    mindays = -5;
end
maxdays = max([pmeasuresfev.ScaledDateNum ; pstudydate.ScaledDateNum + 183]);

plotsacross = 2;
plotsdown = 4;
plotsperpage = plotsacross * plotsdown;
basedir = setBaseDir();
subfolder = 'Plots';
toc

%tic
% create plots for patients with differences home vs clinical
%fprintf('FEV Plots for diff values home vs clinical\n');
%patientlist = [1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 ; 10 ; 11 ; 12 ; 13 ; 14 ; 15];
%filenameprefix = 'TeleMed - ClinicalVsHomeFEV1 - Different Values';
%figurearray = createAndSaveFEVPlots(patientlist, pmeasuresfev, pclinicalfev, pstudydate, ...
%    mindays, maxdays, plotsacross, plotsdown, plotsperpage, basedir, subfolder, filenameprefix);
%close all;
%toc

tic
% create plots for potential anomalous clinical FEV1 measures identified
fprintf('FEV Plots for potential anomalous clinical measures\n');
patientlist = [4 ; 10 ; 12];
plotsacross = 1;
plotsdown = 3;
plotsperpage = 3;
filenameprefix = 'TeleMed - ClinicalVsHomeFEV1 - Outlier Clinical Values';
figurearray = createAndSaveFEVPlots(patientlist, pmeasuresfev, pclinicalfev, pstudydate, ...
    mindays, maxdays, plotsacross, plotsdown, plotsperpage, basedir, subfolder, filenameprefix);
close all;
toc
tic
fprintf('FEV Plots for all patients\n');
patientlist = unique(pmeasuresfev.SmartCareID);
filenameprefix = 'TeleMed - ClinicalVsHomeFEV1';
figurearray = createAndSaveFEVPlots(patientlist, pmeasuresfev, pclinicalfev, pstudydate, ...
    mindays, maxdays, plotsacross, plotsdown, plotsperpage, basedir, subfolder, filenameprefix);
close all;
toc
