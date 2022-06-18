clear; close all; clc;

[studynbr, study, studyfullname] = selectStudy();
chosentreatgap = selectTreatmentGap();

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
[datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
%[physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght, cdMedications, cdNewMeds, cdUnplannedContact] ...
            = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);
        
% enrollment info
nparticipants = size(cdPatient, 1);

fprintf('\n');
fprintf('Participants enrolled  = %d\n', nparticipants);
fprintf('Participants withdrawn = %d\n', sum(ismember(cdPatient.ConsentStatus, 'Withdrawn')));
fprintf('Participants active    = %d\n', sum(ismember(cdPatient.ConsentStatus, 'Yes')));
fprintf('\n');
fprintf('First enrollment date = %s\n', datestr(min(cdPatient.StudyDate)));
fprintf('Data current to date  = %s\n', datestr(max(cdPatient.PatClinDate)));

% calculating study participant demographics

fprintf('\n');
fprintf('Female  = %d (%.1f%%)\n', sum(ismember(cdPatient.Sex, 'Female')), 100 * sum(ismember(cdPatient.Sex, 'Female'))/size(cdPatient, 1));
fprintf('Age     = %.1f +/- %.1f\n', mean(cdPatient.Age(~isnan(cdPatient.Age))), std(cdPatient.Age(~isnan(cdPatient.Age))));

tmpbmi = cdPatient.Weight(~isnan(cdPatient.Weight))./((cdPatient.Height(~isnan(cdPatient.Weight))/100).^2);
fprintf('BMI     = %.1f +/- %.1f\n', mean(tmpbmi), std(tmpbmi));

fprintf('\n');
earliestclinpft = varfun(@min, cdPFT(:, {'ID', 'LungFunctionDate'}), 'GroupingVariables', 'ID');
tmpPFT = outerjoin(cdPFT, earliestclinpft, 'LeftKeys', {'ID'}, 'RightKeys', {'ID'}, ...
    'RightVariables', 'min_LungFunctionDate');
tmpPFT = tmpPFT(tmpPFT.LungFunctionDate == tmpPFT.min_LungFunctionDate,:);
mean(tmpPFT.CalcFEV1_(~isnan(tmpPFT.CalcFEV1_)));
fprintf('CalcFEV1PctPred  = %.1f +/- %.1f\n', mean(tmpPFT.CalcFEV1_(~isnan(tmpPFT.CalcFEV1_))), std(tmpPFT.CalcFEV1_(~isnan(tmpPFT.CalcFEV1_))));
fprintf('<40%%             = %.1f%%\n', 100 * sum(tmpPFT.CalcFEV1_(~isnan(tmpPFT.CalcFEV1_)) < 40) / sum(~isnan(tmpPFT.CalcFEV1_)));
fprintf('>=40%% and >70%%   = %.1f%%\n', 100 * sum(tmpPFT.CalcFEV1_(~isnan(tmpPFT.CalcFEV1_)) >= 40 & tmpPFT.CalcFEV1_(~isnan(tmpPFT.CalcFEV1_)) < 70) / sum(~isnan(tmpPFT.CalcFEV1_)));
fprintf('>=70%% and >90%%   = %.1f%%\n', 100 * sum(tmpPFT.CalcFEV1_(~isnan(tmpPFT.CalcFEV1_)) >= 70 & tmpPFT.CalcFEV1_(~isnan(tmpPFT.CalcFEV1_)) < 90) / sum(~isnan(tmpPFT.CalcFEV1_)));
fprintf('>=90%%            = %.1f%%\n', 100 * sum(tmpPFT.CalcFEV1_(~isnan(tmpPFT.CalcFEV1_)) >= 90) / sum(~isnan(tmpPFT.CalcFEV1_)));

% genotype
fprintf('\n');
nf508homo   = sum(ismember(cdPatient.CFGene1, 'F508del') & ismember(cdPatient.CFGene2, 'F508del'));
nf508hetero = sum((ismember(cdPatient.CFGene1, 'F508del') & ~ismember(cdPatient.CFGene2, 'F508del')) ...
                | (~ismember(cdPatient.CFGene1, 'F508del') & ismember(cdPatient.CFGene2, 'F508del')));
nother      = sum(~ismember(cdPatient.CFGene1, 'F508del') & ~ismember(cdPatient.CFGene2, 'F508del'));

fprintf('F508del homozygous   = %3d (%4.1f%%)\n', nf508homo, 100 * nf508homo/ nparticipants);
fprintf('F508del heterozygous = %3d (%4.1f%%)\n', nf508hetero, 100 * nf508hetero / nparticipants);
fprintf('Other                = %3d (%4.1f%%)\n', nother, 100 * nother / nparticipants);
