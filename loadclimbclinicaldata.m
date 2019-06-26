clear; clc; close all;

basedir = setBaseDir();
subfolder = 'DataFiles/ProjectClimb';

[cdPatient, cdAdmissions, cdAntibiotics, cdClinicVisits, cdOtherVisits, cdCRP, cdPFT, cdMicrobiology, cdHghtWght, cdEndStudy] = createClimbClinicalTables(0);
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
        [cdPatient, cdAdmissions, cdAntibiotics, cdClinicVisits, cdPFT, cdMicrobiology, cdHghtWght] = loadClimbClinDataForPatient(cdPatient, cdAdmissions, cdAntibiotics, cdClinicVisits, cdPFT, cdMicrobiology, cdHghtWght, patfilelist{p}, basedir, tmpfolder, userid);
        userid = userid + 1;
    end 
end

% sort rows
cdAdmissions   = sortrows(cdAdmissions,   {'ID', 'Admitted'});
cdAntibiotics  = sortrows(cdAntibiotics,  {'ID', 'StartDate', 'AntibioticName'});
cdClinicVisits = sortrows(cdClinicVisits, {'ID', 'AttendanceDate'});
cdPFT          = sortrows(cdPFT,          {'ID', 'LungFunctionDate'});
cdMicrobiology = sortrows(cdMicrobiology, {'ID', 'DateMicrobiology'});
cdHghtWght     = sortrows(cdHghtWght,     {'ID', 'MeasDate'});

toc
fprintf('\n');

% add checks for data integrity issues
% cdPatient 
%      - zero/missing height, weight, predictedFEV1, FEV1SetAs - summarise
%      list of patients (ignore lung function where Too Young == 'Yes'
%      - PredictedFEV1 > 6l
%      - Study Date < Jun 2016 or > Jun 2019
%
% otherTables
%      - Dates < Jun 2016 or > Jun 2019
%      - stop/discharge dates < start/admitted dates
%      - zero lung function or height/weight measures
%      - values out of tolerance (eg lung function > 6l, height > 200cm or < 50cm,
%      weight > 75kg or < 10kg

% potentially replace codes with decoded values for admission reason,
% antibiotics etc


tic
fprintf('\n');
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = 'climbclinicaldata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder,outputfilename), 'cdPatient', 'cdMicrobiology', 'cdClinicVisits', ...
    'cdOtherVisits','cdPFT', 'cdHghtWght', 'cdAdmissions', 'cdAntibiotics', 'cdCRP', 'cdEndStudy');
toc
