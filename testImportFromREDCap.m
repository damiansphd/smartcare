clear; close all; clc;

study = 'BR';

fprintf('Importing clinical data from REDCap\n');
fprintf('\n');

subfolder = sprintf('DataFiles/%s/REDCapData', study);
testfile  = 'Test - MATLAB import.xlsx';

redcapdata = readtable(fullfile(basedir, subfolder, testfile));