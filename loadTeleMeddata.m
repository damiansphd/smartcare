clear; clc; close all;

tic
fprintf('Creating TeleMed data structures\n');
fprintf('---------------------------------\n');
basedir = './';
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'clinicaldata.mat';
fprintf('Loading equivalent smartcare data structures as baseline\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Done\n');
tmAdmissions        = cdAdmissions;
tmAdmissions(:,:)   = [];
tmAntibiotics       = cdAntibiotics;
tmAntibiotics(:,:)  = [];
tmClinicVisits      = cdClinicVisits;
tmClinicVisits(:,:) = [];
tmCRP               = cdCRP;
tmCRP(:,:)          = [];
tmEndStudy          = cdEndStudy;
tmEndStudy(:,:)     = [];
tmMicrobiology      = cdMicrobiology;
tmMicrobiology(:,:) = [];
tmOtherVisits       = cdOtherVisits;
tmOtherVisits(:,:)  = [];
tmPatient           = cdPatient;
tmPatient(:,:)      = [];
tmPFT               = cdPFT;
tmPFT(:,:)          = [];
toc
fprintf('\n');

tic
basedir = './';
subfolder = 'DataFiles/TeleMed';
clinicalfile = 'FEVdata.xlsx';
tmdatafile1 = 'K1.xlsx';

fprintf('Loading Telemed clinical patient data');
tmPatientInfo = readtable(fullfile(basedir, subfolder, clinicalfile));
tmPatientInfo(:,{'AZM','inhPx','PNL','Diabetes'}) = [];
tmPatientInfo.ID = str2double(strrep(tmPatientInfo.Patient, 'K', ''));
tmPatientInfo.PredFEV1 = tmPatientInfo.FEV1_L_Av ./ (tmPatientInfo.FEV1___Av/100);
tmPatientInfo.FEV1SetAs = round(tmPatientInfo.PredFEV1,1);

ntmpatients = size(tmPatientInfo,1);

tmPatient.ID(1:ntmpatients) = tmPatientInfo.ID;
tmPatient.Age = tmPatientInfo.Age;
tmPatient.Sex = tmPatientInfo.Gender;


fprintf('\n');
toc




