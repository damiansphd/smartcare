function am4PlotAndSaveAlignedCurves(profile_pre, meancurvemean, meancurvecount, meancurvestd, offsets, measures, max_points, max_offset, align_wind, nmeasures, run_type, plotname, ex_start, sigmamethod)

% am4PlotAndSaveAlignedCurves - plots the curves pre and post alignment for
% each measure, and the histogram of offsets

basedir = './';
subfolder = 'Plots';

plotsacross = 3;
plotsdown = round((nmeasures + 1) / plotsacross);
plottitle = sprintf('%s - %s', plotname, run_type);

f = figure;
set(gcf, 'Units', 'normalized', 'OuterPosition', [0.45, 0, 0.35, 0.92], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = plottitle;
p.TitlePosition = 'centertop'; 
p.FontSize = 12;
p.FontWeight = 'bold';

for m = 1:nmeasures
    % initialise plot areas
    xl = [((-1 * (max_offset + align_wind)) + 1 - 0.5), -0.5];
    yl = [min((meancurvemean(:, m) * .99)) ...
          max((meancurvemean(:, m) * 1.01))];
    
    ax = subplot(plotsdown,plotsacross,m,'Parent',p);
    yyaxis left;
    
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, 0, (profile_pre(:, m)), xl, yl, 'red', ':', 0.5);
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, 0, smooth(profile_pre(:, m), 5), xl, yl, 'red', '-', 0.5);
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, 0, (meancurvemean(:, m)), xl, yl, 'blue', ':', 0.5);
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, 0, smooth(meancurvemean(:, m), 5), xl, yl, 'blue', '-', 0.5);
    
    if sigmamethod == 4
        [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, 0, (meancurvemean(:, m) + meancurvestd(:,m)), xl, yl, 'blue', ':', 0.5);
        [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, 0, smooth(meancurvemean(:, m) + meancurvestd(:,m), 5), xl, yl, 'blue', '--', 0.5);
        [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, 0, (meancurvemean(:, m) - meancurvestd(:,m)), xl, yl, 'blue', ':', 0.5);
        [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, 0, smooth(meancurvemean(:, m) - meancurvestd(:,m), 5), xl, yl, 'blue', '--', 0.5);
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
    
    hold off;
    
end

subplot(plotsdown, plotsacross, nmeasures + 1, 'Parent', p)
histogram(-1 * offsets)
xlim([(-1 * max_offset) + 0.5, 0.5]);
ylim([0 50]);
title('Histogram of Alignment Offsets')

filename = sprintf('%s.png', plottitle);
saveas(f,fullfile(basedir, subfolder, filename));
filename = sprintf('%s.svg', plottitle);
saveas(f,fullfile(basedir, subfolder, filename));

close(f);

end

