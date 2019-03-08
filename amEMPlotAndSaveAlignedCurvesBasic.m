function amEMPlotAndSaveAlignedCurvesBasic(profile_pre, meancurvemean, offsets, ...
    measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder)

% amEMPlotAndSaveAlignedCurvesBasic - plots the curves pre and post alignment for
% each measure, and the histogram of offsets. Simplified version -
% excluding +/- std deviation lines, and count of data points by day

plotsacross = 3;
plotsdown = round((nmeasures + 1) / plotsacross);
plottitle = sprintf('%s - %s Basic', plotname, run_type);
anchor = 1; % latent curve is to be anchored on the plot (right side at min_offset)

[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');

for m = 1:nmeasures
    % initialise plot areas
    xl = [((-1 * (max_offset + align_wind)) + 1 - 0.5), -0.5];
    yl = [min((meancurvemean(:, m) * .99)) ...
          max((meancurvemean(:, m) * 1.01))];
    
    ax = subplot(plotsdown,plotsacross,m,'Parent',p);
    
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, (profile_pre(:, m)), xl, yl, 'red', ':', 0.5, anchor);
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, smooth(profile_pre(:, m), 5), xl, yl, 'red', '-', 0.5, anchor);
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, (meancurvemean(:, m)), xl, yl, 'blue', ':', 0.5, anchor);
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, smooth(meancurvemean(:, m), 5), xl, yl, 'blue', '-', 0.5, anchor);
    
    ax.XAxis.FontSize = 6;
    xlabel('Days prior to Intervention');
    ax.YAxis.Color = 'blue';
    ax.YAxis.FontSize = 6;
    ylabel('Normalised Measure', 'FontSize', 6);
    
    if ex_start ~= 0
        [xl, yl] = plotVerticalLine(ax, ex_start, xl, yl, 'blue', '--', 0.5); % plot ex_start
    end
    
    if measures.Mask(m) == 1
        title(measures.DisplayName(m), 'BackgroundColor', 'g');
    else
        title(measures.DisplayName(m));
    end
    
end

subplot(plotsdown, plotsacross, nmeasures + 1, 'Parent', p)
histogram(-1 * offsets)
xlim([(-1 * max_offset) + 0.5, 0.5]);
ylim([0 50]);
title('Histogram of Alignment Offsets')

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
close(f);

end

