function plotSuperimposedAlignedCurves(meancurvemean, meancurvecount, ...
    measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder)

% plotSuperimposedAlignedCurves - plots the aligned curves for each of the
% measures superimposed on a single plot to show any timing differences in
% the declines

plotsacross = 1;
plotsdown = 1;
plottitle = sprintf('%s - %s Superimposed', plotname, run_type);
anchor = 1; % latent curve is to be anchored on the plot (right side at min_offset)
cntthresh = 8;

% add colour array here and use it in the call to plotLatentCurve
colors = lines(sum(measures.Mask));

% invert pulse rate
pridx = ismember(measures.DisplayName, {'PulseRate'});
meancurvemean(:, pridx) = meancurvemean(:, pridx) * -1;

% need to add filtering of points with < n underlying data points.


[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');
ax = subplot(plotsdown, plotsacross, 1, 'Parent',p);

% initialise plot areas
xl = [((-1 * (max_offset + align_wind)) + 1 - 0.5), -0.5];
yl = [min(min(meancurvemean)) * .99 ...
      max(max(meancurvemean)) * 1.01];

am = 0;
for m = 1:nmeasures
    if measures.Mask(m) == 1    
        am = am + 1;
        tmpmeancurvemean  = meancurvemean(:, m);
        tmpmeancurvecount = meancurvecount(:, m);
        tmpmeancurvemean(tmpmeancurvecount < cntthresh) = NaN;
        
        [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, movmean(meancurvemean(:, m), 5), xl, yl, colors(am, :), '-', 0.5, anchor);
    end

end

if ex_start ~= 0
    [xl, yl] = plotVerticalLine(ax, ex_start, xl, yl, 'blue', '--', 0.5); % plot ex_start
end

legendtext = measures.DisplayName(logical(measures.Mask));
legendtext = [legendtext; {'ExStart'}];
legend(ax, legendtext, 'Location', 'southwest', 'FontSize', 10);

ax.XAxis.FontSize = 10;
xlabel('Days prior to Intervention');
ax.YAxis.FontSize = 10;
ylabel('Normalised Measure');

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
close(f);

end

