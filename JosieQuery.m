clear; clc; close all;

% load clinical data
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
inputfile = 'clinicaldata.mat';
load(fullfile(basedir, subfolder, inputfile));

% microbiology info for Papworth patients
test = cdMicrobiology(ismember(cdMicrobiology.Hospital, 'PAP'),:);

% logical index for patients with pseudomonas
ltest = ~cellfun('isempty', strfind(test.Microbiology, 'seud'));

% list of id's for papworth patients with pseudomonas
ppseu = unique(test.ID(ltest));

test(ismember(test.ID, ppseu),:)

ppseutest = innerjoin(test(ltest,:), cdPatient, 'RightVariables', {'StudyDate'});

unique(ppseutest.ID)

ppseuids = [23, 24, 79, 123, 133];

cdPatient(ismember(cdPatient.ID, ppseuids),:)



