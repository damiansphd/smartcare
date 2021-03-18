function [brPatient, brDrugTherapy, brAdmissions, brAntibiotics, brClinicVisits, brOtherVisits, ...
            brUnplannedContact, brCRP, brPFT, brMicrobiology, brHghtWght, brEndStudy] ...
            = loadBreatheClinDataForPatient(brPatient, brDrugTherapy, brAdmissions, brAntibiotics, ...
                brClinicVisits, brOtherVisits, brUnplannedContact, brCRP, brPFT, brMicrobiology, ...
                brHghtWght, brEndStudy, patfile, patientmaster, basedir, subfolder)
                
% loadBreatheClinDataForPatient - ingests the clinical data for a given
% patient

tmpstring = strrep(patfile, '.xlsx', '');
tmplen    = strlength(tmpstring);

patclindate = datetime(extractAfter(tmpstring, tmplen-8), 'InputFormat', 'yyyyMMdd');

[brpatrow, brdrugtherrow, bradmrow, brabrow, brcvrow, brovrow, brucrow, ...
    brcrprow, brpftrow, brmicrorow, brhwrow, ~] = createBreatheClinicalTables(1);

% patient sheet
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'Patient');
opts.VariableTypes(:, ismember(opts.VariableNames, {'StudyID'}))     = {'char'};
opts.VariableTypes(:, ismember(opts.VariableNames, {'StudyDate'}))   = {'datetime'};
opts.VariableTypes(:, ismember(opts.VariableNames, {'Prior6Mnth'}))  = {'datetime'};
opts.VariableTypes(:, ismember(opts.VariableNames, {'Post6Mnth'}))   = {'datetime'};
%opts.VariableTypes(:, ismember(opts.VariableNames, {'PatClinDate'})) = {'datetime'};
opts.VariableTypes(:, ismember(opts.VariableNames, {'DOB'}))         = {'datetime'};
opts = setvaropts(opts,{'StudyDate'},'InputFormat','MM/dd/yyyy');
opts = setvaropts(opts,{'Prior6Mnth'},'InputFormat','MM/dd/yyyy');
opts = setvaropts(opts,{'Post6Mnth'},'InputFormat','MM/dd/yyyy');
%opts = setvaropts(opts,{'PatClinDate'},'InputFormat','MM/dd/yyyy');
opts = setvaropts(opts,{'DOB'},'InputFormat','MM/dd/yyyy');
patientdata = readtable(fullfile(basedir, subfolder, patfile), opts, 'Sheet', 'Patient');
npatrows = size(patientdata, 1); % NB should always be 1 as sheets are per patient

%if npatrows ~= 1
%    fprintf('**** More than one patient in this single patient file ****\n');
%    return;
%end
%if ismember(patientdata.ID(1), '')
%    fprintf('**** Blank patient id in this file ****\n');
%    return;
%end
i = 1;
%scid                          = patientdata.ID(i);
hospital                      = patientdata.Hospital(i);

% add consistency check for study number and study email 
% needed due to either old papworth s/s formats or an incorrect decision to update study number)
studynbr                      = lower(patientdata.StudyNumber(i));
if ~ismember(patientdata.StudyNumber(i), patientdata.StudyEmail(i))
    fprintf('**** Study Number is inconsistent with Study Email - using Study Email instead\n');
    studynbr                  = lower(patientdata.StudyEmail(i));
end

scid = patientmaster.ID(ismember(patientmaster.StudyNumber, studynbr));
if isnan(scid)
    fprintf('**** Blank patient id in this file ****\n');
    return;
end

fprintf('Patient data - ID = %d, hospital = %3s, study number = %s\n', scid, hospital{1}, studynbr{1});

brpatrow.ID                   = scid;
brpatrow.Hospital             = hospital;
brpatrow.StudyNumber          = studynbr;
brpatrow.StudyDate            = patientdata.StudyDate(i);
if isnat(brpatrow.StudyDate)
    fprintf('**** Blank study date in this file ****\n');
    return;
end
brpatrow.Prior6Mnth           = brpatrow.StudyDate - calmonths(6);
brpatrow.Post6Mnth            = brpatrow.StudyDate + calmonths(6);
brpatrow.PatClinDate          = patclindate;

% temporarily comment out this check until papworth spreadsheet format can
% be brought up to date
%if patclindate ~= patientdata.PatClinDate(i)
%    fprintf ('**** Inconsistency between patient clinical update date in filename and patient tab ****\n');
%end

brpatrow.DOB                  = patientdata.DOB(i);
brpatrow.Age                  = patientdata.Age(i);
gender = patientdata.Sex{i};
if size(gender, 2) == 0
    fprintf('Blank Gender %s\n', gender);
    return
end 
if gender(1) == 'M' || gender(1) == 'm'
    brpatrow.Sex = {'Male'};
elseif gender(1) == 'F' || gender(1) == 'f'
    brpatrow.Sex = {'Female'};
else
    fprintf('Unknown Gender %s\n', gender);
    return
end
brpatrow.Height               = patientdata.Height(i);
brpatrow.Weight               = patientdata.Weight(i);
brpatrow.PredictedFEV1        = patientdata.PredictedFEV1(i);
brpatrow.FEV1SetAs            = round(patientdata.PredictedFEV1(i), 1);
brpatrow.StudyEmail           = patientdata.StudyEmail(i);
brpatrow.CFGene1              = patientdata.CFGene1(i);
brpatrow.CFGene2              = patientdata.CFGene2(i);
brpatrow.GeneralComments      = patientdata.GeneralComments(i);

brpatrow.CalcAge                  = floor(years(brpatrow.StudyDate - brpatrow.DOB));
brpatrow.CalcAgeExact             = years(brpatrow.StudyDate - brpatrow.DOB);
brpatrow.CalcPredictedFEV1        = calcPredictedFEV1(brpatrow.CalcAge, brpatrow.Height, brpatrow.Sex);
brpatrow.CalcPredictedFEV1OrigAge = calcPredictedFEV1(brpatrow.Age, brpatrow.Height, brpatrow.Sex);
brpatrow.CalcFEV1SetAs            = round(calcPredictedFEV1(brpatrow.CalcAge, brpatrow.Height, brpatrow.Sex), 1);
brpatrow.CalcFEV1SetAsOrigAge     = round(calcPredictedFEV1(brpatrow.Age, brpatrow.Height, brpatrow.Sex), 1);

brPatient = [brPatient; brpatrow];

if ~ismember(brpatrow.StudyNumber, brpatrow.StudyEmail)
    fprintf('**** Study Number is inconsistent with Study Email ****\n');
end

% temporary logic in case any spreadsheets in old format are to be
% processed
if ismember(hospital, 'XXX')
    fprintf('Drug Therapy       ');

    ndrthrows = 0;
    for i = 1:npatrows
        if size(patientdata.DrugTherapyType{i}, 2) > 1
            brdrugtherrow.ID                   = scid;
            brdrugtherrow.Hospital             = hospital;
            brdrugtherrow.StudyNumber          = studynbr;
            brdrugtherrow.DrugTherapyStartDate = patientdata.DrugTherapyStartDate(i);
            brdrugtherrow.DrugTherapyType      = patientdata.DrugTherapyType(i);
            brdrugtherrow.DrugTherapyComment   = patientdata.DrugTherapyComment(i);

           brDrugTherapy = [brDrugTherapy; brdrugtherrow];
            ndrthrows = ndrthrows + 1;
        end
    end
    fprintf('%2d rows\n', ndrthrows);

else
    % replace with this code after all clinical spreadsheets have been
    % recreated.
    % and all the comments fields in each table lower down

    % drug therapy data
    fprintf('Drug Therapy       ');
    opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'DrugTherapy');
    opts.VariableTypes(:, ismember(opts.VariableNames, {'DrugTherapyStartDate'})) = {'datetime'};
    opts.DataRange = 'A2';
    drthdata = readtable(fullfile(basedir, subfolder, patfile), opts, 'Sheet', 'DrugTherapy');
    ndrth = size(drthdata, 1);
    fprintf('%2d rows\n', ndrth);
    for i = 1:ndrth
        brdrugtherrow.ID                    = scid;
        brdrugtherrow.Hospital              = hospital;
        brdrugtherrow.StudyNumber           = studynbr;
        brdrugtherrow.DrugTherapyStartDate  = drthdata.DrugTherapyStartDate(i);
        brdrugtherrow.DrugTherapyType       = drthdata.DrugTherapyType(i);
        brdrugtherrow.DrugTherapyComment    = drthdata.DrugTherapyComment(i);

        brDrugTherapy = [brDrugTherapy; brdrugtherrow];
    end
end

% admission data
fprintf('Admissions         ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'Admissions');
opts.VariableTypes(:, ismember(opts.VariableNames, {'Admitted'}))         = {'datetime'};
opts.VariableTypes(:, ismember(opts.VariableNames, {'Discharge'}))         = {'datetime'};
opts = setvaropts(opts,{'Admitted'},'InputFormat','MM/dd/yyyy');
opts = setvaropts(opts,{'Discharge'},'InputFormat','MM/dd/yyyy');
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
    bradmrow.Comments    = admdata.Comments(i);

    brAdmissions = [brAdmissions; bradmrow];
end

% antibiotic data
fprintf('Antibiotics        ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'Antibiotics');
opts.VariableTypes(:, ismember(opts.VariableNames, {'StartDate'}))         = {'datetime'};
opts.VariableTypes(:, ismember(opts.VariableNames, {'StopDate'}))         = {'datetime'};
opts = setvaropts(opts,{'StartDate'},'InputFormat','MM/dd/yyyy');
opts = setvaropts(opts,{'StopDate'},'InputFormat','MM/dd/yyyy');
opts.DataRange = 'A2';
abdata = readtable(fullfile(basedir, subfolder, patfile), opts, 'Sheet', 'Antibiotics');
nab = size(abdata, 1);
fprintf('%2d rows\n', nab);
for i = 1:nab
    brabrow.ID          = scid;
    brabrow.Hospital    = hospital;
    brabrow.StudyNumber = studynbr;
    if size(abdata.AntibioticName{i}, 2) == 0
        fprintf('**** skipping blank row in s/s ****\n');
        continue;
    end
    brabrow.AntibioticName = abdata.AntibioticName(i);
    route = abdata.Route{i};
    if route(1) == 'O' || route(1) == 'o' || route(1) == 'P' || route(1) == 'p'
        brabrow.Route = {'Oral'};
    elseif route(1) == 'I' || route(1) == 'i'
        brabrow.Route = {'IV'};
    else
        fprintf('**** Unknown Route %s ****\n', route);
        continue;
    end
    if size(abdata.HomeIV_s{i}, 1) == 0
        if ismember(brabrow.Route, 'Oral')
            brabrow.HomeIV_s = 'No';
        elseif ismember(brabrow.Route, 'IV')
            fprintf('Row %d (spreadsheet row %d): IV Treatment with blank Home IV field\n', i, i + 2);
        end
    else
        homeiv = abdata.HomeIV_s{i};
        brabrow.HomeIV_s       = abdata.HomeIV_s(i);
        if homeiv(1) == 'N' || homeiv(1) == 'n'
            brabrow.HomeIV_s = {'No'};
        elseif homeiv(1) == 'Y' || homeiv(1) == 'y'
            brabrow.HomeIV_s = {'Yes'};
        else
            fprintf('Unknown Home IVs %s\n', homeiv);
        end
    end
    brabrow.StartDate      = abdata.StartDate(i);
    brabrow.StopDate       = abdata.StopDate(i);
    brabrow.Comments       = abdata.Comments(i);

    brAntibiotics = [brAntibiotics; brabrow];
end

% microbiology data
fprintf('Microbiology       ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'Microbiology');
opts.VariableTypes(:, ismember(opts.VariableNames, {'DateMicrobiology'}))         = {'datetime'};
opts = setvaropts(opts,{'DateMicrobiology'},'InputFormat','MM/dd/yyyy');
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
    brmicrorow.Comments         = microdata.Comments(i);

    brMicrobiology = [brMicrobiology; brmicrorow];
end

fprintf('Clinic visits      ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'ClinicVisits');
opts.VariableTypes(:, ismember(opts.VariableNames, {'AttendanceDate'}))         = {'datetime'};
opts = setvaropts(opts,{'AttendanceDate'},'InputFormat','MM/dd/yyyy');
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
    brcvrow.Comments         = cvdata.Comments(i);

    brClinicVisits = [brClinicVisits; brcvrow];
end 

fprintf('Other visits       ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'OtherVisits');
opts.VariableTypes(:, ismember(opts.VariableNames, {'AttendanceDate'})) = {'datetime'};
opts = setvaropts(opts,{'AttendanceDate'},'InputFormat','MM/dd/yyyy');
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
    brovrow.Comments         = ovdata.Comments(i);

    brOtherVisits = [brOtherVisits; brovrow];
end

fprintf('Unplanned contacts ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'UnplannedContacts');
opts.VariableTypes(:, ismember(opts.VariableNames, {'ContactDate'})) = {'datetime'};
opts = setvaropts(opts,{'ContactDate'},'InputFormat','MM/dd/yyyy');
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
    brucrow.Comments         = ucdata.Comments(i);

    brUnplannedContact = [brUnplannedContact; brucrow];
end

fprintf('PFTs               ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'PFTs');
opts.VariableTypes(:, ismember(opts.VariableNames, {'LungFunctionDate'})) = {'datetime'};
opts = setvaropts(opts,{'LungFunctionDate'},'InputFormat','MM/dd/yyyy');
opts.VariableTypes(:, ismember(opts.VariableNames, {'FEV1'})) = {'double'};
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
    brpftrow.Comments           = pftdata.Comments(i);

    brPFT = [brPFT; brpftrow];
end

fprintf('CRPs               ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'CRPs');
opts.VariableTypes(:, ismember(opts.VariableNames, {'Level'})) = {'char'};
opts.VariableTypes(:, ismember(opts.VariableNames, {'CRPDate'})) = {'datetime'};
opts = setvaropts(opts,{'CRPDate'},'InputFormat','MM/dd/yyyy');
opts.DataRange = 'A2';
crpdata = readtable(fullfile(basedir, subfolder, patfile), opts, 'Sheet', 'CRPs');
ncrp = size(crpdata, 1);
fprintf('%2d rows\n', ncrp);
for i = 1:ncrp
    if size(crpdata.Level{i}, 2) > 0
        brcrprow.ID                 = scid;
        brcrprow.Hospital           = hospital;
        brcrprow.StudyNumber        = studynbr;
        brcrprow.CRPDate            = crpdata.CRPDate(i);
        brcrprow.Level              = crpdata.Level(i);
        brcrprow.NumericLevel       = str2double(regexprep(brcrprow.Level{1}, '[<>]',''));
        brcrprow.Units              = {'mg/L'};
        brcrprow.PatientAntibiotics = crpdata.PatientAntibiotics(i);
        brcrprow.Comments           = crpdata.Comments(i);
        
        brCRP = [brCRP; brcrprow];
    else
        fprintf('*** blank CRP entry ***\n');
    end
end

fprintf('HeightWeight       ');
opts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', 'HeightWeight');
opts.VariableTypes(:, ismember(opts.VariableNames, {'MeasDate'})) = {'datetime'};
opts = setvaropts(opts,{'MeasDate'},'InputFormat','MM/dd/yyyy');
opts.VariableTypes(:, ismember(opts.VariableNames, {'Height'}))   = {'double'};
opts.VariableTypes(:, ismember(opts.VariableNames, {'H_ZScore'})) = {'double'};
opts.VariableTypes(:, ismember(opts.VariableNames, {'Weight'}))   = {'double'};
opts.VariableTypes(:, ismember(opts.VariableNames, {'W_ZScore'})) = {'double'};
opts.VariableTypes(:, ismember(opts.VariableNames, {'BMI'}))       = {'double'};
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
    brhwrow.Comments           = hwdata.Comments(i);
    
    brHghtWght = [brHghtWght; brhwrow];
end

fprintf('\n');

end

