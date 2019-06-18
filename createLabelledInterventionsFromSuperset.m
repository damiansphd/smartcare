clear; close all; clc;

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
study = 'SC';

fprintf('Loading gap 10 labelled interventions using consensus methodology\n');
inputfilename = sprintf('%s_LabelledInterventions_gap10consensus.mat', study);
load(fullfile(basedir, subfolder, inputfilename), 'amLabelledInterventions');
amLabIntrGap10Cons = amLabelledInterventions;
amLabIntrGap10Cons(:, {'PatientOffset', 'Offset', 'LatentCurve', 'IncludeInTestSet', 'LowerBound1', 'UpperBound1', 'LowerBound2', 'UpperBound2'}) = [];

fprintf('Loading gap 20 labelled interventions using earliest methodology\n');
inputfilename = sprintf('%s_LabelledInterventions_gap20earliest.mat', study);
load(fullfile(basedir, subfolder, inputfilename), 'amLabelledInterventions');
amLabIntrGap20Earl = amLabelledInterventions;

amLabelledInterventions = outerjoin(amLabIntrGap10Cons, amLabIntrGap20Earl, 'LeftKeys', {'SmartCareID', 'Hospital', 'IVDateNum'}, ...
    'RightKeys', {'SmartCareID', 'Hospital', 'IVDateNum'}, ...
    'RightVariables', {'IncludeInTestSet', 'LowerBound1', 'UpperBound1', 'LowerBound2', 'UpperBound2'});

fprintf('Need to manually relabel the following interventions with methodology: earliest\n');
fprintf('\n');
amLabelledInterventions(isnan(amLabelledInterventions.LowerBound1), :)

fprintf('Saving labelled interventions to a separate matlab and excel file\n');
subfolder = 'MatlabSavedVariables';
baseoutputfilename = sprintf('%s_LabelledInterventions_gap10earliest', study);
outputfilename = sprintf('%s%s.mat', baseoutputfilename, datestr(clock(),30));
save(fullfile(basedir, subfolder, outputfilename), 'amLabelledInterventions');
outputfilename = sprintf('%s.mat', baseoutputfilename);
save(fullfile(basedir, subfolder, outputfilename), 'amLabelledInterventions');

outputfilename = sprintf('%s%s.xlsx', baseoutputfilename, datestr(clock(),30));
writetable(amLabelledInterventions, fullfile(basedir, 'ExcelFiles', outputfilename));
outputfilename = sprintf('%s.xlsx', baseoutputfilename);
writetable(amLabelledInterventions, fullfile(basedir, 'ExcelFiles', outputfilename));