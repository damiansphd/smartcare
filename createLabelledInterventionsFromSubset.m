clear; close all; clc;

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

fprintf('Loading intervention file\n');
inputfilename = 'amInterventionsTemp.mat';
load(fullfile(basedir, subfolder, inputfilename), 'amInterventions');

fprintf('Loading latest labelled test data file\n');
inputfilename = 'SC_LabelledInterventions.mat';
load(fullfile(basedir, subfolder, inputfilename), 'amLabelledInterventions');

amLabelledInterventions = join(amInterventions, amLabelledInterventions, 'LeftKeys', {'SmartCareID', 'Hospital', 'IVDateNum'}, ...
    'RightKeys', {'SmartCareID', 'Hospital', 'IVDateNum'}, ...
    'RightVariables', {'IncludeInTestSet', 'LowerBound1', 'UpperBound1', 'LowerBound2', 'UpperBound2'});
    
amLabelledInterventions(:, {'PatientOffset', 'Offset', 'LatentCurve'}) = [];

fprintf('Saving labelled interventions to a separate matlab and excel file\n');
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('SC_LabelledInterventions%s.mat', datestr(clock(),30));
save(fullfile(basedir, subfolder, outputfilename), 'amLabelledInterventions');
outputfilename = 'SC_LabelledInterventions.mat';
save(fullfile(basedir, subfolder, outputfilename), 'amLabelledInterventions');

outputfilename = sprintf('SC_LabelledInterventions%s.xlsx', datestr(clock(),30));
writetable(amLabelledInterventions, fullfile(basedir, 'ExcelFiles', outputfilename));
outputfilename = 'SC_LabelledInterventions.xlsx';
writetable(amLabelledInterventions, fullfile(basedir, 'ExcelFiles', outputfilename));