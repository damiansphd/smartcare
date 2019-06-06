clear; close all; clc;

studynbr = input('Enter Study to run for (1 = SmartCare, 2 = TeleMed): ');

if studynbr == 1
    study = 'SC';
elseif studynbr == 2
    study = 'TM';
else
    fprintf('Invalid study\n');
    return;
end

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
fprintf('Loading latest labelled test data file\n');
inputfilename = sprintf('%s_LabelledInterventions.mat', study);
load(fullfile(basedir, subfolder, inputfilename));

%amLabelledInterventions.ExStart = [];

for i = 1:size(amLabelledInterventions, 1)
    ub1 = amLabelledInterventions.UpperBound1(i);
    ub2 = amLabelledInterventions.UpperBound2(i);
    lb1 = amLabelledInterventions.LowerBound1(i);
    lb2 = amLabelledInterventions.LowerBound2(i);

    if ((amLabelledInterventions.DataWindowCompleteness(i) >= 60) ...
            && (((ub1 - lb1) + (ub2 - lb2)) <= 9))
        amLabelledInterventions.IncludeInTestSet(i) = 'Y';
    else
        amLabelledInterventions.IncludeInTestSet(i) = 'N';
    end
end

fprintf('Saving labelled interventions to excel and matlab files\n');

subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%s_LabelledInterventions%s.mat', study, datestr(clock(),30));
save(fullfile(basedir, subfolder, outputfilename), 'amLabelledInterventions');

subfolder = 'ExcelFiles';
outputfilename = sprintf('%s_LabelledInterventions%s.xlsx', study, datestr(clock(),30));
writetable(amLabelledInterventions, fullfile(basedir, subfolder, outputfilename));

subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%s_LabelledInterventions.mat', study);
save(fullfile(basedir, subfolder, outputfilename), 'amLabelledInterventions');

