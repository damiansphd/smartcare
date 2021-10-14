clear; close all; clc;

basedir = setBaseDir();
mlsubfolder = 'MatlabSavedVariables';
exsubfolder = 'ExcelFiles';

[studynbr, study, studyfullname] = selectStudy();
chosentreatgap = selectTreatmentGap();
[testlabelmthd, testlabeltxt] = selectLabelMethodology();    

% load amInterventions table from model result file
%[modelrun, modelidx, models] = amEMMCSelectModelRunFromDir(study, '',      '', 'IntrFilt', 'TGap',       '');
%tic
%fprintf('Loading output from model run\n');
%load(fullfile(basedir, mlsubfolder, sprintf('%s.mat', modelrun)), 'amInterventions');

% load cdPatient table from raw study data
fprintf('Loading raw data for study\n');

tic
[datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
[cdPatient, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = loadAndHarmoniseClinVars(clinicalmatfile, mlsubfolder, study);

basetestlabelfilename = sprintf('%s_LabelledInterventions_gap%d%s', study, chosentreatgap, testlabeltxt);
fprintf('Loading latest labelled test data file %s\n', basetestlabelfilename);
load(fullfile(basedir, mlsubfolder, sprintf('%s.mat', basetestlabelfilename)));

% load s/s of those examples already investigated
donefilename = 'For Damian Andres-BR Interventions with no signal.xlsx';
donesheetname = 'ExamplesWithNoSignal';
alreadydonelist = readtable(fullfile(basedir, exsubfolder, donefilename), 'Sheet', donesheetname);

classificationtable = table('Size',[5 2], ...
    'VariableTypes', {'double', 'cell'}, ...
    'VariableNames', {'TypeCode',     'TypeDescription'});
classificationtable.TypeCode = (1:5)';
classificationtable.TypeDescription = { 'Not an exacerbation'                              ; ...
                                        'Exacerbation started long before reference frame' ; ...
                                        'Antibiotics for other reasons'                    ; ...
                                        'Probable exacerbation'                            ; ...
                                        'Possible exacerbation'                            };
                    
intrlist = outerjoin(amLabelledInterventions, cdPatient, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'}, ...
                        'RightVariables', {'REDCapID', 'StudyNumber'}, 'Type', 'left');

intrlist = outerjoin(intrlist, alreadydonelist, 'LeftKeys', {'SmartCareID', 'IVStartDate'}, 'RightKeys', ...
                        {'SmartCareID', 'IVStartDate'}, 'RightVariables', {'classification', 'Review'}, 'Type', 'left');


intrlist.Properties.VariableNames{'classification'} = 'TypeCode';
intrlist = outerjoin(intrlist, classificationtable, 'LeftKeys', {'TypeCode'}, 'RightKeys', {'TypeCode'}, ...
                        'RightVariables', {'TypeDescription'}, 'Type', 'left');

intrlist = sortrows(intrlist, 'IntrNbr');
intrlist.NHSIdentifier(:) = {' '};

intrlist = intrlist(:, {'IntrNbr', 'Hospital', 'SmartCareID', 'REDCapID', 'StudyNumber', 'NHSIdentifier', 'TypeCode', ...
                        'TypeDescription', 'Review', 'IVStartDate', 'IVStopDate', 'Route', 'SequentialIntervention', 'DrugTherapy', 'Sparse', 'NoSignal'});

outputfilename = 'Papworth - full list of interventions for investigation.xlsx';
writetable(intrlist(ismember(intrlist.Hospital, {'PAP'}), :), fullfile(basedir, exsubfolder, outputfilename), 'Sheet', 'Interventions');


                    




                    
