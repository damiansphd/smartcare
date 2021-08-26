clear; close all; clc;

% other models to potentially add
% sig4 version (although zero offset start is infinity
% vEM with bet random start from 3 or 4

fprintf('Run Model Utility Functions (handling multiple sets of latent curves\n');
fprintf('\n');
fprintf('Choose function to run\n');
fprintf('----------------------\n');
fprintf(' 1: Run prediction plots\n');
fprintf(' 2: Run alignment animation (concurrent)\n');
fprintf(' 3: (*) Run alignment animation (sequential)\n');
fprintf(' 4: Run prod dist animation (concurrent)\n');
fprintf(' 5: (*) Extract and save prob distributions\n');
fprintf(' 6: Label exacerbation plots for test data\n');
fprintf(' 7: Compare results to another model run\n');
fprintf(' 8: Compare results to labelled test data and plot results\n');
fprintf(' 9: (*) <placeholder for Dragos new option\n');
fprintf('10: Compare results for multiple model runs to labelled test data\n');
fprintf('11: (*) Compare results for multiple model runs\n');
fprintf('12: (*) Plot simplified aligned curves\n');
fprintf('13: Plot Test Labels\n');
fprintf('14: Calc Ex Start from Test Labels\n');
fprintf('15: Plot aligned curves\n');
fprintf('16: Plot alignment detail\n');
fprintf('17: Plot alignment curves side-by-side\n');
fprintf('18: Plot alignment curves side-by-side with centering\n');
fprintf('19: Plot variables vs latent curve assignment\n');
fprintf('20: Plot interventions over time by latent curve set (scaled days)\n');
fprintf('21: Load variables for a given model run\n');
fprintf('22: Plot a measure for a set of examples\n');
fprintf('23: Compare latent curve set populations for 2 model runs\n');
fprintf('24: Plot superimposed alignment curves - mean shift - one per page\n');
fprintf('25: Plot superimposed alignment curves - mean shift - all on one page\n');
fprintf('26: Compare results for multiple model runs to labelled test data by latent curve set\n');
fprintf('27: Run plots 18, 19, 20, 24, 25, 29, 30, 31, 32 in one go\n');
fprintf('28: Compare latent curve set populations for multiple model runs\n');
fprintf('29: Plot interventions over time by latent curve set (absolute days)\n');
fprintf('30: Plot probilities of latent curve set assignment\n');
fprintf('31: Plot superimposed alignment curves - max shift - one per page\n');
fprintf('32: Plot superimposed alignment curves - max shift - all on one page\n');
fprintf('33: Plot histogram of vertical shifts\n');
fprintf('34: Run normalised prediction plots\n');
fprintf('35: Plot superimposed alignment curves - exzero shift - one per page\n');
fprintf('36: Plot superimposed alignment curves - exzero shift - all on one page\n');
fprintf('37: Plot superimposed measures - mean shift - one intervention per page\n');
fprintf('38: Plot superimposed measures - max shift - one intervention per page\n');
fprintf('39: Plot superimposed measures - exzero shift - one intervention per page\n');
fprintf('40: Plot superimposed alignment curves - 7d mean shift - one per page\n');
fprintf('41: Plot superimposed alignment curves - 7d mean shift - all on one page\n');
fprintf('42: Plot superimposed measures - 7d mean shift - one intervention per page\n');
fprintf('43: Plot histogram of time since last exacerbation\n');
fprintf('44: Plotting histogram of lc set by hospital\n');

noptions = 44;
fprintf('\n');
runfunction = selectValFromRange('Choose function', 1, noptions);
fprintf('\n');

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
[~, studytmp, ~] = selectStudy();

if ismember(runfunction, [10, 26])
    [modelrun, modelidx, models] = amEMMCSelectModelRunFromDir(studytmp, '', 'LCSet', 'IntrFilt', 'TGap', 'TstLbl');
elseif ismember(runfunction, [28, 30])
    [modelrun, modelidx, models] = amEMMCSelectModelRunFromDir(studytmp, '', 'LCSet', 'IntrFilt', 'TGap',       '');
else
    [modelrun, modelidx, models] = amEMMCSelectModelRunFromDir(studytmp, '',      '', 'IntrFilt', 'TGap',       '');
end

fprintf('Loading output from model run\n');
load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun)));

predictivemodelinputsfile = sprintf('%spredictivemodelinputs.mat', study);
ivandmeasuresfile = sprintf('%sivandmeasures_gap%d.mat', study, treatgap);

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
    
if runfunction == 1
    tic
    %subfolder = 'Plots';
    fprintf('Plotting prediction results\n');
    normmode = 1; % plot regular measurement data
    for i=1:ninterventions
        amEMMCPlotsAndSavePredictions(amInterventions, amIntrDatacube, measures, pdoffset, overall_pdoffset, ...
            hstg, overall_hist, vshift, meancurvemean, normmean, normstd, isOutlier, ex_start, i, nmeasures, ...
            max_offset, align_wind, sigmamethod, plotname, plotsubfolder, normmode);
    end
    toc
    fprintf('\n');
elseif runfunction == 2
    tic
    subfolder = 'AnimatedPlots';
    fprintf('Running concurrent alignment animation\n');
    moviefilename = sprintf('%s-ConcurrentAlignment', modelrun);
    animatedlc = 0; % just until i rerun the model to save this variable
    [f, p, niterations] = amEMMCAnimatedAlignmentConcurrent(animatedmeancurvemean, animatedoffsets, animatedlc, animated_overall_pdoffset, ...
        unaligned_profile, measures, max_offset, align_wind, nmeasures, ninterventions, nlatentcurves, runmode, fullfile(basedir, subfolder, moviefilename));
    toc
    fprintf('\n');
elseif runfunction == 3
    tic
    subfolder = 'AnimatedPlots';
    fprintf('Running sequential alignment animation\n');
    moviefilename = sprintf('%s-SequentialAlignment', modelrun);
    [f, p, niterations] = animatedAlignmentSequential(animatedmeancurvemean, unaligned_profile, measures, max_offset, ...
        align_wind, nmeasures, fullfile(basedir, subfolder, moviefilename));
    toc
    fprintf('\n');
elseif runfunction == 4
    tic
    fprintf('Running concurrent prod distribution animation\n');
    subfolder = 'AnimatedPlots';
    moviefilename = sprintf('%s-ProbDistribution', modelrun);
    [f, p, niterations] = amEMMCAnimatedProbDistConcurrent(animated_overall_pdoffset, max_offset, ninterventions, ...
        nlatentcurves, fullfile(basedir, subfolder, moviefilename));
    toc
    fprintf('\n');
elseif runfunction == 5
    tic
    fprintf('Saving prob distributions to a separate matlab file\n');
    subfolder = 'MatlabSavedVariables';
    outputfilename = sprintf('%s-PDs.mat', modelrun);
    save(fullfile(basedir, subfolder, outputfilename), 'initial_offsets', 'offsets', 'hstg', ...
        'pdoffset', 'overall_hist', 'overall_pdoffset');
elseif runfunction == 6
    fprintf('Labelling exacerbation start on measurement plots to create test data set\n');
    treatgap = selectTreatmentGap();
    [testlabelmthd, testlabeltxt] = selectLabelMethodology();
    
    basetestlabelfilename = sprintf('%s_LabelledInterventions_gap%d%s', study, treatgap, testlabeltxt);
    
    fprintf('1: Run from scratch\n');
    fprintf('2: Continue from partway through\n');
    fprintf('3: Update a single intervention\n');
    fprintf('4: Run for additional examples\n');

    labelmode = selectValFromRange('Select mode to run', 1, 4);

    if labelmode == 1
        if ~exist(fullfile(basedir, subfolder, sprintf('%s.mat', basetestlabelfilename)), 'file')
            fprintf('Creating new labelled test data file\n');
            [amLabelledInterventions] = createInitialLabelledIntr(amInterventions);
            interfrom = 1;
            interto = ninterventions;
        else
            fprintf('Labelled test file %s already exists\n', sprintf('%s.mat', basetestlabelfilename));
            return;
        end
    elseif labelmode == 2
        fprintf('Loading latest labelled test data file %s\n', basetestlabelfilename);
        load(fullfile(basedir, subfolder, sprintf('%s.mat', basetestlabelfilename)));
        interfrom = selectValFromRange('Enter intervention to restart from', 2, ninterventions);
        interto   = ninterventions;
    elseif labelmode == 3
        fprintf('Loading latest labelled test data file %s\n', basetestlabelfilename);
        load(fullfile(basedir, subfolder, sprintf('%s.mat', basetestlabelfilename)));
        interfrom = selectValFromRange('Enter intervention to update', 1, ninterventions);
        interto = interfrom;
    elseif labelmode == 4
        fprintf('Loading latest labelled test data file %s\n', basetestlabelfilename);
        load(fullfile(basedir, subfolder, sprintf('%s.mat', basetestlabelfilename)));
        [amLabelledInterventions] = updateListOfLabelledIntr(amInterventions, amLabelledInterventions);
        interfrom = 1;
        interto = ninterventions;
    end

    [amLabelledInterventions] = amEMMCCreateLabelledInterventions(amIntrDatacube, amLabelledInterventions, ...
        interfrom, interto, measures, normmean, max_offset, align_wind, study, nmeasures, labelmode, basetestlabelfilename);

elseif runfunction == 7
    fprintf('Comparing results to another model run\n');
    fprintf('\n');
    fprintf('Select second model to compare\n');
    fprintf('\n');
    [modelrun2, modelidx2] = amEMMCSelectModelRunFromDir(studytmp, '', '', 'IntrFilt', 'TGap', '');
    amEMMCCompareModelRuns(modelrun, modelidx, modelrun2, modelidx2);
elseif runfunction == 8
    fprintf('Comparing results to the labelled test data\n');
    fprintf('\n');
    fprintf('1: Test set only\n');
    fprintf('2: All Interventions\n');

    testsetmode = selectValFromRange('Select mode to run', 1, 2);
    subfolder = 'MatlabSavedVariables';
    load(fullfile(basedir, subfolder, labelledinterventionsfile));
    %amEMMCCompareModelRunToTestData(amLabelledInterventions(intrkeepidx, :), amInterventions, amIntrDatacube, measures, pdoffset, overall_pdoffset, hstg, overall_hist, ...
    %    meancurvemean, normmean, normstd, ex_start, nmeasures, ninterventions, nlatentcurves, max_offset, align_wind, sigmamethod, study, mversion, modelrun, modelidx, testsetmode);
    amEMMCCompareModelRunToTestData(amLabelledInterventions, amInterventions, amIntrDatacube, measures, pdoffset, overall_pdoffset, hstg, overall_hist, ...
        meancurvemean, normmean, normstd, ex_start, nmeasures, nlatentcurves, max_offset, align_wind, sigmamethod, study, mversion, modelrun, modelidx, testsetmode, plotsubfolder);

elseif runfunction == 9
    fprintf('<placeholder for Dragos new option>\n');
elseif runfunction == 10
    fprintf('Comparing results of multiple model runs to the labelled test data\n');
    fprintf('\n');
    subfolder = 'MatlabSavedVariables';
    load(fullfile(basedir, subfolder, labelledinterventionsfile));
    plotmode = 'Overall'; 
    %[lcbymodelrun, offsetbymodelrun] = amEMMCCompareMultipleModelRunToTestData(amLabelledInterventions(intrkeepidx, :), modelrun, modelidx, models, plotmode, study);
    [lcbymodelrun, offsetbymodelrun] = amEMMCCompareMultipleModelRunToTestData(amLabelledInterventions, modelidx, models, plotmode, study);
elseif runfunction == 11
    fprintf('Comparing results of multiple model runs\n');
    fprintf('\n');
    [modeliterations, modeloffsets] = compareMultipleModelRunResults(modelrun, modelidx, models, basedir, subfolder);
elseif runfunction == 12
    fprintf('Plotting simplified aligned curves\n');
    fprintf('\n');
    run_type = 'Best Alignment';
    amEMPlotAndSaveAlignedCurvesBasic(unaligned_profile, meancurvemean, offsets, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder);
elseif runfunction == 13
    fprintf('Loading latest labelled test data file\n');
    load(fullfile(basedir, subfolder, labelledinterventionsfile));
    fprintf('Plotting labelled test data\n');
    fprintf('\n');
    amEMMCPlotLabelledInterventions(amIntrDatacube, amInterventions, amLabelledInterventions, ...
        measures, normmean, max_offset, align_wind, study, nmeasures)  
elseif runfunction == 14
    fprintf('Loading latest labelled test data file\n');
    load(fullfile(basedir, subfolder, labelledinterventionsfile));
    fprintf('Calculating Ex_Start from Test Labels and Offsets\n');
    fprintf('\n');
    %derived_ex_start = amEMMCCalcExStartsFromTestLabels(amLabelledInterventions(intrkeepidx, :), amInterventions, ...
    %    overall_pdoffset, max_offset, sprintf('Plots/%s', modelrun), modelrun, ninterventions, nlatentcurves);
    derived_ex_start = amEMMCCalcExStartsFromTestLabels(amLabelledInterventions, amInterventions, ...
        overall_pdoffset, max_offset, sprintf('Plots/%s', modelrun), modelrun, ninterventions, nlatentcurves);
elseif runfunction == 15
    run_type = 'Best Alignment';
    fprintf('Plotting aligned curves \n');
    amEMMCPlotAndSaveAlignedCurves(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, ...
        amInterventions.Offset, amInterventions.LatentCurve, ...
        measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, sigmamethod, plotname, plotsubfolder, nlatentcurves);
elseif runfunction == 16
    run_type = 'Best Alignment';
    fprintf('Plotting alignment detail\n');
    [sorted_interventions, max_points] = amEMMCVisualiseAlignmentDetail(amIntrNormcube, amHeldBackcube, amInterventions, meancurvemean, ...
        meancurvecount, meancurvestd, overall_pdoffset, measures, min_offset, max_offset, align_wind, nmeasures, ninterventions, ...
        run_type, ex_start, curveaveragingmethod, plotname, plotsubfolder, nlatentcurves);
elseif runfunction == 17
    run_type = 'Best Alignment';
    fprintf('Plotting alignment curves side-by-side\n');
    centerplots = false;
    amEMMCPlotAlignedCurvesSideBySide(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, amInterventions.Offset, amInterventions.LatentCurve, ...
        measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, sigmamethod, plotname, plotsubfolder, nlatentcurves, centerplots);
elseif runfunction == 18
    run_type = 'Best Alignment';
    fprintf('Plotting alignment curves side-by-side with centering\n');
    centerplots = true;
    amEMMCPlotAlignedCurvesSideBySide(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, amInterventions.Offset, amInterventions.LatentCurve, ...
        measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, sigmamethod, plotname, plotsubfolder, nlatentcurves, centerplots);
elseif runfunction == 19
    fprintf('Loading Predictive Model Patient Measures Stats\n');
    basedir = setBaseDir();
    subfolder = 'MatlabSavedVariables';
    load(fullfile(basedir, subfolder, predictivemodelinputsfile), 'pmPatients', 'pmPatientMeasStats');
    fprintf('Loading Treatment and Measures Prior info\n');
    basedir = setBaseDir();
    subfolder = 'MatlabSavedVariables';
    fprintf('Loading clinical microbiology, antibiotic, admissions, and CRP data\n');
    load(fullfile(basedir, subfolder, ivandmeasuresfile), 'ivandmeasurestable');
    [~, clinicalmatfile, ~] = getRawDataFilenamesForStudy(study);
    [~, ~, cdMicrobiology, cdAntibiotics, cdAdmissions, ~, cdCRP, ~, ~, ~, ~] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);
    fprintf('Plotting Variables vs latent curve allocation\n');
    amEMMCPlotVariablesVsLatentCurveSet(amInterventions, pmPatients, pmPatientMeasStats, ivandmeasurestable, ...
        cdMicrobiology, cdAntibiotics, cdAdmissions, cdCRP, measures, plotname, plotsubfolder, ninterventions, nlatentcurves, study);
elseif runfunction == 20
    fprintf('Loading Predictive Model Patient info\n');
    basedir = setBaseDir();
    subfolder = 'MatlabSavedVariables';
    sprintf('%s_LabelledInterventions.mat', study);
    load(fullfile(basedir, subfolder, predictivemodelinputsfile), 'pmPatients', 'npatients', 'maxdays');
    fprintf('Loading unfiltered interventions\n');
    amInterventionsKeep = amInterventions;
    sprintf(amRunParameters.modelinputsmatfile{1}, study, treatgap)
    load(fullfile(basedir, subfolder, modelinputsmatfile), 'amInterventions');
    amInterventionsFull = amInterventions;
    amInterventions = amInterventionsKeep;
    fprintf('Plotting interventions over time by latent curve set\n');
    plotmode = 1; % plot using scaled dates
    amEMMCPlotInterventionsByLatentCurveSet(pmPatients, amInterventions, amInterventionsFull, npatients, maxdays, plotname, plotsubfolder, nlatentcurves, plotmode);
elseif runfunction == 21
    fprintf('Done\n');
elseif runfunction == 22
    measure = amEMMCSelectMeasure(measures, nmeasures);
    amEMMCPlotSingleMeasureByLCSet(amInterventions, amIntrDatacube, normmean, measure, measures, ...
            ex_start, max_offset, align_wind, plotname, plotsubfolder, nlatentcurves);
elseif runfunction == 23
    fprintf('Comparing latent curve set population to another model run\n');
    fprintf('\n');
    fprintf('Select second model to compare\n');
    fprintf('\n');
    [modelrun2, modelidx2] = amEMMCSelectModelRunFromDir(studytmp, '', '', 'IntrFilt', 'TGap', '');
    amEMMCCompareModelRunsByLCSets(modelrun, modelidx, modelrun2, modelidx2);
elseif runfunction == 24
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - mean shift - one per page\n');
    compactplot = false;
    shiftmode = 1; % shift by mean to left of ex_start
    amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, countthreshold, compactplot, shiftmode, study);
elseif runfunction == 25
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - mean shift - all on one page\n');
    compactplot = true;
    shiftmode = 1; % shift by mean to left of ex_start
    amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, countthreshold, compactplot, shiftmode, study);
elseif runfunction == 26
    fprintf('Comparing results of multiple model runs to the labelled test data by latent curve set\n');
    fprintf('\n');
    subfolder = 'MatlabSavedVariables';
    load(fullfile(basedir, subfolder, labelledinterventionsfile));
    plotmode = 'ByLCSet'; 
    amEMMCCompareMultipleModelRunToTestData(amLabelledInterventions(intrkeepidx, :), modelrun, modelidx, models, plotmode);
elseif runfunction == 27
    % run plot 18
    run_type = 'Best Alignment';
    fprintf('Plotting alignment curves side-by-side with centering\n');
    centerplots = true;
    amEMMCPlotAlignedCurvesSideBySide(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, amInterventions.Offset, amInterventions.LatentCurve, ...
        measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, sigmamethod, plotname, plotsubfolder, nlatentcurves, centerplots);
    % run plot 19
    fprintf('Loading Predictive Model Patient Measures Stats\n');
    basedir = setBaseDir();
    subfolder = 'MatlabSavedVariables';
    load(fullfile(basedir, subfolder, predictivemodelinputsfile), 'pmPatients', 'pmPatientMeasStats');
    fprintf('Loading Treatment and Measures Prior info\n');
    basedir = setBaseDir();
    subfolder = 'MatlabSavedVariables';
    load(fullfile(basedir, subfolder, ivandmeasuresfile), 'ivandmeasurestable');
    if ismember(study, 'SC')
        clinicalmatfile   = 'clinicaldata.mat';
        microbiologytable = 'cdMicrobiology';
        abtable           = 'cdAntibiotics';
        admtable          = 'cdAdmissions';
        crptable          = 'cdCRP';
    elseif ismember(study, 'TM')
        clinicalmatfile   = 'telemedclinicaldata.mat';
        microbiologytable = 'tmMicrobiology';
        abtable           = 'tmAntibiotics';
        admtable          = 'tmAdmissions';
        crptable          = 'tmCRP';
    else
        fprintf('Invalid study\n');
        return;
    end
    fprintf('Loading clinical microbiology and CRP data\n');
    load(fullfile(basedir, subfolder, clinicalmatfile), microbiologytable, abtable, admtable, crptable);
    if ismember(study, 'TM')
        cdMicrobiology = tmMicrobiology;
        cdAntibiotics  = tmAntibiotics;
        cdAdmissions   = tmAdmissions;
        cdCRP          = tmCRP;
    end
    fprintf('Plotting Variables vs latent curve allocation\n');
    amEMMCPlotVariablesVsLatentCurveSet(amInterventions, pmPatients, pmPatientMeasStats, ivandmeasurestable, ...
        cdMicrobiology, cdAntibiotics, cdAdmissions, cdCRP, measures, plotname, plotsubfolder, ninterventions, nlatentcurves);
    % run plot 20
    fprintf('Loading Predictive Model Patient info\n');
    basedir = setBaseDir();
    subfolder = 'MatlabSavedVariables';
    load(fullfile(basedir, subfolder, predictivemodelinputsfile), 'pmPatients', 'npatients', 'maxdays');
    fprintf('Loading unfiltered interventions\n');
    amInterventionsKeep = amInterventions;
    load(fullfile(basedir, subfolder, modelinputsmatfile), 'amInterventions');
    amInterventionsFull = amInterventions;
    amInterventions = amInterventionsKeep;
    fprintf('Plotting interventions over time by latent curve set\n');
    plotmode = 1; % plot using scaled dates
    amEMMCPlotInterventionsByLatentCurveSet(pmPatients, amInterventions, amInterventionsFull, npatients, maxdays, plotname, plotsubfolder, nlatentcurves, plotmode);
    % run plot 24
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - mean shift - one per page\n');
    compactplot = false;
    shiftmode = 1; % shift by mean to left of ex_start
    amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, countthreshold, compactplot, shiftmode, study);
    % run plot 25
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - mean shift - all on one page\n');
    compactplot = true;
    shiftmode = 1; % shift by mean to left of ex_start
    amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, countthreshold, compactplot, shiftmode, study);
    % run plot 29
    fprintf('Loading Predictive Model Patient info\n');
    basedir = setBaseDir();
    subfolder = 'MatlabSavedVariables';
    sprintf('%s_LabelledInterventions.mat', study);
    load(fullfile(basedir, subfolder, predictivemodelinputsfile), 'pmPatients', 'npatients', 'maxdays');
    fprintf('Loading unfiltered interventions\n');
    amInterventionsKeep = amInterventions;
    load(fullfile(basedir, subfolder, modelinputsmatfile), 'amInterventions');
    amInterventionsFull = amInterventions;
    amInterventions = amInterventionsKeep;
    fprintf('Plotting interventions over time by latent curve set\n');
    plotmode = 2; % plot using scaled dates
    amEMMCPlotInterventionsByLatentCurveSet(pmPatients, amInterventions, amInterventionsFull, npatients, maxdays, plotname, plotsubfolder, nlatentcurves, plotmode);
	%run plot 30
    fprintf('Plotting probilities of latent curve set assignment\n');
    amEMMCPlotProbsLCSet(overall_pdoffset, amInterventions, min_offset, max_offset, plotname, plotsubfolder, ninterventions, nlatentcurves);
    % run plot 31
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - max shift - one per page\n');
    compactplot = false;
    shiftmode = 2; % shift by max to left of ex_start
    amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, countthreshold, compactplot, shiftmode);
    % run plot 32
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - max shift - all on one page\n');
    compactplot = true;
    shiftmode = 2; % shift by max to left of ex_start
    amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, countthreshold, compactplot, shiftmode);
    
elseif runfunction == 28
    fprintf('Comparing latent curve set population to multiple model runs\n');
    amEMMCCompareMultipleModelRunsByLCSets(modelrun, modelidx, models);
elseif runfunction == 29
    fprintf('Loading Predictive Model Patient info\n');
    basedir = setBaseDir();
    subfolder = 'MatlabSavedVariables';
    sprintf('%s_LabelledInterventions.mat', study);
    load(fullfile(basedir, subfolder, predictivemodelinputsfile), 'pmPatients', 'npatients', 'maxdays');
    fprintf('Loading unfiltered interventions\n');
    amInterventionsKeep = amInterventions;
    load(fullfile(basedir, subfolder, modelinputsmatfile), 'amInterventions');
    amInterventionsFull = amInterventions;
    amInterventions = amInterventionsKeep;
    fprintf('Plotting interventions over time by latent curve set\n');
    plotmode = 2; % plot using scaled dates
    amEMMCPlotInterventionsByLatentCurveSet(pmPatients, amInterventions, amInterventionsFull, npatients, maxdays, plotname, plotsubfolder, nlatentcurves, plotmode);
elseif runfunction == 30
    fprintf('Plotting probilities of latent curve set assignment\n');
    amEMMCPlotProbsLCSet(overall_pdoffset, amInterventions, min_offset, max_offset, plotname, plotsubfolder, ninterventions, nlatentcurves);
elseif runfunction == 31
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - max shift - one per page\n');
    compactplot = false;
    shiftmode = 2; % shift by max to left of ex_start
    amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, countthreshold, compactplot, shiftmode, study);
elseif runfunction == 32
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - max shift - all on one page\n');
    compactplot = true;
    shiftmode = 2; % shift by max to left of ex_start
    amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, countthreshold, compactplot, shiftmode, study);
elseif runfunction == 33
    fprintf('Plotting histogram of vertical shifts\n');
    amEMMCPlotHistogramOfVShifts(amInterventions, vshift, measures, nmeasures, ninterventions, nlatentcurves, plotname, plotsubfolder, vshiftmode, vshiftmax);
elseif runfunction == 34
    tic
    fprintf('Plotting normalised prediction results\n');
    normmode = 2; % plot normalised measurement data
    for i=1:ninterventions
        amEMMCPlotsAndSavePredictions(amInterventions, amIntrNormcube, measures, pdoffset, overall_pdoffset, ...
            hstg, overall_hist, vshift, meancurvemean, normmean, normstd, isOutlier, ex_start, i, nmeasures, ...
            max_offset, align_wind, sigmamethod, plotname, plotsubfolder, normmode);
    end
    toc
    fprintf('\n');
elseif runfunction == 35
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - exzero shift - one per page\n');
    compactplot = false;
    shiftmode = 3; % shift to be zero at ex_start
    amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, countthreshold, compactplot, shiftmode, study);
elseif runfunction == 36
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - exzero shift - all on one page\n');
    compactplot = true;
    shiftmode = 3; % shift to be zero at ex_start
    amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, countthreshold, compactplot, shiftmode, study);
elseif runfunction == 37
    fprintf('Plotting superimposed measures - mean shift - one intervention per page\n');
    shiftmode = 1; % shift by mean to left of ex_start
    amEMMCPlotSuperimposedMeasuresB4Intr(amIntrNormcube, amInterventions, ...
        measures, max_offset, align_wind, nmeasures, ninterventions, ex_start, plotsubfolder, shiftmode);
elseif runfunction == 38
    fprintf('Plotting superimposed measures - max shift - one intervention per page\n');
    shiftmode = 2; % shift by max to left of ex_start
    amEMMCPlotSuperimposedMeasuresB4Intr(amIntrNormcube, amInterventions, ...
        measures, max_offset, align_wind, nmeasures, ninterventions, ex_start, plotsubfolder, shiftmode);
elseif runfunction == 39
    fprintf('Plotting superimposed measures - exzero shift - one intervention per page\n');
    shiftmode = 3; % shift to be zero at ex_start
    amEMMCPlotSuperimposedMeasuresB4Intr(amIntrNormcube, amInterventions, ...
        measures, max_offset, align_wind, nmeasures, ninterventions, ex_start, plotsubfolder, shiftmode);
elseif runfunction == 40
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - mean shift - one per page\n');
    compactplot = false;
    shiftmode = 4; % shift by 7d mean to left of ex_start
    amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, countthreshold, compactplot, shiftmode, study);
elseif runfunction == 41
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - mean shift - all on one page\n');
    compactplot = true;
    shiftmode = 4; % shift by 7d mean to left of ex_start
    amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, countthreshold, compactplot, shiftmode, study);
elseif runfunction == 42
    fprintf('Plotting superimposed measures - 5d mean shift - one intervention per page\n');
    shiftmode = 4; % shift by 7d mean to left of ex_start
    amEMMCPlotSuperimposedMeasuresB4Intr(amIntrNormcube, amInterventions, ...
        measures, max_offset, align_wind, nmeasures, ninterventions, ex_start, plotsubfolder, shiftmode);
elseif runfunction == 43
    fprintf('Plotting histogram of time since last exacerbation\n');
    fprintf('Loading Predictive Model Patient Measures Stats\n');
    load(fullfile(basedir, subfolder, predictivemodelinputsfile), 'pmPatients', 'pmPatientMeasStats', 'npatients', 'maxdays');
    fprintf('Loading Treatment and Measures Prior info\n');
    load(fullfile(basedir, subfolder, ivandmeasuresfile), 'ivandmeasurestable');
    amEMMCPlotHistOfTimeSinceLastExacerbation(pmPatients, amInterventions, ivandmeasurestable, ...
        npatients, maxdays, plotname, plotsubfolder, nlatentcurves);
elseif runfunction == 44
    fprintf('Plotting histogram of lc set by hospital\n');
    if contains(modelrun, {'Age', 'Gender'})
        % call function to combine both files
        [tmpInterventions, tmpnlc] = combineSplitClassResults(study, modelrun, basedir, subfolder);
    else
        tmpInterventions = amInterventions;
        tmpnlc           = nlatentcurves;
    end
    plotLCSetByHospital(tmpInterventions, plotname, plotsubfolder, tmpnlc);

    
else
    fprintf('Should not get here....\n');
end
    

    