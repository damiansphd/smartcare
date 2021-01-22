clear; clc; close all;

study = 'BR';
chosentreatgap = 1;
smode = input('Run for 1) all patients on study for > 6 months or 2) exclude CFTR modulator therapy start during analysis period ? ', 's');

mode = str2double(smode);

if (isnan(mode) || mode < 1 || mode > 2)
    fprintf('Invalid choice\n');
    return;
elseif mode == 1
    modetext = 'All Patients';
elseif mode == 2
    modetext = 'Excl CFTR Patients';
end

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
[datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
[physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[brPatient, brDrugTherapy, ~, brAntibiotics, brAdmissions, brPFT, brCRP, ...
    brClinicVisits, brOtherVisits, ~, brHghtWght, ~, ~, brUnplannedContact] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);

tic
ivandmeasuresfile = sprintf('%sivandmeasures_gap%d.mat', study, chosentreatgap);
fprintf('Loading iv treatment and measures prior data\n');
load(fullfile(basedir, subfolder, ivandmeasuresfile));
toc

% set various parameters
plotsubfolder = sprintf('Plots/%s/BR Interim Checkpoint/%s', study, modetext);
if ~exist(fullfile(basedir, plotsubfolder), 'dir')
    mkdir(fullfile(basedir, plotsubfolder));
end
cutoffd = datetime(2020, 3, 15);
%cutoffd = datetime(2020, 11, 30); % cutoff date is last date the data was processed
mintwindow = 6; % minimum time window for analysis
clintw  = 3;
hmtw    = 3;
ntypes  = 15;

% set up result tables
brIntChkptSum = table('Size',[ntypes 7], ...
    'VariableTypes', {'cell',     'double', 'double',      'double',        'double',      'double',        'double'}, ...
    'VariableNames', {'DataType', 'n',      'Period1Mean', 'Period1StdErr', 'Period2Mean', 'Period2StdErr', 'pVal'});

brPrePostPat   = brPatient;
[brPrePostPat] = filterPrePostByStudyStart(brPrePostPat, mintwindow, cutoffd);
brPrePostDT    = brDrugTherapy(ismember(brDrugTherapy.ID, brPrePostPat.ID), :);

if mode == 2
    [brPrePostPat, brPrePostDT] = filterPrePostByDrugTherapy(brPrePostPat, brPrePostDT, mintwindow);
end

% set up various input tables in a standardised way
tmpClinFEV = brPFT;
tmpClinFEV.Properties.VariableNames({'LungFunctionDate'}) = {'Date'};
tmpClinFEV.Properties.VariableNames({'FEV1'}) = {'Amount'};
tmpClinFEV.DateNum = datenum(tmpClinFEV.Date) - offset;

tmpHomeFEV = physdata(ismember(physdata.RecordingType, {'FEV1Recording'}), {'SmartCareID', 'Date_TimeRecorded', 'DateNum', 'FEV'});
tmpHomeFEV.Properties.VariableNames({'SmartCareID'}) = {'ID'};
tmpHomeFEV.Properties.VariableNames({'Date_TimeRecorded'}) = {'Date'};
tmpHomeFEV.Properties.VariableNames({'FEV'}) = {'Amount'};

tmpClinWght = brHghtWght;
tmpClinWght.Properties.VariableNames({'MeasDate'}) = {'Date'};
tmpClinWght.Properties.VariableNames({'Weight'}) = {'Amount'};
tmpClinWght.DateNum = datenum(tmpClinWght.Date) - offset;

tmpHomeWght = physdata(ismember(physdata.RecordingType, {'WeightRecording'}), {'SmartCareID', 'Date_TimeRecorded', 'DateNum', 'WeightInKg'});
tmpHomeWght.Properties.VariableNames({'SmartCareID'}) = {'ID'};
tmpHomeWght.Properties.VariableNames({'Date_TimeRecorded'}) = {'Date'};
tmpHomeWght.Properties.VariableNames({'WeightInKg'}) = {'Amount'};

tmpIVs = ivandmeasurestable(~ismember(ivandmeasurestable.Route, {'Oral'}), {'SmartCareID', 'IVStartDate', 'IVDateNum', 'IVStopDate', 'IVStopDateNum'});
tmpIVs.Properties.VariableNames({'SmartCareID'})   = {'ID'};
tmpIVs.Properties.VariableNames({'IVStartDate'})   = {'StartDate'};
tmpIVs.Properties.VariableNames({'IVStopDate'})    = {'StopDate'};
tmpIVs.Properties.VariableNames({'IVDateNum'})     = {'StartDateNum'};
tmpIVs.Properties.VariableNames({'IVStopDateNum'}) = {'StopDateNum'};
tmpIVs(~ismember(tmpIVs.ID, brPrePostPat.ID), :) = [];

tmpEmergCont = brUnplannedContact;
tmpEmergCont.Properties.VariableNames({'ContactDate'}) = {'Date'};
tmpEmergCont(~ismember(tmpEmergCont.ID, brPrePostPat.ID), :) = [];

type = 1;

% 1) FEV1 decline using clinical pre and clinical during, best per 3months
meastype = 'FEV1';
bestwind = 3;
gradtype = sprintf('Best%dm', bestwind);
period1  = 'Pre';
period2  = 'Dur';
comptype = 'CvC';
twindow  = 12;
[brPrePostPat, brIntChkptSum] = plotPointsWithLFitLoop(brPrePostPat, brIntChkptSum, ...
    tmpClinFEV, tmpClinFEV, brAntibiotics, study, meastype, bestwind, gradtype, comptype, period1, period2, twindow, type, cutoffd, plotsubfolder, offset);

% 2) FEV1 decline using clinical pre and home during, best per 3months
meastype = 'FEV1';
bestwind = 3;
gradtype = sprintf('Best%dm', bestwind);
period1  = 'Pre';
period2  = 'Dur';
comptype = 'CvH';
twindow  = 12;
type     = type + 1;
[brPrePostPat, brIntChkptSum] = plotPointsWithLFitLoop(brPrePostPat, brIntChkptSum, ...
    tmpClinFEV, tmpHomeFEV, brAntibiotics, study, meastype, bestwind, gradtype, comptype, period1, period2, twindow, type, cutoffd, plotsubfolder, offset);

% 3) Weight decline using clinical pre and home during, best per 3months
%meastype = 'Weight';
%bestwind = 3;
%gradtype = sprintf('Best%dm', bestwind);
%period1  = 'Pre';
%period2  = 'Dur';
%comptype = 'CvH';
%twindow  = 6;
%type     = type + 1;
%[brIntChkptPat, brIntChkptSum] = plotPointsWithLFitLoop(brIntChkptPat, brIntChkptSum, ...
%    tmpClinWght, tmpHomeWght, brAntibiotics, study, meastype, bestwind, gradtype, comptype, period1, period2, twindow, type, cutoffd, plotsubfolder, offset);

% 4) Weight decline using clinical pre and home during, best per 2months
meastype = 'Weight';
bestwind = 2;
gradtype = sprintf('Best%dm', bestwind);
period1  = 'Pre';
period2  = 'Dur';
comptype = 'CvH';
twindow  = 6;
type     = type + 1;
[brPrePostPat, brIntChkptSum] = plotPointsWithLFitLoop(brPrePostPat, brIntChkptSum, ...
    tmpClinWght, tmpHomeWght, brAntibiotics, study, meastype, bestwind, gradtype, comptype, period1, period2, twindow, type, cutoffd, plotsubfolder, offset);

% 5) Weight decline using clinical pre and home during, best per 1month
meastype = 'Weight';
bestwind = 1;
gradtype = sprintf('Best%dm', bestwind);
period1  = 'Pre';
period2  = 'Dur';
comptype = 'CvH';
twindow  = 6;
type     = type + 1;
[brPrePostPat, brIntChkptSum] = plotPointsWithLFitLoop(brPrePostPat, brIntChkptSum, ...
    tmpClinWght, tmpHomeWght, brAntibiotics, study, meastype, bestwind, gradtype, comptype, period1, period2, twindow, type, cutoffd, plotsubfolder, offset);

% 6) Nbr days on IV Treatments pre vs during 12 months
%meastype = 'IVDays';
%period1  = 'Pre';
%period2  = 'Dur';
%twindow  = 12;
%type     = type + 1;
%[brIntChkptPat, brIntChkptSum] = calcDaysInPeriodWithHistogram(brIntChkptPat, brIntChkptSum, ...
%    tmpIVs, study, meastype, period1, period2, twindow, type, cutoffd, plotsubfolder);

% 7) Nbr days on IV Treatments pre vs during 6  months
meastype = 'IVDays';
period1  = 'Pre';
period2  = 'Dur';
twindow  = 6;
type     = type + 1;
[brPrePostPat, brIntChkptSum] = calcDaysInPeriodWithHistogram(brPrePostPat, brIntChkptSum, ...
    tmpIVs, study, meastype, period1, period2, twindow, type, cutoffd, plotsubfolder);

% 8) Nbr emergency contacts pre vs during 12  months
%meastype = 'EmergCont';
%period1  = 'Pre';
%period2  = 'Dur';
%twindow  = 12;
%type     = type + 1;
%[brIntChkptPat, brIntChkptSum] = calcDaysInPeriodWithHistogram(brIntChkptPat, brIntChkptSum, ...
%    tmpEmergCont, study, meastype, period1, period2, twindow, type, cutoffd, plotsubfolder);

% 9) Nbr emergency contacts pre vs during 6 mpnths
meastype = 'EmergCont';
period1  = 'Pre';
period2  = 'Dur';
twindow  = 6;
type     = type + 1;
[brPrePostPat, brIntChkptSum] = calcDaysInPeriodWithHistogram(brPrePostPat, brIntChkptSum, ...
    tmpEmergCont, study, meastype, period1, period2, twindow, type, cutoffd, plotsubfolder);

for i = 1:type
    fprintf('%24s: n=%2d Pre Study %+2.5f +/- %2.5f : During Study %+2.5f +/- %2.5f : p-Val %.3f\n', ...
                                                            brIntChkptSum.DataType{i}, brIntChkptSum.n(i),...
                                                            brIntChkptSum.Period1Mean(i), brIntChkptSum.Period1StdErr(i), ...
                                                            brIntChkptSum.Period2Mean(i), brIntChkptSum.Period2StdErr(i), ...
                                                            brIntChkptSum.pVal(i));
end

% now use pre/post gradients to project a hypothetical gain/loss in lung
% function (and/or weight) at 12m after study start
brPrePostPat.StudyBenFEV1(:)    = 0;
brPrePostPat.StudyBenFEV1Pct(:) = 0;

exidx = brPrePostPat.FEV1Best3mCvHPre == 0 | brPrePostPat.FEV1Best3mCvHDur == 0;

brPrePostPat.StudyBenFEV1(~exidx) = (365 * (brPrePostPat.FEV1Best3mCvHDur(~exidx) - brPrePostPat.FEV1Best3mCvHPre(~exidx)));
brPrePostPat.StudyBenFEV1Pct(~exidx) = brPrePostPat.StudyBenFEV1(~exidx) ./ brPrePostPat.FEV1Best3mCvHStudyDateVal(~exidx);

AvgStudyBenFEV1L = sum(brPrePostPat.StudyBenFEV1(~exidx)) / sum(~exidx);
AvgStudyBenFEV1Pct = AvgStudyBenFEV1L / mean(brPrePostPat.FEV1Best3mCvHStudyDateVal(~exidx));
    
fprintf('Average 12month FEV1 benefit from Study = %.0fml (%.1f%%)\n', 1000 * AvgStudyBenFEV1L, 100 * AvgStudyBenFEV1Pct);

