clear; close all; clc;

basedir = setBaseDir();
subfolder = 'DataFiles';
featureparamfile = selectFeatureParameters();
featureparamfile = strcat(featureparamfile, '.xlsx');

pmFeatureParams = readtable(fullfile(basedir, subfolder, featureparamfile));

maxfeatureduration = max(pmFeatureParams.featureduration);
maxnormwindow      = max(pmFeatureParams.normwindow);

fprintf('Creating Feature and Label files for %2d permutations of parameters\n', size(pmFeatureParams,1));
fprintf('\n');

for rp = 1:size(pmFeatureParams,1)
    featureparamsrow = pmFeatureParams(rp,:);
    outputfilename = generateFileNameFromFullFeatureParams(featureparamsrow);
    fprintf('%2d. Generating features and labels for %s\n', rp, outputfilename);
    fprintf('-------------------------------------------------------------------------------\n');
    
    % load model inputs
    tic
    basedir = setBaseDir();
    subfolder = 'MatlabSavedVariables';
    basefeatfile = generateFileNameFromBaseFeatureParams(featureparamsrow);
    fprintf('Loading base feature and label data: %s\n', basefeatfile);
    load(fullfile(basedir, subfolder, strcat(basefeatfile, '.mat')));
    toc
    fprintf('\n');
    
    tic
    [pmNormFeatures, pmNormFeatNames, measures] = createFullFeaturesAndLabelsFcn(pmRawMeasFeats, pmMSFeats, pmBuckMeasFeats, pmRangeFeats, pmVolFeats, ...
        pmAvgSegFeats, pmVolSegFeats, pmCChangeFeats, pmPMeanFeats, pmPStdFeats, ...
        pmBuckPMeanFeats, pmBuckPStdFeats, pmDateFeats, pmDemoFeats, featureparamsrow, measures, nmeasures);
    toc
    fprintf('\n');
    
    % save output variables
    tic
    basedir = setBaseDir();
    subfolder = 'MatlabSavedVariables';
    outputfilename = sprintf('%s.mat',outputfilename);
    fprintf('Saving output variables to file %s\n', outputfilename);
    save(fullfile(basedir, subfolder, outputfilename), ...
        'studynbr', 'studydisplayname', 'pmStudyInfo', ...
        'pmPatients', 'npatients', 'pmAntibiotics', 'pmAMPred', ...
        'pmOverallStats', 'pmPatientMeasStats', ...
        'pmRawDatacube', 'pmInterpDatacube', 'pmDatacube', ...
        'maxdays', 'measures', 'nmeasures', 'ntilepoints', ...
        'pmFeatureParams', 'rp', ...
        'pmMucube', 'pmSigmacube', 'pmMuNormcube', 'pmSigmaNormcube', ...
        'pmBuckMuNormcube', 'pmBuckSigmaNormcube', 'muntilepoints', 'sigmantilepoints', ...
        'pmBucketedcube', 'pmMSDatacube', 'pmInterpVolcube', 'mvolstats', 'pmInterpSegVolcube', ...
        'pmInterpRangecube', 'pmInterpSegAvgcube', ...
        'pmFeatureIndex', 'pmMuIndex', 'pmSigmaIndex', ...
        'pmRawMeasFeats', 'pmMSFeats', 'pmBuckMeasFeats', 'pmRangeFeats', 'pmVolFeats', 'pmCChangeFeats', ...
        'pmPMeanFeats', 'pmBuckPMeanFeats', 'pmDateFeats', 'pmDemoFeats', ...
        'pmNormFeatures', 'pmNormFeatNames', ...
        'pmIVLabels', 'pmABLabels', 'pmExLabels', 'pmExLBLabels', 'pmExABLabels', 'pmExABxElLabels');
    toc
    fprintf('\n');
end

beep on;
beep;

