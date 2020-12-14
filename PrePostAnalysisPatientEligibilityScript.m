clear; clc; close all;

study = 'BR';
chosentreatgap = 10;

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

cutoffd = datetime(2020, 11, 30); % cutoff date is last date the data was processed

mintwindow = 6; % minimum time window for analysis

brPrePostPat = brPatient;
ntotpats = size(brPrePostPat, 1);

fprintf('Asof %s: Total patients in Project Breathe                        = %d\n', datestr(cutoffd, 1), ntotpats);
[brPrePostPat] = filterPrePostByStudyStart(brPrePostPat, mintwindow);
ndatepats = size(brPrePostPat, 1);
brPrePostDT    = brDrugTherapy(ismember(brDrugTherapy.ID, brPrePostPat.ID), :);

fprintf('Subtract patients with study date < 6 months from %s              = %d\n', datestr(cutoffd, 1), ntotpats - ndatepats);
fprintf('Asof %s: Leaving                                                  = %d\n', datestr(cutoffd, 1), ndatepats);

brPrePostPat = outerjoin(brPrePostPat, brPrePostDT, 'LeftKeys', {'ID'}, 'RightKeys', {'ID'}, 'RightVariables', {'DrugTherapyStartDate', 'DrugTherapyType', 'DrugTherapyComment'});

notreatmentid = unique(brPrePostPat.ID(isnat(brPrePostPat.DrugTherapyStartDate)));
nnotreatpats = size(notreatmentid, 1);
fprintf('Asof %s: Total patients not on treatment                          = %d    ***\n', datestr(cutoffd, 1), nnotreatpats);

ontreatmentid = unique(brPrePostPat.ID(~ismember(brPrePostPat.ID, notreatmentid)));
nontreatpats = size(ontreatmentid, 1);
fprintf('Asof %s: Total patients on treatment                              = %d\n', datestr(cutoffd, 1), nontreatpats);

minduration = 6;

excl6mid = unique(brPrePostPat.ID((brPrePostPat.DrugTherapyStartDate >= (brPrePostPat.StudyDate - calmonths(minduration))) ...
                & (brPrePostPat.DrugTherapyStartDate < (brPrePostPat.StudyDate + calmonths(minduration)))));
nexcl6mpats = size(excl6mid, 1);
fprintf('Asof %s: Of which, started/changed within +/-%2dm of study date    = %d\n', datestr(cutoffd, 1), minduration, nexcl6mpats);

ontreatpre6mnochangeid = unique(brPrePostPat.ID(~ismember(brPrePostPat.ID, excl6mid) ...
                & (brPrePostPat.DrugTherapyStartDate < (brPrePostPat.StudyDate - calmonths(minduration)))));
nontreatpre6mnochange = size(ontreatpre6mnochangeid, 1);
fprintf('Asof %s: Of which, started earlier than %2dm pre study date        = %d    ***\n', datestr(cutoffd, 1), minduration, nontreatpre6mnochange);

ontreatpost6mnochangeid = unique(brPrePostPat.ID(~ismember(brPrePostPat.ID, excl6mid) ...
                & ~ismember(brPrePostPat.ID, ontreatpre6mnochangeid) ...
                & (brPrePostPat.DrugTherapyStartDate >= (brPrePostPat.StudyDate + calmonths(minduration)))));
nontreatpost6mnochange = size(ontreatpost6mnochangeid, 1);
fprintf('Asof %s: Of which, started/changed later than %2dm post study date = %d    ***\n', datestr(cutoffd, 1), minduration, nontreatpost6mnochange);

fprintf('\n');
fprintf('Asof %s: Total eligibile patients using +/-%2dm criterion          = %d    ***\n', datestr(cutoffd, 1), minduration, nnotreatpats + nontreatpre6mnochange + nontreatpost6mnochange);

fprintf('\n');

minduration = 12;

excl12mid = unique(brPrePostPat.ID((brPrePostPat.DrugTherapyStartDate >= (brPrePostPat.StudyDate - calmonths(minduration))) ...
                & (brPrePostPat.DrugTherapyStartDate < (brPrePostPat.StudyDate + calmonths(minduration)))));
nexcl12mpats = size(excl12mid, 1);
fprintf('Asof %s: Of which, started/changed within +/-%2dm of study date    = %d\n', datestr(cutoffd, 1), minduration, nexcl12mpats);

ontreatpre12mnochangeid = unique(brPrePostPat.ID(~ismember(brPrePostPat.ID, excl12mid) ...
                & (brPrePostPat.DrugTherapyStartDate < (brPrePostPat.StudyDate - calmonths(minduration)))));
nontreatpre12mnochange = size(ontreatpre12mnochangeid, 1);
fprintf('Asof %s: Of which, started earlier than %2dm pre study date        = %d    ***\n', datestr(cutoffd, 1), minduration, nontreatpre12mnochange);

ontreatpost12mnochangeid = unique(brPrePostPat.ID(~ismember(brPrePostPat.ID, excl12mid) ...
                & ~ismember(brPrePostPat.ID, ontreatpre12mnochangeid) ...
                & (brPrePostPat.DrugTherapyStartDate >= (brPrePostPat.StudyDate + calmonths(minduration)))));
nontreatpost12mnochange = size(ontreatpost12mnochangeid, 1);
fprintf('Asof %s: Of which, started/changed later than %2dm post study date = %d    ***\n', datestr(cutoffd, 1), minduration, nontreatpost12mnochange);

fprintf('\n');
fprintf('Asof %s: Total eligibile patients using +/-%2dm criterion          = %d    ***\n', datestr(cutoffd, 1), minduration, nnotreatpats + nontreatpre12mnochange + nontreatpost12mnochange);

