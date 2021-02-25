function [patientmaster] = loadPatientMasterFileForAllHosp(study, hosprows)

% loadPatientMasterFileForAllHosp - loads and concatenates the patient
% master files for all hospitals

patientmaster = [];

for h = 1:size(hosprows, 1)

    [~, hosppatmastdate] = getLatestBreatheDatesForHosp(hosprows.Acronym{h});
    [hosppatmaster] = loadPatientMasterFileForHosp(study, hosprows(h, :), hosppatmastdate); 
    patientmaster = [patientmaster; hosppatmaster];
    fprintf('For %s hospital\n', hosprows.Name{h});
    printPatientMasterStats(hosppatmaster);
    fprintf('\n');
end

fprintf('Overall\n');
printPatientMasterStats(patientmaster);
fprintf('\n');
    
end

