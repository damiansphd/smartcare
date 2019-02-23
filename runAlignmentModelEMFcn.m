function runAlignmentModelEMFcn(amRunParameters)

% function to run the alignment model (EM version) given a set of run
% parameters

% set the various model run parameters
[mversion, study, modelinputsmatfile, datademographicsfile, dataoutliersfile, ...
    sigmamethod, mumethod, curveaveragingmethod, smoothingmethod, offsetblockingmethod, ...
    measuresmask, runmode, modelrun, imputationmode, confidencemode, printpredictions, ...
    max_offset, align_wind, ex_start, outprior, heldbackpct, confidencethreshold] ...
    = amEMSetModelRunParametersFromTable(amRunParameters);

fprintf('Running Alignment Model %s\n', mversion);
fprintf('\n');

% load the required input data
tic
basedir = setBaseDir();
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
%max_offset = 25; % should not be greater than ex_start (set lower down) as this would imply intervention before exacerbation !
%align_wind = 25;
% define prior probability of a data point being an outlier
%outprior = 0.01;
%heldbackpct = 0.01;
%confidencethreshold = 0.9;
baseplotname = sprintf('%s%s_sig%d_mu%d_ca%d_sm%d_rm%d_ob%d_im%d_cm%d_mm%d_mo%d_dw%d', study, mversion, sigmamethod, mumethod, curveaveragingmethod, ...
    smoothingmethod, runmode, offsetblockingmethod, imputationmode, confidencemode, measuresmask, max_offset, align_wind);
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
    isOutlier, ppts, qual, min_offset, niterations] = amEMAlignCurves(amIntrNormcube, amHeldBackcube, amInterventions, outprior, measures, ...
    normstd, max_offset, align_wind, nmeasures, ninterventions, detaillog, sigmamethod, smoothingmethod, offsetblockingmethod, runmode, fnmodelrun);
fprintf('%s - ErrFcn = %.8f\n', run_type, qual);

% save the zero offset pre-profile to unaligned_profile so all plots show a
% consistent unaligned curve as the pre-profile.
unaligned_profile = profile_pre;

plotname = sprintf('%s_obj%.8f', baseplotname, qual);

% plot and save aligned curves (pre and post)
amEMPlotAndSaveAlignedCurves(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, offsets, ...
    measures, 0, min_offset, max_offset, align_wind, nmeasures, run_type, 0, sigmamethod, plotname, 'Plots');

toc
fprintf('\n');

if ex_start == 0
    ex_start = input('Look at best start and enter exacerbation start: ');
    fprintf('\n');
end

tic
run_type = 'Best Alignment';

plotname = sprintf('%s_ex%d_obj%.8f', baseplotname, ex_start, qual);

plotsubfolder = strcat('Plots', '/', plotname);
mkdir(strcat(basedir, plotsubfolder));

[amInterventions] = calcConfidenceBounds(overall_pdoffset, amInterventions, offsets, min_offset, max_offset, ninterventions, confidencethreshold, confidencemode);

[sorted_interventions, max_points] = amEMVisualiseAlignmentDetail(amIntrNormcube, amHeldBackcube, amInterventions, meancurvemean, ...
    meancurvecount, meancurvestd, overall_pdoffset, measures, min_offset, max_offset, align_wind, nmeasures, ninterventions, ...
    run_type, ex_start, curveaveragingmethod, plotname, plotsubfolder);

amEMPlotAndSaveAlignedCurves(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, offsets, ...
    measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, sigmamethod, plotname, plotsubfolder);

% calculate the total number of outliers and the total number of data
% points
[totaloutliers, totalpoints] = calcTotalOutliers(amIntrDatacube, isOutlier, amHeldBackcube, offsets, max_offset, align_wind, ninterventions);

% calculate imputed probabilities for held back points
[amImputedCube, imputedscore] = calcImputedProbabilities(amIntrNormcube, amHeldBackcube, ...
    meancurvemean, meancurvestd, normstd, overall_pdoffset, max_offset, align_wind, ...
    nmeasures, ninterventions,sigmamethod, smoothingmethod, imputationmode);

toc
fprintf('\n');

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%s.mat', plotname);
fprintf('Saving alignment model results to file %s\n', outputfilename);
fprintf('\n');
save(fullfile(basedir, subfolder, outputfilename), 'amDatacube', 'amIntrDatacube', 'amIntrNormcube', ...
    'amHeldBackcube', 'amImputedCube', 'imputedscore', 'amInterventions', ...
    'meancurvesumsq', 'meancurvesum', 'meancurvecount', 'meancurvemean', 'meancurvestd', 'animatedmeancurvemean', ...
    'initial_offsets', 'offsets', 'animatedoffsets', 'qual', 'unaligned_profile', ...
    'hstg', 'pdoffset', 'overall_hist', 'overall_pdoffset', 'animated_overall_pdoffset', ...
    'ppts', 'isOutlier', 'outprior', 'totaloutliers', 'totalpoints', ...
    'sorted_interventions', 'normmean', 'normstd', 'measures', 'baseplotname', 'plotname', 'plotsubfolder', ...
    'study', 'mversion', 'min_offset', 'max_offset', 'align_wind', 'ex_start', 'confidencethreshold', ...
    'sigmamethod', 'mumethod', 'curveaveragingmethod', 'smoothingmethod', 'offsetblockingmethod', ...
    'measuresmask', 'runmode', 'imputationmode', 'confidencemode', 'printpredictions', ...
    'nmeasures', 'ninterventions', 'niterations');
toc
fprintf('\n');

if printpredictions == 1
    tic
    fprintf('Plotting prediction results\n');
    for i=1:ninterventions
        amEMPlotsAndSavePredictions(amInterventions, amIntrDatacube, measures, pdoffset, ...
            overall_pdoffset, hstg, overall_hist, meancurvemean, normmean, normstd, isOutlier, ex_start, ...
            i, nmeasures, max_offset, align_wind, sigmamethod, plotname, plotsubfolder);
    end
    toc
    fprintf('\n');
end

end




