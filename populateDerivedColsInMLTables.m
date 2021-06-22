function [brPatient, brCRP, brPFT] = populateDerivedColsInMLTables(brPatient, brCRP, brPFT)

% populateDerivedColsInMLTables - populates the derived columns in the
% relevant tables (that aren't available directly from REDCap


brPatient.Prior6Mnth               = brPatient.StudyDate - calmonths(6);
brPatient.Post6Mnth                = brPatient.StudyDate + calmonths(6);

wdrwnidx = ismember(brPatient.ConsentStatus, 'Withdrawn') & brPatient.WithdrawalDate < brPatient.PatClinDate;

brPatient.PatClinDate(wdrwnidx) = brPatient.WithdrawalDate(wdrwnidx);

brPatient.FEV1SetAs             = round(brPatient.PredictedFEV1, 1);
brPatient.StudyEmail            = brPatient.StudyNumber;
brPatient.CalcAge               = floor(years(brPatient.StudyDate - brPatient.DOB));
brPatient.CalcAgeExact          = years(brPatient.StudyDate - brPatient.DOB);
for n = 1:size(brPatient, 1)
    brPatient.CalcPredictedFEV1(n)        = calcPredictedFEV1(brPatient.CalcAge(n), brPatient.Height(n), brPatient.Sex(n));
    brPatient.CalcPredictedFEV1OrigAge(n) = calcPredictedFEV1(brPatient.Age(n), brPatient.Height(n), brPatient.Sex(n));
end
brPatient.CalcFEV1SetAs         = round(brPatient.CalcPredictedFEV1, 1);
brPatient.CalcFEV1SetAsOrigAge  = round(brPatient.CalcPredictedFEV1OrigAge, 1);

brPFT.Units(:)   = {'L'};
brPFT = outerjoin(brPFT, brPatient, 'LeftKeys', {'ID'}, 'RightKeys', {'ID'}, 'RightVariables', {'FEV1SetAs', 'CalcFEV1SetAs'}, 'Type', 'left');
brPFT.FEV1_      = 100 * brPFT.FEV1 ./ brPFT.FEV1SetAs;
brPFT.CalcFEV1_  = 100 * brPFT.FEV1 ./ brPFT.CalcFEV1SetAs;
brPFT(:, {'FEV1SetAs', 'CalcFEV1SetAs'}) = [];

brCRP.Units(:)     = {'mg/L'};
brCRP.NumericLevel = brCRP.Level;

end

