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

[hosprow, isValid] = selectHospital();
if ~isValid
    return
end
fprintf('\n');

for h = 1:size(hosprow, 1)
    tic
    fprintf('Creating updated mapping file for %s\n', hosprow.Name{h});
    fprintf('\n');
    
    [clindate, guidmapdate] = getLatestBreatheDatesForHosp(hosprow.Acronym{h});
    outputfolder = sprintf('DataFiles/%s/ClinicalData/%s/%sUpd', study, hosprow.Acronym{h}, clindate);
    if ~exist(fullfile(basedir, outputfolder), 'dir')
        mkdir(fullfile(basedir, outputfolder));
    end
    
    [guidmap] = loadGUIDFileForHosp(study, hosprow(h, :), guidmapdate);
    toc
    fprintf('\n');
    
    
    consentfile  = sprintf('Consent_status %s.xlsx', guidmapdate);
    fprintf('Loading consent status file %s\n', consentfile);
    dfsubfolder = sprintf('DataFiles/%s/ClinicalData/%s', study, hosprow.Acronym{h});
    consentstatus = readtable(fullfile(basedir, dfsubfolder, consentfile));
    fprintf('\n');

    hospPatient = brPatient(ismember(brPatient.Hospital, hosprow.Acronym{h}), :);
    npatients = size(hospPatient, 1);
    
    consentstatus.StudyNumber = lower(consentstatus.StudyNumber);
    guidmap.StudyNumber       = lower(guidmap.StudyNumber);
    hospPatient.StudyNumber   = lower(hospPatient.StudyNumber);
    
    patientmaster = outerjoin(consentstatus, guidmap, 'LeftKeys', {'StudyNumber'}, 'RightKeys', {'StudyNumber'}, 'RightVariables', {'PartitionKey'});
    
    temp = outerjoin(guidmap, consentstatus, 'LeftKeys', {'StudyNumber'}, 'RightKeys', {'StudyNumber'}, 'RightVariables', {'ConsentStatus'});
    
    fprintf('Participants with missing partition key:\n');
    patientmaster(ismember(patientmaster.PartitionKey, {''}), :)
    %misspartkey = guidmapnew(ismember(guidmapnew.PartitionKey, {''}), :);
    %guidmapnew(ismember(guidmapnew.PartitionKey, {''}), :) = [];
    
    fprintf('Partition key mappings with no corresponding consent info:\n');
    temp(ismember(temp.ConsentStatus, {''}), :)
    missconsstat = temp(ismember(temp.ConsentStatus, {''}), :);
    
    patientmaster = outerjoin(patientmaster, hospPatient, 'LeftKeys', {'StudyNumber'}, 'RightKeys', {'StudyNumber'}, 'RightVariables', {'ID', 'StudyDate'});
    
    fprintf('No internal ID assigned yet (ie no clinical spreadsheet received for these participants):\n');
    patientmaster(isnan(patientmaster.ID),:)
    
    patientmaster = sortrows(patientmaster, {'ID', 'StudyDate'}, 'ascend');
    patientmaster.Hospital(:) = hosprow.Acronym(h);
    patientmaster = patientmaster(:, {'ID', 'Hospital', 'StudyNumber', 'StudyDate', 'ConsentStatus', 'ConsentDate', 'WithdrawalDate', 'PartitionKey'});
    
    patientmaster.OldID = patientmaster.ID;
    patientmaster.ID(:) = hosprow.IDOffset(h) + (1:size(patientmaster, 1));
    
    patientmaster
    
    filedate = guidmapdate;
    dfsubfolder = sprintf('DataFiles/%s/PatientMasterFiles', study);
    filename    = sprintf('PBPatientMaster%s%s.xlsx', hosprow.Acronym{h}, filedate);
    writetable(patientmaster(:, {'ID', 'Hospital', 'StudyNumber', 'StudyDate', 'ConsentStatus', 'ConsentDate', 'WithdrawalDate', 'PartitionKey'}), fullfile(basedir, dfsubfolder , filename));
    
end

    
    