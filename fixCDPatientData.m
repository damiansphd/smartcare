function [cdPatientOut] = fixCDPatientData(cdPatient)

% fixCDPatientData - fix anomalies in Patient data

tic
fprintf('Fixing Patient data anomalies\n');
fprintf('-----------------____--------\n');

% Fix non-numeric value of Weight
idx1 = find(cdPatient.ID == 88);
idx2 = find(ismember(cdPatient.Weight,'75,4'));
idx = intersect(idx1,idx2);
cdPatient.Weight(idx) = {'75.4'};
updates = size(idx,1);
fprintf('Fixing %2d mis-typed Weight values\n', updates);

% now can convert StopDate to a datetime format
cdPatient.Weight = str2double(cdPatient.Weight);

% fix height in m - convert to cm
idx = find(cdPatient.Height < 2.2);
cdPatient.Height(idx) = cdPatient.Height(idx) * 100;
updates = size(idx,1);
fprintf('Fixing %2d Heights in m - converted to cm\n', updates);

% pending followups from Emem on :_
% 1) Patient 179, weight and height = 57.9. Awaiting correct height
% 2) Patient 70, weight = 105kg. Awaiting confirmation this is correct
% 3) Patient 42, weight = 117kg. Awaiting confirmation this is correct
% 4) Patient 201, weight = 34.3kg. Awaiting confirmation this is correct

cdPatientOut = cdPatient;

toc
fprintf('\n');

end

