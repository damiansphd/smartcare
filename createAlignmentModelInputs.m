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
measures = table('Size',[nmeasures 3], 'VariableTypes', {'int32', 'cell', 'cell'} ,'VariableNames', {'Index', 'Name', 'Column'});
measures.Index = [1:9]';
measures.Name = unique(physdata.RecordingType);
for i = 1:size(measures,1)
     measures.Column(i) = cellstr(getColumnForMeasure(measures.Name{i}));
end

tic

% create list of interventions with enough data to run model on
fprintf('Creating list of interventions\n');
abTreatments = createListOfInterventions(ivandmeasurestable, physdata, offset);
toc
tic
% create datacube - 3D array of patients/days/measures for model
fprintf('Creating 3D data array\n');
[datacube, normcube] = createDataCube(physdata, measures, demographicstable, npatients, ndays, nmeasures);
toc

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
outputfilename = 'alignmentmodelinputs.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder,outputfilename), 'abTreatments','datacube', 'normcube', 'measures', 'npatients','ndays', 'nmeasures');
toc




