clear; close all; clc;

% load relevant data
[studynbr, study, studyfullname] = selectStudy();
chosentreatgap = selectTreatmentGap();

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
[datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
[physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);

tic
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, demographicsmatfile));
toc

tic
ivandmeasuresfile = sprintf('%sivandmeasures_gap%d.mat', study, chosentreatgap);
fprintf('Loading iv treatment and measures prior data\n');
load(fullfile(basedir, subfolder, ivandmeasuresfile));
toc


% calcuate clinical pft baseline info
temp = cdPFT(:,{'ID', 'FEV1'});
temp2 = varfun(@mean, temp, 'GroupingVariables', {'ID'});
temp3 = outerjoin(cdPatient, temp2, 'LeftKeys', 'ID', 'RightKeys', 'ID', 'RightVariables', {'GroupCount', 'mean_FEV1'});
%temp3.PercentPredicted = 100 * (temp3.mean_FEV1 ./temp3.CalcPredictedFEV1);
temp3.PercentPredicted = 100 * (temp3.mean_FEV1 ./temp3.CalcFEV1SetAs);

fprintf('Total patients                 = %3d\n', size(cdPatient, 1));
fprintf('Patients with no clinical PFTs = %3d ******\n', sum(isnan(temp3.PercentPredicted)));
fprintf('Updating %3d patients with home PFTs\n', sum(isnan(temp3.PercentPredicted)));
temp3.PercentPredicted(isnan(temp3.PercentPredicted)) = demographicstable.Fun_FEV1_(ismember(demographicstable.RecordingType, {'LungFunctionRecording'}) & ismember(demographicstable.SmartCareID, temp3.ID(isnan(temp3.PercentPredicted))),1);

fprintf('Patients with clinical PFTs    = %3d\n', sum(~isnan(temp3.PercentPredicted)));
fprintf('# patients < 40                = %3d (%.0f)\n', sum(temp3.PercentPredicted < 40), 100 * sum(temp3.PercentPredicted < 40) / size(cdPatient, 1));
fprintf('# patients >= 40 & < 70        = %3d (%.0f)\n', sum(temp3.PercentPredicted >= 40 & temp3.PercentPredicted < 70), 100 * sum(temp3.PercentPredicted >= 40 & temp3.PercentPredicted < 70) / size(cdPatient, 1));
fprintf('# patients >= 70 & < 90        = %3d (%.0f)\n', sum(temp3.PercentPredicted >= 70 & temp3.PercentPredicted < 90), 100 * sum(temp3.PercentPredicted >= 70 & temp3.PercentPredicted < 90) / size(cdPatient, 1));
fprintf('# patients >= 90               = %3d (%.0f)\n', sum(temp3.PercentPredicted >= 90), 100 * sum(temp3.PercentPredicted >= 90) / size(cdPatient, 1));

fprintf('\n');
fprintf('Overall Study mean /std) = %.3f, %.3f\n', mean(temp3.PercentPredicted), std(temp3.PercentPredicted));


% also calc actual dates by center
temp4 = cdPatient(:, {'Hospital', 'StudyDate'});
temp4.StudyEndDate = temp4.StudyDate + 183;
demofunc = @(x)[min(x) max(x)];
temp5 = varfun(demofunc, temp4, 'GroupingVariables', {'Hospital'});
temp5.Fun_StudyDate(:,2) = [];
temp5.Fun_StudyEndDate(:,1) = [];

fprintf('\n');
fprintf('Overall study dates: From %11s To %11s\n', datestr(min(temp5.Fun_StudyDate), 1), datestr(max(temp5.Fun_StudyEndDate), 1));

fprintf('By Hospital :\n');
temp5

% calculate patient demographics - eg histogram # of interventions per patient


temp6 = ivandmeasurestable(:, {'SmartCareID', 'IVDateNum'});
temp7 = varfun(@min, temp6, 'GroupingVariables', {'SmartCareID'});
temp7.min_IVDateNum = [];
temp8 = outerjoin(cdPatient(:, {'ID'}), temp7(:, {'SmartCareID', 'GroupCount'}), 'LeftKeys', {'ID'}, 'RightKeys', {'SmartCareID'}, 'RightVariables', {'GroupCount'});
temp8.GroupCount(isnan(temp8.GroupCount)) = 0;

histogram(temp8.GroupCount, 'Orientation', 'horizontal', 'LineWidth', 1);

