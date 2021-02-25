function [hosppatientmaster] = loadPatientMasterFileForHosp(study, hosprow, patientmasterdate)

% loadPatientMasterFileForHosp - convenience function to load the patient
% master file for a given hospital and date

basedir = setBaseDir();

patientmasterfile  = sprintf('PBPatientMaster%s%s.xlsx', hosprow.Acronym{1}, patientmasterdate);
fprintf('Loading patient master file %s\n', patientmasterfile);

dfsubfolder = sprintf('DataFiles/%s/PatientMasterFiles', study);
hosppatientmaster = readtable(fullfile(basedir, dfsubfolder, patientmasterfile));
    
hosppatientmaster.StudyNumber = lower(hosppatientmaster.StudyNumber);

end

