clear; close all; clc;

[studynbr, study, studyfullname] = selectStudy();
%chosentreatgap = selectTreatmentGap();

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
[datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
[physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);

sclf = physdata(ismember(physdata.RecordingType, 'LungFunctionRecording'), :);

clinpft = cdPFT(:, {'ID', 'Hospital', 'StudyNumber', 'LungFunctionID', 'LungFunctionDate', 'FEV1_', 'CalcFEV1_'});
clinpft.LFdn = datenum(cdPFT.LungFunctionDate) - offset;


tempoutput = outerjoin(clinpft, sclf, 'LeftKeys', {'ID', 'LFdn'}, 'RightKeys', {'SmartCareID', 'DateNum'}, 'RightVariables', {'FEV1_', 'CalcFEV1_'});
tempoutput(isnan(tempoutput.ID), :) = [];
tempoutput.LFdn = [];

writetable(tempoutput, fullfile(basedir, 'ExcelFiles', 'EmemLungFunctionComparison.xlsx'));
