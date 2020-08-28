function [pmMucube, pmSigmacube, pmMuNormcube, pmSigmaNormcube, pmBuckMuNormcube, pmBuckSigmaNormcube, ...
        muntilepoints, sigmantilepoints, pmDatacube, pmInterpDatacube, pmInterpVolcube, mvolstats, pmInterpSegVolcube, ...
        pmInterpRangecube, pmInterpSegAvgcube, pmBucketedcube, ntilepoints, pmMSDatacube] ...
        = createPreBaseFeat(pmPatients, npatients, pmOverallStats, pmPatientMeasStats, ...
        pmRawDatacube, maxdays, measures, nmeasures, featureparams)

% createPreBaseFeat - utility function to create the various norm, vol,
% range cubes - can be used by main createBaseFeaturesAndLabelsScript as
% well as Missingness Scenario

studydisplayname = featureparams.StudyDisplayName{1};

% interpolate missing data
tic
[pmInterpDatacube]    = createPMInterpDatacube(pmPatients, pmRawDatacube, npatients, maxdays, nmeasures);

if featureparams.interpmethod == 0
    fprintf('No interpolation\n');
    pmDatacube = pmRawDatacube;
elseif featureparams.interpmethod == 1
    fprintf('Full Interpolation\n');
    pmDatacube = pmInterpDatacube;
elseif featureparams.interpmethod >= 2
    fprintf('Limited Interpolation over gaps of %d days\n', (featureparams.interpmethod - 1));
    [pmDatacube] = createPMLimInterpDatacube(pmPatients, pmRawDatacube, npatients, nmeasures, featureparams.interpmethod);
end
toc
fprintf('\n');

% handle missing features (eg no sleep measures for a given patient)
tic
fprintf('Handling missing features\n');
[pmInterpDatacube] = handleMissingFeatures(pmPatients, pmInterpDatacube, pmOverallStats, npatients, maxdays, nmeasures); 
toc
fprintf('\n');

% create normalisation window cube (for use with Normalisation method 3 & 4 in
% model
tic
fprintf('Creating normalisation window cube\n');
[pmMucube, pmSigmacube, pmMuNormcube, pmSigmaNormcube, pmBuckMuNormcube, pmBuckSigmaNormcube, ...
muntilepoints, sigmantilepoints] = createPMNormWindowcube(pmPatients, pmInterpDatacube, ...
    pmOverallStats, pmPatientMeasStats, featureparams.normmethod, ...
    featureparams.normwindow, featureparams.nbuckpmeas,...
    npatients, maxdays, measures, nmeasures, studydisplayname); 
toc
fprintf('\n');

% create measures volatility cube
tic
fprintf('Creating volatility and segment volatility cubes\n');
[pmInterpVolcube, mvolstats, pmInterpSegVolcube] = createPMInterpVolcube(pmPatients, pmInterpDatacube, ...
    npatients, maxdays, nmeasures, featureparams.featureduration, featureparams.nvolseg, ...
    featureparams.normwindow); 
toc
fprintf('\n');

% create measures range cube
tic
fprintf('Creating range and segment average measure cubes\n');
[pmInterpRangecube, pmInterpSegAvgcube] = createPMInterpRangecube(pmPatients, pmInterpDatacube, ...
    npatients, maxdays, nmeasures, featureparams.featureduration, featureparams.navgseg, ...
    featureparams.normwindow); 
toc
fprintf('\n');

if featureparams.smfunction > 0
    tic
    pmInterpDatacube = createPMInterpSmoothcube(pmInterpDatacube, pmPatients, npatients, ...
                            maxdays, measures, nmeasures, featureparams.smfunction, ...
                            featureparams.smwindow, featureparams.smlength);
    toc
    fprintf('\n');
end

% create bucketed data cube
tic
fprintf('Creating bucketed data\n');
[pmBucketedcube, ntilepoints] = createPMBucketedcube(pmInterpDatacube, featureparams.nbuckets, npatients, maxdays, nmeasures); 
toc
fprintf('\n');

% create missingness data cube
tic
fprintf('Creating missingness cube ');
% for feature = 0 if data present, = 1 if missing
pmMSDatacube = isnan(pmDatacube);
fprintf('- %d missing data points\n', sum(sum(sum(pmMSDatacube))));
% for feature = 1 if data present, = 0 if missing
%pmMSDatacube = ~isnan(pmDatacube);
% for feature = 1 if data present, = -1 if missing
%pmMSDatacube = 2 * (~isnan(pmDatacube)) - 1;
toc
fprintf('\n');

% set missing data to be zero
%tic
%fprintf('Updating missing data to zero\n');
%pmDatacube(isnan(pmDatacube)) = 0;
%toc
%fprintf('\n');

end

