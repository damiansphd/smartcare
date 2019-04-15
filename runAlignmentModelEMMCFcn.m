function runAlignmentModelEMMCFcn(amRunParameters)

% function to run the alignment model (EM version) given a set of run
% parameters. This version allows for multiple versions of the latent
% curves

% set the various model run parameters
[mversion, study, modelinputsmatfile, datademographicsfile, dataoutliersfile, ...
    sigmamethod, mumethod, curveaveragingmethod, smoothingmethod, ...
    measuresmask, runmode, modelrun, imputationmode, confidencemode, printpredictions, ...
    max_offset, align_wind, ex_start, outprior, heldbackpct, confidencethreshold, nlatentcurves] ...
    = amEMMCSetModelRunParametersFromTable(amRunParameters);

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

baseplotname = sprintf('%s%s_sig%d_mu%d_ca%d_sm%d_rm%d_im%d_cm%d_mm%d_mo%d_dw%d_nl%d', study, mversion, sigmamethod, mumethod, curveaveragingmethod, ...
    smoothingmethod, runmode, imputationmode, confidencemode, measuresmask, max_offset, align_wind, nlatentcurves);
detaillog = true;

% pre-process measures table and associated measurement data
[amDatacube, measures, nmeasures] = amEMMCPreprocessMeasures(amDatacube, amInterventions, measures, ...
    demographicstable, measuresmask, align_wind, npatients, ndays, ninterventions);

% create cube for data window data by intervention (for each measure)
[amIntrDatacube] = createIntrDatacube(amDatacube, amInterventions, align_wind, ...
    max_offset, ninterventions, nmeasures, curveaveragingmethod);

% pre-process intervention table and associated measurement data
[amInterventions, amIntrDatacube, ninterventions] = amEMMCPreprocessInterventions(amInterventions, ...
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

[meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd, amInterventions, initial_offsets, animatedmeancurvemean, profile_pre, ...
    animatedoffsets, hstg, pdoffset, overall_hist, overall_pdoffset, animated_overall_pdoffset, ...
    isOutlier, pptsstruct, qual, min_offset, niterations, run_type] = amEMMCAlignCurves(amIntrNormcube, amHeldBackcube, amInterventions, ...
    outprior, measures, normstd, max_offset, align_wind, nmeasures, ninterventions, nlatentcurves, ...
    detaillog, sigmamethod, smoothingmethod, runmode, fnmodelrun);
fprintf('%s - ErrFcn = %.8f\n', run_type, qual);

% save the zero offset pre-profile to unaligned_profile so all plots show a
% consistent unaligned curve as the pre-profile.
unaligned_profile = profile_pre;

plotname = sprintf('%s_obj%.8f', baseplotname, qual);

% plot and save aligned curves (pre and post)
amEMMCPlotAndSaveAlignedCurves(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, ...
    amInterventions.Offset, amInterventions.LatentCurve, ...
    measures, 0, min_offset, max_offset, align_wind, nmeasures, run_type, 0, sigmamethod, plotname, 'Plots', nlatentcurves);

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

[amInterventions] = amEMMCCalcConfidenceBounds(overall_pdoffset, amInterventions, min_offset, max_offset, ninterventions, confidencethreshold, confidencemode);

[sorted_interventions, max_points] = amEMMCVisualiseAlignmentDetail(amIntrNormcube, amHeldBackcube, amInterventions, meancurvemean, ...
    meancurvecount, meancurvestd, overall_pdoffset, measures, min_offset, max_offset, align_wind, nmeasures, ninterventions, ...
    run_type, ex_start, curveaveragingmethod, plotname, plotsubfolder, nlatentcurves);

amEMMCPlotAndSaveAlignedCurves(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, ...
    amInterventions.Offset, amInterventions.LatentCurve, ...
    measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, sigmamethod, plotname, plotsubfolder, nlatentcurves);

% calculate the total number of outliers and the total number of data
% points
[totaloutliers, totalpoints] = amEMMCCalcTotalOutliers(amIntrDatacube, isOutlier, amHeldBackcube, ...
    amInterventions.Offset, amInterventions.LatentCurve, max_offset, align_wind, ninterventions);

% calculate imputed probabilities for held back points
[amImputedCube, imputedscore] = amEMMCCalcImputedProbabilities(amIntrNormcube, amHeldBackcube, ...
    meancurvemean, meancurvestd, normstd, overall_pdoffset, max_offset, align_wind, ...
    nmeasures, ninterventions, sigmamethod, smoothingmethod, imputationmode, amInterventions.LatentCurve, nlatentcurves);

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
    'initial_offsets', 'animatedoffsets', 'qual', 'unaligned_profile', ...
    'hstg', 'pdoffset', 'overall_hist', 'overall_pdoffset', 'animated_overall_pdoffset', ...
    'pptsstruct', 'isOutlier', 'outprior', 'totaloutliers', 'totalpoints', ...
    'sorted_interventions', 'normmean', 'normstd', 'measures', 'baseplotname', 'plotname', 'plotsubfolder', ...
    'study', 'mversion', 'min_offset', 'max_offset', 'align_wind', 'ex_start', 'confidencethreshold', ...
    'sigmamethod', 'mumethod', 'curveaveragingmethod', 'smoothingmethod', ...
    'measuresmask', 'runmode', 'imputationmode', 'confidencemode', 'printpredictions', ...
    'nmeasures', 'ninterventions', 'niterations');
toc
fprintf('\n');

if printpredictions == 1
    tic
    fprintf('Plotting prediction results\n');
    for i=1:ninterventions
        amEMMCPlotsAndSavePredictions(amInterventions, amIntrDatacube, measures, pdoffset, ...
            overall_pdoffset, hstg, overall_hist, meancurvemean, normmean, normstd, isOutlier, ex_start, ...
            i, nmeasures, max_offset, align_wind, sigmamethod, plotname, plotsubfolder);
    end
    toc
    fprintf('\n');
end

end




