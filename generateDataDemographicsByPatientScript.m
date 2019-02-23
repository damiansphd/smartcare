clc; clear; close;

studynbr = input('Enter Study to run for (1 = SmartCare, 2 = TeleMed): ');

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

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
fprintf('Loading clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading measurement data\n');
load(fullfile(basedir, subfolder, datamatfile));
toc
fprintf('\n');

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

generateDataDemographicsByPatientFn(physdata, cdPatient, study);

