

basedir = setBaseDir();
clinicalmatfile = 'clinicaldata.mat';
subfolder = 'MatlabSavedVariables';
fprintf('Loading clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));

temp = cdPatient(:,{'ID', 'Hospital', 'StudyNumber', 'StudyDate', 'PredictedFEV1', 'CalcPredictedFEV1'});

writetable(temp, fullfile(basedir, 'ExcelFiles', sprintf('%s.xlsx', 'EmemPatientPredictedFEV1')));