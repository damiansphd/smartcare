% clear all user defined variables, close all figures/plots, clear the terminal screen
clear;close all;clc;

%----------------------------------------

pid_inputFilename = 'patientid_data.csv';
pid_outputFilename = 'patientid_data.mat';
cdab_inputFilename = 'ClinicalData_Antibiotics_corrected.csv';
cdab_outputFilename = 'ClinicalData_Antibiotics.mat';
cdad_inputFilename = 'ClinicalData_Admissions_corrected.csv';
cdad_outputFilename = 'ClinicalData_Admissions.mat';
cdcrp_inputFilename = 'ClinicalData_CRP.csv';
cdcrp_outputFilename = 'ClinicalData_CRP.mat';
cdmb_inputFilename = 'ClinicalData_Microbiology.csv';
cdmb_outputFilename = 'ClinicalData_Microbiology.mat';
cdpft_inputFilename = 'ClinicalData_PFT_corrected.csv';
cdpft_outputFilename = 'ClinicalData_PFT.mat';
cdpat_inputFilename = 'ClinicalData_Patient_corrected.csv';
cdpat_outputFilename = 'ClinicalData_Patient.mat';
cdcv_inputFilename = 'ClinicalData_ClinicVisits.csv';
cdcv_outputFilename = 'ClinicalData_ClinicVisits.mat';
cdeos_inputFilename = 'EOS data_ALL.csv';
cdeos_outputFilename = 'ClinicalData_EndOfStudy.mat';

tic
%fprintf('Pre-processing patient id data and saving in Octave/Matlab format\n')
%processAndSavePatientIDData(pid_inputFilename,pid_outputFilename);
toc
fprintf('\n');

tic
%fprintf('Pre-processing clinical antibiotics data and saving in Octave/Matlab format\n')
%processAndSaveCDAntibiotics(cdab_inputFilename,cdab_outputFilename);
toc
fprintf('\n');

tic
%fprintf('Pre-processing clinical admissions data and saving in Octave/Matlab format\n')
%processAndSaveCDAdmissions(cdad_inputFilename,cdad_outputFilename);
toc
fprintf('\n');

tic
%fprintf('Pre-processing clinical CRP data and saving in Octave/Matlab format\n')
%processAndSaveCDCRP(cdcrp_inputFilename,cdcrp_outputFilename);
toc
fprintf('\n');

tic
%fprintf('Pre-processing clinical Microbiology data and saving in Octave/Matlab format\n')
%processAndSaveCDMicrobiology(cdmb_inputFilename,cdmb_outputFilename);
toc
fprintf('\n');

tic
%fprintf('Pre-processing clinical PFT data and saving in Octave/Matlab format\n')
%processAndSaveCDPFT(cdpft_inputFilename,cdpft_outputFilename);
toc
fprintf('\n');

tic
%fprintf('Pre-processing clinical Patient data and saving in Octave/Matlab format\n')
%processAndSaveCDPatient(cdpat_inputFilename,cdpat_outputFilename);
toc
fprintf('\n');

tic
%fprintf('Pre-processing clinical Clinic Visits data and saving in Octave/Matlab format\n')
%processAndSaveCDClinicVisits(cdcv_inputFilename,cdcv_outputFilename);
toc
fprintf('\n');

tic
fprintf('Pre-processing clinical End of Study data and saving in Octave/Matlab format\n')
processAndSaveCDEndOfStudy(cdeos_inputFilename,cdeos_outputFilename);
toc
fprintf('\n');

%tic
%fprintf('Pre-processing smartcare measurement data and saving in Octave/Matlab format\n')
%processAndSaveSmartCareData(sc_inputFilename,sc_outputFilename);
%toc
%----------------------------------------


