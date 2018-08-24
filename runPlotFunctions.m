clear; close all; clc;

modelrun = selectModelRunFromList('');

% other models to potentially add
% sig4 version (although zero offset start is infinity
% vEM with bet random start from 3 or 4

fprintf('Choose function to run\n');
fprintf('----------------------\n');
fprintf('1: Run prediction plots\n');
fprintf('2: Run alignment animation (concurrent)\n');
fprintf('3: Run alignment animation (sequential)\n');
fprintf('4: Run prod dist animation (concurrent)\n');
fprintf('5: Extract and save prob distributions\n');
runfunction = input('Choose function (1-5) ');

fprintf('\n');

if runfunction > 5
    fprintf('Invalid choice\n');
    return;
end
if isequal(runfunction,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('\n');
basedir = './';
subfolder = 'MatlabSavedVariables';
fprintf('Loading output from model run\n');
load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun)));

if exist('animated_overall_pdoffset', 'var') == 0
    animated_overall_pdoffset = 0;
end
    
if runfunction == 1
    tic
    subfolder = 'Plots';
    fprintf('Plotting prediction results\n');
    for i=1:ninterventions
        amEMPlotsAndSavePredictions(amInterventions, amIntrDatacube, measures, pdoffset, overall_pdoffset, ...
            overall_pdoffset_all, overall_pdoffset_xAL, hstg, overall_hist, overall_hist_all, overall_hist_xAL, ...
            offsets, meancurvemean, normmean, ex_start, i, nmeasures, max_offset, align_wind, study, version);
    end
    toc
    fprintf('\n');
elseif runfunction == 2
    tic
    subfolder = 'AnimatedPlots';
    fprintf('Running concurrent alignment animation\n');
    moviefilename = sprintf('%s-ConcurrentAlignment', modelrun);
    [f, p, niterations] = animatedAlignmentConcurrent(animatedmeancurvemean, animatedoffsets, animated_overall_pdoffset, ...
        unaligned_profile, measures, max_offset, align_wind, nmeasures, ninterventions, runmode, fullfile(basedir, subfolder, moviefilename));
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
    subfolder = 'AnimatedPlots';
    fprintf('Running concurrent prod distribution animation\n');
    moviefilename = sprintf('%s-ProbDistribution', modelrun);
    [f, p, niterations] = animatedProbDistConcurrent(animated_overall_pdoffset, max_offset, ninterventions, ...
        fullfile(basedir, subfolder, moviefilename));
    toc
    fprintf('\n');
else
    tic
    fprintf('Saving prob distributions to a separate matlab file\n');
    basedir = './';
    subfolder = 'MatlabSavedVariables';
    outputfilename = sprintf('%s-PDs.mat', modelrun);
    save(fullfile(basedir, subfolder, outputfilename), 'initial_offsets', 'offsets', 'hstg', ...
        'pdoffset', 'overall_hist', 'overall_pdoffset');
end
    

