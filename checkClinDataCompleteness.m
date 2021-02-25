function checkClinDataCompleteness(patmaster, brPatient)

% checkClinDataCompleteness - convenience function to check the integrity
% of the contents of patient master file with the clinical spreadsheets
% received/processed

fprintf('# consented but no clin spreadsheet received:          %3d\n', sum(strncmpi(patmaster.ConsentStatus, "Y", 1) & ~ismember(patmaster.StudyNumber, brPatient.StudyNumber)));
if sum(strncmpi(patmaster.ConsentStatus, "Y", 1) & ~ismember(patmaster.StudyNumber, brPatient.StudyNumber)) ~= 0
    patmaster(strncmpi(patmaster.ConsentStatus, "Y", 1) & ~ismember(patmaster.StudyNumber, brPatient.StudyNumber), :)
    fprintf('\n');
end

fprintf('# withdrawn yet clin spreadsheet received:             %3d\n', sum(strncmpi(patmaster.ConsentStatus, "W", 1) &  ismember(patmaster.StudyNumber, brPatient.StudyNumber)));
if sum(strncmpi(patmaster.ConsentStatus, "W", 1) &  ismember(patmaster.StudyNumber, brPatient.StudyNumber)) ~= 0
    patmaster(strncmpi(patmaster.ConsentStatus, "W", 1) &  ismember(patmaster.StudyNumber, brPatient.StudyNumber), :)
    fprintf('\n');
end

fprintf('# consent pending yet clin spreadsheet received:       %3d\n', sum(strncmpi(patmaster.ConsentStatus, "P", 1) &  ismember(patmaster.StudyNumber, brPatient.StudyNumber)));
if sum(strncmpi(patmaster.ConsentStatus, "P", 1) &  ismember(patmaster.StudyNumber, brPatient.StudyNumber)) ~= 0
    patmaster(strncmpi(patmaster.ConsentStatus, "P", 1) &  ismember(patmaster.StudyNumber, brPatient.StudyNumber), :)
    fprintf('\n');
end

fprintf('# not in patient master yet clin spreadsheet received: %3d\n', sum(~ismember(brPatient.StudyNumber, patmaster.StudyNumber)));
if sum(~ismember(brPatient.StudyNumber, patmaster.StudyNumber)) ~= 0
    patmaster(~ismember(brPatient.StudyNumber, patmaster.StudyNumber), :)
    fprintf('\n');
end

fprintf('\n');

end

