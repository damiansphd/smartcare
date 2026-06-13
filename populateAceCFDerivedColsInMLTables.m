function [acPatient, acCRP, acPFT] = populateAceCFDerivedColsInMLTables(acPatient, acCRP, acPFT, acPatDataUpdTo, acEndStudy)

% populateAceCFDerivedColsInMLTables - populates the derived columns in the
% relevant tables (that aren't available directly from REDCap for the
% ACE-CF study).

acPatient.Prior6Mnth               = acPatient.StudyDate - calmonths(6);
acPatient.Post6Mnth                = acPatient.StudyDate + calmonths(6);
acPatient.Age                      = floor(years(acPatient.StudyDate - acPatient.DOB));

% add patient data updated to as column to acPatient table
acPatient.PatClinDate = [];
acPatient = outerjoin(acPatient, acPatDataUpdTo, 'LeftKeys', {'ID'}, 'RightKeys', {'ID'}, 'RightVariables', {'PatClinDate'}, 'Type', 'left');

% default last clinical update date to be the study date where not yet
% entered in REDCap
patnoupdidx = isnat(acPatient.PatClinDate);
acPatient.PatClinDate(patnoupdidx) = acPatient.StudyDate(patnoupdidx);

% add study end date as column to acPatient table
acPatient = outerjoin(acPatient, acEndStudy, 'LeftKeys', {'ID'}, 'RightKeys', {'ID'}, 'RightVariables', {'EndOfStudyDate', 'EndOfStudyReason'}, 'Type', 'left');
acPatient.StudyEndDate = acPatient.EndOfStudyDate;

% default study end date to be the study date + 1 year where not yet
% entered in REDCap
studyendidx = isnat(acPatient.StudyEndDate);
acPatient.StudyEndDate(studyendidx) = acPatient.StudyDate(studyendidx) + days(365);

% limit official study period to 365 days if EndOfStudyDate is longer
studyendidx = days(acPatient.StudyEndDate - acPatient.StudyDate) > 365;
acPatient.StudyEndDate(studyendidx) = acPatient.StudyDate(studyendidx) + days(365);

acPatient.FEV1SetAs             = round(acPatient.PredictedFEV1, 1);

acPatient.CalcAge               = acPatient.Age;
acPatient.CalcAgeExact          = years(acPatient.StudyDate - acPatient.DOB);

for n = 1:size(acPatient, 1)
    acPatient.CalcPredictedFEV1(n)        = calcPredictedFEV1(acPatient.CalcAge(n), acPatient.Height(n), acPatient.Sex(n));
    acPatient.CalcPredictedFEV1OrigAge(n) = acPatient.CalcPredictedFEV1(n);
end
acPatient.CalcFEV1SetAs         = round(acPatient.CalcPredictedFEV1, 1);
acPatient.CalcFEV1SetAsOrigAge  = acPatient.CalcFEV1SetAs;

acPFT.Units(:)   = {'L'};
acPFT = outerjoin(acPFT, acPatient, 'LeftKeys', {'ID'}, 'RightKeys', {'ID'}, 'RightVariables', {'FEV1SetAs', 'CalcFEV1SetAs'}, 'Type', 'left');
acPFT.FEV1_      = 100 * acPFT.FEV1 ./ acPFT.FEV1SetAs;
acPFT.CalcFEV1_  = 100 * acPFT.FEV1 ./ acPFT.CalcFEV1SetAs;
acPFT(:, {'FEV1SetAs', 'CalcFEV1SetAs'}) = [];

acCRP.Units(:)     = {'mg/L'};
acCRP.NumericLevel = acCRP.Level;

end

