update_histogram = 0;
qual = 0;
qualcount = 0;
for i=1:ninterventions
    [meancurvesumsq, meancurvesum, meancurvecount] = amEMMCRemoveFromMean(meancurvesumsq, meancurvesum, meancurvecount, ...
        overall_pdoffset, amIntrCube, amHeldBackcube, i, min_offset, max_offset, align_wind, nmeasures, nlatentcurves);
    [meancurvesumsq, meancurvesum, meancurvecount] = amEMMCAddAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, pptsstruct, nlatentcurves);
    [meancurvemean, meancurvestd] = amEMMCCalcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);

    lc = amInterventions.LatentCurve(i);
    [iqual, icount] = amEMMCCalcObjFcn(meancurvemean(lc, :, :), meancurvestd(lc, :, :), amIntrCube, amHeldBackcube, ...
        isOutlier(lc, :, :, :, :), outprior, measures.Mask, measures.OverallRange, normstd, hstg(lc, :, :, :), i, ...
        amInterventions.Offset(i), max_offset, align_wind, nmeasures, update_histogram, sigmamethod, smoothingmethod);

    qual = qual + iqual;
    qualcount = qualcount + icount;

    %fprintf('Intervention %d, qual = %.4f\n', i, qual/qualcount);

    [meancurvesumsq, meancurvesum, meancurvecount] = amEMMCRemoveAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, pptsstruct, nlatentcurves);
    [meancurvesumsq, meancurvesum, meancurvecount] = amEMMCAddToMean(meancurvesumsq, meancurvesum, meancurvecount, ...
        overall_pdoffset, amIntrCube, amHeldBackcube, i, min_offset, max_offset, align_wind, nmeasures, nlatentcurves);
    [meancurvemean, meancurvestd] = amEMMCCalcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);
end

qual = qual / qualcount;