clear; close all; clc;

studynbr = input('Enter Study to run for (1 = SmartCare, 2 = TeleMed): ');
chosentreatgap = selectTreatmentGap();

if studynbr == 1
    study = 'SC';
    clinicalmatfile = 'clinicaldata.mat';
    datamatfile = 'smartcaredata.mat';
    
elseif studynbr == 2
    study = 'TM';
    clinicalmatfile = 'telemedclinicaldata.mat';
    datamatfile = 'telemeddata.mat';
else
    fprintf('Invalid study\n');
    return;
end

ivandmeasuresfile = sprintf('%sivandmeasures_gap%d.mat', study, chosentreatgap);
datademographicsfile = sprintf('%sdatademographicsbypatient.mat', study);

tic
basedir = setBaseDir();
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
measures.AlignWindStd = zeros(nmeasures, 1); % populate during model execution
measures.OverallStd = zeros(nmeasures, 1); % populate during model execution
measures.Mask = zeros(nmeasures, 1); % populate during model execution

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
[amDatacube] = createDataCube(physdata, measures, demographicstable, overalltable, npatients, ndays, nmeasures);
toc

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%salignmentmodelinputs_gap%d.mat', study, treatgap);
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder,outputfilename), 'amInterventions','amDatacube', 'measures', 'npatients','ndays', 'nmeasures', 'ninterventions');
toc




