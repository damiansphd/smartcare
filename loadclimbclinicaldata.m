clear; clc; close all;

study = 'CL';

basedir = setBaseDir();
subfolder = sprintf('DataFiles/%s/Proformas final', study);

[clABNameTable] = getClimbAntibioticNameTable();
[clPatient, clAdmissions, clAntibiotics, clClinicVisits, clOtherVisits, clCRP, clPFT, clMicrobiology, clHghtWght, clOthClinMeas, clEndStudy] = createClimbClinicalTables(0);
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
        [clPatient, clAdmissions, clAntibiotics, clClinicVisits, clPFT, clMicrobiology, clHghtWght, clOthClinMeas] = loadClimbClinDataForPatient(clPatient, clAdmissions, clAntibiotics, clClinicVisits, clPFT, clMicrobiology, clHghtWght, clOthClinMeas, clABNameTable, patfilelist{p}, basedir, tmpfolder, userid);
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
%      - zero height/weight measures
%      - values out of tolerance (eg height > 200cm or < 50cm,
%      weight > 75kg or < 10kg

% potentially replace codes with decoded values for admission reason,
% antibiotics etc

idx = clPFT.FEV1 == 0;
fprintf('Removing %d zero PFT Clinical Measurements\n', sum(idx));
clPFT(idx,:) = [];

idx =  clPFT.FEV1 > 4;
fprintf('Removing %d Anomalous PFT Clinical Measurements (>4l)\n', sum(idx));
clPFT(idx,:) = [];

% admission data
idx = isnat(clAdmissions.Admitted) | isnat(clAdmissions.Discharge);
fprintf('Found %d Admissions with blank dates\n', sum(idx));
if sum(idx) > 0
    clAdmissions(idx,:)
    %clAdmissions(idx, :) = [];
end

idx = clAdmissions.Discharge < clAdmissions.Admitted;
fprintf('Found %d Admissions with Discharge before Admission\n', sum(idx));
if sum(idx) > 0
    clAdmissions(idx,:)
end

idx = days(clAdmissions.Discharge - clAdmissions.Admitted) > 30;
fprintf('Found %d Admissions > 1 month duration\n', sum(idx));
if sum(idx) > 0
    clAdmissions(idx,:)
    %clAdmissions(idx, :) = [];
end

% antibiotics data
idx = isnat(clAntibiotics.StartDate) | isnat(clAntibiotics.StopDate);
fprintf('Found %d Antibiotics with blank dates\n', sum(idx));
if sum(idx) > 0
    clAntibiotics(idx,:)
    %clAntibiotics(idx, :) = [];
end

idx = clAntibiotics.StopDate < clAntibiotics.StartDate;
fprintf('Found %d Antibiotic Treatments with Stop Date before Start Date\n', sum(idx));
if sum(idx) > 0
    clAntibiotics(idx,:)
end

idx = days(clAntibiotics.StopDate - clAntibiotics.StartDate) > 30;
fprintf('Found %d Antibiotics > 1 month duration\n', sum(idx));
if sum(idx) > 0
    clAntibiotics(idx,:)
    %clAntibiotics(idx, :) = [];
end

% find any treatments that finished before the study start date for each
% patient
tempab = join(clAntibiotics, clPatient, 'LeftKeys', 'ID', 'RightKeys', 'ID', 'RightVariables', {'StudyNumber', 'StudyDate'});
idx = tempab.StopDate < tempab.StudyDate;
fprintf('\n');
fprintf('Deleting %d antibiotic treatments before study start', sum(idx));
clAntibiotics(idx,:) = [];

tic
subfolder = 'ExcelFiles';
outputfilename = 'CLantibiotictreatments.xlsx';
fprintf('\n');
fprintf('Saving antibiotics treatments to excel file %s\n', outputfilename);
writetable(clAntibiotics(~ismember(clAntibiotics.Route, 'IV'), :), fullfile(basedir, subfolder,outputfilename), 'Sheet', 'Oral');
writetable(clAntibiotics(ismember(clAntibiotics.Route, 'IV'), :), fullfile(basedir, subfolder,outputfilename), 'Sheet', 'IV');
writetable(tempab(idx,:), fullfile(basedir, subfolder,outputfilename), 'Sheet', 'ABbeforeStudyStart');

toc

tic
fprintf('\n');
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = 'climbclinicaldata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder,outputfilename), 'clPatient', 'clMicrobiology', 'clClinicVisits', ...
    'clOtherVisits','clPFT', 'clHghtWght', 'clAdmissions', 'clAntibiotics', 'clCRP', 'clOthClinMeas', 'clEndStudy', 'clABNameTable');
toc

