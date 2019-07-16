clear; clc; close all;

basedir = setBaseDir();
subfolder = 'DataFiles/ProjectClimb';

[clPatient, clAdmissions, clAntibiotics, clClinicVisits, clOtherVisits, clCRP, clPFT, clMicrobiology, clHghtWght, clEndStudy] = createClimbClinicalTables(0);
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
        [clPatient, clAdmissions, clAntibiotics, clClinicVisits, clPFT, clMicrobiology, clHghtWght] = loadClimbClinDataForPatient(clPatient, clAdmissions, clAntibiotics, clClinicVisits, clPFT, clMicrobiology, clHghtWght, patfilelist{p}, basedir, tmpfolder, userid);
        userid = userid + 1;
    end 
end

% sort rows
clAdmissions   = sortrows(clAdmissions,   {'ID', 'Admitted'});
clAntibiotics  = sortrows(clAntibiotics,  {'ID', 'StartDate', 'AntibioticName'});
clClinicVisits = sortrows(clClinicVisits, {'ID', 'AttendanceDate'});
clPFT          = sortrows(clPFT,          {'ID', 'LungFunctionDate'});
clMicrobiology = sortrows(clMicrobiology, {'ID', 'DateMicrobiology'});
clHghtWght     = sortrows(clHghtWght,     {'ID', 'MeasDate'});

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
save(fullfile(basedir, subfolder,outputfilename), 'clPatient', 'clMicrobiology', 'clClinicVisits', ...
    'clOtherVisits','clPFT', 'clHghtWght', 'clAdmissions', 'clAntibiotics', 'clCRP', 'clEndStudy');
toc
