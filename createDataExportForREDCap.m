% createDataExportForREDCap.m - a script that takes current clinical data
% and converts it into the format for importing into REDCap. To be used in
% the once-off data conversion. Thereafter all clinical data will be
% managed in the REDCap project database (and the loading of clinical data 
% will have to be ammended to come from there rather than the spreadsheets

clear; close all; clc;

study = 'BR';

fprintf('Creating the clinical data conversion files for REDCap (csv format)\n');
fprintf('One file per hospital to allow imports to assign the data to the correct data access group by hospital\n')
fprintf('\n');

brhosp = getListOfBreatheHospitals();

%[patientmaster] = loadPatientMasterFileForAllHosp(study, brhosp);


% load the clinical data and patient master file
tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
[~, clinicalmatfile, ~] = getRawDataFilenamesForStudy(study);
[cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, ~, cdHghtWght, ~, ~, cdUnplannedContact] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);
toc
fprintf('\n');

% load the codes and labels for the drop down lists to convert current
% values back to the equivalent codes.
subfolder = 'DataFiles/BR/REDCapData';
ddfile    = 'DropDownLookUpValuesAllActual.xlsx';
outputfolder = 'ExcelFiles/REDCapData';
if ~exist(fullfile(basedir, outputfolder), 'dir')
    mkdir(fullfile(basedir, outputfolder));
end

ddantibiotics  = readtable(fullfile(basedir, subfolder, ddfile), 'Sheet', 'Antibiotics');
ddcfgene       = readtable(fullfile(basedir, subfolder, ddfile), 'Sheet', 'CFGene');
ddmicrobiology = readtable(fullfile(basedir, subfolder, ddfile), 'Sheet', 'Microbiology');
dddrugtherapy  = readtable(fullfile(basedir, subfolder, ddfile), 'Sheet', 'DrugTherapy');
ddclinicvisit  = readtable(fullfile(basedir, subfolder, ddfile), 'Sheet', 'ClinicVisit');
ddothervisit   = readtable(fullfile(basedir, subfolder, ddfile), 'Sheet', 'OtherVisit');
ddunplanned    = readtable(fullfile(basedir, subfolder, ddfile), 'Sheet', 'UnplannedContact');

completecode = 2;
defaultval   = 999;

% start REDCap study_id at 101
study_id = 101;

for h = 1:size(brhosp, 1)
    % get latest clinical date for hospital and set correct source directory
    fprintf('Loading for %s\n', brhosp.Name{h});
    
    [~, hosppatmastdate] = getLatestBreatheDatesForHosp(brhosp.Acronym{h});
    [hosppatmaster] = loadPatientMasterFileForHosp(study, brhosp(h, :), hosppatmastdate);

    % create the (initially empty) output table
    [hospREDCapData] = createREDCapDataTable(0);
    
    hospPatient = cdPatient(ismember(cdPatient.Hospital, brhosp.Acronym{h}), :);
    npatients = size(hospPatient, 1);

    tic
    for i = 1:npatients
        
        oldid = hospPatient.ID(i);
        study_nbr = lower(hospPatient.StudyNumber{i});
        
        fprintf('Patient %3d:%32s (prev %3d):', study_id, study_nbr, oldid);
        
        % 1) patient_info instrument
        nrows = 1;
        fprintf('PatientInfo(%d)..', nrows);
        [phrcd] = createREDCapDataTable(1);
        phrcd.study_id         = study_id;
        phrcd.hospital         = hospPatient.Hospital{i};
        phrcd.study_number     = cellstr(study_nbr);
        phrcd.study_date       = cellstr(datestr(hospPatient.StudyDate(i), 24));
        phrcd.patclindate      = cellstr(datestr(hospPatient.PatClinDate(i), 24));
        phrcd.dob              = cellstr(datestr(hospPatient.DOB(i), 24));
        phrcd.age              = cellstr(num2str(hospPatient.Age(i)));
        phrcd.gender           = hospPatient.Sex(i);
        phrcd.heightcm         = cellstr(num2str(hospPatient.Height(i)));
        phrcd.weightkg         = cellstr(num2str(hospPatient.Weight(i)));
        phrcd.predfev1ltr      = cellstr(num2str(hospPatient.PredictedFEV1(i)));
        phrcd.cfgene1          = cellstr(num2str(ddcfgene.Value(ismember(ddcfgene.Label, hospPatient.CFGene1(i)))));
        phrcd.cfgene2          = cellstr(num2str(ddcfgene.Value(ismember(ddcfgene.Label, hospPatient.CFGene2(i)))));
        phrcd.patient_comments = hospPatient.GeneralComments(i);
        phrcd.consent_status   = hosppatmaster.ConsentStatus(hosppatmaster.ID == hospPatient.ID(i));
        if ~isnat(hosppatmaster.ConsentDate(hosppatmaster.ID == hospPatient.ID(i)))
            phrcd.consent_date{1}  = datestr(hosppatmaster.ConsentDate(hosppatmaster.ID == hospPatient.ID(i)), 24);
        else
            phrcd.consent_date{1} = '';
        end    
        if ~isnat(hosppatmaster.WithdrawalDate(hosppatmaster.ID == hospPatient.ID(i)))
            phrcd.withdrawal_date{1} = datestr(hosppatmaster.WithdrawalDate(hosppatmaster.ID == hospPatient.ID(i)), 24);
        else
            phrcd.withdrawal_date{1} = '';
        end
        phrcd.partition_key    = hosppatmaster.PartitionKey(hosppatmaster.ID == hospPatient.ID(i));
        phrcd.patient_info_complete{1} = num2str(completecode);
        
        [hospREDCapData] = [hospREDCapData ; phrcd];
        
        % 2) drug_therapy instrument
        patDT = cdDrugTherapy(cdDrugTherapy.ID == oldid, :);
        nrows = size(patDT, 1);
        fprintf('DT(%d)..', nrows);
        if nrows > 0
            [phrcd] = createREDCapDataTable(nrows);
            phrcd.study_id(:)      = study_id;
            phrcd.redcap_repeat_instrument(:) = cellstr('drug_therapy');
            phrcd.redcap_repeat_instance(:) = cellstr(num2str((1:nrows)'));
            patDT = outerjoin(patDT, dddrugtherapy, 'LeftKeys', {'DrugTherapyType'}, 'RightKeys', {'Label'}, 'RightVariables', {'Value'}, 'Type', 'Left');
            patDT.Value(isnan(patDT.Value)) = defaultval;
            patDT = sortrows(patDT, {'DrugTherapyStartDate'}, {'ascend'});
            if size(patDT, 1) ~= nrows
                fprintf('**** unexpected values not in lookup ****\n')
                return;
            end
            phrcd.dt_name          = cellstr(num2str(patDT.Value));
            phrcd.dt_start_date(:) = cellstr(datestr(patDT.DrugTherapyStartDate, 24));
            %phrcd.dt_stop_date(:)  = cellstr(datestr(patDT.DrugTherapyStopDate, 24)); % no stop date currently stored - need to manually populate in REDCap
            phrcd.dt_comments(:)   = patDT.DrugTherapyComment;
            phrcd.drug_therapy_complete(:) = cellstr(num2str(completecode));
            
            [hospREDCapData] = [hospREDCapData ; phrcd];
        end
        
        % 3) antibiotics instrument
        patAB = cdAntibiotics(cdAntibiotics.ID == oldid, :);
        nrows = size(patAB, 1);
        fprintf('ABs(%3d)..', nrows);
        if nrows > 0
            [phrcd] = createREDCapDataTable(nrows);
            phrcd.study_id(:)      = study_id;
            phrcd.redcap_repeat_instrument(:) = cellstr('antibiotics');
            phrcd.redcap_repeat_instance(:) = cellstr(num2str((1:nrows)'));
            patAB = outerjoin(patAB, ddantibiotics, 'LeftKeys', {'AntibioticName'}, 'RightKeys', {'Label'}, 'RightVariables', {'Value'}, 'Type', 'Left');
            patAB.Value(isnan(patAB.Value)) = defaultval;
            patAB = sortrows(patAB, {'StartDate'}, {'ascend'});
            if size(patAB, 1) ~= nrows
                fprintf('**** unexpected values not in lookup ****\n')
                return;
            end
            phrcd.ab_name          = cellstr(num2str(patAB.Value));
            phrcd.ab_route         = patAB.Route;
            phrcd.ab_homeiv_s      = patAB.HomeIV_s;
            phrcd.ab_start_date(:) = cellstr(datestr(patAB.StartDate, 24));
            phrcd.ab_stop_date(:)  = cellstr(datestr(patAB.StopDate, 24));
            % phrcd.ab_elective - not currently stored, will need to be manually populated in REDCap
            phrcd.ab_comments(:)   = patAB.Comments;
            phrcd.antibiotics_complete(:) = cellstr(num2str(completecode));
            
            [hospREDCapData] = [hospREDCapData ; phrcd];
        end
        
        % 4) admissions instrument
        patAD = cdAdmissions(cdAdmissions.ID == oldid, :);
        nrows = size(patAD, 1);
        fprintf('ADs(%3d)..', nrows);
        if nrows > 0
            [phrcd] = createREDCapDataTable(nrows);
            phrcd.study_id(:)      = study_id;
            phrcd.redcap_repeat_instrument(:) = cellstr('admissions');
            phrcd.redcap_repeat_instance(:) = cellstr(num2str((1:nrows)'));
            phrcd.ad_start_date(:) = cellstr(datestr(patAD.Admitted, 24));
            phrcd.ad_stop_date(:)  = cellstr(datestr(patAD.Discharge, 24));
            phrcd.ad_comments(:)   = patAD.Comments;
            phrcd.admissions_complete(:) = cellstr(num2str(completecode));
            
            [hospREDCapData] = [hospREDCapData ; phrcd];
        end
        
        % 5) clinic visits instrument
        patCV = cdClinicVisits(cdClinicVisits.ID == oldid, :);
        nrows = size(patCV, 1);
        fprintf('CVs(%3d)..', nrows);
        if nrows > 0
            [phrcd] = createREDCapDataTable(nrows);
            phrcd.study_id(:)      = study_id;
            phrcd.redcap_repeat_instrument(:) = cellstr('clinic_visits');
            phrcd.redcap_repeat_instance(:) = cellstr(num2str((1:nrows)'));
            patCV = outerjoin(patCV, ddclinicvisit, 'LeftKeys', {'Location'}, 'RightKeys', {'Label'}, 'RightVariables', {'Value'}, 'Type', 'Left');
            patCV.Value(isnan(patCV.Value)) = defaultval;
            patCV = sortrows(patCV, {'AttendanceDate'}, {'ascend'});
            if size(patCV, 1) ~= nrows
                fprintf('**** unexpected values not in lookup ****\n')
                return;
            end
            phrcd.cv_location           = cellstr(num2str(patCV.Value));
            phrcd.cv_attendance_date(:) = cellstr(datestr(patCV.AttendanceDate, 24));
            phrcd.cv_comments(:)        = patCV.Comments;
            phrcd.clinic_visits_complete(:) = cellstr(num2str(completecode));
            
            [hospREDCapData] = [hospREDCapData ; phrcd];
        end
        
        % 6) other visits instrument
        patOV = cdOtherVisits(cdOtherVisits.ID == oldid, :);
        nrows = size(patOV, 1);
        fprintf('OVs(%3d)..', nrows);
        if nrows > 0
            [phrcd] = createREDCapDataTable(nrows);
            phrcd.study_id(:)      = study_id;
            phrcd.redcap_repeat_instrument(:) = cellstr('other_visits');
            phrcd.redcap_repeat_instance(:) = cellstr(num2str((1:nrows)'));
            patOV = outerjoin(patOV, ddothervisit, 'LeftKeys', {'VisitType'}, 'RightKeys', {'Label'}, 'RightVariables', {'Value'}, 'Type', 'Left');
            patOV.Value(isnan(patOV.Value)) = defaultval;
            patOV = sortrows(patOV, {'AttendanceDate'}, {'ascend'});
            if size(patOV, 1) ~= nrows
                fprintf('**** unexpected values not in lookup ****\n')
                return;
            end
            phrcd.ov_visit_type         = cellstr(num2str(patOV.Value));
            phrcd.ov_attendance_date(:) = cellstr(datestr(patOV.AttendanceDate, 24));
            phrcd.ov_comments(:)        = patOV.Comments;
            phrcd.other_visits_complete(:) = cellstr(num2str(completecode));
            
            [hospREDCapData] = [hospREDCapData ; phrcd];
        end
        
        % 7) unplanned contacts instrument
        patUP = cdUnplannedContact(cdUnplannedContact.ID == oldid, :);
        nrows = size(patUP, 1);
        fprintf('UCs(%3d)..', nrows);
        if nrows > 0
            [phrcd] = createREDCapDataTable(nrows);
            phrcd.study_id(:)      = study_id;
            phrcd.redcap_repeat_instrument(:) = cellstr('unplanned_contact');
            phrcd.redcap_repeat_instance(:) = cellstr(num2str((1:nrows)'));
            patUP = outerjoin(patUP, ddunplanned, 'LeftKeys', {'TypeOfContact'}, 'RightKeys', {'Label'}, 'RightVariables', {'Value'}, 'Type', 'Left');
            patUP.Value(isnan(patUP.Value)) = defaultval;
            patUP = sortrows(patUP, {'ContactDate'}, {'ascend'});
            if size(patUP, 1) ~= nrows
                fprintf('**** unexpected values not in lookup ****\n')
                return;
            end
            phrcd.up_type_of_contact    = cellstr(num2str(patUP.Value));
            phrcd.up_contact_date(:)    = cellstr(datestr(patUP.ContactDate, 24));
            phrcd.up_comments(:)        = patUP.Comments;
            phrcd.unplanned_contact_complete(:) = cellstr(num2str(completecode));
            
            [hospREDCapData] = [hospREDCapData ; phrcd];
        end
        
        % 8) crp instrument
        patCRP = cdCRP(cdCRP.ID == oldid, :);
        nrows = size(patCRP, 1);
        fprintf('CRPs(%3d)..', nrows);
        if nrows > 0
            [phrcd] = createREDCapDataTable(nrows);
            phrcd.study_id(:)      = study_id;
            phrcd.redcap_repeat_instrument(:) = cellstr('crps');
            phrcd.redcap_repeat_instance(:) = cellstr(num2str((1:nrows)'));
            phrcd.crp_date(:)      = cellstr(datestr(patCRP.CRPDate, 24));
            phrcd.crp_level(:)     = cellstr(num2str(patCRP.NumericLevel));
            phrcd.crp_comments(:)  = patCRP.Comments;
            phrcd.crps_complete(:) = cellstr(num2str(completecode));
            
            [hospREDCapData] = [hospREDCapData ; phrcd];
        end
        
        % 9) pft instrument
        patPFT = cdPFT(cdPFT.ID == oldid, :);
        nrows = size(patPFT, 1);
        fprintf('PFTs(%3d)..', nrows);
        if nrows > 0
            [phrcd] = createREDCapDataTable(nrows);
            phrcd.study_id(:)      = study_id;
            phrcd.redcap_repeat_instrument(:) = cellstr('pfts');
            phrcd.redcap_repeat_instance(:) = cellstr(num2str((1:nrows)'));
            phrcd.pft_date(:)      = cellstr(datestr(patPFT.LungFunctionDate, 24));
            phrcd.pft_fev1(:)      = cellstr(num2str(patPFT.FEV1));
            phrcd.pft_comments(:)  = patPFT.Comments;
            phrcd.pfts_complete(:) = cellstr(num2str(completecode));
            
            [hospREDCapData] = [hospREDCapData ; phrcd];
        end
        
        % 10) microbiology instrument
        patMB = cdMicrobiology(cdMicrobiology.ID == oldid, :);
        nrows = size(patMB, 1);
        fprintf('MB(%3d)..', nrows);
        if nrows > 0
            [phrcd] = createREDCapDataTable(nrows);
            phrcd.study_id(:)      = study_id;
            phrcd.redcap_repeat_instrument(:) = cellstr('microbiology');
            phrcd.redcap_repeat_instance(:) = cellstr(num2str((1:nrows)'));
            patMB = outerjoin(patMB, ddmicrobiology, 'LeftKeys', {'Microbiology'}, 'RightKeys', {'Label'}, 'RightVariables', {'Value'}, 'Type', 'Left');
            patMB.Value(isnan(patMB.Value)) = defaultval;
            patMB = sortrows(patMB, {'DateMicrobiology'}, {'ascend'});
            if size(patMB, 1) ~= nrows
                fprintf('**** unexpected values not in lookup ****\n')
                return;
            end
            phrcd.mb_name        = cellstr(num2str(patMB.Value));
            for d = 1:nrows
                if ~isnat(patMB.DateMicrobiology(d))
                    phrcd.mb_date(d) = cellstr(datestr(patMB.DateMicrobiology(d), 24));
                else
                    phrcd.mb_date(d) = cellstr('');
                end
            end
            phrcd.mb_comments(:) = patMB.Comments;
            phrcd.microbiology_complete(:) = cellstr(num2str(completecode));
            
            [hospREDCapData] = [hospREDCapData ; phrcd];
        end
        
        % 11) weight instrument
        patWT = cdHghtWght(cdHghtWght.ID == oldid, :);
        patWT.Weight(isnan(patWT.Weight)) = 0;
        nrows = size(patWT, 1);
        fprintf('Wght(%3d)..', nrows);
        if nrows > 0
            [phrcd] = createREDCapDataTable(nrows);
            phrcd.study_id(:)      = study_id;
            phrcd.redcap_repeat_instrument(:) = cellstr('weight');
            phrcd.redcap_repeat_instance(:) = cellstr(num2str((1:nrows)'));
            phrcd.hw_meas_date(:) = cellstr(datestr(patWT.MeasDate, 24));
            phrcd.hw_weight(:)    = cellstr(num2str(patWT.Weight));
            phrcd.hw_comments(:)  = patWT.Comments;
            phrcd.weight_complete(:) = cellstr(num2str(completecode));
            
            [hospREDCapData] = [hospREDCapData ; phrcd];
        end
        
        fprintf('\n');
        study_id = study_id + 1;
        
    end
    
    hospfilename = sprintf('%s-REDCapData.csv', brhosp.Acronym{h});
    writetable(hospREDCapData, fullfile(basedir, outputfolder, hospfilename));
    
end


