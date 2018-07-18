function am3PlotAndSaveAlignedCurves(profile_pre, profile_post, count_post, std_post, offsets, qual, measures, max_points, max_offset, align_wind, nmeasures, run_type, study, ex_start)

% am3PlotAndSaveAlignedCurves - plots the curves pre and post alignment for
% each measure, and the histogram of offsets

basedir = './';
subfolder = 'Plots';

plotsacross = 2;
plotsdown = round((nmeasures + 1) / plotsacross);
plottitle = sprintf('%sAlignment Model3 - %s - ErrFcn = %7.4f', study,run_type, qual);

f = figure;
set(gcf, 'Units', 'normalized', 'OuterPosition', [0.45, 0, 0.35, 0.92], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = plottitle;
p.TitlePosition = 'centertop'; 
p.FontSize = 16;
p.FontWeight = 'bold';

for m = 1:nmeasures
    xl = [((-1 * (max_offset + align_wind)) - 0.5), -0.5];
    yl = [min(min(profile_pre(m,:)), min(profile_post(m,:) - std_post(m,:))) max(max(profile_pre(m,:)), max(profile_post(m,:) + std_post(m,:)))];
    ax = subplot(plotsdown,plotsacross,m,'Parent',p);
    
    yyaxis left;
    plot([-1 * (max_offset + align_wind): -1], profile_pre(m,:), 'Color', 'red','LineStyle', ':');
    ax.XAxis.FontSize = 8;
    xlabel('Days prior to Intervention');
    ax.YAxis(1).Color = 'blue';
    ax.YAxis(1).FontSize = 8;
    ylabel('Normalised Measure', 'FontSize', 8);
    xlim(xl);
    ylim(yl);
    hold on;
    plot([-1 * (max_offset + align_wind): -1], smooth(profile_pre(m,:), 5), 'Color', 'red', 'LineStyle', '-');
    plot([-1 * (max_offset + align_wind): -1], profile_post(m,:), 'Color', 'blue', 'LineStyle', ':');
    plot([-1 * (max_offset + align_wind): -1], smooth(profile_post(m,:), 5), 'Color', 'blue', 'LineStyle', '-');
    line([-1 * (max_offset + align_wind): -1], profile_post(m,:) + std_post(m,:), 'Color', 'blue', 'LineStyle', ':');
    line([-1 * (max_offset + align_wind): -1], smooth(profile_post(m,:) + std_post(m,:), 5), 'Color', 'blue', 'LineStyle', '--');
    line([-1 * (max_offset + align_wind): -1], profile_post(m,:) - std_post(m,:), 'Color', 'blue', 'LineStyle', ':');
    line([-1 * (max_offset + align_wind): -1], smooth(profile_post(m,:) - std_post(m,:), 5), 'Color', 'blue', 'LineStyle', '--');
    
    if ex_start ~= 0
        line([ex_start ex_start], yl, 'Color', 'blue', 'LineStyle', '--');
    end
    
    yyaxis right
    ax.YAxis(2).Color = 'black';
    ax.YAxis(2).FontSize = 8;
    ylabel('Count of Data points');
    if isequal(run_type,'Best Alignment')
        bar([-1 * (max_offset + align_wind): -1], max_points, 0.5, 'FaceColor', 'white', 'FaceAlpha', 0.1);
    end
    bar([-1 * (max_offset + align_wind): -1], count_post(m, :), 0.5, 'FaceColor', 'black', 'FaceAlpha', 0.25, 'LineWidth', 0.2);
    ylim([0 max(count_post(m, :) * 2)]);
    
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

