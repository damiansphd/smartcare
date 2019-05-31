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
fprintf('17: Plot alignment surves side-by-side\n');
fprintf('18: Plot alignment surves side-by-side with centering\n');
fprintf('19: Plot variables vs latent curve assignment\n');
fprintf('20: Plot interventions over time by latent curve set\n');
fprintf('21: Load variables for a given model run\n');
fprintf('22: Plot a measure for a set of examples\n');
fprintf('23: Compare latent curve set populations for 2 model runs\n');
fprintf('24: Plot superimposed alignment surves\n');
fprintf('25: Compare results for multiple model runs to labelled test data by latent curve set\n');
fprintf('\n');
runfunction = input('Choose function (1-25): ');

fprintf('\n');

if runfunction > 25
    fprintf('Invalid choice\n');
    return;
end
if isequal(runfunction,'')
    fprintf('Invalid choice\n');
    return;
end

if runfunction ~= 25
    [modelrun, modelidx, models] = amEMMCSelectModelRunFromDir('');
else
    [modelrun, modelidx, models] = amEMMCSelectModelRunFromDir('LCSet');
end

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
fprintf('Loading output from model run\n');
load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun)));

% default some variables for backward compatibility with prior versions
if exist('animated_overall_pdoffset', 'var') == 0
    animated_overall_pdoffset = 0;
end
if exist('isOutlier', 'var') == 0
    isOutlier = zeros(nlatentcurves, ninterventions, align_wind, nmeasures, max_offset);
end
    
if runfunction == 1
    tic
    subfolder = 'Plots';
    fprintf('Plotting prediction results\n');
    for i=1:ninterventions
        amEMMCPlotsAndSavePredictions(amInterventions, amIntrDatacube, measures, pdoffset, overall_pdoffset, ...
            hstg, overall_hist, meancurvemean, normmean, normstd, isOutlier, ex_start, i, nmeasures, ...
            max_offset, align_wind, sigmamethod, plotname, plotsubfolder);
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
    fprintf('1: Run from scratch\n');
    fprintf('2: Continue from partway through\n');
    fprintf('3: Update a single intervention\n');
    
    labelmode = input('Select mode to run (1-3) ? ');
    
    if labelmode > 3
        fprintf('Invalid choice\n');
        return;
    end
    if isequal(labelmode,'')
        fprintf('Invalid choice\n');
        return;
    end
    
    if labelmode == 1
        fprintf('Creating new labelled test data file\n');
        amLabelledInterventions = amInterventions;
        amLabelledInterventions.LowerBound1 = [];
        amLabelledInterventions.UpperBound1 = [];
        amLabelledInterventions.LowerBound2 = [];
        amLabelledInterventions.UpperBound2 = [];
        amLabelledInterventions.ConfidenceProb = [];
        amLabelledInterventions.Ex_Start    = [];
        amLabelledInterventions.Pred        = [];
        amLabelledInterventions.RelLB1      = [];
        amLabelledInterventions.RelUB1      = [];
        amLabelledInterventions.RelLB2      = [];
        amLabelledInterventions.RelUB2      = [];
        
        amLabelledInterventions.Offset(:)            = 0;
        amLabelledInterventions.IncludeInTestSet(:)  = 'N';
        amLabelledInterventions.ExStart(:)           = ex_start;
        amLabelledInterventions.LowerBound1(:)       = 0;
        amLabelledInterventions.UpperBound1(:)       = 0;
        amLabelledInterventions.LowerBound2(:)       = 0;
        amLabelledInterventions.UpperBound2(:)       = 0;
        interfrom = 1;
        interto = ninterventions;
    elseif labelmode == 2
        fprintf('Loading latest labelled test data file\n');
        inputfilename = sprintf('%s_LabelledInterventions.mat', study);
        load(fullfile(basedir, subfolder, inputfilename));
        interfrom = input('Enter intervention to restart from ? ');
        if interfrom < 2 || interfrom > ninterventions 
            fprintf('Invalid choice\n');
            return;
        end
        if isequal(interfrom,'')
            fprintf('Invalid choice\n');
            return;
        end
        interto = ninterventions;
    else
        fprintf('Loading latest labelled test data file\n');
        inputfilename = sprintf('%s_LabelledInterventions.mat', study);
        load(fullfile(basedir, subfolder, inputfilename));
        interfrom = input('Enter intervention to update ? ');
        if interfrom < 1 || interfrom > ninterventions 
            fprintf('Invalid choice\n');
            return;
        end
        if isequal(interfrom,'')
            fprintf('Invalid choice\n');
            return;
        end
        interto = interfrom;
    end

    [amLabelledInterventions] = amEMMCCreateLabelledInterventions(amIntrDatacube, amLabelledInterventions, pdoffset, overall_pdoffset, ...
        interfrom, interto, measures, normmean, max_offset, align_wind, ex_start, study, nmeasures);
    
    fprintf('Saving labelled interventions to a separate matlab file\n');
    subfolder = 'MatlabSavedVariables';
    outputfilename = sprintf('%s_LabelledInterventions%s.mat', study, datestr(clock(),30));
    save(fullfile(basedir, subfolder, outputfilename), 'amLabelledInterventions');
    outputfilename = sprintf('%s_LabelledInterventions.mat', study);
    save(fullfile(basedir, subfolder, outputfilename), 'amLabelledInterventions');
elseif runfunction == 7
    fprintf('Comparing results to another model run\n');
    fprintf('\n');
    fprintf('Select second model to compare\n');
    fprintf('\n');
    [modelrun2, modelidx2] = amEMMCSelectModelRunFromDir('');
    amEMMCCompareModelRuns(modelrun, modelidx, modelrun2, modelidx2);
elseif runfunction == 8
    fprintf('Comparing results to the labelled test data\n');
    fprintf('\n');
    subfolder = 'MatlabSavedVariables';
    testdatafilename = sprintf('%s_LabelledInterventions.mat', study);
    load(fullfile(basedir, subfolder, testdatafilename));
    amEMMCCompareModelRunToTestData(amLabelledInterventions, amInterventions, amIntrDatacube, measures, pdoffset, overall_pdoffset, hstg, overall_hist, ...
        meancurvemean, normmean, normstd, ex_start, nmeasures, ninterventions, nlatentcurves, max_offset, align_wind, sigmamethod, study, mversion, modelrun, modelidx);
elseif runfunction == 9
    fprintf('<placeholder for Dragos new option>\n');
elseif runfunction == 10
    fprintf('Comparing results of multiple model runs to the labelled test data\n');
    fprintf('\n');
    subfolder = 'MatlabSavedVariables';
    testdatafilename = sprintf('%s_LabelledInterventions.mat', study);
    load(fullfile(basedir, subfolder, testdatafilename));
    plotmode = 'Overall'; 
    amEMMCCompareMultipleModelRunToTestData(amLabelledInterventions, modelrun, modelidx, models, plotmode);
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
    inputfilename = sprintf('%s_LabelledInterventions.mat', study);
    load(fullfile(basedir, subfolder, inputfilename));
    fprintf('Plotting labelled test data\n');
    fprintf('\n');
    amEMMCPlotLabelledInterventions(amIntrDatacube, amInterventions, amLabelledInterventions, ...
    pdoffset, overall_pdoffset, measures, normmean, max_offset, align_wind, ex_start, ...
    study, nmeasures)  
elseif runfunction == 14
    fprintf('Loading latest labelled test data file\n');
    inputfilename = sprintf('%s_LabelledInterventions.mat', study);
    load(fullfile(basedir, subfolder, inputfilename));
    fprintf('Calculating Ex_Start from Test Labels and Offsets\n');
    fprintf('\n');
    derived_ex_start = amEMMCCalcExStartsFromTestLabels(amLabelledInterventions, amInterventions, ...
        overall_pdoffset, max_offset, sprintf('Plots/%s', modelrun), modelrun, ninterventions, nlatentcurves);
elseif runfunction == 15
    run_type = 'Best Alignment';
    subfolder = 'Plots';
    fprintf('Plotting aligned curves \n');
    amEMMCPlotAndSaveAlignedCurves(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, ...
        amInterventions.Offset, amInterventions.LatentCurve, ...
        measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, sigmamethod, plotname, plotsubfolder, nlatentcurves);
elseif runfunction == 16
    run_type = 'Best Alignment';
    subfolder = 'Plots';
    fprintf('Plotting alignment detail\n');
    [sorted_interventions, max_points] = amEMMCVisualiseAlignmentDetail(amIntrNormcube, amHeldBackcube, amInterventions, meancurvemean, ...
        meancurvecount, meancurvestd, overall_pdoffset, measures, min_offset, max_offset, align_wind, nmeasures, ninterventions, ...
        run_type, ex_start, curveaveragingmethod, plotname, plotsubfolder, nlatentcurves);
elseif runfunction == 17
    run_type = 'Best Alignment';
    subfolder = 'Plots';
    fprintf('Plotting alignment curves side-by-side\n');
    centerplots = false;
    amEMMCPlotAlignedCurvesSideBySide(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, amInterventions.Offset, amInterventions.LatentCurve, ...
        measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, sigmamethod, plotname, plotsubfolder, nlatentcurves, centerplots);
elseif runfunction == 18
    run_type = 'Best Alignment';
    subfolder = 'Plots';
    fprintf('Plotting alignment curves side-by-side with centering\n');
    centerplots = true;
    amEMMCPlotAlignedCurvesSideBySide(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, amInterventions.Offset, amInterventions.LatentCurve, ...
        measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, sigmamethod, plotname, plotsubfolder, nlatentcurves, centerplots);
elseif runfunction == 19
    fprintf('Loading Predictive Model Patient Measures Stats\n');
    basedir = setBaseDir();
    subfolder = 'MatlabSavedVariables';
    load(fullfile(basedir, subfolder, 'SCpredictivemodelinputs.mat'), 'pmPatients', 'pmPatientMeasStats');
    fprintf('Loading Treatment and Measures Prior info\n');
    basedir = setBaseDir();
    subfolder = 'MatlabSavedVariables';
    load(fullfile(basedir, subfolder, 'SCivandmeasures.mat'), 'ivandmeasurestable');
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
    amEMMCPlotVariablesVsLatentCurveSet(amInterventions, initial_latentcurve, pmPatients, pmPatientMeasStats, ivandmeasurestable, ...
        cdMicrobiology, cdAntibiotics, cdAdmissions, cdCRP, measures, plotname, plotsubfolder, ninterventions, nlatentcurves);
elseif runfunction == 20
    fprintf('Loading Predictive Model Patient Measures Stats\n');
    basedir = setBaseDir();
    subfolder = 'MatlabSavedVariables';
    load(fullfile(basedir, subfolder, 'SCpredictivemodelinputs.mat'), 'pmPatients', 'pmAntibiotics', 'pmAMPred', 'pmPatientMeasStats', 'npatients', 'maxdays');
    fprintf('Plotting interventions over time by latent curve set\n');
    amEMMCPlotInterventionsByLatentCurveSet(pmPatients, pmAntibiotics, amInterventions, npatients, maxdays, plotname, plotsubfolder, nlatentcurves);
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
    [modelrun2, modelidx2] = amEMMCSelectModelRunFromDir('');
    amEMMCCompareModelRunsByLCSets(modelrun, modelidx, modelrun2, modelidx2);
elseif runfunction == 24
    run_type = 'Best Alignment';
    subfolder = 'Plots';
    fprintf('Plotting superimposed alignment curves\n');
    centerplots = false;
    amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves);
elseif runfunction == 25
    fprintf('Comparing results of multiple model runs to the labelled test data by latent curve set\n');
    fprintf('\n');
    subfolder = 'MatlabSavedVariables';
    testdatafilename = sprintf('%s_LabelledInterventions.mat', study);
    load(fullfile(basedir, subfolder, testdatafilename));
    plotmode = 'ByLCSet'; 
    amEMMCCompareMultipleModelRunToTestData(amLabelledInterventions, modelrun, modelidx, models, plotmode);
else
    fprintf('Should not get here....\n');
end
    

    