function [bePatient, bePFT] = populateBronchExDerivedColsInMLTables(bePatient, bePFT)

% populateBronchExDerivedColsInMLTables - populates the derived columns in the
% relevant tables (that aren't available directly from REDCap for the
% BronchEx study).

bePatient.Prior6Mnth               = bePatient.StudyDate - calmonths(6);
bePatient.Post6Mnth                = bePatient.StudyDate + calmonths(6);
bePatient.PatClinDate              = bePatient.StudyDate + days(bePatient.StudyDays + 10);

bePatient.CalcAge               = floor(years(bePatient.StudyDate - bePatient.DOB));
bePatient.CalcAgeExact          = years(bePatient.StudyDate - bePatient.DOB);

for n = 1:size(bePatient, 1)
    bePatient.CalcPredictedFEV1(n)        = calcPredictedFEV1(bePatient.CalcAge(n), bePatient.Height(n), bePatient.Sex(n));
    bePatient.CalcPredictedFEV1OrigAge(n) = bePatient.CalcPredictedFEV1(n);
end
bePatient.CalcFEV1SetAs         = round(bePatient.CalcPredictedFEV1, 1);
bePatient.CalcFEV1SetAsOrigAge  = bePatient.CalcFEV1SetAs;
bePatient.PredictedFEV1         = bePatient.CalcPredictedFEV1;
bePatient.FEV1SetAs             = round(bePatient.PredictedFEV1, 1);

%bePFT = outerjoin(bePFT, bePatient, 'LeftKeys', {'ID'}, 'RightKeys', {'ID'}, 'RightVariables', {'FEV1SetAs', 'CalcFEV1SetAs'}, 'Type', 'left');
%bePFT.FEV1_      = 100 * bePFT.FEV1 ./ bePFT.FEV1SetAs;
%bePFT.CalcFEV1_  = 100 * bePFT.FEV1 ./ bePFT.CalcFEV1SetAs;
%bePFT(:, {'FEV1SetAs', 'CalcFEV1SetAs'}) = [];

end

