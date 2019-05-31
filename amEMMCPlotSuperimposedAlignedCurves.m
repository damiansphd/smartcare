function amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, amInterventions, ...
    measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves)

% amEMMCPlotSuperimposedAlignedCurves - wrapper around the
% plotSuperimposedAlignedCurves to plot for each set of latent curves

plotsacross = 2;
plotsdown   = 2;
plottitle   = sprintf('%s - %s Superimposed', plotname, run_type);
[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');

cntthresh = 5;
smoothwdth = 4;

% Preprocess the latent curve :-
% 1) invert pulse rate
% 2) remove points with fewer than count threshold underlying data poins
% contributing
% 3) apply mean smoothing
% 4) apply a vertical shift (by the average of the points to the left of
% ex_start)
for n = 1:nlatentcurves
    pridx = ismember(measures.DisplayName, {'PulseRate'});
    meancurvemean(n, :, pridx) = meancurvemean(n, :, pridx) * -1;
    for m = 1:nmeasures
        meancurvemean(n, meancurvecount(n, :, m) < cntthresh, m) = NaN;
        meancurvemean(n, :, m) = movmean(meancurvemean(n, :, m), smoothwdth, 'omitnan');
        vertshift = mean(meancurvemean(n, 1:(align_wind + max_offset - 1 + ex_start(n)), m));
        meancurvemean(n, :, m) = meancurvemean(n, :, m) - vertshift;
        fprintf('For curve %d and measure %13s, vertical shift is %.3f\n', n, measures.DisplayName{m}, -vertshift);
    end
end

% set the plot range over all curves to ensure comparable visual scaling
xl = [((-1 * (max_offset + align_wind)) + 1 - 0.5), -0.5];
yl = [min(min(min(meancurvemean))) ...
      max(max(max(meancurvemean)))];

% for each curve, plot all measures superimposed
for n = 1:nlatentcurves
    tmp_meancurvemean  = reshape(meancurvemean(n, :, :),  [max_offset + align_wind - 1, nmeasures]);
    tmp_meancurvecount = reshape(meancurvecount(n, :, :), [max_offset + align_wind - 1, nmeasures]);
    tmp_ninterventions   = sum(amInterventions.LatentCurve == n);
    
    if tmp_ninterventions ~= 0
        ax = subplot(plotsdown, plotsacross, n, 'Parent',p);
        plotSuperimposedAlignedCurves(ax, tmp_meancurvemean, tmp_meancurvecount, xl, yl, ...
                measures, min_offset, max_offset, align_wind, ex_start(n), n, cntthresh);
    end
end

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
close(f);

end
