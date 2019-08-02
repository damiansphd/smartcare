clear; close all; clc;

% other models to potentially add
% sig4 version (although zero offset start is infinity
% vEM with bet random start from 3 or 4

fprintf('Run Plots For Paper\n');
fprintf('\n');
fprintf('Choose plot to run\n');
fprintf('----------------------\n');
fprintf('0: Paper Figure 0 - Heatmap\n');
fprintf('1: Paper Figure 1 - Clinical and Home Measures\n');
fprintf('2: Paper Figure 2 - Early and Late Exacerbations\n');
fprintf('3: Paper Figure 3 - Typical profile of an exacerbation\n');
fprintf('4: Paper Figure 4 - Sub-population decline curve profiles with examples\n');
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
[studynbr, study, studyfullname] = selectStudy();
if runfunction == 0 || runfunction == 1
    fprintf('Loading raw data for study\n');
    chosentreatgap = selectTreatmentGap();
    tic
    [datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(studynbr, study);
    [physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, studynbr, study);
    [cdPatient, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
        cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght, cdMedications, cdNewMeds] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, studynbr, study);
    %fprintf('Loading demographic data by patient\n');
    %load(fullfile(basedir, subfolder, demographicsmatfile), 'demographicstable', 'overalltable');
    alignmentmodelinputsfile = sprintf('%salignmentmodelinputs_gap%d.mat', study, chosentreatgap);
    fprintf('Loading alignment model inputs\n');
    load(fullfile(basedir, subfolder, alignmentmodelinputsfile), 'amInterventions','amDatacube', 'measures', 'npatients','ndays', 'nmeasures', 'ninterventions');
    toc
    fprintf('\n');
elseif runfunction == 2
    chosentreatgap = selectTreatmentGap();
    tic
    [datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(studynbr, study);
    %fprintf('Loading demographic data by patient\n');
    %load(fullfile(basedir, subfolder, demographicsmatfile), 'demographicstable', 'overalltable');
    alignmentmodelinputsfile = sprintf('%salignmentmodelinputs_gap%d.mat', study, chosentreatgap);
    fprintf('Loading alignment model inputs\n');
    load(fullfile(basedir, subfolder, alignmentmodelinputsfile), 'amInterventions','amDatacube', 'measures', 'npatients','ndays', 'nmeasures', 'ninterventions');
    toc
    fprintf('\n');
else
    [modelrun, modelidx, models] = amEMMCSelectModelRunFromDir('',      '', 'IntrFilt', 'TGap',       '');
    tic
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
    toc
    fprintf('\n');
end
    
if runfunction == 0
    fprintf('Creating sorted measures heatmap for study period\n');
    createMeasuresHeatmapSortedForPaper(physdata, offset, cdPatient, study);
elseif runfunction == 1
    fprintf('Plotting clinical and home measures\n');
    visualiseMeasuresForPaperFcn2(physdata, offset, cdPatient, cdAntibiotics, ...
        cdCRP, cdPFT, cdNewMeds, measures, nmeasures, study);
elseif runfunction == 2
    fprintf('Plotting measures around exacerbation\n');
    visualiseExacerbationForPaperFcn(amDatacube, amInterventions, measures, nmeasures, npatients, study);
elseif runfunction == 3
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - mean shift - all on one page\n');
    compactplot = true;
    shiftmode = 4; % shift by 7d mean to left of ex_start
    examplemode = 0; % no examples
    lcexamples = [];
    amEMMCPlotSuperimposedAlignedCurvesForPaper(meancurvemean, meancurvecount, amIntrNormcube, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, ...
        nlatentcurves, countthreshold, shiftmode, study, examplemode, lcexamples);
elseif runfunction == 4
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - mean shift - all on one page\n');
    compactplot = true;
    shiftmode = 4; % shift by 7d mean to left of ex_start
    %lcexamples = [42, 52, 61];
    examplemode = 1; % include examples
    lcexamples = [42, 52, 45];
    amEMMCPlotSuperimposedAlignedCurvesForPaper2(meancurvemean, meancurvecount, amIntrNormcube, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, ...
        nlatentcurves, countthreshold, shiftmode, study, examplemode, lcexamples);
else
    fprintf('Should not get here....\n');
end
    

    