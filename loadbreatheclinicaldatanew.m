% loads Breathe clinical data for each patient
% - concatenates all individual patients' clinical data category by category
% - performs some field level data quality checks
% 
% Input:
% ------
% one spreadsheet per patient from the "DataFiles/BR/ClinicalData/" directory,
% among hospitals list taking part into the study
%
% Output:
% -------
% breatheclinicaldata.mat with the following variables:
% - brAdmissions          synonym for hospitalisation
% - brAntibiotics         ab's name, route, homeIV, start/end date
% - brClinicVisits        date, location (e.g. home or clinic)
% - brCRP                 CRP measures
% - brDrugTherapy         CFTR modulators therapy, start/stop date
% - brEndStudy            empty for Breathe - nonrelevant
% - brHghWght             height, weight (and seldom BMI, H_z & W_z scores)
% - brMicrobiology        what bacterias in the lungs
% - brOtherVisits         e.g. annual reviews, emergencies
% - brPatient             patient profile (including mutations)
% - brPFT                 Pulmonary Function Tests
% - brUnplannedContact    e.g. call
% - patientmaster         study enrollment start/end dates, StudyNumber (clinical), GUID/Partition Key (MagicBullet server)
% 
% Histogram of patient clinical data by month of last update.png - plot


clear; clc; close all;

study = 'BR';

basedir = setBaseDir();
subfolder = sprintf('DataFiles/%s/ClinicalData', study);

[brPatient, brDrugTherapy, brAdmissions, brAntibiotics, brClinicVisits, brOtherVisits, brUnplannedContact, ...
    brCRP, brPFT, brMicrobiology, brHghtWght, brEndStudy] = createBreatheClinicalTables(0);

tic
% get list of Project Breathe hospitals
brhosp = getListOfBreatheHospitals();

[patientmaster] = loadPatientMasterFileForAllHosp(study, brhosp);

fprintf('Loading Project Breathe clinical data\n');
fprintf('------------------------------------\n');

% for each hospital, get the list of patient files
for i = 1:size(brhosp, 1)
    % get latest clinical date for hospital and set correct source directory
    fprintf('Loading for %s\n', brhosp.Name{i});
    [clinprocdate, ~] = getLatestBreatheDatesForHosp(brhosp.Acronym{i});
    tmpfolder = sprintf('%s/%s/%s', subfolder, brhosp.Acronym{i}, clinprocdate);
    patfilelist = getListOfBreatheHospPatFiles(basedir, tmpfolder);
    for p = 1:size(patfilelist, 1)
        % for each patient file, extract the data and store in the clinical data tables
        [brPatient, brDrugTherapy, brAdmissions, brAntibiotics, brClinicVisits, brOtherVisits, brUnplannedContact, brCRP, brPFT, brMicrobiology, brHghtWght, brEndStudy] ...
            = loadBreatheClinDataForPatient(brPatient, brDrugTherapy, brAdmissions, brAntibiotics, brClinicVisits, brOtherVisits, brUnplannedContact, brCRP, brPFT, ...
                    brMicrobiology, brHghtWght, brEndStudy, patfilelist{p}, patientmaster, basedir, tmpfolder);
    end 
end
toc
fprintf('\n');

checkClinDataCompleteness(patientmaster, brPatient);

% sort rows
brDrugTherapy       = sortrows(brDrugTherapy,      {'ID', 'DrugTherapyStartDate'});
brAdmissions        = sortrows(brAdmissions,       {'ID', 'Admitted'});
brAntibiotics       = sortrows(brAntibiotics,      {'ID', 'StartDate', 'AntibioticName'});
brClinicVisits      = sortrows(brClinicVisits,     {'ID', 'AttendanceDate'});
brOtherVisits       = sortrows(brOtherVisits,      {'ID', 'AttendanceDate'});
brUnplannedContact  = sortrows(brUnplannedContact, {'ID', 'ContactDate'});
brPFT               = sortrows(brPFT,              {'ID', 'LungFunctionDate'});
brCRP               = sortrows(brCRP,              {'ID', 'CRPDate'});
brMicrobiology      = sortrows(brMicrobiology,     {'ID', 'DateMicrobiology'});
brHghtWght          = sortrows(brHghtWght,         {'ID', 'MeasDate'});

% data integrity checks
tic
fprintf('Data Integrity Checks\n');
fprintf('---------------------\n');
% patient data
idx = isnat(brPatient.StudyDate) | isnat(brPatient.DOB);
fprintf('Found %d Patients with blank dates\n', sum(idx));
if sum(idx) > 0
    brPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'StudyDate', 'DOB'})
    brPatient(idx, :) = [];
end
idx = brPatient.Height < 120 | brPatient.Height > 220;
fprintf('Found %d Patients height < 1.2m or > 2.2m\n', sum(idx));
if sum(idx) > 0
    brPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'Height'})
end
idx = brPatient.Weight < 35 | brPatient.Weight > 120;
fprintf('Found %d Patients weight < 35kg or > 120kg\n', sum(idx));
if sum(idx) > 0
    brPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'Weight'})
end
idx = brPatient.Age < 18 | brPatient.Age > 60;
fprintf('Found %d Patients aged < 18 or > 60\n', sum(idx));
if sum(idx) > 0
    brPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'StudyDate', 'DOB', 'Age', 'CalcAge', 'CalcAgeExact'})
end
idx = brPatient.Age ~= brPatient.CalcAge;
fprintf('Found %d Patients age inconsistent with age calculated from DOB\n', sum(idx));
if sum(idx) > 0
    brPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'StudyDate', 'DOB', 'Age', 'CalcAge', 'CalcAgeExact'})
end
idx = abs(brPatient.PredictedFEV1 - brPatient.CalcPredictedFEV1) > 0.05;
fprintf('Found %d Patients with predicted FEV1 inconsistent with that calculated from age, height, gender\n', sum(idx));
if sum(idx) > 0
    brPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'Age', 'PredictedFEV1', 'CalcPredictedFEV1'})
end

% drug therapy data
% TODO % clean drug therapy namings (see unique(brDrugTherapy.DrugTherapyType)
idx = isnat(brDrugTherapy.DrugTherapyStartDate);
fprintf('Found %d Drug Therapy rows with blank dates\n', sum(idx));
if sum(idx) > 0
    brDrugTherapy(idx,:)
    brDrugTherapy(idx, :) = [];
end

% admission data
idx = isnat(brAdmissions.Admitted) | isnat(brAdmissions.Discharge);
fprintf('Found %d Admissions with blank dates\n', sum(idx));
if sum(idx) > 0
    brAdmissions(idx,:)
    brAdmissions(idx, :) = [];
end
idx = brAdmissions.Discharge < brAdmissions.Admitted;
fprintf('Found %d Admissions with Discharge before Admission\n', sum(idx));
if sum(idx) > 0
    brAdmissions(idx,:)
    brAdmissions(idx, :) = [];
end
idx = days(brAdmissions.Discharge - brAdmissions.Admitted) > 30;
fprintf('Found %d Admissions > 1 month duration\n', sum(idx));
if sum(idx) > 0
    brAdmissions(idx,:)
    % do not delete this as they may be legitimate
    % brAdmissions(idx, :) = [];
end

% antibiotics data
idx = isnat(brAntibiotics.StartDate) & isnat(brAntibiotics.StopDate);
fprintf('Found %d Antibiotics with both blank dates\n', sum(idx));
if sum(idx) > 0
    brAntibiotics(idx,:)
    brAntibiotics(idx, :) = [];
end
idx = isnat(brAntibiotics.StartDate) & ~isnat(brAntibiotics.StopDate);
fprintf('Found %d Antibiotics with blank start dates\n', sum(idx));
if sum(idx) > 0
    brAntibiotics(idx,:)
    brAntibiotics(idx, :) = [];
end
idx = ~isnat(brAntibiotics.StartDate) & isnat(brAntibiotics.StopDate);
fprintf('Found %d Antibiotics with blank stop dates\n', sum(idx));
if sum(idx) > 0
    brAntibiotics(idx,:)
    brAntibiotics(idx, :) = [];
end
idx = brAntibiotics.StopDate < brAntibiotics.StartDate;
fprintf('Found %d Antibiotics with Stop Date before Start Date\n', sum(idx));
if sum(idx) > 0
    brAntibiotics(idx,:)
    brAntibiotics(idx, :) = [];
end
idx = days(brAntibiotics.StopDate - brAntibiotics.StartDate) > 30;
fprintf('Found %d Antibiotics > 1 month duration\n', sum(idx));
if sum(idx) > 0
    brAntibiotics(idx,:)
    % do not delete this as they may be legitimate
    %brAntibiotics(idx, :) = [];
end

% microbiology data
idx = isnat(brMicrobiology.DateMicrobiology);
fprintf('Found %d Microbiology records with blank dates\n', sum(idx));
%if sum(idx) > 0
%    brMicrobiology(idx,:)
%end

% clinic visits
idx = isnat(brClinicVisits.AttendanceDate);
fprintf('Found %d Clinic Visits with blank dates\n', sum(idx));
if sum(idx) > 0
    brClinicVisits(idx,:)
    brClinicVisits(idx, :) = [];
end

% other visits
idx = isnat(brOtherVisits.AttendanceDate);
fprintf('Found %d Other Visits with blank dates\n', sum(idx));
if sum(idx) > 0
    brOtherVisits(idx,:)
    brOtherVisits(idx, :) = [];
end

% unplanned contacts
idx = isnat(brUnplannedContact.ContactDate);
fprintf('Found %d Unplanned Contacts with blank dates\n', sum(idx));
if sum(idx) > 0
    brUnplannedContact(idx,:)
    brUnplannedContact(idx, :) = [];
end

% pft
idx = isnat(brPFT.LungFunctionDate);
fprintf('Found %d PFT measurements with blank dates\n', sum(idx));
if sum(idx) > 0
    brPFT(idx,:)
    brPFT(idx, :) = [];
end
idx = brPFT.FEV1 == 0;
fprintf('Found %d zero PFT measurements\n', sum(idx));
if sum(idx) > 0
    brPFT(idx,:)
    brPFT(idx, :) = [];
end
idx = brPFT.FEV1 > 6 | brPFT.FEV1 < 0.5;
fprintf('Found %d < 0.5l or > 6l PFT Clinical Measurements\n', sum(idx));
if sum(idx) > 0
    brPFT(idx,:)
    brPFT(idx, :) = [];
end

% crp
idx = isnat(brCRP.CRPDate);
fprintf('Found %d CRP measurements with blank dates\n', sum(idx));
if sum(idx) > 0
    brCRP(idx,:)
    brCRP(idx, :) = [];
end
idx = brCRP.NumericLevel > 200;
fprintf('Found %d > 200mg/L CRP measurements\n', sum(idx));
if sum(idx) > 0
    brCRP(idx,:)
end

% crp
idx = isnat(brHghtWght.MeasDate);
fprintf('Found %d Height Weight measurements with blank dates\n', sum(idx));
if sum(idx) > 0
    brHghtWght(idx,:)
    brHghtWght(idx, :) = [];
end
idx = brHghtWght.Weight < 35 | brHghtWght.Weight > 120;
fprintf('Found %d < 35kg or > 120kg Weight measurements\n', sum(idx));
if sum(idx) > 0
    brHghtWght(idx,:)
end
toc
fprintf('\n');

tic
fprintf('Checking for dates in the future\n');
brDrugTherapy(brDrugTherapy.DrugTherapyStartDate > datetime("today"),:)
brAdmissions(brAdmissions.Admitted > datetime("today"),:)
brAdmissions(brAdmissions.Discharge > datetime("today"),:)
brAntibiotics(brAntibiotics.StartDate > datetime("today"), :)
brAntibiotics(brAntibiotics.StopDate > datetime("today"),:)
brClinicVisits(brClinicVisits.AttendanceDate > datetime("today"),:)
brOtherVisits(brOtherVisits.AttendanceDate > datetime("today"),:)
brUnplannedContact(brUnplannedContact.ContactDate > datetime("today"),:)
brCRP(brCRP.CRPDate > datetime("today"),:)
brPFT(brPFT.LungFunctionDate > datetime("today"),:)
brHghtWght(brHghtWght.MeasDate > datetime("today"),:)
toc
fprintf('\n');

% save output files
tic
fprintf('\n');
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = 'breatheclinicaldata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder,outputfilename), 'brPatient', 'brDrugTherapy', 'brAdmissions', ...
    'brAntibiotics', 'brClinicVisits', 'brOtherVisits', 'brUnplannedContact', ...
    'brPFT', 'brCRP', 'brHghtWght', 'brMicrobiology', 'brEndStudy', 'patientmaster');
toc

% plot histograms by hospital and by month of last patient clinical data
% update

plotsacross = 2;
plotsdown   = ceil(size(brhosp, 1)/plotsacross);

pghght = 3 * plotsdown;
pgwdth = 7;

plottitle = sprintf('Histogram of patient clinical data by month of last update');
[f, p] = createFigureAndPanelForPaper(plottitle, pgwdth, pghght);

for i = 1:size(brhosp, 1)

    ax = subplot(plotsdown, plotsacross, i, 'Parent', p);

    histogram(ax, month(brPatient.PatClinDate(ismember(brPatient.Hospital, brhosp.Acronym(i)))));
    
    xlabel(ax, 'Month');
    ylabel(ax, 'Count');
    title(ax, brhosp.Name{i});
    xlim(ax, [1 12]);
    
    
end

plotsubfolder = sprintf('Plots/%s', study);
savePlotInDir(f, plottitle, plotsubfolder);
close(f);
    

