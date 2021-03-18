clear; clc; close all;

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
[studynbr, study, studyfullname] = selectStudy();

fprintf('Loading raw data for study\n');
chosentreatgap = selectTreatmentGap();
[modelrun, modelidx, models] = amEMMCSelectModelRunFromDir(study, '',      '', 'IntrFilt', 'TGap',       '');
    
tic
[datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
[physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght, cdMedications, cdNewMeds] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);
alignmentmodelinputsfile = sprintf('%salignmentmodelinputs_gap%d.mat', study, chosentreatgap);
fprintf('Loading alignment model inputs\n');
load(fullfile(basedir, subfolder, alignmentmodelinputsfile), 'amInterventions','amDatacube', 'measures', 'npatients','ndays', 'nmeasures', 'ninterventions');
fprintf('Loading output from model run\n');
load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun)));
toc
fprintf('\n');

% microbiology info for Papworth patients
%test = cdMicrobiology(ismember(cdMicrobiology.Hospital, 'PAP'),:);

% list of id's for patients with pseudomonas
pseudpatid = unique(cdMicrobiology.ID(contains(lower(cdMicrobiology.Microbiology), 'pseud')));

npseudpat = size(pseudpatid, 1);

pseudpat = table('Size',[npseudpat 2], ...
    'VariableTypes', {'double', 'double'}, ...
    'VariableNames', {'ID'    , 'HasPseud'});

pseudpat.ID = pseudpatid;
pseudpat.HasPseud(:) = 1;


intrcount = varfun(@max, amInterventions, 'InputVariables', {'Pred'}, 'GroupingVariables', {'SmartCareID'});
intrcount.Properties.VariableNames{'GroupCount'} = 'IntrCount';

eligpat = cdPatient(:, {'ID', 'Hospital', 'StudyNumber', 'StudyDate'});

eligpat = outerjoin(eligpat, intrcount, 'LeftKeys', {'ID'}, 'RightKeys', {'SmartCareID'}, 'RightVariables', {'IntrCount'});
eligpat.IntrCount(isnan(eligpat.IntrCount)) = 0;

eligpat = outerjoin(eligpat, pseudpat, 'LeftKeys', {'ID'}, 'RightKeys', {'ID'}, 'RightVariables', {'HasPseud'});
eligpat.HasPseud(isnan(eligpat.HasPseud)) = 0;

%eligpat(eligpat.IntrCount ~= 0 & eligpat.HasPseud ~= 0,:)

eligintr = innerjoin(amInterventions, eligpat(eligpat.IntrCount ~= 0 & eligpat.HasPseud ~= 0,:), 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'}, 'RightVariables', {'StudyNumber', 'StudyDate'});


eligintr.PredDate      = eligintr.IVStartDate - days(eligintr.IVScaledDateNum - eligintr.Pred);
eligintr.RelLB1Date    = eligintr.IVStartDate - days(eligintr.IVScaledDateNum - eligintr.RelLB1);
eligintr.RelUB1Date    = eligintr.IVStartDate - days(eligintr.IVScaledDateNum - eligintr.RelUB1);
eligintr.RelLB2Date(:) = datetime(0,0,0,0,0,0);
eligintr.RelUB2Date(:) = datetime(0,0,0,0,0,0);

eligintr.RelLB2Date(eligintr.RelLB2 ~= -1, :) = eligintr.IVStartDate(eligintr.RelLB2 ~= -1, :) ...
    - days(eligintr.IVScaledDateNum(eligintr.RelLB2 ~= -1, :) - eligintr.RelLB2(eligintr.RelLB2 ~= -1, :));
eligintr.RelUB2Date(eligintr.RelUB2 ~= -1, :) = eligintr.IVStartDate(eligintr.RelUB2 ~= -1, :) ...
    - days(eligintr.IVScaledDateNum(eligintr.RelUB2 ~= -1, :) - eligintr.RelUB2(eligintr.RelUB2 ~= -1, :));

eligintr.StudyDate    = cellstr(datestr(eligintr.StudyDate,   'dd-mmm-yyyy'));
eligintr.IVStartDate  = cellstr(datestr(eligintr.IVStartDate, 'dd-mmm-yyyy'));
eligintr.IVStopDate   = cellstr(datestr(eligintr.IVStopDate,  'dd-mmm-yyyy'));
eligintr.PredDate     = cellstr(datestr(eligintr.PredDate,    'dd-mmm-yyyy'));
eligintr.RelLB1Date   = cellstr(datestr(eligintr.RelLB1Date,  'dd-mmm-yyyy'));
eligintr.RelUB1Date   = cellstr(datestr(eligintr.RelUB1Date,  'dd-mmm-yyyy'));
eligintr.RelLB2Date   = cellstr(datestr(eligintr.RelLB2Date,  'dd-mmm-yyyy'));
eligintr.RelUB2Date   = cellstr(datestr(eligintr.RelUB2Date,  'dd-mmm-yyyy'));

eligintr.RelLB2Date(ismember(eligintr.RelLB2Date, {'30-Nov-9999'})) = cellstr('');
eligintr.RelUB2Date(ismember(eligintr.RelUB2Date, {'30-Nov-9999'})) = cellstr('');

filteligintr = eligintr(:, {'IntrNbr', 'SmartCareID', 'Hospital', 'StudyNumber', 'StudyDate', ...
                            'IVStartDate', 'IVStopDate', 'Route', 'PredDate', 'RelLB1Date', ...
                            'RelUB1Date', 'RelLB2Date', 'RelUB2Date'});

basedir = setBaseDir();
subfolder = 'ExcelFiles';
xlfilename = sprintf('JosieQuery2 %s.xlsx', plotname);
%writetable(filteligintr(ismember(filteligintr.IntrNbr, [1, 2, 3, 33, 34, 42, 44, 45]), :), fullfile(basedir, subfolder, xlfilename), 'Sheet', 'Already Used');
%writetable(filteligintr(~ismember(filteligintr.IntrNbr, [1, 2, 3, 33, 34, 42, 44, 45]), :), fullfile(basedir, subfolder, xlfilename), 'Sheet', 'New Examples');
writetable(filteligintr(ismember(filteligintr.IntrNbr, [2, 3, 33, 34, 6, 21, 39, 41, 67, 72, 88, 89, 97]), :), fullfile(basedir, subfolder, xlfilename), 'Sheet', 'Requested Examples');


