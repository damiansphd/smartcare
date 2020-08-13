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

for i = 1:size(hosprow, 1)
    tic
    fprintf('Creating patient clinical files for %s\n', hosprow.Name{i});
    [clindate, ~, guidmapdate] = getLatestBreatheDatesForHosp(hosprow.Acronym{i});
    outputfolder = sprintf('DataFiles/%s/ClinicalData/%s/%s', study, hosprow.Acronym{i}, clindate);
    if ~exist(fullfile(basedir, outputfolder), 'dir')
        mkdir(fullfile(basedir, outputfolder));
    end
    
    tic
    fprintf('Loading Breathe GUID Mapping info\n');
    fprintf('---------------------------------\n');
    guidfile  = sprintf('Project Breathe GUID to email address map %s.xlsx', guidmapdate);
    dfsubfolder = sprintf('DataFiles/%s', study);
    guidmap = readtable(fullfile(basedir, dfsubfolder, guidfile), 'Sheet', hosprow.Name{i});
    guidmap.Properties.VariableNames{1} = 'StudyNumber';
    toc
    fprintf('\n');

    % filter brPatient for records by hospital
    
    hospPatient = brPatient(ismember(brPatient.Hospital, hosprow.Acronym{i}), :);
    npatients = size(hospPatient, 1);

    tic
    for i = 1:npatients
    %for i = 1:2
        scid     = hospPatient.ID(i);
        hospital = hospPatient.Hospital{i};
        studynbr  = hospPatient.StudyNumber{i};
        filename = sprintf('PBClinData-%3d-%s-%s-%s.xlsx', scid, hospital, studynbr, clindate);
        fprintf('Creating file %s\n', filename);    

        tmpPatient          = hospPatient(brPatient.ID == scid, :);              
        tmpAntibiotics      = brAntibiotics(brAntibiotics.ID == scid, :);
        tmpAdmissions       = brAdmissions(brAdmissions.ID == scid, :);
        tmpClinicVisits     = brClinicVisits(brClinicVisits.ID == scid, :);
        tmpOtherVisits      = brOtherVisits(brOtherVisits.ID == scid, :);
        tmpUnplannedContact = brUnplannedContact(brUnplannedContact.ID == scid, :);
        tmpCRP              = brCRP(brCRP.ID == scid, :);
        tmpPFT              = brPFT(brPFT.ID == scid, :);
        tmpMicrobiology     = brMicrobiology(brMicrobiology.ID == scid, :);
        tmpHghtWght         = brHghtWght(brHghtWght.ID == scid, :);

        % remove unwanted columns
        tmpPatient(:, {'FEV1SetAs', 'CalcAge', 'CalcAgeExact', 'CalcPredictedFEV1', ...
            'CalcPredictedFEV1OrigAge', 'CalcFEV1SetAs', 'CalcFEV1SetAsOrigAge'}) = [];
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
        writetable(tmpAntibiotics      , fullfile(basedir, outputfolder, filename), 'Sheet', 'Antibiotics'       );
        writetable(tmpAdmissions       , fullfile(basedir, outputfolder, filename), 'Sheet', 'Admissions'        );
        writetable(tmpClinicVisits     , fullfile(basedir, outputfolder, filename), 'Sheet', 'ClinicVisits'      );
        writetable(tmpOtherVisits      , fullfile(basedir, outputfolder, filename), 'Sheet', 'OtherVisits'       );
        writetable(tmpUnplannedContact , fullfile(basedir, outputfolder, filename), 'Sheet', 'UnplannedContacts' );
        writetable(tmpCRP              , fullfile(basedir, outputfolder, filename), 'Sheet', 'CRPs'              );
        writetable(tmpPFT              , fullfile(basedir, outputfolder, filename), 'Sheet', 'PFTs'              );
        writetable(tmpMicrobiology     , fullfile(basedir, outputfolder, filename), 'Sheet', 'Microbiology'      );
        writetable(tmpHghtWght         , fullfile(basedir, outputfolder, filename), 'Sheet', 'HeightWeight'      );

    end
    
    

    % now create stub spreadsheets for any new patients.
    newpats = guidmap(~ismember(guidmap.StudyNumber, hospPatient.StudyNumber), :);
    [tmpPatient, tmpAdmissions, tmpAntibiotics, tmpClinicVisits, tmpOtherVisits, tmpUnplannedContact, ...
        tmpCRP, tmpPFT, tmpMicrobiology, tmpHghtWght, ~] = createBreatheClinicalTables(1);
    
    % remove unwanted columns and the row where a table has a numeric
    % column
    tmpPatient(:, {'FEV1SetAs', 'CalcAge', 'CalcAgeExact', 'CalcPredictedFEV1', ...
        'CalcPredictedFEV1OrigAge', 'CalcFEV1SetAs', 'CalcFEV1SetAsOrigAge'}) = [];
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
    
    if npatients == 0
        scid = hosprow.StartID;
    else 
        scid = scid + 1;
    end
    
    hospital = hosprow.Acronym{1};
    
    for p = 1:size(newpats, 1)
        studynbr = newpats.StudyNumber{p};
        filename = sprintf('PBClinData-%3d-%s-%s-%s.xlsx', scid, hospital, studynbr, clindate);
        fprintf('Creating file %s\n', filename);
        
        tmpPatient.ID          = scid;
        tmpPatient.Hospital    = hospital;
        tmpPatient.StudyNumber = studynbr;
        tmpPatient.StudyEmail  = studynbr;

        writetable(tmpPatient          , fullfile(basedir, outputfolder, filename), 'Sheet', 'Patient'           );
        writetable(tmpAntibiotics      , fullfile(basedir, outputfolder, filename), 'Sheet', 'Antibiotics'       );
        writetable(tmpAdmissions       , fullfile(basedir, outputfolder, filename), 'Sheet', 'Admissions'        );
        writetable(tmpClinicVisits     , fullfile(basedir, outputfolder, filename), 'Sheet', 'ClinicVisits'      );
        writetable(tmpOtherVisits      , fullfile(basedir, outputfolder, filename), 'Sheet', 'OtherVisits'       );
        writetable(tmpUnplannedContact , fullfile(basedir, outputfolder, filename), 'Sheet', 'UnplannedContacts' );
        writetable(tmpCRP              , fullfile(basedir, outputfolder, filename), 'Sheet', 'CRPs'              );
        writetable(tmpPFT              , fullfile(basedir, outputfolder, filename), 'Sheet', 'PFTs'              );
        writetable(tmpMicrobiology     , fullfile(basedir, outputfolder, filename), 'Sheet', 'Microbiology'      );
        writetable(tmpHghtWght         , fullfile(basedir, outputfolder, filename), 'Sheet', 'HeightWeight'      );
        
        scid = scid + 1;
    end

    toc
    fprintf('\n');
end



