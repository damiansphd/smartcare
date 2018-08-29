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
fprintf('6: Label exacerbation plots for test data\n');
fprintf('7: Check model run results vs labelled test data\n');
runfunction = input('Choose function (1-7) ');

fprintf('\n');

if runfunction > 7
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
    fprintf('Running concurrent prod distribution animation\n');
    subfolder = 'AnimatedPlots';
    moviefilename = sprintf('%s-ProbDistribution', modelrun);
    [f, p, niterations] = animatedProbDistConcurrent(animated_overall_pdoffset, max_offset, ninterventions, ...
        fullfile(basedir, subfolder, moviefilename));
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
        for a = 1:ninterventions
            amLabelledInterventions.DataWindowCompleteness(a) = 0;
            amLabelledInterventions.SequentialIntervention(a) = 'N';
            amLabelledInterventions.IncludeInTestSet(a)       = 'N';
            amLabelledInterventions.ExStart(a)                = ex_start;
            amLabelledInterventions.LowerBound(a)             = 0;
            amLabelledInterventions.UpperBound(a)             = 0;
        end
        interfrom = 1;
        interto = ninterventions;
    elseif labelmode == 2
        fprintf('Loading latest labelled test data file\n');
        inputfilename = 'LabelledInterventions.mat';
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
        inputfilename = 'LabelledInterventions.mat';
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

    [amLabelledInterventions] = createLabelledInterventions(amIntrDatacube, amLabelledInterventions, pdoffset, overall_pdoffset, ...
        interfrom, interto, measures, normmean, max_offset, align_wind, ex_start, study, ninterventions, nmeasures);
    
    fprintf('Saving labelled interventions to a separate matlab file\n');
    subfolder = 'MatlabSavedVariables';
    outputfilename = sprintf('LabelledInterventions%s.mat', datestr(clock(),30));
    save(fullfile(basedir, subfolder, outputfilename), 'amLabelledInterventions');
    outputfilename = sprintf('LabelledInterventions.mat');
    save(fullfile(basedir, subfolder, outputfilename), 'amLabelledInterventions');
else
    fprintf('Checking model run results against the labelled test data\n');
    
end
    

    

