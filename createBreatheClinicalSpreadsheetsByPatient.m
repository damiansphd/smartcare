clear; clc; close all;

tic
fprintf('Loading Breathe Clinical Data\n');
fprintf('-----------------------------\n');
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'breatheclinicaldata.mat';
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Done\n');
toc
fprintf('\n');

[clindate, ~, ~] = getLatestBreatheDates();
study = 'BR';

subfolder = sprintf('DataFiles/ProjectBreathe/ClinicalData/%s', clindate);
mkdir(fullfile(basedir, subfolder));

npatients = size(brPatient, 1);

tic
for i = 1:npatients
%for i = 1:2
    scid     = brPatient.ID(i);
    hospital = brPatient.Hospital{i};
    studyid  = brPatient.StudyNumber{i};
    filename = sprintf('PBClinicalData-%3d-%s%s-%s.xlsx', scid, hospital, studyid, clindate);
    fprintf('Creating file %s\n', filename);    

    %{'ID', 'StudyNumber', 'StudyEmail', 'StudyDate', 'Prior6Mnth', 'Post6Mnth', 'DOB', 'Age', 'Sex', ...
    %                                              'Height', 'Weight', 'PredictedFEV1', 'CFGene1', 'CFGene2', 'GeneralComments', ...
    %                                              'DrugTherapyStartDate', 'DrugTherapyType', 'DrugTherapyComment'});
    
    tmpPatient          = brPatient(brPatient.ID == scid, :);              
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
        
    writetable(tmpPatient          , fullfile(basedir, subfolder, filename), 'Sheet', 'Patient'           );
    writetable(tmpAntibiotics      , fullfile(basedir, subfolder, filename), 'Sheet', 'Antibiotics'       );
    writetable(tmpAdmissions       , fullfile(basedir, subfolder, filename), 'Sheet', 'Admissions'        );
    writetable(tmpClinicVisits     , fullfile(basedir, subfolder, filename), 'Sheet', 'ClinicVisits'      );
    writetable(tmpOtherVisits      , fullfile(basedir, subfolder, filename), 'Sheet', 'OtherVisits'       );
    writetable(tmpUnplannedContact , fullfile(basedir, subfolder, filename), 'Sheet', 'UnplannedContacts' );
    writetable(tmpCRP              , fullfile(basedir, subfolder, filename), 'Sheet', 'CRPs'              );
    writetable(tmpPFT              , fullfile(basedir, subfolder, filename), 'Sheet', 'PFTs'              );
    writetable(tmpMicrobiology     , fullfile(basedir, subfolder, filename), 'Sheet', 'Microbiology'      );
    writetable(tmpHghtWght         , fullfile(basedir, subfolder, filename), 'Sheet', 'HeightWeight'      );

end

toc
fprintf('\n');
