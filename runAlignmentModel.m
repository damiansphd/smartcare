clear; close all; clc;

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'clinicaldata.mat';
scmatfile = 'smartcaredata.mat';
ivandmeasuresfile = 'ivandmeasures.mat';
datademographicsfile = 'datademographicsbypatient.mat';


fprintf('Loading Clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading SmartCare measurement data\n');
load(fullfile(basedir, subfolder, scmatfile));
fprintf('Loading iv treatment and measures prior data\n');
load(fullfile(basedir, subfolder, ivandmeasuresfile));
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, datademographicsfile));
toc

% useful variables
npatients = max(physdata.SmartCareID);
ndays = max(physdata.ScaledDateNum);
nmeasures = size(unique(physdata.RecordingType),1);
measures = table('Size',[nmeasures 2], 'VariableTypes', {'int32', 'cell'} ,'VariableNames', {'Index', 'Name'});
measures.Index = [1:9]';
measures.Name = unique(physdata.RecordingType);

tic

% create list of interventions with enough data to run model on
fprintf('Creating list of interventions\n');
abTreatments = createListOfInterventions(ivandmeasurestable, physdata, offset);
toc
tic
% create 3D array of patients/days/measures for model
fprintf('Creating 3D data array\n');
datacube = createDataCube(physdata, npatients, ndays, nmeasures);
toc




