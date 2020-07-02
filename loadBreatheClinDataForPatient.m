function [brPatient, brAdmissions, brAntibiotics, brClinicVisits, brOtherVisits, brUnplannedContact, brCRP, brPFT, brMicrobiology, brHghtWght, brEndStudy] ...
            = loadBreatheClinDataForPatient(brPatient, brAdmissions, brAntibiotics, brClinicVisits, brOtherVisits, brUnplannedContact, brCRP, brPFT, ...
                    brMicrobiology, brHghtWght, brEndStudy, patfile, basedir, subfolder)
                
% loadBreatheClinDataForPatient - ingests the clinical data for a given
% patient

[brpatrow, bradmrow, brabrow, brcvrow, brovrow, brucrow, ...
    brcrprow, brpftrow, brmicrorow, brhwrow, ~] = createBreatheClinicalTables(1);

% patient sheet
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'Patient');
opts.VariableTypes(:, ismember(opts.VariableNames, {'StudyID'}))    = {'char'};
opts.VariableTypes(:, ismember(opts.VariableNames, {'StudyDate'}))  = {'datetime'};
opts.VariableTypes(:, ismember(opts.VariableNames, {'Prior6Mnth'})) = {'datetime'};
opts.VariableTypes(:, ismember(opts.VariableNames, {'Post6Mnth'}))  = {'datetime'};
opts.VariableTypes(:, ismember(opts.VariableNames, {'DOB'}))        = {'datetime'};
patientdata = readtable(fullfile(basedir, subfolder, patfile), opts, 'Sheet', 'Patient');
npatients = size(patientdata, 1); % NB should always be 1 as sheets are per patient

if npatients ~= 1
    fprintf('**** More than one patient in this single patient file ****\n');
    return;
end
if ismember(patientdata.ID(1), '')
    fprintf('**** Blank patient id in this file ****\n');
    return;
end
i = 1;
scid                          = patientdata.ID(i);
hospital                      = patientdata.Hospital(i);
studynbr                      = patientdata.StudyNumber(i);
fprintf('Patient data - ID = %d, hospital = %3s, study number = %s\n', scid, hospital{1}, studynbr{1});

brpatrow.ID                   = scid;
brpatrow.Hospital             = hospital;
brpatrow.StudyNumber          = studynbr;
brpatrow.StudyDate            = patientdata.StudyDate(1);
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
brpatrow.GeneralComments      = patientdata.GeneralComments(i);
brpatrow.DrugTherapyStartDate = patientdata.DrugTherapyStartDate(i);
brpatrow.DrugTherapyType      = patientdata.DrugTherapyType(i);
brpatrow.DrugTherapyComment   = patientdata.DrugTherapyComment(i);

brpatrow.CalcAge                  = floor(years(brpatrow.StudyDate - brpatrow.DOB));
brpatrow.CalcAgeExact             = years(brpatrow.StudyDate - brpatrow.DOB);
brpatrow.CalcPredictedFEV1        = calcPredictedFEV1(brpatrow.CalcAge, brpatrow.Height, brpatrow.Sex);
brpatrow.CalcPredictedFEV1OrigAge = calcPredictedFEV1(brpatrow.Age, brpatrow.Height, brpatrow.Sex);
brpatrow.CalcFEV1SetAs            = round(calcPredictedFEV1(brpatrow.CalcAge, brpatrow.Height, brpatrow.Sex), 1);
brpatrow.CalcFEV1SetAsOrigAge     = round(calcPredictedFEV1(brpatrow.Age, brpatrow.Height, brpatrow.Sex), 1);

brPatient = [brPatient; brpatrow];

%if ~ismember(brPatient.StudyNumber, strrep(strrep(brPatient.StudyEmail, 'projectb', ''), '@gmail.com', ''))
if ~ismember(brpatrow.StudyNumber, brpatrow.StudyEmail)
    fprintf('**** Study Number is inconsistent with Study Email ****\n');
end

% admission data
fprintf('Admissions         ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'Admissions');
opts.DataRange = 'A2';
admdata = readtable(fullfile(basedir, subfolder, patfile), opts, 'Sheet', 'Admissions');
nadm = size(admdata, 1);
fprintf('%2d rows\n', nadm);
for i = 1:nadm
    bradmrow.ID          = scid;
    bradmrow.Hospital    = hospital;
    bradmrow.StudyNumber = studynbr;
    bradmrow.Admitted    = admdata.Admitted(i);
    bradmrow.Discharge   = admdata.Discharge(i);

    brAdmissions = [brAdmissions; bradmrow];
end

% antibiotic data
fprintf('Antibiotics        ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'Antibiotics');
opts.DataRange = 'A2';
abdata = readtable(fullfile(basedir, subfolder, patfile), opts, 'Sheet', 'Antibiotics');
nab = size(abdata, 1);
fprintf('%2d rows\n', nab);
for i = 1:nab
    brabrow.ID          = scid;
    brabrow.Hospital    = hospital;
    brabrow.StudyNumber = studynbr;
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

% microbiology data
fprintf('Microbiology       ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'Microbiology');
opts.DataRange = 'A2';
microdata = readtable(fullfile(basedir, subfolder, patfile), opts, 'Sheet', 'Microbiology');
nmicro = size(microdata, 1);
fprintf('%2d rows\n', nmicro);
for i = 1:nmicro
    brmicrorow.ID               = scid;
    brmicrorow.Hospital         = hospital;
    brmicrorow.StudyNumber      = studynbr;
    brmicrorow.Microbiology     = microdata.Microbiology(i);
    brmicrorow.DateMicrobiology = microdata.DateMicrobiology(i);
    brmicrorow.NameIfOther      = microdata.NameIfOther(i);

    brMicrobiology = [brMicrobiology; brmicrorow];
end

fprintf('Clinic visits      ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'ClinicVisits');
opts.DataRange = 'A2';
cvdata = readtable(fullfile(basedir, subfolder, patfile), opts, 'Sheet', 'ClinicVisits');
ncv = size(cvdata, 1);
fprintf('%2d rows\n', ncv);
for i = 1:ncv
    brcvrow.ID               = scid;
    brcvrow.Hospital         = hospital;
    brcvrow.StudyNumber      = studynbr;
    brcvrow.AttendanceDate   = cvdata.AttendanceDate(i);
    brcvrow.Location         = cvdata.Location(i);

    brClinicVisits = [brClinicVisits; brcvrow];
end

fprintf('Other visits       ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'OtherVisits');
opts.DataRange = 'A2';
ovdata = readtable(fullfile(basedir, subfolder, patfile), opts, 'Sheet', 'OtherVisits');
nov = size(ovdata, 1);
fprintf('%2d rows\n', nov);
for i = 1:nov
    brovrow.ID               = scid;
    brovrow.Hospital         = hospital;
    brovrow.StudyNumber      = studynbr;
    brovrow.AttendanceDate   = ovdata.AttendanceDate(i);
    brovrow.VisitType        = ovdata.VisitType(i);

    brOtherVisits = [brOtherVisits; brovrow];
end

fprintf('Unplanned contacts ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'UnplannedContacts');
opts.DataRange = 'A2';
ucdata = readtable(fullfile(basedir, subfolder, patfile), opts, 'Sheet', 'UnplannedContacts');
nuc = size(ucdata, 1);
fprintf('%2d rows\n', nuc);
for i = 1:nuc
    brucrow.ID               = scid;
    brucrow.Hospital         = hospital;
    brucrow.StudyNumber      = studynbr;
    brucrow.ContactDate      = ucdata.ContactDate(i);
    brucrow.TypeOfContact    = ucdata.TypeOfContact(i);

    brUnplannedContact = [brUnplannedContact; brucrow];
end

fprintf('PFTs               ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'PFTs');
opts.DataRange = 'A2';
pftdata = readtable(fullfile(basedir, subfolder, patfile), opts, 'Sheet', 'PFTs');
npft = size(pftdata, 1);
fprintf('%2d rows\n', npft);
for i = 1:npft
    brpftrow.ID                 = scid;
    brpftrow.Hospital           = hospital;
    brpftrow.StudyNumber        = studynbr;
    brpftrow.LungFunctionDate   = pftdata.LungFunctionDate(i);
    brpftrow.FEV1               = pftdata.FEV1(i);
    brpftrow.Units              = {'L'};
    fev1setas                   = brPatient.FEV1SetAs(1);
    calcfev1setas               = brPatient.CalcFEV1SetAs(1);
    brpftrow.FEV1_              = 100 * brpftrow.FEV1 / fev1setas;
    brpftrow.CalcFEV1_          = 100 * brpftrow.FEV1 / calcfev1setas;

    brPFT = [brPFT; brpftrow];
end

fprintf('CRPs               ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'CRPs');
opts.DataRange = 'A2';
crpdata = readtable(fullfile(basedir, subfolder, patfile), opts, 'Sheet', 'CRPs');
ncrp = size(crpdata, 1);
fprintf('%2d rows\n', ncrp);
for i = 1:ncrp
    brcrprow.ID                 = scid;
    brcrprow.Hospital           = hospital;
    brcrprow.StudyNumber        = studynbr;
    brcrprow.CRPDate            = crpdata.CRPDate(i);
    brcrprow.Level              = crpdata.Level(i);
    brcrprow.NumericLevel       = crpdata.Level(i);
    brcrprow.Units              = {'mg/L'};
    brcrprow.PatientAntibiotics = crpdata.PatientAntibiotics(i);

    brCRP = [brCRP; brcrprow];
end

fprintf('HeightWeight       ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'HeightWeight');
opts.DataRange = 'A2';
hwdata = readtable(fullfile(basedir, subfolder, patfile), opts, 'Sheet', 'HeightWeight');
nhw = size(hwdata, 1);
fprintf('%2d rows\n', nhw);
for i = 1:nhw
    brhwrow.ID                 = scid;
    brhwrow.Hospital           = hospital;
    brhwrow.StudyNumber        = studynbr;
    brhwrow.MeasDate           = hwdata.MeasDate(i);
    brhwrow.Height             = hwdata.Height(i);
    brhwrow.H_ZScore           = hwdata.H_ZScore(i);
    brhwrow.Weight             = hwdata.Weight(i);
    brhwrow.W_ZScore           = hwdata.W_ZScore(i);
    brhwrow.BMI                = hwdata.BMI(i);
    
    brHghtWght = [brHghtWght; brhwrow];
end

end

