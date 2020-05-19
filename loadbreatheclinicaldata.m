clear; clc; close all;

basedir = setBaseDir();
subfolder = 'DataFiles/ProjectBreathe';
[clinicaldate, ~, ~] = getLatestBreatheDates();

clinicalfile1 = sprintf('PB Data sheet - Patient_Admissions_PFTs_1yrPFT_Clinics_Other-%s.xlsx', clinicaldate);
clinicalfile2 = sprintf('PB Data sheet - Antibiotics_CRP_MicroBiology_Unplanned-%s.xlsx', clinicaldate);

[brPatient, brAdmissions, brAntibiotics, brClinicVisits, brOtherVisits, brUnplannedContact, ...
    brCRP, brPFT, brMicrobiology, brHghtWght, brEndStudy] = createBreatheClinicalTables(0);
[brpatrow, bradmrow, brabrow, brcvrow, brovrow, brucrow, ...
    brcrprow, brpftrow, brmicrorow, ~, ~] = createBreatheClinicalTables(1);

% patient sheet
tic
fprintf('Loading Project Breathe patient data\n');
fprintf('------------------------------------\n');
opts = detectImportOptions(fullfile(basedir, subfolder, clinicalfile1), 'Sheet', 'Patients');
opts.VariableTypes(:, ismember(opts.VariableNames, {'StudyID'})) = {'char'};
patientdata = readtable(fullfile(basedir, subfolder, clinicalfile1), opts, 'Sheet', 'Patients');
npatients = size(patientdata, 1);
userid = 501;
hospital = 'PAP';
for i = 1:npatients
    if ~ismember(patientdata.StudyID{i}, '')
        brpatrow.ID                   = userid;
        brpatrow.Hospital             = hospital;
        brpatrow.StudyNumber          = patientdata.StudyID(i);
        brpatrow.StudyDate            = patientdata.StudyDate(i);
        brpatrow.Prior6Mnth           = brpatrow.StudyDate - calmonths(6);
        brpatrow.Post6Mnth            = brpatrow.StudyDate + calmonths(6);
        brpatrow.DOB                  = patientdata.DOB(i);
        brpatrow.Age                  = patientdata.Age(i);
        brpatrow.Sex                  = patientdata.Sex(i);
        brpatrow.Height               = patientdata.Height(i);
        brpatrow.Weight               = patientdata.Weight(i);
        brpatrow.PredictedFEV1        = patientdata.PredictedFEV1(i);
        brpatrow.FEV1SetAs            = round(patientdata.PredictedFEV1(i), 1);
        brpatrow.StudyEmail           = patientdata.StudyEmail(i);
        brpatrow.CFGene1              = patientdata.CFGene1(i);
        brpatrow.CFGene2              = patientdata.CFGene2(i);
        brpatrow.GeneralComments      = patientdata.Comments(i);
        brpatrow.DrugTherapyStartDate = patientdata.DrugTherapyStartDate(i);
        brpatrow.DrugTherapyType      = patientdata.DrugType(i);
        brpatrow.DrugTherapyComment   = patientdata.Comment(i);
        

        brpatrow.CalcAge                  = floor(years(brpatrow.StudyDate - brpatrow.DOB));
        brpatrow.CalcAgeExact             = years(brpatrow.StudyDate - brpatrow.DOB);
        brpatrow.CalcPredictedFEV1        = calcPredictedFEV1(brpatrow.CalcAge, brpatrow.Height, brpatrow.Sex);
        brpatrow.CalcPredictedFEV1OrigAge = calcPredictedFEV1(brpatrow.Age, brpatrow.Height, brpatrow.Sex);
        brpatrow.CalcFEV1SetAs            = round(calcPredictedFEV1(brpatrow.CalcAge, brpatrow.Height, brpatrow.Sex), 1);
        brpatrow.CalcFEV1SetAsOrigAge     = round(calcPredictedFEV1(brpatrow.Age, brpatrow.Height, brpatrow.Sex), 1);

        brPatient = [brPatient; brpatrow];
        userid = userid + 1;
    else
        fprintf('Row %d (spreadsheet row %d): Invalid StudyID %s\n',  i, i + 2, patientdata.StudyID{i});
    end
end
toc
fprintf('\n');

fprintf('Inconsitent Study Numbers and Emails\n');
fprintf('------------------------------------\n');
brPatient(~ismember(brPatient.StudyNumber, strrep(strrep(brPatient.StudyEmail, 'projectb', ''), '@gmail.com', '')), :)


% admission data
tic
fprintf('Loading Project Breathe admission data\n');
fprintf('--------------------------------------\n');
opts = detectImportOptions(fullfile(basedir, subfolder, clinicalfile1), 'Sheet', 'Admissions');
opts.VariableTypes(:, ismember(opts.VariableNames, {'StudyID'})) = {'char'};
opts.DataRange = 'A3';
admdata = readtable(fullfile(basedir, subfolder, clinicalfile1), opts, 'Sheet', 'Admissions');
nadm = size(admdata, 1);
for i = 1:nadm
    if size(brPatient.ID(ismember(brPatient.StudyNumber, admdata.StudyID(i))), 1) == 0
        fprintf('Row %d (spreadsheet row %d): Invalid StudyID %s\n',  i, i + 2, admdata.StudyID{i});
    else
        bradmrow.ID          = brPatient.ID(ismember(brPatient.StudyNumber, admdata.StudyID(i)));
        bradmrow.Hospital    = hospital;
        bradmrow.StudyNumber = admdata.StudyID(i);
        bradmrow.Admitted    = admdata.Admitted(i);
        bradmrow.Discharge   = admdata.Discharge(i);

        brAdmissions = [brAdmissions; bradmrow];
    end
end
toc
fprintf('\n');

% antibiotic data
tic
fprintf('Loading Project Breathe antibiotic data\n');
fprintf('---------------------------------------\n');
opts = detectImportOptions(fullfile(basedir, subfolder, clinicalfile2), 'Sheet', 'Antibiotics');
opts.VariableTypes(:, ismember(opts.VariableNames, {'StudyID'})) = {'char'};
opts.DataRange = 'A3';
abdata = readtable(fullfile(basedir, subfolder, clinicalfile2), opts, 'Sheet', 'Antibiotics');
nab = size(abdata, 1);
for i = 1:nab
    if size(brPatient.ID(ismember(brPatient.StudyNumber, abdata.StudyID(i))), 1) == 0
    %if size(brPatient.ID(ismember(brPatient.StudyEmail, abdata.StudyID(i))), 1) == 0
        fprintf('Row %d (spreadsheet row %d): Invalid StudyID %s\n',  i, i + 2, abdata.StudyID{i});
    else
        brabrow.ID          = brPatient.ID(ismember(brPatient.StudyNumber, abdata.StudyID(i)));
        %brabrow.ID          = brPatient.ID(ismember(brPatient.StudyEmail, abdata.StudyID(i)));
        brabrow.Hospital    = hospital;
        brabrow.StudyNumber = abdata.StudyID(i);
        brabrow.AntibioticName = abdata.AntibioticName(i);
        brabrow.Route          = abdata.Route(i);
        if size(abdata.HomeIV_s{i}, 1) == 0
            if ismember(brabrow.Route, 'Oral')
                brabrow.HomeIV_s = 'No';
            elseif ismember(brabrow.Route, 'IV')
                fprintf('Row %d (spreadsheet row %d): IV Treatment with blank Home IV field\n', i, i + 2);
            end
        else
            brabrow.HomeIV_s       = abdata.HomeIV_s(i);
        end
        brabrow.StartDate      = abdata.StartDate(i);
        brabrow.StopDate       = abdata.StopDate(i);
        brabrow.Comments       = abdata.Comments(i);
    
        brAntibiotics = [brAntibiotics; brabrow];
    end
end
toc
fprintf('\n');

% microbiology data
tic
fprintf('Loading Project Breathe microbiology data\n');
fprintf('-----------------------------------------\n');
opts = detectImportOptions(fullfile(basedir, subfolder, clinicalfile2), 'Sheet', 'Microbiology');
opts.VariableTypes(:, ismember(opts.VariableNames, {'StudyID'})) = {'char'};
opts.DataRange = 'A3';
microdata = readtable(fullfile(basedir, subfolder, clinicalfile2), opts, 'Sheet', 'Microbiology');
nmicro = size(microdata, 1);
for i = 1:nmicro
    if size(brPatient.ID(ismember(brPatient.StudyNumber, microdata.StudyID(i))), 1) == 0
        fprintf('Row %d (spreadsheet row %d): Invalid StudyID %s\n',  i, i + 2, microdata.StudyID{i});
    else
        brmicrorow.ID               = brPatient.ID(ismember(brPatient.StudyNumber, microdata.StudyID(i)));
        brmicrorow.Hospital         = hospital;
        brmicrorow.StudyNumber      = microdata.StudyID(i);
        brmicrorow.Microbiology     = microdata.Microbiology(i);
        brmicrorow.DateMicrobiology = microdata.DateFirstSeen(i);
        brmicrorow.NameIfOther      = microdata.NameIfOther(i);

        brMicrobiology = [brMicrobiology; brmicrorow];
    end
end
toc
fprintf('\n');

tic
fprintf('Loading Project Breathe clinic visits data\n');
fprintf('------------------------------------------\n');
opts = detectImportOptions(fullfile(basedir, subfolder, clinicalfile1), 'Sheet', 'Clinic Visits');
opts.VariableTypes(:, ismember(opts.VariableNames, {'StudyID'})) = {'char'};
opts.DataRange = 'A3';
cvdata = readtable(fullfile(basedir, subfolder, clinicalfile1), opts, 'Sheet', 'Clinic Visits');
ncv = size(cvdata, 1);
for i = 1:ncv
    % fprintf('%d\n', i);
    if size(brPatient.ID(ismember(brPatient.StudyNumber, cvdata.StudyID(i))), 1) == 0
        fprintf('Row %d (spreadsheet row %d): Invalid StudyID %s\n',  i, i + 2, cvdata.StudyID{i});
    else
        brcvrow.ID               = brPatient.ID(ismember(brPatient.StudyNumber, cvdata.StudyID(i)));
        brcvrow.Hospital         = hospital;
        brcvrow.StudyNumber      = cvdata.StudyID(i);
        brcvrow.AttendanceDate   = cvdata.AttendanceDate(i);
        brcvrow.Location         = cvdata.Location(i);
    
        brClinicVisits = [brClinicVisits; brcvrow];
    end
end
toc
fprintf('\n');

tic
fprintf('Loading Project Breathe other visits data\n');
fprintf('-----------------------------------------\n');
opts = detectImportOptions(fullfile(basedir, subfolder, clinicalfile1), 'Sheet', 'Other Visits');
opts.VariableTypes(:, ismember(opts.VariableNames, {'StudyID'})) = {'char'};
opts.DataRange = 'A3';
ovdata = readtable(fullfile(basedir, subfolder, clinicalfile1), opts, 'Sheet', 'Other Visits');
nov = size(ovdata, 1);
for i = 1:nov
    if size(brPatient.ID(ismember(brPatient.StudyNumber, ovdata.StudyID(i))), 1) == 0
        fprintf('Row %d (spreadsheet row %d): Invalid StudyID %s\n',  i, i + 2, ovdata.StudyID{i});
    else
        brovrow.ID               = brPatient.ID(ismember(brPatient.StudyNumber, ovdata.StudyID(i)));
        brovrow.Hospital         = hospital;
        brovrow.StudyNumber      = ovdata.StudyID(i);
        brovrow.AttendanceDate   = ovdata.AttendanceDate(i);
        brovrow.VisitType        = ovdata.TypeOfVisit(i);

        brOtherVisits = [brOtherVisits; brovrow];
    end
end
toc
fprintf('\n');

tic
fprintf('Loading Project Breathe unplanned contact data\n');
fprintf('----------------------------------------------\n');
opts = detectImportOptions(fullfile(basedir, subfolder, clinicalfile2), 'Sheet', 'Unplanned Contacts');
opts.VariableTypes(:, ismember(opts.VariableNames, {'StudyID'})) = {'char'};
opts.DataRange = 'A3';
ucdata = readtable(fullfile(basedir, subfolder, clinicalfile2), opts, 'Sheet', 'Unplanned Contacts');
nuc = size(ucdata, 1);
for i = 1:nuc
    if size(brPatient.ID(ismember(brPatient.StudyNumber, ucdata.StudyID(i))), 1) == 0
        fprintf('Row %d (spreadsheet row %d): Invalid StudyID %s\n',  i, i + 2, ucdata.StudyID{i});
    else
        brucrow.ID               = brPatient.ID(ismember(brPatient.StudyNumber, ucdata.StudyID(i)));
        brucrow.Hospital         = hospital;
        brucrow.StudyNumber      = ucdata.StudyID(i);
        brucrow.ContactDate      = ucdata.Date(i);
        brucrow.TypeOfContact    = ucdata.TypeOfContact(i);

        brUnplannedContact = [brUnplannedContact; brucrow];
    end
end
toc
fprintf('\n');

tic
fprintf('Loading Project Breathe PFT data\n');
fprintf('--------------------------------\n');
opts = detectImportOptions(fullfile(basedir, subfolder, clinicalfile1), 'Sheet', 'PFTs');
opts.VariableTypes(:, ismember(opts.VariableNames, {'StudyID'})) = {'char'};
opts.DataRange = 'A3';
pftdata = readtable(fullfile(basedir, subfolder, clinicalfile1), opts, 'Sheet', 'PFTs');

opts = detectImportOptions(fullfile(basedir, subfolder, clinicalfile1), 'Sheet', '1yr PFTs');
opts.VariableTypes(:, ismember(opts.VariableNames, {'StudyID'})) = {'char'};
opts.DataRange = 'A3';
pft1Ydata = readtable(fullfile(basedir, subfolder, clinicalfile1), opts, 'Sheet', '1yr PFTs');

pftdata = [pftdata; pft1Ydata];

npft = size(pftdata, 1);
for i = 1:npft
    if size(brPatient.ID(ismember(brPatient.StudyNumber, pftdata.StudyID(i))), 1) == 0
        fprintf('Row %d (spreadsheet row %d): Invalid StudyID %s\n',  i, i + 2, pftdata.StudyID{i});
    else
        brpftrow.ID                 = brPatient.ID(ismember(brPatient.StudyNumber, pftdata.StudyID(i)));
        brpftrow.Hospital           = hospital;
        brpftrow.StudyNumber        = pftdata.StudyID(i);
        brpftrow.LungFunctionDate   = pftdata.LungFunctionDate(i);
        brpftrow.FEV1               = pftdata.FEV1(i);
        brpftrow.Units              = {'L'};
        fev1setas                   = brPatient.FEV1SetAs(ismember(brPatient.StudyNumber, pftdata.StudyID(i)));
        calcfev1setas               = brPatient.CalcFEV1SetAs(ismember(brPatient.StudyNumber, pftdata.StudyID(i)));
        brpftrow.FEV1_              = 100 * brpftrow.FEV1 / fev1setas;
        brpftrow.CalcFEV1_          = 100 * brpftrow.FEV1 / calcfev1setas;

        brPFT = [brPFT; brpftrow];
    end
end
toc
fprintf('\n');

tic
fprintf('Loading Project Breathe CRP data\n');
fprintf('--------------------------------\n');
opts = detectImportOptions(fullfile(basedir, subfolder, clinicalfile2), 'Sheet', 'CRPs');
opts.VariableTypes(:, ismember(opts.VariableNames, {'StudyID'})) = {'char'};
opts.DataRange = 'A3';
crpdata = readtable(fullfile(basedir, subfolder, clinicalfile2), opts, 'Sheet', 'CRPs');
ncrp = size(crpdata, 1);
for i = 1:ncrp
    if size(brPatient.ID(ismember(brPatient.StudyNumber, crpdata.StudyID(i))), 1) == 0
        fprintf('Row %d (spreadsheet row %d): Invalid StudyID %s\n',  i, i + 2, crpdata.StudyID{i});
    else
        brcrprow.ID                 = brPatient.ID(ismember(brPatient.StudyNumber, crpdata.StudyID(i)));
        brcrprow.Hospital           = hospital;
        brcrprow.StudyNumber        = crpdata.StudyID(i);
        brcrprow.CRPDate            = crpdata.CRPDate(i);
        brcrprow.Level              = crpdata.Level(i);
        brcrprow.NumericLevel       = crpdata.Level(i);
        brcrprow.Units              = {'mg/L'};
        brcrprow.PatientAntibiotics = crpdata.PatientAntibiotics(i);

        brCRP = [brCRP; brcrprow];
    end
end
toc
fprintf('\n');

% sort rows
brAdmissions        = sortrows(brAdmissions,       {'ID', 'Admitted'});
brAntibiotics       = sortrows(brAntibiotics,      {'ID', 'StartDate', 'AntibioticName'});
brClinicVisits      = sortrows(brClinicVisits,     {'ID', 'AttendanceDate'});
brOtherVisits       = sortrows(brOtherVisits,      {'ID', 'AttendanceDate'});
brUnplannedContact  = sortrows(brUnplannedContact, {'ID', 'ContactDate'});
brPFT               = sortrows(brPFT,              {'ID', 'LungFunctionDate'});
brCRP               = sortrows(brCRP,              {'ID', 'CRPDate'});
brMicrobiology      = sortrows(brMicrobiology,     {'ID', 'DateMicrobiology'});

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
toc
fprintf('\n');

tic
fprintf('Checking for dates in the future\n');
brAdmissions(brAdmissions.Admitted > datetime("today"),:)
brAdmissions(brAdmissions.Discharge > datetime("today"),:)
brAntibiotics(brAntibiotics.StartDate > datetime("today"), :)
brAntibiotics(brAntibiotics.StopDate > datetime("today"),:)
brClinicVisits(brClinicVisits.AttendanceDate > datetime("today"),:)
brOtherVisits(brOtherVisits.AttendanceDate > datetime("today"),:)
brUnplannedContact(brUnplannedContact.ContactDate > datetime("today"),:)
brCRP(brCRP.CRPDate > datetime("today"),:)
brPFT(brPFT.LungFunctionDate > datetime("today"),:)
toc
fprintf('\n');

% save output files
tic
fprintf('\n');
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = 'breatheclinicaldata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder,outputfilename), 'brPatient', 'brMicrobiology', ...
    'brClinicVisits', 'brOtherVisits', 'brUnplannedContact', 'brPFT', 'brHghtWght', ...
    'brAdmissions', 'brAntibiotics', 'brCRP', 'brEndStudy');
toc






