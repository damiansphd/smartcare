function runAlignmentModelEMMCFcn(amRunParameters)

% function to run the alignment model (EM version) given a set of run
% parameters. This version allows for multiple versions of the latent
% curves

% set the various model run parameters
[mversion, study, modelinputsmatfile, datademographicsfile, dataoutliersfile, labelledinterventionsfile, ...
    sigmamethod, mumethod, curveaveragingmethod, smoothingmethod, datasmoothmethod, ...
    measuresmask, runmode, randomseed, modelrun, imputationmode, confidencemode, printpredictions, ...
    max_offset, align_wind, outprior, heldbackpct, confidencethreshold, nlatentcurves, countthreshold] ...
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
fprintf('Loading latest labelled test data file\n');
load(fullfile(basedir, subfolder, labelledinterventionsfile));
toc

tic
fprintf('Preparing input data\n');

baseplotname = sprintf('%s%s_sig%d_mu%d_ca%d_sm%d_rm%d_im%d_cm%d_mm%d_mo%d_dw%d_nl%d_rs%d_ds%d_ct%d', study, mversion, sigmamethod, mumethod, curveaveragingmethod, ...
    smoothingmethod, runmode, imputationmode, confidencemode, measuresmask, max_offset, align_wind, nlatentcurves, randomseed, datasmoothmethod, countthreshold);
detaillog = true;

% pre-process measures table and associated measurement data
[amDatacube, measures, nmeasures] = amEMMCPreprocessMeasures(amDatacube, amInterventions, measures, ...
    demographicstable, measuresmask, align_wind, npatients, ndays, ninterventions);

% create cube for data window data by intervention (for each measure)
[amIntrDatacube] = amEMMCCreateIntrDatacube(amDatacube, amInterventions, measures, align_wind, ...
    max_offset, ninterventions, nmeasures, curveaveragingmethod, datasmoothmethod);

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

[meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd, amInterventions, initial_offsets, initial_latentcurve, ...
    animatedmeancurvemean, profile_pre, animatedoffsets, animatedlc, hstg, pdoffset, overall_hist, overall_pdoffset, animated_overall_pdoffset, ...
    isOutlier, pptsstruct, qual, min_offset, niterations, run_type] = amEMMCAlignCurves(amIntrNormcube, amHeldBackcube, amInterventions, ...
    outprior, measures, normstd, max_offset, align_wind, nmeasures, ninterventions, nlatentcurves, ...
    detaillog, sigmamethod, smoothingmethod, runmode, randomseed, countthreshold, fnmodelrun);
fprintf('%s - ErrFcn = %.8f\n', run_type, qual);

% save the zero offset pre-profile to unaligned_profile so all plots show a
% consistent unaligned curve as the pre-profile.
% *** updated to use final curve set assignment with initial uniform offset
% distribution for this ***
% unaligned_profile = profile_pre;
tmp_meancurvesum      = zeros(nlatentcurves, max_offset + align_wind - 1, nmeasures);
tmp_meancurvesumsq    = zeros(nlatentcurves, max_offset + align_wind - 1, nmeasures);
tmp_meancurvecount    = zeros(nlatentcurves, max_offset + align_wind - 1, nmeasures);
tmp_overall_pdoffset  = zeros(nlatentcurves, ninterventions, max_offset);
for i = 1:ninterventions
    if runmode == 5
        tmp_overall_pdoffset(:, i, :) = 0;
        tmp_overall_pdoffset(amInterventions.LatentCurve(i), i, 1) = 1;
    else
        tmp_overall_pdoffset(amInterventions.LatentCurve(i), i,:) = amEMMCConvertFromLogSpaceAndNormalise(zeros(1, max_offset));
    end
end
for i = 1:ninterventions
    [tmp_meancurvesumsq, tmp_meancurvesum, tmp_meancurvecount] = amEMMCAddToMean(tmp_meancurvesumsq, tmp_meancurvesum, tmp_meancurvecount, ...
        tmp_overall_pdoffset, amIntrNormcube, amHeldBackcube, i, min_offset, max_offset, align_wind, nmeasures, nlatentcurves);
end
[unaligned_profile, ~] = amEMMCCalcMeanAndStd(tmp_meancurvesumsq, tmp_meancurvesum, tmp_meancurvecount, min_offset, max_offset, align_wind);

plotname = sprintf('%s_obj%.8f', baseplotname, qual);
temp_max_points = zeros(nlatentcurves, 1);
temp_ex_start   = zeros(1, nlatentcurves);

% plot and save aligned curves (pre and post)
amEMMCPlotAndSaveAlignedCurves(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, ...
    amInterventions.Offset, amInterventions.LatentCurve, ...
    measures, temp_max_points, min_offset, max_offset, align_wind, nmeasures, run_type, temp_ex_start, sigmamethod, plotname, 'Plots', nlatentcurves);

toc
fprintf('\n');

%if ex_start == 0
%    ex_start = input('Look at best start and enter exacerbation start: ');
%    fprintf('\n');
%end

ex_start = amEMMCCalcExStartsFromTestLabels(amLabelledInterventions, amInterventions, ...
        overall_pdoffset, max_offset, 'Plots', plotname, ninterventions, nlatentcurves);

tic
run_type = 'Best Alignment';
ex_text = sprintf('%d', ex_start);
plotname = sprintf('%s_ni%d_ex%s_obj%.8f', baseplotname, niterations, ex_text, qual);
plotsubfolder = strcat('Plots', '/', plotname);
mkdir(strcat(basedir, plotsubfolder));
%strcat(measures.ShortName{logical(measures.RawMeas)})

[amInterventions] = amEMMCCalcConfidenceBounds(overall_pdoffset, amInterventions, min_offset, max_offset, ninterventions, confidencethreshold, confidencemode);
[amInterventions] = amEMMCCalcAbsPredAndBounds(amInterventions, ex_start, nlatentcurves);

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
    'initial_offsets', 'initial_latentcurve', 'animatedoffsets', 'animatedlc', 'qual', 'unaligned_profile', ...
    'hstg', 'pdoffset', 'overall_hist', 'overall_pdoffset', 'animated_overall_pdoffset', ...
    'pptsstruct', 'isOutlier', 'outprior', 'totaloutliers', 'totalpoints', ...
    'sorted_interventions', 'max_points', 'normmean', 'normstd', 'measures', 'baseplotname', 'plotname', 'plotsubfolder', ...
    'study', 'mversion', 'min_offset', 'max_offset', 'align_wind', 'ex_start', 'confidencethreshold', ...
    'sigmamethod', 'mumethod', 'curveaveragingmethod', 'smoothingmethod', 'datasmoothmethod', 'countthreshold', ...
    'measuresmask', 'runmode', 'randomseed', 'imputationmode', 'heldbackpct', 'confidencemode', 'printpredictions', ...
    'nmeasures', 'ninterventions', 'niterations', 'nlatentcurves');
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




