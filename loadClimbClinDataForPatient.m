function [cdPatient, cdAdmissions, cdAntibiotics, cdClinicVisits, cdPFT, cdMicrobiology, cdHghtWght, cdOthClinMeas] = ...
            loadClimbClinDataForPatient(cdPatient, cdAdmissions, cdAntibiotics, cdClinicVisits, cdPFT, cdMicrobiology, ...
                                cdHghtWght, cdOthClinMeas, clABNameTable, patfile, basedir, subfolder, userid)
        
% loadClimbClinDataForPatient - populate the clinical data tables for a given
% patient's information

hosplength = 3;
idlength = 3;
matlabexcelserialdatediff = datenum(datetime(1899,12,31)) - 1;
notime = true;

[cdpatrow, cdadmrow, cdabrow, cdcvrow, ~, ~, cdpftrow, cdmicrorow, cdhwrow, cdocmrow, ~] = createClimbClinicalTables(1);

cdpatientsheet = '(1) Enrolment Visit Worksheet';
cdmicrosheet = '(1) Positive bacterial growth i';
cdcvsheet = '(1) Clinic attendance dates dur';
cdpftsheet = '(1) Hospital Lung Function meas';
cdadmsheet = '(1) Hospital Admission dates in';
cdabsheet = '(1) Hospital Admission dates in';
cdoralabsheet = '(1) New  or  Changes to Medicat';
cdhwsheet = '(1) Height and Weight measureme';

fprintf('File %s, ID %d\n', patfile, userid);
fprintf('=======================\n');
fprintf('Patient Info\n');
fprintf('------------\n');
tmppatient = readtable(fullfile(basedir, subfolder, patfile), 'Sheet', cdpatientsheet, 'ReadVariableNames', false);
cdpatrow.ID = userid;
cdpatrow.StudyNumber = upper(tmppatient.Var2(ismember(tmppatient.Var1, 'User ID')));
if ~ismember(cdpatrow.StudyNumber, extractBefore(patfile, 7))
    fprintf('**** Filename does not match User ID field - Exiting ****\n');
    return
end
cdpatrow.Hospital      = extractBefore(cdpatrow.StudyNumber, hosplength + 1);
%cdpatrow.StudyDate     = datetime(tmppatient.Var2(ismember(tmppatient.Var1, 'Date')), 'InputFormat', 'dd-MMM-yyyy');
cdpatrow.StudyDate     = ingestDateCell(tmppatient.Var2(ismember(tmppatient.Var1, 'Date')),   matlabexcelserialdatediff, 1, notime);
cdpatrow.Age           = str2double(tmppatient.Var2(ismember(tmppatient.Var1, 'Age(Y)')));
if isnan(cdpatrow.Age)
    fprintf('**** Invalid Age: %s ****\n', tmppatient.Var2{ismember(tmppatient.Var1, 'Age(Y)')});
    cdpatrow.Age   = 0;
    cdpatrow.AgeYy = 0;
end
cdpatrow.AgeYy         = str2double(tmppatient.Var2(ismember(tmppatient.Var1, 'Age(Y)')));
cdpatrow.AgeMm         = str2double(tmppatient.Var2(ismember(tmppatient.Var1, 'Age(M)')));
if isnan(cdpatrow.AgeMm)
    fprintf('**** Invalid AgeMm: %s ****\n', tmppatient.Var2{ismember(tmppatient.Var1, 'Age(M)')});
    cdpatrow.AgeMm = 0;
end
cdpatrow.DOB           = cdpatrow.StudyDate - calyears(cdpatrow.Age) - calmonths(cdpatrow.AgeMm);
cdpatrow.Sex           = tmppatient.Var2(ismember(tmppatient.Var1, 'Gender'));
cdpatrow.Height        = str2double(tmppatient.Var2(ismember(tmppatient.Var1, 'Height (cm)')));
if isnan(cdpatrow.Height)
    fprintf('**** Invalid Height: %s ****\n', tmppatient.Var2{ismember(tmppatient.Var1, 'Height (cm)')});
    cdpatrow.Height = 0;
end
cdpatrow.Weight        = str2double(tmppatient.Var2(ismember(tmppatient.Var1, 'Weight (kg)')));
if isnan(cdpatrow.Weight)
    fprintf('**** Invalid Weight: %s ****\n', tmppatient.Var2{ismember(tmppatient.Var1, 'Weight (kg)')});
    cdpatrow.Weight = 0;
end
cdpatrow.TooYoung      = tmppatient.Var2(ismember(tmppatient.Var1, 'Too young'));
cdpatrow.PredictedFEV1 = str2double(strrep(tmppatient.Var2(ismember(tmppatient.Var1, 'FEV1 (Litres)')), 'L', ''));
if isnan(cdpatrow.PredictedFEV1)
    fprintf('**** Invalid Predicted FEV1: %s **** (Too Young = %s, Age = %dy%dm)\n', tmppatient.Var2{ismember(tmppatient.Var1, 'FEV1 (Litres)')}, ...
        cdpatrow.TooYoung{1}, cdpatrow.AgeYy, cdpatrow.AgeMm);
    cdpatrow.PredictedFEV1 = 0;
end
cdpatrow.FEV1SetAs     = str2double(strrep(tmppatient.Var2(ismember(tmppatient.Var1, 'FEV1 value entered into home lung function monitor (if applicable)')), 'L', ''));
if isnan(cdpatrow.FEV1SetAs)
    fprintf('**** Invalid FEV1SetAs: %s **** (Too Young = %s, Age = %dy%dm)\n', tmppatient.Var2{ismember(tmppatient.Var1, 'FEV1 value entered into home lung function monitor (if applicable)')}, ...
        cdpatrow.TooYoung{1}, cdpatrow.AgeYy, cdpatrow.AgeMm);
    cdpatrow.FEV1SetAs = 0;
end
if ismember(cdpatrow.TooYoung, 'No')
    if cdpatrow.PredictedFEV1 ~= 0 && cdpatrow.FEV1SetAs == 0
        cdpatrow.FEV1SetAs = round(cdpatrow.PredictedFEV1, 1);
    end
    if cdpatrow.FEV1SetAs ~= 0 && cdpatrow.PredictedFEV1 == 0
        cdpatrow.PredictedFEV1 = cdpatrow.FEV1SetAs;
    end
end
cdpatrow.StudyEmail    = tmppatient.Var2(ismember(tmppatient.Var1, 'Email'));
cdpatrow.CalcAge       = cdpatrow.Age;
cdpatrow.CalcAgeExact  = cdpatrow.Age + str2double(tmppatient.Var2(ismember(tmppatient.Var1, 'Age(M)'))) / 12;
% for now just set these to the same as the value in the file. Replace when
% I get the formula for children's predicted FEV1 calculation
cdpatrow.CalcPredictedFEV1        = cdpatrow.PredictedFEV1;
cdpatrow.CalcPredictedFEV1OrigAge = cdpatrow.PredictedFEV1;
cdpatrow.CalcFEV1SetAs            = cdpatrow.FEV1SetAs;
cdpatrow.CalcFEV1SetAsOrigAge     = cdpatrow.FEV1SetAs;

cdPatient = [cdPatient; cdpatrow];

tmpmicro = readtable(fullfile(basedir, subfolder, patfile), 'Sheet', cdmicrosheet);
fprintf('Microbiology Info - %2d rows\n', size(tmpmicro, 1));
fprintf('-----------------------\n');
for i = 1:size(tmpmicro, 1)
    cdmicrorow.ID          = userid;
    cdmicrorow.StudyNumber = cdpatrow.StudyNumber;
    cdmicrorow.Hospital   = cdpatrow.Hospital;
    cdmicrorow.Microbiology = tmpmicro.Bacteria(i);
    [cdmicrorow.DateMicrobiology, isValid] = ingestDateCell(tmpmicro.Date(i), matlabexcelserialdatediff, i, notime);
    if isValid
        cdMicrobiology = [cdMicrobiology; cdmicrorow];
    end
end

tmpcv = readtable(fullfile(basedir, subfolder, patfile), 'Sheet', cdcvsheet);
fprintf('Clinic Visits - %2d rows\n', size(tmpcv, 1));
fprintf('-----------------------\n');
for i = 1:size(tmpcv, 1)
    isValid = true;
    cdcvrow.ID          = userid;
    cdcvrow.StudyNumber = cdpatrow.StudyNumber;
    cdcvrow.Hospital   = cdpatrow.Hospital;
    [cdcvrow.AttendanceDate, isValid] = ingestDateCell(tmpcv.Date(i), matlabexcelserialdatediff, i, notime);
    if isValid
        cdClinicVisits = [cdClinicVisits; cdcvrow];
    end
end

tmppft = readtable(fullfile(basedir, subfolder, patfile), 'Sheet', cdpftsheet);
fprintf('Clinical Lung Function Measures - %2d rows\n', size(tmppft, 1));
fprintf('-----------------------------------------\n');
for i = 1:size(tmppft, 1)
    isValid = true;
    cdpftrow.ID          = userid;
    cdpftrow.StudyNumber = cdpatrow.StudyNumber;
    cdpftrow.Hospital    = cdpatrow.Hospital;
    [cdpftrow.LungFunctionDate, isValid] = ingestDateCell(tmppft.Date(i), matlabexcelserialdatediff, i, notime);
    cdpftrow.FEV1 = tmppft.FEV1_litresPredicted_(i);
    if isnan(cdpftrow.FEV1)
        fprintf('%3d: **** Invalid Clinical FEV1 Volume: %d ****\n', i, cdpftrow.FEV1);
        cdpftrow.FEV1 = 0;
    end
    cdpftrow.FEV1_ = tmppft.FEV1__Predicted_(i);
    if isnan(cdpftrow.FEV1_)
        fprintf('%3d: **** Invalid Clinical FEV1 %%: %d ****\n', i, cdpftrow.FEV1_);
        cdpftrow.FEV1_ = 0;
    end
    cdpftrow.FVC1 = tmppft.FVC_litresPredicted_(i);
    if isnan(cdpftrow.FVC1)
        fprintf('%3d: **** Invalid Clinical FVC Volume: %d ****\n', i, cdpftrow.FVC1);
        cdpftrow.FVC1 = 0;
    end
    cdpftrow.FVC1_ = tmppft.FVC__Predicted_(i);
    if isnan(cdpftrow.FVC1_)
        fprintf('%3d: **** Invalid Clinical FVC %%: %d ****\n', i, cdpftrow.FVC1_);
        cdpftrow.FVC1_ = 0;
    end
    cdpftrow.CalcFEV1SetAs = cdpftrow.FEV1;
    cdpftrow.CalcFEV1_     = cdpftrow.FEV1_;
    
    if isValid
        cdPFT = [cdPFT; cdpftrow];
    end
end

tmpadm = readtable(fullfile(basedir, subfolder, patfile), 'Sheet', cdadmsheet);
fprintf('Hospital Admissions - %2d rows\n', size(tmpadm, 1));
fprintf('-----------------------------\n');
if ~ismember('Exacerbation', tmpadm.Properties.VariableNames)
    fprintf('Adding missing Exacerbation column to admission/iv data\n');
    tmpadm.Exacerbation(:) = cellstr('');
end
for i = 1:size(tmpadm, 1)
    cdadmrow.ID          = userid;
    cdadmrow.StudyNumber = cdpatrow.StudyNumber;
    cdadmrow.Hospital    = cdpatrow.Hospital;
    cdadmrow.Reason      = tmpadm.ReasonForAdmission(i);
    [cdadmrow.Admitted,  isValid] = ingestDateCell(tmpadm.DateAdmitted(i),   matlabexcelserialdatediff, i, notime);
    [cdadmrow.Discharge, tmpisValid] = ingestDateCell(tmpadm.DateDischarged(i), matlabexcelserialdatediff, i, notime);
    if ~tmpisValid
        isValid = tmpisValid;
    end
    
    if isValid
        cdAdmissions = [cdAdmissions; cdadmrow];
    end
end

fprintf('Hospital Antibiotics - %2d rows\n', size(tmpadm, 1));
fprintf('------------------------------\n');
for i = 1:size(tmpadm, 1)
    cdabrow.ID          = userid;
    cdabrow.StudyNumber = cdpatrow.StudyNumber;
    cdabrow.Hospital    = cdpatrow.Hospital;
    cdabrow.Reason      = tmpadm.ReasonForAdmission(i);
    [cdabrow.StartDate, isValid] = ingestDateCell(tmpadm.StartDate(i), matlabexcelserialdatediff, i, notime);
    [cdabrow.StopDate,  tmpisValid] = ingestDateCell(tmpadm.StopDate(i),  matlabexcelserialdatediff, i, notime);
    if ~tmpisValid
        isValid = tmpisValid;
    end
    if isValid
        if ismember(tmpadm.Exacerbation(i), 'X')
            fprintf('%3d: **** Found an exacerbation related IV treatment ****\n', i);
            if strlength(tmpadm.AntibioticUse_Name_preparation_{i}) ~= 0
                allabstr  = tmpadm.AntibioticUse_Name_preparation_{i};
                diffabidx = strfind(allabstr, ',');
                diffabidx(1, size(diffabidx, 2) + 1) = strlength(allabstr) + 1;
                for s = 1:size(diffabidx, 2)
                    if s == 1
                        fromidx = 1;
                    else
                        fromidx = diffabidx(s - 1) + 1;
                    end
                    oneabstr = extractBetween(allabstr, fromidx, diffabidx(s) - 1);
                    oneabstr = strrep(oneabstr, ' ', '');
                    dividx   = strfind(oneabstr{1}, '/');
                    if size(dividx, 2) == 0
                        cdabrow.AntibioticName = getABNameFromCode(oneabstr, clABNameTable);
                        cdabrow.Route = 'IV';
                        cdabrow.HomeIV_s = 'No';
                        cdAntibiotics = [cdAntibiotics; cdabrow];
                    elseif size(dividx, 2) == 1
                        cdabrow.AntibioticName = getABNameFromCode(extractBefore(oneabstr, dividx), clABNameTable);
                        cdabrow.Route          = extractAfter(oneabstr, dividx);
                        cdabrow.HomeIV_s = 'No';
                        if ismember(cdabrow.Route, 'PO')
                            cdabrow.Route = 'Oral';
                        end
                        cdAntibiotics = [cdAntibiotics; cdabrow];
                    else
                        fprintf('**** Invalid Antibiotic format %s ****\n', oneabstr);
                    end
                end
            end
        end
    end
end

oropts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', cdoralabsheet);
oropts.DataRange = 'A2';
oropts.VariableNamesRange = 'A1';
oropts.VariableTypes(:, ismember(oropts.VariableNames, {'Medication', 'Exacerbation'})) = {'char'};
tmporal = readtable(fullfile(basedir, subfolder, patfile), oropts, 'Sheet', cdoralabsheet, 'ReadVariableNames', true);
fprintf('Oral Antibiotics - %2d rows\n', size(tmporal, 1));
fprintf('--------------------------\n');
for i = 1:size(tmporal, 1)
    if ismember(tmporal.Exacerbation(i), 'X')
        cdabrow.ID          = userid;
        cdabrow.StudyNumber = cdpatrow.StudyNumber;
        cdabrow.Hospital    = cdpatrow.Hospital;
        cdabrow.Reason      = {'PE'};
        [cdabrow.StartDate, isValid] = ingestDateCell(tmporal.StartDate(i), matlabexcelserialdatediff, i, notime);
        [cdabrow.StopDate,  tmpisValid] = ingestDateCell(tmporal.StopDate(i),  matlabexcelserialdatediff, i, notime);
        if ~tmpisValid
            isValid = tmpisValid;
        end
        if isValid
            cdabrow.AntibioticName = getABNameFromCode(tmporal.Medication{i}, clABNameTable);
            cdabrow.Route = 'Oral';
            cdabrow.HomeIV_s = 'No';
            cdAntibiotics = [cdAntibiotics; cdabrow];  
        end
    end
end

hwopts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', cdhwsheet);
hwopts.VariableTypes(:, ismember(hwopts.VariableNames, {'HeightInCM', 'ZScore_ifKnown_', 'WeightInKG', 'ZScore_ifKnown__1', 'BMI_ifKnown_'})) = {'double'};
tmphw = readtable(fullfile(basedir, subfolder, patfile), hwopts, 'Sheet', cdhwsheet);
fprintf('Clinical Height & Weight Measures - %2d rows\n', size(tmphw, 1));
fprintf('-------------------------------------------\n');
for i = 1:size(tmphw, 1)
    isValid = true;
    cdhwrow.ID          = userid;
    cdhwrow.StudyNumber = cdpatrow.StudyNumber;
    cdhwrow.Hospital   = cdpatrow.Hospital;
    [cdhwrow.MeasDate, isValid] = ingestDateCell(tmphw.Date(i), matlabexcelserialdatediff, i, notime);
    cdhwrow.Height = tmphw.HeightInCM(i);
    if isnan(cdhwrow.Height)
        fprintf('%3d: **** Invalid Clinical Height: %d ****\n', i, cdhwrow.Height);
        cdhwrow.Height = 0;
    end
    cdhwrow.H_ZScore = tmphw.ZScore_ifKnown_(i);
    if isnan(cdhwrow.H_ZScore)
        fprintf('%3d: **** Invalid Clinical Height Z-Score: %d ****\n', i, cdhwrow.H_ZScore);
        cdhwrow.H_ZScore = 0;
    end
    cdhwrow.Weight = tmphw.WeightInKG(i);
    if isnan(cdhwrow.Weight)
        fprintf('%3d: **** Invalid Clinical Weight: %d ****\n', i, cdhwrow.Weight);
        cdhwrow.Weight = 0;
    end
    cdhwrow.W_ZScore = tmphw.ZScore_ifKnown__1(i);
    if isnan(cdhwrow.W_ZScore)
        fprintf('%3d: **** Invalid Clinical Weight Z-Score: %d ****\n', i, cdhwrow.W_ZScore);
        cdhwrow.W_ZScore = 0;
    end
    cdhwrow.BMI = tmphw.BMI_ifKnown_(i);
    if isnan(cdhwrow.BMI)
        fprintf('%3d: **** Invalid Clinical BMI: %d ****\n', i, cdhwrow.BMI);
        cdhwrow.BMI = 0;
    end
    if isValid
        cdHghtWght = [cdHghtWght; cdhwrow];
    end
end

fprintf('Other Clinical Measures\n');
fprintf('-----------------------\n');
[~, sheetlist] = xlsfinfo(fullfile(basedir, subfolder, patfile));
sheetlist = sheetlist';
sheetlist = sheetlist(contains(sheetlist, 'Subsequent Visit - Clinical'));
fprintf('Found %d subsequent visits\n', size(sheetlist, 1));
for a = 1:size(sheetlist, 1)
    fprintf('Processing visit %d\n', a);
    svopts = detectImportOptions(fullfile(basedir, subfolder, patfile), 'Sheet', sheetlist{a}, 'ReadVariableNames', false);
    svopts.DataRange = 'A1';
    tmpsv = readtable(fullfile(basedir, subfolder, patfile), svopts, 'Sheet', sheetlist{a});
    cdocmrow.ID          = userid;
    cdocmrow.StudyNumber = cdpatrow.StudyNumber;
    cdocmrow.Hospital    = cdpatrow.Hospital;
    [cdocmrow.MeasDate, isValid] = ingestDateCell(tmpsv.Var2(ismember(tmpsv.Var1, 'Date')), matlabexcelserialdatediff, a, notime);
    
    tmphr = str2double(tmpsv.Var2(ismember(tmpsv.Var1, 'HR')));
    if size(tmphr, 1) == 1
        cdocmrow.HR = tmphr;
    else
        if sum(~isnan(tmphr)) == 0
            cdocmrow.HR = nan;
        elseif sum(~isnan(tmphr)) == 1
            cdocmrow.HR = tmphr(~isnan(tmphr));
        else
            fprintf('Duplicate values for HR\n');
            cdocmrow.HR = nan;
        end
    end
    tmprr = str2double(tmpsv.Var2(ismember(tmpsv.Var1, 'RR')));
    if size(tmprr, 1) == 1
        cdocmrow.RR = tmprr;
    else
        if sum(~isnan(tmprr)) == 0
            cdocmrow.RR = nan;
        elseif sum(~isnan(tmprr)) == 1
            cdocmrow.RR = tmprr(~isnan(tmprr));
        else
            fprintf('Duplicate values for RR\n');
            cdocmrow.RR = nan;
        end
    end
    tmpTemp = str2double(tmpsv.Var2(ismember(tmpsv.Var1, 'Temp')));
    if size(tmpTemp, 1) == 1
        cdocmrow.Temp = tmpTemp;
    else
        if sum(~isnan(tmpTemp)) == 0
            cdocmrow.Temp = nan;
        elseif sum(~isnan(tmpTemp)) == 1
            cdocmrow.Temp = tmpTemp(~isnan(tmpTemp));
        else
            fprintf('Duplicate values for Temperature\n');
            cdocmrow.Temp = nan;
        end
    end
    tmpO2 = str2double(tmpsv.Var2(ismember(tmpsv.Var1, 'O2 Sats')));
    if size(tmpO2, 1) == 1
        cdocmrow.O2_Sat  = tmpO2;
    else
        if sum(~isnan(tmpO2)) == 0
            cdocmrow.O2_Sat = nan;
        elseif sum(~isnan(tmpO2)) == 1
            cdocmrow.O2_Sat = tmpO2(~isnan(tmpO2));
        else
            fprintf('Duplicate values for O2 Sat\n');
            cdocmrow.O2_Sat = nan;
        end
    end
    if (~isnan(cdocmrow.HR) || ~isnan(cdocmrow.RR) || ~isnan(cdocmrow.Temp) || ~isnan(cdocmrow.O2_Sat))
        cdOthClinMeas = [cdOthClinMeas; cdocmrow];
    else
        fprintf('Skipping as all measures are blank\n');
    end
end

fprintf('\n');

end

