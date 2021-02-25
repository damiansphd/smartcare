function printPatientMasterStats(patmaster)

% printPatientMasterStats - prints numbers enrolled, number consented,
% number pending, number withdrawn, number active

fprintf('Number of Patients enrolled:             %3d\n', size(patmaster, 1));
fprintf('Number of Patients pending consent:      %3d\n', sum(strncmpi(patmaster.ConsentStatus, "P", 1)));
fprintf('Number of Patients withdrawn:            %3d\n', sum(strncmpi(patmaster.ConsentStatus, "W", 1)));
fprintf('Number of Patients consented and active: %3d\n', sum(strncmpi(patmaster.ConsentStatus, "Y", 1)));

if (size(patmaster, 1) - sum(strncmpi(patmaster.ConsentStatus, "P", 1)) ...
        - sum(strncmpi(patmaster.ConsentStatus, "W", 1)) ...
        - sum(strncmpi(patmaster.ConsentStatus, "Y", 1))) ~= 0
    fprintf ('**** Numbers do not add up - please check consent status values in the patient master file ****\n');
end

end

