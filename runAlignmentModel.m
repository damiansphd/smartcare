clear; close all; clc;

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
modelinputsmatfile = 'alignmentmodelinputs.mat';
fprintf('Loading Alignment Model Inputs data\n');
load(fullfile(basedir, subfolder, modelinputsmatfile));
toc

max_offset = 25; % should not be greater than ex_start (set lower down) as this implies intervention before exacerbation !
align_wind = 20;

tic
fprintf('Running alignement with zero offset start\n');
for i=1:size(amInterventions,1)
        amInterventions.Offset(i) = 0;
end

run_type = 'Zero Offset Start';
[best_offsets, best_profile_pre, best_profile_post, best_histogram, best_qual] = amAlignCurves(amNormcube, amInterventions, measures, max_offset, align_wind, nmeasures, ninterventions, run_type);
fprintf('%s - ErrFcn = %6.1f\n', run_type, best_qual);
toc
fprintf('\n');

niterations = 50;
for j=1:niterations
    tic
    for i=1:ninterventions
        amInterventions.Offset(i) = floor(rand * max_offset/2);
    end
    run_type = sprintf('Random Offset Start %d', j);
    [offsets, profile_pre, profile_pre, histogram, qual] = amAlignCurves(amNormcube, amInterventions, measures, max_offset, align_wind, nmeasures, ninterventions, run_type);
    if qual < best_qual
        best_offsets = offsets;
        best_profile_pre = profile_pre;
        best_profile_post = profile_post;
        best_histogram = histogram;
        best_qual = qual; 
    end
    fprintf('%s - ErrFcn = %6.1f\n', run_type, qual);
    toc
end
fprintf('\n');

