clear; close all; clc;

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
[studynbr, study, studyfullname] = selectStudy();

fprintf('Loading raw data for study\n');
chosentreatgap = selectTreatmentGap();
tic
[datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
[physdata, offset, physdata_predateoutlierhandling] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght, cdMedications, cdNewMeds] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);
alignmentmodelinputsfile = sprintf('%salignmentmodelinputs_gap%d.mat', study, chosentreatgap);
fprintf('Loading alignment model inputs\n');
load(fullfile(basedir, subfolder, alignmentmodelinputsfile), 'amInterventions','amDatacube', 'measures', 'npatients','ndays', 'nmeasures', 'ninterventions');
ivandmeasuresfile = sprintf('%sivandmeasures_gap%d.mat', study, chosentreatgap);
fprintf('Loading Treatment and Measures Prior info\n');
load(fullfile(basedir, subfolder, ivandmeasuresfile), 'ivandmeasurestable');
toc
fprintf('\n');

goodpatlist = unique(physdata.SmartCareID);
goodpattbl = table('Size',[size(goodpatlist, 1), 1], ...
                   'VariableTypes', {'double'}, ...
                   'VariableNames', {'SmartCareID'});
goodpattbl.SmartCareID = goodpatlist;
goodpattbl = innerjoin(goodpattbl, cdPatient, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'}, 'RightVariables', {'StudyDate'});
goodpattbl.StudyDn = datenum(goodpattbl.StudyDate) - offset + 1;
goodpattbl.PatClinDn = goodpattbl.StudyDn + 183;

minmeasdn = varfun(@min, physdata(:, {'SmartCareID', 'DateNum'}), 'GroupingVariables', {'SmartCareID'});
goodpattbl = outerjoin(goodpattbl, minmeasdn, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, ...
                        'RightVariables', {'min_DateNum'}, 'Type', 'left');
goodpattbl.Properties.VariableNames{'min_DateNum'} = 'MeasStart';
goodpattbl.StartDate = min(goodpattbl.StudyDn, goodpattbl.MeasStart);

maxmeasdn = varfun(@max, physdata(:, {'SmartCareID', 'DateNum'}), 'GroupingVariables', {'SmartCareID'});
goodpattbl = outerjoin(goodpattbl, maxmeasdn, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, ...
                        'RightVariables', {'max_DateNum'}, 'Type', 'left');                    
goodpattbl.Properties.VariableNames{'max_DateNum'} = 'MeasEnd';
goodpattbl.EndDate = max(goodpattbl.PatClinDn, goodpattbl.MeasEnd);

cdAntibiotics.IVStartDn = ceil(datenum(datetime(cdAntibiotics.StartDate))-offset) + 1;
treatsforgoodpats   = innerjoin(cdAntibiotics, goodpattbl, 'LeftKeys', {'ID'}, 'RightKeys', {'SmartCareID'}, 'RightVariables', {'MeasStart', 'MeasEnd'});
treatsactper        = treatsforgoodpats(treatsforgoodpats.MeasStart <= treatsforgoodpats.IVStartDn & (treatsforgoodpats.MeasEnd + 10) >= treatsforgoodpats.IVStartDn, :);


intrforgoodpats = innerjoin(ivandmeasurestable, goodpattbl, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, 'RightVariables', {'MeasStart', 'MeasEnd'});
intractper    = intrforgoodpats(intrforgoodpats.MeasStart <= intrforgoodpats.IVDateNum & (intrforgoodpats.MeasEnd + 10) >= intrforgoodpats.IVDateNum, :);


interventions1 = intrforgoodpats(intrforgoodpats.DaysWithMeasures >= 15 & intrforgoodpats.AvgMeasuresPerDay >= 2, ...
    {'SmartCareID', 'Hospital', 'IVStartDate', 'IVDateNum', 'IVStopDate', 'IVStopDateNum', 'Route', 'Type', 'SequentialIntervention', 'DaysWithMeasures', 'AvgMeasuresPerDay'});

interventions2 = intractper(intractper.DaysWithMeasures >= 15 & intractper.AvgMeasuresPerDay >= 2, ...
    {'SmartCareID', 'Hospital', 'IVStartDate', 'IVDateNum', 'IVStopDate', 'IVStopDateNum', 'Route', 'Type', 'SequentialIntervention', 'DaysWithMeasures', 'AvgMeasuresPerDay'});

fprintf('Plotting histogram of mnumber of interventions\n');
plotNbrIntrByPatient(physdata, offset, intractper, cdPatient, amInterventions, study, 'Thesis');
    