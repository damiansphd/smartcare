clear; close all; clc;

studynbr = input('Enter Study to run for (1 = SmartCare, 2 = TeleMed): ');
fprintf('\n');

if studynbr == 1
    study = 'SC';
elseif studynbr == 2
    study = 'TM';
else
    fprintf('Invalid choice\n');
    return;
end

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

fprintf('\n');
fprintf('Loading labelled test data file\n');
inputfilename = sprintf('%s_LabelledInterventions.mat', study);
load(fullfile(basedir, subfolder, inputfilename));

fprintf('\n');
fprintf('Writing labelled test data to excel\n');

subfolder = 'ExcelFiles';
sheetname = sprintf('%s_LabelledInterventions', study);
outputfilename = sprintf('%s_LabelledInterventions.xlsx', study);

writetable(amLabelledInterventions,  fullfile(basedir, subfolder, outputfilename), 'Sheet', sheetname);

