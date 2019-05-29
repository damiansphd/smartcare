function amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, ...
    measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves)

% amEMMCPlotSuperimposedAlignedCurves - wrapper around the
% plotSuperimposedAlignedCurves to plot for each set of latent curves

for n = 1:nlatentcurves
    tmp_meancurvemean  = reshape(meancurvemean(n, :, :),  [max_offset + align_wind - 1, nmeasures]);
    tmp_meancurvecount = reshape(meancurvecount(n, :, :), [max_offset + align_wind - 1, nmeasures]);
    
    tmp_plotname = sprintf('%s C%d', plotname, n);
    
    plotSuperimposedAlignedCurves(tmp_meancurvemean, tmp_meancurvecount, ...
            measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start(n), tmp_plotname, plotsubfolder);
end

end
