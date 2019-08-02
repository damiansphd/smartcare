clear; clc; close all;

basedir = setBaseDir();
subfolder = 'DataFiles';
clinicaldatafile = 'clinicaldata_updated.xlsx';
cdpatientsheet   = 'Patients';
cdmicrosheet     = 'Microbiolgy';
cdcvsheet        = 'Clinic Visits';
cdovsheet        = 'Other Visits';
cdpftsheet       = "PFT's";
cdadmisssheet    = 'Admissions';
cdantibsheet     = 'Antibiotics';
cdcrpsheet       = 'CRP Levels';
cdmedsheet       = 'Medications';
cdnewmedsheet    = 'New Medications';
endofstudyfile   = 'EOS Data_ALL.xlsx';

tic
% load relevant clinical data
fprintf('Loading relevant clinical data\n');
cdPatient = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdpatientsheet);
cdPatient = sortrows(cdPatient, {'ID'}, 'ascend');
fprintf('Patient data has %d rows\n', size(cdPatient, 1));
cdMicrobiology = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdmicrosheet);
cdMicrobiology = sortrows(cdMicrobiology, {'ID', 'DateMicrobiology'}, 'ascend');
fprintf('Microbiology data has %d rows\n', size(cdMicrobiology, 1));
cdClinicVisits = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdcvsheet);
cdClinicVisits = sortrows(cdClinicVisits, {'ID', 'AttendanceDate'}, 'ascend');
fprintf('Clinic Visits data has %d rows\n', size(cdClinicVisits, 1));
cdOtherVisits = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdovsheet);
cdOtherVisits = sortrows(cdOtherVisits, {'ID', 'AttendanceDate'}, 'ascend');
fprintf('Other Visits data has %d rows\n', size(cdOtherVisits, 1));
cdPFT = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdpftsheet);
cdPFT = sortrows(cdPFT, {'ID', 'LungFunctionDate'}, 'ascend');
fprintf('PFT data has %d rows\n', size(cdPFT, 1));
cdAdmissions = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdadmisssheet);
cdAdmissions = sortrows(cdAdmissions, {'ID', 'Admitted'}, 'ascend');
fprintf('Admissions data has %d rows\n', size(cdAdmissions, 1));
cdAntibiotics = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdantibsheet);
cdAntibiotics = sortrows(cdAntibiotics, {'ID', 'StartDate'}, 'ascend');
fprintf('Antibiotics data has %d rows\n', size(cdAntibiotics,1));
cdCRP = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdcrpsheet);
cdCRP = sortrows(cdCRP, {'ID', 'CRPDate'}, 'ascend');
fprintf('CRP data has %d rows\n', size(cdCRP, 1));
cdMedications = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdmedsheet);
cdMedications = sortrows(cdMedications, {'ID', 'MedID'}, 'ascend');
fprintf('Medications data has %d rows\n', size(cdMedications, 1));
cdNewMeds = readtable(fullfile(basedir, subfolder, clinicaldatafile), 'Sheet', cdnewmedsheet);
cdNewMeds = sortrows(cdNewMeds, {'ID', 'StartDate'}, 'ascend');
fprintf('New Medications data has %d rows\n', size(cdNewMeds, 1));
cdEndStudy = readtable(fullfile(basedir, subfolder, endofstudyfile));
cdEndStudy = sortrows(cdEndStudy, {'ID'}, 'ascend');
fprintf('End of Study data has %d rows\n', size(cdEndStudy, 1));
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

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = 'clinicaldata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder,outputfilename), 'cdPatient', 'cdMicrobiology', 'cdClinicVisits', ...
    'cdOtherVisits','cdPFT', 'cdAdmissions', 'cdAntibiotics', 'cdCRP', 'cdMedications', 'cdNewMeds', 'cdEndStudy');
toc
