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

for i=1:a
        abTreatments.InitialOffset(i) = 0;
end

[best_offsets, profile_pre, profile_post, best_histogram, best_qual] = alignCurves(normcube, abTreatments, max_offset, align_wind, nmeasures);
fprintf('Baseline - zero offset start - ErrFcn = %6.1f\n', best_qual);
toc
fprintf('\n');
