% creates the inputs for the model
% 
% - creates list of interventions with enough data to run model on
% - formats measure data into a datacube of size (npatients, ndays,
% nmeasurestype)
% - outputs this in a .mat file
% 
% Input:
% ------
% clinical and measurements data
% ivandmeasures_gap .mat
%
%
% Output:
% -------
% alignmentmodelinputs_gap .mat

clear; close all; clc;

[studynbr, study, studyfullname] = selectStudy();
chosentreatgap = selectTreatmentGap();

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
[datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
[physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[~, cdDrugTherapy, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);

tic
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, demographicsmatfile));
toc

tic
ivandmeasuresfile = sprintf('%sivandmeasures_gap%d.mat', study, chosentreatgap);
fprintf('Loading iv treatment and measures prior data\n');
load(fullfile(basedir, subfolder, ivandmeasuresfile));
toc

% useful variables
npatients = max(physdata.SmartCareID);
ndays = max(physdata.ScaledDateNum);

[measures, nmeasures] = createMeasuresTable(physdata);

tic
% create list of interventions with enough data to run model on
fprintf('Creating list of interventions\n');
amInterventions = createListOfInterventions(ivandmeasurestable, physdata, offset);
ninterventions = size(amInterventions,1);
toc

amInterventions = addDrugTherapyInfo(amInterventions, cdDrugTherapy);

tic
% create datacube - 3D array of patients/days/measures for model
fprintf('Creating 3D data array\n');
[amDatacube] = createDataCube(physdata, measures, npatients, ndays, nmeasures);
toc

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%salignmentmodelinputs_gap%d.mat', study, treatgap);
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder,outputfilename), 'amInterventions','amDatacube', 'measures', 'npatients','ndays', 'nmeasures', 'ninterventions');
toc




