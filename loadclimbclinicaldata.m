clear; clc; close all;

basedir = setBaseDir();
subfolder = 'DataFiles/ProjectClimb';

[cdPatient, cdAdmissions, cdAntibiotics, cdClinicVisits, cdOtherVisits, cdCRP, cdPFT, cdMicrobiology, cdEndStudy] = createClimbClinicalTables(0);
userid = 301;

tic
% get list of Project Climb hospitals
cbhosp = getListOfClimbHospitals();

% for each hospital, get the list of patient files
for i = 1:size(cbhosp, 1)
    tmpfolder = sprintf('%s/%s', subfolder, cbhosp.Acronym{i});
    patfilelist = getListOfClimbHospPatFiles(basedir, tmpfolder);
    for p = 1:size(patfilelist, 1)
        % for each patient file, extract the data and store in the clinical
        % data tables
        [cdPatient, cdAdmissions, cdAntibiotics, cdClinicVisits, cdPFT, cdMicrobiology] = loadClimbClinDataForPatient(cdPatient, cdAdmissions, cdAntibiotics, cdClinicVisits, cdPFT, cdMicrobiology, patfilelist{p}, basedir, tmpfolder, userid);
        userid = userid + 1;
    end 
end

% sort rows
cdAdmissions = sortrows(cdAdmissions, {'ID', 'Admitted'});
cdAntibiotics = sortrows(cdAntibiotics, {'ID', 'StartDate', 'AntibioticName'});
cdClinicVisits = sortrows(cdClinicVisits, {'ID', 'AttendanceDate'});
cdPFT = sortrows(cdPFT, {'ID', 'LungFunctionDate'});
cdMicrobiology = sortrows(cdMicrobiology, {'ID', 'DateMicrobiology'});

toc
fprintf('\n');

% add checks for data integrity issues
% 1) zero PFT values (in any of the columns)
% 2) Dates < Jun 2016
% 3) stop/discharge dates < start/admitted dates

% potentially replace codes with decoded values for admission reason,
% antibiotics etc


tic
fprintf('\n');
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = 'climbclinicaldata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder,outputfilename), 'cdPatient', 'cdMicrobiology', 'cdClinicVisits', 'cdOtherVisits','cdPFT', 'cdAdmissions', 'cdAntibiotics', 'cdCRP', 'cdEndStudy');
toc
