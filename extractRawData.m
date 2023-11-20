clear; clc; close all;

[studynbr, study, studyfullname] = selectStudy();

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
[datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
[physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[cdPatient, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);

% save updated patient id mapping table to excel
tic
subfolder = 'ExcelFiles';
outputfilename = sprintf('%sphysdata.csv', study);
fprintf('Saving physdata to csv file %s\n',outputfilename);
writetable(physdata, fullfile(basedir, subfolder, outputfilename))

outputfilename = sprintf('%sPatient.csv', study);
fprintf('Saving cdPatient to csv file %s\n',outputfilename);
writetable(cdPatient, fullfile(basedir, subfolder, outputfilename))

toc
fprintf('\n');