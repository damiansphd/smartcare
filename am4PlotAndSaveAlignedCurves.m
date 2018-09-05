function am4PlotAndSaveAlignedCurves(profile_pre, meancurvemean, meancurvecount, meancurvestd, offsets, ...
    measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, plotname, ex_start, sigmamethod)

% am4PlotAndSaveAlignedCurves - plots the curves pre and post alignment for
% each measure, and the histogram of offsets

plotsacross = 3;
plotsdown = round((nmeasures + 1) / plotsacross);
plottitle = sprintf('%s - %s', plotname, run_type);
anchor = 1; % latent curve is to be anchored on the plot (right side at min_offset)

[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');

for m = 1:nmeasures
    % initialise plot areas
    xl = [((-1 * (max_offset + align_wind)) + 1 - 0.5), -0.5];
    yl = [min((meancurvemean(:, m) * .99)) ...
          max((meancurvemean(:, m) * 1.01))];
    
    ax = subplot(plotsdown,plotsacross,m,'Parent',p);
    yyaxis left;
    
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, (profile_pre(:, m)), xl, yl, 'red', ':', 0.5, anchor);
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, smooth(profile_pre(:, m), 5), xl, yl, 'red', '-', 0.5, anchor);
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, (meancurvemean(:, m)), xl, yl, 'blue', ':', 0.5, anchor);
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, smooth(meancurvemean(:, m), 5), xl, yl, 'blue', '-', 0.5, anchor);
    
    if sigmamethod == 4
        [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, (meancurvemean(:, m) + meancurvestd(:,m)), xl, yl, 'blue', ':', 0.5, anchor);
        [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, smooth(meancurvemean(:, m) + meancurvestd(:,m), 5), xl, yl, 'blue', '--', 0.5, anchor);
        [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, (meancurvemean(:, m) - meancurvestd(:,m)), xl, yl, 'blue', ':', 0.5, anchor);
        [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, smooth(meancurvemean(:, m) - meancurvestd(:,m), 5), xl, yl, 'blue', '--', 0.5, anchor);
    end
    
    ax.XAxis.FontSize = 6;
    xlabel('Days prior to Intervention');
    ax.YAxis(1).Color = 'blue';
    ax.YAxis(1).FontSize = 6;
    ylabel('Normalised Measure', 'FontSize', 6);
    
    if ex_start ~= 0
        [xl, yl] = plotVerticalLine(ax, ex_start, xl, yl, 'blue', '--', 0.5); % plot ex_start
    end
    
    yyaxis right
    ax.YAxis(2).Color = 'black';
    ax.YAxis(2).FontSize = 6;
    ylabel('Count of Data points');
    if isequal(run_type,'Best Alignment')
        bar([-1 * (max_offset + align_wind - 1): -1], max_points, 0.5, 'FaceColor', 'white', 'FaceAlpha', 0.1);
    end
    bar([-1 * (max_offset + align_wind - 1): -1], meancurvecount(:, m), 0.5, 'FaceColor', 'black', 'FaceAlpha', 0.25, 'LineWidth', 0.2);
    if isequal(run_type,'Best Alignment')
        ylim([0 max(max_points) * 4]);
    else
        ylim([0 max(meancurvecount(:, m) * 4)]);
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
savePlot(f, plottitle);
close(f);

end

