function amEMMCPlotAndSaveAlignedCurves(profile_pre, meancurvemean, meancurvecount, meancurvestd, offsets, latentcurves, ...
    measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, sigmamethod, plotname, plotsubfolder, nlatentcurves)

% amEMMCPlotAndSaveAlignedCurves - wrapper around the
% amEMPlotAndSaveAlignedCurves to plot for each set of latent curves

for n = 1:nlatentcurves
    tmp_profile_pre    = reshape(profile_pre(n, :, :),    [max_offset + align_wind - 1, nmeasures]);
    tmp_meancurvemean  = reshape(meancurvemean(n, :, :),  [max_offset + align_wind - 1, nmeasures]);
    tmp_meancurvecount = reshape(meancurvecount(n, :, :), [max_offset + align_wind - 1, nmeasures]);
    tmp_meancurvestd   = reshape(meancurvestd(n, :, :),   [max_offset + align_wind - 1, nmeasures]);
    tmp_offsets        = offsets(latentcurves == n);
    
    tmp_plotname = sprintf('%s C%d', plotname, n);
    
    amEMPlotAndSaveAlignedCurves(tmp_profile_pre, tmp_meancurvemean, tmp_meancurvecount, tmp_meancurvestd, ...
            tmp_offsets, measures, max_points(n, :), min_offset, max_offset, align_wind, nmeasures, run_type, ex_start(n), sigmamethod, tmp_plotname, plotsubfolder);
end

end
