clc; clear; close all;

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'clinicaldata.mat';
scmatfile = 'smartcaredata.mat';

outputfilename = 'clinicalFEVInconsistencies.xlsx';

fprintf('Loading Clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading SmartCare measurement data\n');
load(fullfile(basedir, subfolder, scmatfile));
toc

% issues with FEV1% not being consistent with FEV1 and PredictedFEV1
test = innerjoin(cdPFT, cdPatient(:,{'ID','PredictedFEV1','FEV1SetAs'}));
test.CalculatedFEV1_ = round(100* (test.FEV1 ./ test.PredictedFEV1));
test.Difference = test.FEV1_ - test.CalculatedFEV1_;

writetable(test(abs(test.FEV1_ - test.CalculatedFEV1_) > 2, :), outputfilename);

% Patients with more than one predicted fev value across home measures
test2 = unique(physdata(~isnan(physdata.PredictedFEV), {'SmartCareID', 'PredictedFEV'}));
pfcount = varfun(@sum, test2(:,{'SmartCareID'}), 'GroupingVariables', {'SmartCareID'});
ppredfevissues = pfcount.SmartCareID(pfcount.GroupCount > 1);

test2 = innerjoin(test2, cdPatient(:,{'ID','FEV1SetAs','CalcFEV1SetAs', 'PredictedFEV1', 'CalcPredictedFEV1'}), 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'});
test2.ScalingRatio = test2.CalcFEV1SetAs ./ test2.PredictedFEV;

multivaluescpredfev = test2(ismember(test2.SmartCareID, ppredfevissues),:);
scpredfev = test2(~ismember(test2.SmartCareID, ppredfevissues),:);

% inconsistencies between predictedFEV in clinical data and home
% measurement data
test3 = innerjoin(physdata(~isnan(physdata.PredictedFEV),{'SmartCareID', 'Date_TimeRecorded', 'PredictedFEV'}), ...
    cdPatient(:,{'ID','PredictedFEV1','FEV1SetAs', 'CalcPredictedFEV1', 'CalcFEV1SetAs'}), ...
    'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'});

