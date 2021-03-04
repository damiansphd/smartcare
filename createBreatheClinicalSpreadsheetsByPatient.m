clear; clc; close all;

tic
fprintf('Loading Breathe Clinical Data\n');
fprintf('-----------------------------\n');
basedir = setBaseDir();
mssubfolder = 'MatlabSavedVariables';
clinicalmatfile = 'breatheclinicaldata.mat';
load(fullfile(basedir, mssubfolder, clinicalmatfile));
fprintf('Done\n');
toc
fprintf('\n');

study = 'BR';

% get list of Project Breathe hospitals
%brhosp = getListOfBreatheHospitals();

% select hospital to run for
[hosprow, isValid] = selectHospital();
if ~isValid
    return
end
fprintf('\n');

for h = 1:size(hosprow, 1)
    tic
    fprintf('Creating patient clinical files for %s\n', hosprow.Name{h});
    fprintf('\n');
    
    [clindate, hosppatmastdate] = getLatestBreatheDatesForHosp(hosprow.Acronym{h});
    outputfolder = sprintf('DataFiles/%s/ClinicalData/%s/%sUpd', study, hosprow.Acronym{h}, clindate);
    if ~exist(fullfile(basedir, outputfolder), 'dir')
        mkdir(fullfile(basedir, outputfolder));
    end
    
    [hosppatmaster] = loadPatientMasterFileForHosp(study, hosprow(h, :), hosppatmastdate);
    toc
    fprintf('\n');

    % filter brPatient for records by hospital
    hospPatient = brPatient(ismember(brPatient.Hospital, hosprow.Acronym{h}), :);
    npatients = size(hospPatient, 1);

    tic
    for i = 1:npatients
        hospital    = hospPatient.Hospital{i};
        studynbr    = lower(hospPatient.StudyNumber{i});
        % need to store the original scid assigned for the first batch of
        % spreadsheets created after switching to the patient master file
        % should be able to switch back to exclusively using the
        % patientmaster scid once they've all been recreated
        oldscid     = hospPatient.ID(i);
        scid        = hosppatmaster.ID(ismember(hosppatmaster.StudyNumber, studynbr));
        consentstatus = hosppatmaster.ConsentStatus{hosppatmaster.ID == scid};
        if upper(consentstatus(1)) == 'Y' || upper(consentstatus(1)) == 'W'
            patclindate = hospPatient.PatClinDate(i);
            filename    = sprintf('PBClinData-%3d-%s-%s-%s.xlsx', scid, hospital, studynbr, datestr(patclindate, 'yyyymmdd'));
            fprintf('Creating file %s\n', filename);    

            % can change these back to use scid once we've done the switch
            % over
            tmpPatient          = hospPatient(hospPatient.ID == oldscid, :);
            tmpPatient.ID(1)    = scid;
            tmpPatient.StudyNumber{1} = lower(tmpPatient.StudyNumber{1});
            tmpPatient.StudyEmail{1}  = lower(tmpPatient.StudyNumber{1});
            tmpDrugTherapy      = brDrugTherapy(brDrugTherapy.ID == oldscid, :);
            tmpAntibiotics      = brAntibiotics(brAntibiotics.ID == oldscid, :);
            tmpAdmissions       = brAdmissions(brAdmissions.ID == oldscid, :);
            tmpClinicVisits     = brClinicVisits(brClinicVisits.ID == oldscid, :);
            tmpOtherVisits      = brOtherVisits(brOtherVisits.ID == oldscid, :);
            tmpUnplannedContact = brUnplannedContact(brUnplannedContact.ID == oldscid, :);
            tmpCRP              = brCRP(brCRP.ID == oldscid, :);
            tmpPFT              = brPFT(brPFT.ID == oldscid, :);
            tmpMicrobiology     = brMicrobiology(brMicrobiology.ID == oldscid, :);
            tmpHghtWght         = brHghtWght(brHghtWght.ID == oldscid, :);

            % remove unwanted columns
            tmpPatient(:, {'FEV1SetAs', 'CalcAge', 'CalcAgeExact', 'CalcPredictedFEV1', ...
                'CalcPredictedFEV1OrigAge', 'CalcFEV1SetAs', 'CalcFEV1SetAsOrigAge'}) = [];
            tmpDrugTherapy(:, {'ID', 'StudyNumber', 'Hospital'})               = [];
            tmpAntibiotics(:, {'ID', 'StudyNumber', 'Hospital'})               = [];
            tmpAdmissions(:, {'ID', 'StudyNumber', 'Hospital'})                = [];
            tmpClinicVisits(:, {'ID', 'StudyNumber', 'Hospital'})              = [];
            tmpOtherVisits(:, {'ID', 'StudyNumber', 'Hospital'})               = [];
            tmpUnplannedContact(:, {'ID', 'StudyNumber', 'Hospital'})          = [];
            tmpCRP(:, {'ID', 'StudyNumber', 'Hospital', 'NumericLevel'})       = [];
            tmpPFT(:, {'ID', 'StudyNumber', 'Hospital', 'FEV1_', 'CalcFEV1_'}) = [];
            tmpMicrobiology(:, {'ID', 'StudyNumber', 'Hospital'})              = [];
            tmpHghtWght(:, {'ID', 'StudyNumber', 'Hospital'})                  = [];

            writetable(tmpPatient          , fullfile(basedir, outputfolder, filename), 'Sheet', 'Patient'           );
            writetable(tmpDrugTherapy      , fullfile(basedir, outputfolder, filename), 'Sheet', 'DrugTherapy'       );
            writetable(tmpAntibiotics      , fullfile(basedir, outputfolder, filename), 'Sheet', 'Antibiotics'       );
            writetable(tmpAdmissions       , fullfile(basedir, outputfolder, filename), 'Sheet', 'Admissions'        );
            writetable(tmpClinicVisits     , fullfile(basedir, outputfolder, filename), 'Sheet', 'ClinicVisits'      );
            writetable(tmpOtherVisits      , fullfile(basedir, outputfolder, filename), 'Sheet', 'OtherVisits'       );
            writetable(tmpUnplannedContact , fullfile(basedir, outputfolder, filename), 'Sheet', 'UnplannedContacts' );
            writetable(tmpCRP              , fullfile(basedir, outputfolder, filename), 'Sheet', 'CRPs'              );
            writetable(tmpPFT              , fullfile(basedir, outputfolder, filename), 'Sheet', 'PFTs'              );
            writetable(tmpMicrobiology     , fullfile(basedir, outputfolder, filename), 'Sheet', 'Microbiology'      );
            writetable(tmpHghtWght         , fullfile(basedir, outputfolder, filename), 'Sheet', 'HeightWeight'      );
            
        elseif upper(consentstatus(1)) == 'P' 
            fprintf('Skipping patient %d(%s) as consent not yet given\n', scid, studynbr);
            continue;
        else
            fprintf('**** Unknown consent status for patient %d(%s) ****\n', scid, studynbr);
            return;
        end
    end
    
    

    % now create stub spreadsheets for any new patients.
    newpats = hosppatmaster(~ismember(hosppatmaster.StudyNumber, lower(hospPatient.StudyNumber)), :);
    [tmpPatient, tmpDrugTherapy, tmpAdmissions, tmpAntibiotics, tmpClinicVisits, tmpOtherVisits, tmpUnplannedContact, ...
        tmpCRP, tmpPFT, tmpMicrobiology, tmpHghtWght, ~] = createBreatheClinicalTables(1);
    
    % remove unwanted columns and the row where a table has a numeric
    % column
    tmpPatient(:, {'FEV1SetAs', 'CalcAge', 'CalcAgeExact', 'CalcPredictedFEV1', ...
        'CalcPredictedFEV1OrigAge', 'CalcFEV1SetAs', 'CalcFEV1SetAsOrigAge'}) = [];
    tmpDrugTherapy(:, {'ID', 'StudyNumber', 'Hospital'})               = [];
    tmpAntibiotics(:, {'ID', 'StudyNumber', 'Hospital'})               = [];
    tmpAdmissions(:, {'ID', 'StudyNumber', 'Hospital'})                = [];
    tmpClinicVisits(:, {'ID', 'StudyNumber', 'Hospital'})              = [];
    tmpOtherVisits(:, {'ID', 'StudyNumber', 'Hospital'})               = [];
    tmpUnplannedContact(:, {'ID', 'StudyNumber', 'Hospital'})          = [];
    tmpCRP(:, {'ID', 'StudyNumber', 'Hospital', 'NumericLevel'})       = [];
    tmpPFT(:, {'ID', 'StudyNumber', 'Hospital', 'FEV1_', 'CalcFEV1_'}) = [];
    tmpMicrobiology(:, {'ID', 'StudyNumber', 'Hospital'})              = [];
    tmpHghtWght(:, {'ID', 'StudyNumber', 'Hospital'})                  = [];
    
    tmpPFT(1, :)      = [];
    tmpCRP(1, :)      = [];
    tmpHghtWght(1, :) = [];
    
    %if npatients == 0
    %    scid = hosprow.StartID;
    %else 
    %    scid = scid + 1;
    %end
    
    hospital = hosprow.Acronym{1};
    
    for p = 1:size(newpats, 1)
        studynbr = newpats.StudyNumber{p};
        scid = newpats.ID(p);
        consentstatus = hosppatmaster.ConsentStatus{hosppatmaster.ID == scid};
        if upper(consentstatus(1)) == 'Y'
            filename = sprintf('PBClinData-%3d-%s-%s-%s.xlsx', scid, hospital, studynbr, clindate);
            fprintf('Creating file %s\n', filename);

            tmpPatient.ID          = scid;
            tmpPatient.Hospital    = hospital;
            tmpPatient.StudyNumber = studynbr;
            tmpPatient.StudyEmail  = studynbr;

            writetable(tmpPatient          , fullfile(basedir, outputfolder, filename), 'Sheet', 'Patient'           );
            writetable(tmpDrugTherapy      , fullfile(basedir, outputfolder, filename), 'Sheet', 'DrugTherapy'       );
            writetable(tmpAntibiotics      , fullfile(basedir, outputfolder, filename), 'Sheet', 'Antibiotics'       );
            writetable(tmpAdmissions       , fullfile(basedir, outputfolder, filename), 'Sheet', 'Admissions'        );
            writetable(tmpClinicVisits     , fullfile(basedir, outputfolder, filename), 'Sheet', 'ClinicVisits'      );
            writetable(tmpOtherVisits      , fullfile(basedir, outputfolder, filename), 'Sheet', 'OtherVisits'       );
            writetable(tmpUnplannedContact , fullfile(basedir, outputfolder, filename), 'Sheet', 'UnplannedContacts' );
            writetable(tmpCRP              , fullfile(basedir, outputfolder, filename), 'Sheet', 'CRPs'              );
            writetable(tmpPFT              , fullfile(basedir, outputfolder, filename), 'Sheet', 'PFTs'              );
            writetable(tmpMicrobiology     , fullfile(basedir, outputfolder, filename), 'Sheet', 'Microbiology'      );
            writetable(tmpHghtWght         , fullfile(basedir, outputfolder, filename), 'Sheet', 'HeightWeight'      );

            %scid = scid + 1;
   
        elseif upper(consentstatus(1)) == 'P' 
            fprintf('Skipping patient %d(%s) as consent not yet given\n', scid, studynbr);
            continue;
        elseif upper(consentstatus(1)) == 'W'
            fprintf('Skipping patient %d(%s) as they have withdrawn\n', scid, studynbr);
            continue;
        else
            fprintf('**** Unknown consent status for patient %d(%s) ****\n', scid, studynbr);
            return;
        end
    end

    toc
    fprintf('\n');
end



