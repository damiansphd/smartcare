clear; close all; clc;

% other models to potentially add
% sig4 version (although zero offset start is infinity
% vEM with bet random start from 3 or 4

fprintf('Run Plots For Paper\n');
fprintf('\n');
fprintf('Choose plot to run\n');
fprintf('----------------------\n');
fprintf('0: Paper Figure 0\n');
fprintf('1: Paper Figure 1\n');
fprintf('2: Paper Figure 2\n');
fprintf('3: Paper Figure 3\n');
fprintf('4: Paper Figure 4\n');
fprintf('5: Paper Figure 5\n');

fprintf('\n');
npaperplots = 5;
srunfunction = input(sprintf('Choose function (0-%d): ', npaperplots), 's');
runfunction = str2double(srunfunction);

if (isnan(runfunction) || runfunction < 0 || runfunction > npaperplots)
    fprintf('Invalid choice\n');
    runfunction = -1;
    return;
end

fprintf('\n');

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
tic
if runfunction == 0 || runfunction == 1 || runfunction == 2
    fprintf('Loading raw data for study\n');
    [studynbr, study, studyfullname] = selectStudy();
    chosentreatgap = selectTreatmentGap();
    [datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(studynbr, study);
    [physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, studynbr, study);
    [cdPatient, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
        cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, studynbr, study);
    alignmentmodelinputsfile = sprintf('%salignmentmodelinputs_gap%d.mat', study, chosentreatgap);
    fprintf('Loading demographic data by patient\n');
    load(fullfile(basedir, subfolder, demographicsmatfile), 'demographicstable', 'overalltable');
    fprintf('Loading alignment model inputs\n');
    load(fullfile(basedir, subfolder, alignmentmodelinputsfile), 'amInterventions','amDatacube', 'measures', 'npatients','ndays', 'nmeasures', 'ninterventions');
    toc
    fprintf('\n');
else
    [modelrun, modelidx, models] = amEMMCSelectModelRunFromDir('',      '', 'IntrFilt', 'TGap',       '');
    fprintf('Loading output from model run\n');
    load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun)));
    %predictivemodelinputsfile = sprintf('%spredictivemodelinputs.mat', study);
    %ivandmeasuresfile = sprintf('%sivandmeasures_gap%d.mat', study, treatgap);

    % default some variables for backward compatibility with prior versions
    if ~exist('animated_overall_pdoffset', 'var')
        animated_overall_pdoffset = 0;
    end
    if ~exist('isOutlier', 'var')
        isOutlier = zeros(nlatentcurves, ninterventions, align_wind, nmeasures, max_offset);
    end
    if (~exist('intrkeepidx','var'))
        intrkeepidx = true(ninterventions, 1);
    end
    if (~exist('vshift','var'))
        vshift = zeros(nlatentcurves, ninterventions, nmeasures, max_offset);
    end
end
toc
    
if runfunction == 0
    fprintf('Creating sorted measures heatmap for study period\n');
    createMeasuresHeatmapSorted(physdata, offset, cdPatient, study);
elseif runfunction == 1
    fprintf('Plotting clinical and home measures\n');
    visualiseMeasuresFcn(physdata, offset, cdPatient, cdAdmissions, cdAntibiotics, cdClinicVisits, cdCRP, cdPFT, measures, study);
else
    fprintf('Should not get here....\n');
end
    

    