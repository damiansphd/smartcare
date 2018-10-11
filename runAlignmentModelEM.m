clear; close all; clc;

version = 'vEM3';

fprintf('Running Alignment Model %s\n', version);
fprintf('\n');

% set the various model run parameters
[study, modelinputsmatfile, datademographicsfile, dataoutliersfile, sigmamethod, mumethod, curveaveragingmethod, ...
    smoothingmethod, offsetblockingmethod, measuresmask, runmode, modelrun, imputationmode, printpredictions] = amEMSetModelRunParameters;

% load the required input data
tic
basedir = './';
subfolder = 'MatlabSavedVariables';
fnmodelrun = fullfile(basedir, subfolder, sprintf('%s.mat',modelrun));
fprintf('Loading alignment model Inputs data\n');
load(fullfile(basedir, subfolder, modelinputsmatfile));
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, datademographicsfile));
fprintf('Loading data outliers\n');
load(fullfile(basedir, subfolder, dataoutliersfile));
toc

tic
fprintf('Preparing input data\n');

% set remaining more static model parameters
max_offset = 25; % should not be greater than ex_start (set lower down) as this would imply intervention before exacerbation !
align_wind = 25;
% define prior probability of a data point being an outlier
outprior = 0.01;
heldbackpct = 0.01;
baseplotname = sprintf('%s_AM%s_sig%d_mu%d_ca%d_sm%d_rm%d_ob%d_im%d_mm%d_mo%d_dw%d', study, version, sigmamethod, mumethod, curveaveragingmethod, ...
    smoothingmethod, runmode, offsetblockingmethod, imputationmode, measuresmask, max_offset, align_wind);
detaillog = true;

% pre-process measures table and associated measurement data
[amDatacube, measures, nmeasures] = amEMPreprocessMeasures(amDatacube, amInterventions, measures, ...
    demographicstable, measuresmask, align_wind, npatients, ndays, ninterventions);

% create cube for data window data by intervention (for each measure)
[amIntrDatacube] = createIntrDatacube(amDatacube, amInterventions, align_wind, ...
    max_offset, ninterventions, nmeasures, curveaveragingmethod);

% pre-process intervention table and associated measurement data
[amInterventions, amIntrDatacube, ninterventions] = amEMPreprocessInterventions(amInterventions, ...
    amIntrDatacube, max_offset, align_wind, ninterventions, nmeasures);

% populate multiplicative normalisation (sigma) values based on methodology
% selected
normstd = calculateSigmaNormalisation(amInterventions, measures, demographicstable, ninterventions, nmeasures, sigmamethod);

% calculate additive normalisation (mu) based on methodology
% and then create normalised data cube.

normmean = calculateMuNormalisation(amDatacube, amInterventions, measures, demographicstable, ...
    dataoutliers, align_wind, ninterventions, nmeasures, mumethod);

% populate normalised data cube by intervention
[amIntrNormcube] = createNormalisedIntrDatacube(amIntrDatacube, normmean, normstd, ...
    max_offset, align_wind, ninterventions, nmeasures, sigmamethod);

% populate index array for held back points (to be used for imputation
[amHeldBackcube] = createHeldBackcube(amIntrDatacube, max_offset, align_wind, ninterventions, nmeasures, heldbackpct, imputationmode);

toc
fprintf('\n');

tic
fprintf('Running alignment\n');
% should really move this into AlignCurves function or override with value
% loaded in there
for i=1:size(amInterventions,1)
        amInterventions.Offset(i) = 0;
end
initial_offsets = amInterventions.Offset;

if runmode == 6
    run_type = 'Pre-selected Start';
else
    run_type = 'Uniform Start';
end
[meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd, animatedmeancurvemean, profile_pre, ...
    offsets, animatedoffsets, hstg, pdoffset, overall_hist, overall_pdoffset, animated_overall_pdoffset, ...
    isOutlier, ppts, qual, min_offset] = amEMAlignCurves(amIntrNormcube, amHeldBackcube, amInterventions, outprior, measures, ...
    normstd, max_offset, align_wind, nmeasures, ninterventions, detaillog, sigmamethod, smoothingmethod, offsetblockingmethod, runmode, fnmodelrun);
fprintf('%s - ErrFcn = %.8f\n', run_type, qual);

% save the zero offset pre-profile to unaligned_profile so all plots show a
% consistent unaligned curve as the pre-profile.
unaligned_profile = profile_pre;

plotname = sprintf('%s_obj%.8f', baseplotname, qual);

% plot and save aligned curves (pre and post)
amEMPlotAndSaveAlignedCurves(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, offsets, ...
    measures, 0, min_offset, max_offset, align_wind, nmeasures, run_type, plotname, 0, sigmamethod);

toc
fprintf('\n');

%return;

ex_start = input('Look at best start and enter exacerbation start: ');
fprintf('\n');

tic
run_type = 'Best Alignment';

amInterventions.Offset = offsets;

plotname = sprintf('%s_ex%d_obj%.8f', baseplotname, ex_start, qual);

[sorted_interventions, max_points] = amEMVisualiseAlignmentDetail(amIntrNormcube, amHeldBackcube, amInterventions, meancurvemean, ...
    meancurvecount, meancurvestd, overall_pdoffset, offsets, measures, min_offset, max_offset, align_wind, nmeasures, run_type, ...
    study, ex_start, version, curveaveragingmethod);

amEMPlotAndSaveAlignedCurves(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, offsets, ...
    measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, plotname, ex_start, sigmamethod);

% create additional overall histograms and prob distributions
overall_hist_all = zeros(ninterventions, max_offset);
overall_hist_xAL = zeros(ninterventions, max_offset);
overall_pdoffset_all = zeros(ninterventions, max_offset);
overall_pdoffset_xAL = zeros(ninterventions, max_offset);
fitmeasure = zeros(nmeasures, ninterventions);

for j = 1:ninterventions
    overall_hist_all(j, :) = reshape(sum(hstg(:,j,:),1), [1, max_offset]);
    overall_hist_xAL(j, :) = reshape(sum(hstg(~ismember(measures.DisplayName, {'Activity', 'LungFunction'}),j,:),1), [1, max_offset]);
end

% convert back from log space
for j=1:ninterventions
    overall_pdoffset_all(j, min_offset+1:max_offset)  = convertFromLogSpaceAndNormalise(overall_hist_all(j, min_offset+1:max_offset));
    overall_pdoffset_xAL(j, min_offset+1:max_offset)  = convertFromLogSpaceAndNormalise(overall_hist_xAL(j, min_offset+1:max_offset));
end

totaloutliers = 0;
totalpoints = 0;
for i = 1:ninterventions
       totaloutliers = totaloutliers + sum(sum(isOutlier(i, :, :, offsets(i) + 1)));
       totalpoints   = totalpoints + sum(sum(~isnan(amIntrDatacube(i, max_offset:max_offset + align_wind -1, :))));
end

totalpoints = totalpoints - sum(sum(sum(amHeldBackcube)));

[amImputedCube, imputedscore] = calcImputedProbabilities(amIntrNormcube, amHeldBackcube, ...
    meancurvemean, meancurvestd, normstd, overall_pdoffset, max_offset, align_wind, ...
    nmeasures, ninterventions,sigmamethod, smoothingmethod, imputationmode);

toc
fprintf('\n');

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%s_ex%d_obj%.8f.mat', baseplotname, ex_start, qual);
fprintf('Saving alignment model results to file %s\n', outputfilename);
fprintf('\n');
save(fullfile(basedir, subfolder, outputfilename), 'amDatacube', 'amIntrDatacube', 'amIntrNormcube', 'amHeldBackcube', ...
    'amImputedCube', 'imputedscore', 'amInterventions', ...
    'meancurvesumsq', 'meancurvesum', 'meancurvecount', 'meancurvemean', 'meancurvestd', 'animatedmeancurvemean', ...
    'initial_offsets', 'offsets', 'animatedoffsets', 'qual', 'unaligned_profile', 'hstg', 'pdoffset', ...
    'overall_hist', 'overall_hist_all', 'overall_hist_xAL', 'ppts', 'isOutlier', 'outprior', 'totaloutliers', 'totalpoints', ...
    'overall_pdoffset', 'overall_pdoffset_all', 'overall_pdoffset_xAL', 'animated_overall_pdoffset', ...
    'sorted_interventions', 'normmean', 'normstd', 'measures', 'study', 'version', ...
    'min_offset', 'max_offset', 'align_wind', 'ex_start', ...
    'sigmamethod', 'mumethod', 'curveaveragingmethod', 'smoothingmethod', 'offsetblockingmethod', ...
    'measuresmask', 'runmode', 'imputationmode', 'printpredictions', 'nmeasures', 'ninterventions');
toc
fprintf('\n');

if printpredictions == 1
    tic
    fprintf('Plotting prediction results\n');
    for i=1:ninterventions
        amEMPlotsAndSavePredictions(amInterventions, amIntrDatacube, amHeldBackcube, measures, pdoffset, overall_pdoffset, ...
            overall_pdoffset_all, overall_pdoffset_xAL, hstg, overall_hist, overall_hist_all, overall_hist_xAL, offsets, ...
            meancurvemean, normmean, normstd, isOutlier, ex_start, i, nmeasures, max_offset, align_wind, study, version);
    end
    toc
    fprintf('\n');
end




