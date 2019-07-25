clear; clc; close all;

basedir = setBaseDir();
subfolder = 'DataFiles/ProjectClimb/';
exreasonsfile = 'CLReasonsForIVTreatments.xlsx';

ivreasons = readtable(fullfile(basedir, subfolder, exreasonsfile), 'ReadVariableNames', true);

exacerbationreasons = array2table(ivreasons.ReasonForIV(ismember(ivreasons.ExacerbationRelated, {'X'})));
exacerbationreasons.Properties.VariableNames{'Var1'} = 'Reason';

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = 'climbexacerbationreasons.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder, outputfilename), 'exacerbationreasons');