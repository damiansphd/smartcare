clear; clc; close all;

basedir = './';
subfolder = 'DataFiles';
clinicaldatafile = 'clinicaldata.xlsx';
cdpatientsheet = 'Patients';
cdmicrosheet = 'Microbiolgy';
cdcvsheet = 'Clinic Visits';
cdpftsheet = "PFT's";
cdadmisssheet = 'Admissions';
cdantibsheet = 'Antibiotics';
cdcrpsheet = 'CRP Levels';
endofstudyfile = 'EOS Data_ALL.xlsx';

tic
% load relevant clinical data
fprintf('Loading relevant clinical data\n');
cdPatient = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdpatientsheet);
fprintf('Patient data has %d rows\n',size(cdPatient,1));
cdMicrobiology = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdmicrosheet);
fprintf('Microbiology data has %d rows\n',size(cdMicrobiology,1));
cdClinicVisits = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdcvsheet);
fprintf('Clinic Visits data has %d rows\n',size(cdClinicVisits,1));
cdPFT = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdpftsheet);
fprintf('PFT data has %d rows\n',size(cdPFT,1));
cdAdmissions = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdadmisssheet);
fprintf('Admissions data has %d rows\n',size(cdAdmissions,1));
cdAntibiotics = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdantibsheet);
fprintf('Antibiotics data has %d rows\n',size(cdAntibiotics,1));
cdCRP = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdcrpsheet);
fprintf('CRP data has %d rows\n',size(cdCRP,1));
cdEndStudy = readtable(fullfile(basedir, subfolder, endofstudyfile));
fprintf('End of Study data has %d rows\n',size(cdEndStudy,1));
toc
fprintf('\n');

% correct Patient data anomalies
cdPatient = fixCDPatientData(cdPatient);

% no issues with microbiology data 

% no issues with clinic visits data

% correct PFT data anomalies
cdPFT = fixCDPFTData(cdPFT, cdPatient);

% correct Antibiotics data anomalies
cdAntibiotics = fixCDAntibioticsData(cdAntibiotics);

% correct Admissions data anomalies
cdAdmissions = fixCDAdmissionsData(cdAdmissions);

% correct CRP data anomalies
cdCRP = fixCDCRPData(cdCRP);

% no issues with end of study data

tic
fprintf('\n');

basedir = './';
subfolder = 'MatlabSavedVariables';
outputfilename = 'clinicaldata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder,outputfilename), 'cdPatient', 'cdMicrobiology', 'cdClinicVisits', 'cdPFT', 'cdAdmissions', 'cdAntibiotics', 'cdCRP', 'cdEndStudy');
toc
