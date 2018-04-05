
clear; clc; close;

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
cdPatient = readtable(clinicaldatafile, 'Sheet', cdpatientsheet);
fprintf('Patient data has %d rows\n',size(cdPatient,1));
cdMicrobiology = readtable(clinicaldatafile, 'Sheet', cdmicrosheet);
fprintf('Microbiology data has %d rows\n',size(cdMicrobiology,1));
cdClinicVisits = readtable(clinicaldatafile, 'Sheet', cdcvsheet);
fprintf('Clinic Visits data has %d rows\n',size(cdClinicVisits,1));
cdPFT = readtable(clinicaldatafile, 'Sheet', cdpftsheet);
fprintf('PFT data has %d rows\n',size(cdPFT,1));
cdAdmissions = readtable(clinicaldatafile, 'Sheet', cdadmisssheet);
fprintf('Admissions data has %d rows\n',size(cdAdmissions,1));
cdAntibiotics = readtable(clinicaldatafile, 'Sheet', cdantibsheet);
fprintf('Antibiotics data has %d rows\n',size(cdAntibiotics,1));
cdCRP = readtable(clinicaldatafile, 'Sheet', cdcrpsheet);
fprintf('CRP data has %d rows\n',size(cdCRP,1));
cdEndStudy = readtable(endofstudyfile);
fprintf('End of Study data has %d rows\n',size(cdEndStudy,1));
toc
fprintf('\n');

% no issues with microbiology data 

% no issues with clinic visits data

% correct PFT data anomalies
cdPFT = fixCDPFTData(cdPFT);

% correct Antibiotics data anomalies
cdAntibiotics = fixCDAntibioticsData(cdAntibiotics);

% add column to hold numeric equivalent of CRP level column
cdCRP = fixCDCRPData(cdCRP;

% no issues with end of study data

tic
fprintf('\n');
outputfilename = 'clinicaldata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(outputfilename, 'cdPatient', 'cdMicrobiology', 'cdClinicVisits', 'cdPFT', 'cdAdmissions', 'cdAntibiotics', 'cdCRP', 'cdEndStudy');
toc
