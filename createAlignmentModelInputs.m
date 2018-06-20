clear; close all; clc;

studynbr = input('Enter Study to run for (1 = SmartCare, 2 = TeleMed): ');

if studynbr == 1
    study = 'SC';
    clinicalmatfile = 'clinicaldata.mat';
    datamatfile = 'smartcaredata.mat';
    ivandmeasuresfile = 'SCivandmeasures.mat';
    datademographicsfile = 'SCdatademographicsbypatient.mat';
elseif studynbr == 2
    study = 'TM';
    clinicalmatfile = 'telemedclinicaldata.mat';
    datamatfile = 'telemeddata.mat';
    ivandmeasuresfile = 'TMivandmeasures.mat';
    datademographicsfile = 'TMdatademographicsbypatient.mat';
else
    fprintf('Invalid study\n');
    return;
end

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
fprintf('Loading clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading measurement data\n');
load(fullfile(basedir, subfolder, datamatfile));
fprintf('Loading iv treatment and measures prior data\n');
load(fullfile(basedir, subfolder, ivandmeasuresfile));
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, datademographicsfile));
toc

if studynbr == 2
    physdata = tmphysdata;
    cdPatient = tmPatient;
    cdMicrobiology = tmMicrobiology;
    cdAntibiotics = tmAntibiotics;
    cdAdmissions = tmAdmissions;
    cdPFT = tmPFT;
    cdCRP = tmCRP;
    cdClinicVisits = tmClinicVisits;
    cdEndStudy = tmEndStudy;
    offset = tmoffset;
end

% useful variables
npatients = max(physdata.SmartCareID);
ndays = max(physdata.ScaledDateNum);
nmeasures = size(unique(physdata.RecordingType),1);
measures = table('Size',[nmeasures 4], 'VariableTypes', {'int32', 'cell', 'cell', 'cell'} ,'VariableNames', {'Index', 'Name', 'DisplayName', 'Column'});
measures.Index = [1:nmeasures]';
measures.Name = unique(physdata.RecordingType);
measures.DisplayName = replace(measures.Name, 'Recording', '');
measures.AlignWindStd = zeros(nmeasures,1); % populate during model execution

for i = 1:size(measures,1)
     measures.Column(i) = cellstr(getColumnForMeasure(measures.Name{i}));
end

tic

% create list of interventions with enough data to run model on
fprintf('Creating list of interventions\n');
amInterventions = createListOfInterventions(ivandmeasurestable, physdata, offset);
ninterventions = size(amInterventions,1);
toc
tic
% create datacube - 3D array of patients/days/measures for model
fprintf('Creating 3D data array\n');
[amDatacube, amNormcube] = createDataCube(physdata, measures, demographicstable, overalltable, npatients, ndays, nmeasures);
toc

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%salignmentmodelinputs.mat', study);
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder,outputfilename), 'amInterventions','amDatacube', 'amNormcube', 'measures', 'npatients','ndays', 'nmeasures', 'ninterventions');
toc




