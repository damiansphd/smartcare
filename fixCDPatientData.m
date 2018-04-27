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

% fix typo in study start date for patient 36
idx = find(cdPatient.ID == 36);
cdPatient.StudyDate(idx) = datetime('21/10/2015');
updates = size(idx,1);
fprintf('Fixing %2d incorrect Study Dates\n', updates);

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

% add column for calculated age - as the Age column has some mistakes
fprintf('Adding column for calculated Age\n');
cdPatient.CalcAge = floor(years(cdPatient.StudyDate - cdPatient.DOB));
cdPatient.CalcAgeExact = years(cdPatient.StudyDate - cdPatient.DOB);

% add columns for calculated PredictedFEV1 and FEV1SetAs based on
% sex/age/height using ECSC formulae
fprintf('Adding columns for calculated PredictedFEV1 and FEV1SetAs\n');
cdMalePatient = cdPatient(ismember(cdPatient.Sex,'Male'),:);
cdFemalePatient = cdPatient(~ismember(cdPatient.Sex,'Male'),:);

cdMalePatient.CalcPredictedFEV1 = (cdMalePatient.Height * 0.01 * 4.3) - (cdMalePatient.CalcAge * 0.029) - 2.49;
cdMalePatient.CalcPredictedFEV1OrigAge = (cdMalePatient.Height * 0.01 * 4.3) - (cdMalePatient.Age * 0.029) - 2.49;
cdFemalePatient.CalcPredictedFEV1 = (cdFemalePatient.Height * 0.01 * 3.95) - (cdFemalePatient.CalcAge * 0.025) - 2.6;
cdFemalePatient.CalcPredictedFEV1OrigAge = (cdFemalePatient.Height * 0.01 * 3.95) - (cdFemalePatient.Age * 0.025) - 2.6;

cdMalePatient.CalcFEV1SetAs = round(cdMalePatient.CalcPredictedFEV1,1);
cdMalePatient.CalcFEV1SetAsOrigAge = round(cdMalePatient.CalcPredictedFEV1OrigAge,1);
cdFemalePatient.CalcFEV1SetAs = round(cdFemalePatient.CalcPredictedFEV1,1);
cdFemalePatient.CalcFEV1SetAsOrigAge = round(cdFemalePatient.CalcPredictedFEV1OrigAge,1);

cdPatient = sortrows([cdMalePatient ; cdFemalePatient], {'ID'}, 'ascend');


cdPatientOut = cdPatient;

toc
fprintf('\n');

end

