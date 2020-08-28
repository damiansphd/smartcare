function analyseModelPrediction(patientrow, calcdatedn, ...
    pmTrCVFeatureIndex, pmTrCVNormFeatures, trcvlabels, pmTrCVPatientSplit, pmModelRes, ...
    measures, nmeasures, labelidx, featureparamsrow, lbdisplayname, ...
    plotsubfolder, basemodelresultsfile)
    
% analyseModelPrediction - show contributions from the different sets of
% features.

% *** change to use normfeatures rather than underlying cubes ***

pnbr = patientrow.PatientNbr;
fold = pmTrCVPatientSplit.SplitNbr(pmTrCVPatientSplit.PatientNbr == pnbr);
normfeaturerow = pmTrCVNormFeatures(pmTrCVFeatureIndex.PatientNbr == pnbr & pmTrCVFeatureIndex.ScenType == 0 & pmTrCVFeatureIndex.CalcDatedn == calcdatedn, :);

[featureduration, predictionduration, monthfeat, demofeat, ...
 nbuckets, navgseg, nvolseg, nbuckpmeas, nrawmeasures, nmsmeasures, nbucketmeasures, nrangemeasures, ...
 nvolmeasures, navgsegmeasures, nvolsegmeasures, ncchangemeasures, ...
 npmeanmeasures, npstdmeasures, nbuckpmeanmeasures, nbuckpstdmeasures, ...
 nrawfeatures, nmsfeatures, nbucketfeatures, nrangefeatures, nvolfeatures, navgsegfeatures, ...
 nvolsegfeatures, ncchangefeatures, npmeanfeatures, npstdfeatures, ...
 nbuckpmeanfeatures, nbuckpstdfeatures, ndatefeatures, ndemofeatures, ...
 nfeatures, nnormfeatures] = setNumMeasAndFeatures(featureparamsrow, measures, nmeasures);

featureweights = pmModelRes.pmNDayRes(labelidx).Folds(fold).Model.Coefficients.Estimate(2:end);
bias = pmModelRes.pmNDayRes(labelidx).Folds(fold).Model.Coefficients.Estimate(1);
nextfeat = 1;

fprintf('\n');
fprintf('Prediction Analysis for Patient %d, Calc Date %d (Fold %d)\n', pnbr, calcdatedn, fold);
fprintf('------------------------------------------------\n');
fprintf('\n');
fprintf('Total Features * Weights: %+.2f\n', normfeaturerow * featureweights);
fprintf('Bias                    : %+.2f\n', bias);
fprintf('Prediction              : %5.2f%%\n', 100 * sigmoid((normfeaturerow * featureweights) + bias));

tempmeas = measures(measures.RawMeas==1,:);
if nrawmeasures == 0
    nmfeat = 0;
else
    nmfeat = nrawfeatures/nrawmeasures;
end
fprintf('\n');
fprintf('Raw Measures (%2d features per measure)\n', nmfeat);
fprintf('--------------------------------------\n');
for i = 1:nrawmeasures
    printFeatVals(normfeaturerow, featureweights, calcdatedn, i, tempmeas, nmfeat, nextfeat);
    nextfeat = nextfeat + nmfeat;
end

tempmeas = measures(measures.MSMeas==1,:);
if nmsmeasures == 0
    nmsfeat = 0;
else
    nmsfeat = nmsfeatures/nmsmeasures;
end
fprintf('\n');
fprintf('Missingness Measures (%2d features per measure)\n', nmsfeat);
fprintf('----------------------------------------------\n');
for i = 1:nmsmeasures
    printFeatVals(normfeaturerow, featureweights, calcdatedn, i, tempmeas, nmsfeat, nextfeat);
    nextfeat = nextfeat + nmsfeat;
end

tempmeas = measures(measures.BucketMeas==1,:);
if nbucketmeasures == 0
    nmfeat = 0;
else
    nmfeat = nbucketfeatures/nbucketmeasures;
end
fprintf('\n');
fprintf('Bucketed Measures (%2d features per measure)\n', nmfeat);
fprintf('-------------------------------------------\n');
for i = 1:nbucketmeasures
    printFeatVals(normfeaturerow, featureweights, calcdatedn, i, tempmeas, nmfeat, nextfeat);
    nextfeat = nextfeat + nmfeat;
end

tempmeas = measures(measures.Range==1,:);
if nrangemeasures == 0
    nmfeat = 0;
else
    nmfeat = nrangefeatures/nrangemeasures;
end
fprintf('\n');
fprintf('Range Measures (%2d features per measure)\n', nmfeat);
fprintf('----------------------------------------\n');
for i = 1:nrangemeasures
    printFeatVals(normfeaturerow, featureweights, calcdatedn, i, tempmeas, nmfeat, nextfeat);
    nextfeat = nextfeat + nmfeat;
end

tempmeas = measures(measures.Volatility==1,:);
if nvolmeasures == 0
    nmfeat = 0;
else
    nmfeat = nvolfeatures/nvolmeasures;
end
fprintf('\n');
fprintf('Volatility Measures (%2d features per measure)\n', nmfeat);
fprintf('---------------------------------------------\n');
for i = 1:nvolmeasures
    printFeatVals(normfeaturerow, featureweights, calcdatedn, i, tempmeas, nmfeat, nextfeat);
    nextfeat = nextfeat + nmfeat;
end

tempmeas = measures(measures.AvgSeg==1,:);
if navgsegmeasures == 0
    nmfeat = 0;
else
    nmfeat = navgsegfeatures/navgsegmeasures;
end
fprintf('\n');
fprintf('Avg Seg Measures (%2d features per measure)\n', nmfeat);
fprintf('------------------------------------------\n');
for i = 1:navgsegmeasures
    printFeatVals(normfeaturerow, featureweights, calcdatedn, i, tempmeas, nmfeat, nextfeat);
    nextfeat = nextfeat + nmfeat;
end

tempmeas = measures(measures.VolSeg==1,:);
if nvolsegmeasures == 0
    nmfeat = 0;
else
    nmfeat = nvolsegfeatures/nvolsegmeasures;
end
fprintf('\n');
fprintf('Avg Vol Measures (%2d features per measure)\n', nmfeat);
fprintf('------------------------------------------\n');
for i = 1:nvolsegmeasures
    printFeatVals(normfeaturerow, featureweights, calcdatedn, i, tempmeas, nmfeat, nextfeat);
    nextfeat = nextfeat + nmfeat;
end

tempmeas = measures(measures.CChange==1,:);
if ncchangemeasures == 0
    nmfeat = 0;
else
    nmfeat = ncchangefeatures/ncchangemeasures;
end
fprintf('\n');
fprintf('Contiguous Change Measures (%2d features per measure)\n', nmfeat);
fprintf('----------------------------------------------------\n');
for i = 1:ncchangemeasures
    printFeatVals(normfeaturerow, featureweights, calcdatedn, i, tempmeas, nmfeat, nextfeat);
    nextfeat = nextfeat + nmfeat;
end

tempmeas = measures(measures.PMean==1,:);
if npmeanmeasures == 0
    nmfeat = 0;
else
    nmfeat = npmeanfeatures/npmeanmeasures;
end
fprintf('\n');
fprintf('Patient Mean (%2d features per measure)\n', nmfeat);
fprintf('--------------------------------------\n');
for i = 1:npmeanmeasures
    printFeatVals(normfeaturerow, featureweights, calcdatedn, i, tempmeas, nmfeat, nextfeat);
    nextfeat = nextfeat + nmfeat;
end

tempmeas = measures(measures.PStd==1,:);
if npstdmeasures == 0
    nmfeat = 0;
else
    nmfeat = npstdfeatures/npstdmeasures;
end
fprintf('\n');
fprintf('Patient Std (%2d features per measure)\n', nmfeat);
fprintf('-------------------------------------\n');
for i = 1:npstdmeasures
    printFeatVals(normfeaturerow, featureweights, calcdatedn, i, tempmeas, nmfeat, nextfeat);
    nextfeat = nextfeat + nmfeat;
end

tempmeas = measures(measures.BuckPMean==1,:);
if nbuckpmeanmeasures == 0
    nmfeat = 0;
else
    nmfeat = nbuckpmeanfeatures/nbuckpmeanmeasures;
end
fprintf('\n');
fprintf('Bucketed Patient Mean (%2d features per measure)\n', nmfeat);
fprintf('-----------------------------------------------\n');
for i = 1:nbuckpmeanmeasures
    printFeatVals(normfeaturerow, featureweights, calcdatedn, i, tempmeas, nmfeat, nextfeat);
    nextfeat = nextfeat + nmfeat;
end

tempmeas = measures(measures.BuckPStd==1,:);
if nbuckpstdmeasures == 0
    nmfeat = 0;
else
    nmfeat = nbuckpstdfeatures/nbuckpstdmeasures;
end
fprintf('\n');
fprintf('Bucketed Patient Std (%2d features per measure)\n', nmfeat);
fprintf('----------------------------------------------\n');
for i = 1:nbuckpstdmeasures
    printFeatVals(normfeaturerow, featureweights, calcdatedn, i, tempmeas, nmfeat, nextfeat);
    nextfeat = nextfeat + nmfeat;
end

tempmeas = measures(1,:);
tempmeas.DisplayName{1} = 'Date';
nmfeat = ndatefeatures;
fprintf('\n');
fprintf('Date Features (%2d features)\n', nmfeat);
fprintf('---------------------------\n');
printFeatVals(normfeaturerow, featureweights, calcdatedn, 1, tempmeas, nmfeat, nextfeat);
nextfeat = nextfeat + nmfeat;

tempmeas = measures(1,:);
tempmeas.DisplayName{1} = 'Demographics';
nmfeat = ndemofeatures;
fprintf('\n');
fprintf('Demographic Features (%2d features)\n', nmfeat);
fprintf('----------------------------------\n');
printFeatVals(normfeaturerow, featureweights, calcdatedn, 1, tempmeas, nmfeat, nextfeat);
nextfeat = nextfeat + nmfeat;

end

