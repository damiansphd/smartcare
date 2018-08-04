

basedir = './';
subfolder = 'Plots';

plotsacross = 3;
plotsdown = round((nmeasures + 1) / plotsacross);
plottitle = sprintf('%sAlignment Model4 - %s - ErrFcn = %7.4f', study,run_type, qual);

f = figure;
set(gcf, 'Units', 'normalized', 'OuterPosition', [0.45, 0, 0.35, 0.92], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = plottitle;
p.TitlePosition = 'centertop'; 
p.FontSize = 16;
p.FontWeight = 'bold';

for m = 1:nmeasures
    xl = [((-1 * (max_offset + align_wind)) + 1 - 0.5), -0.5];
    yl = [min(min(best_profile_pre(:,m)), min(best_meancurvemean(:,m))) max(max(best_profile_pre(:,m)), max(best_meancurvemean(:,m)))];
    ax = subplot(plotsdown,plotsacross,m,'Parent',p);
    
    yyaxis left;
    hold on;
    line([-1 * (max_offset + align_wind - 1): -1], best_profile_pre(:,m)', 'Color', 'red','LineStyle', '-');
    line([-1 * (max_offset + align_wind - 1): -1], (best_profile_pre(:,m) + best_meancurvestd(:,m))', 'Color', 'red','LineStyle', '--');
    line([-1 * (max_offset + align_wind - 1): -1], (best_profile_pre(:,m) - best_meancurvestd(:,m))', 'Color', 'red','LineStyle', '--');
    line([-1 * (max_offset + align_wind - 1): -1], best_meancurvemean(:,m)', 'Color', 'blue','LineStyle', ':');
    line([-1 * (max_offset + align_wind - 1): -1], smooth(best_meancurvemean(:,m), 5)', 'Color', 'blue', 'LineStyle', '-');
    
    ax.XAxis.FontSize = 8;
    xlabel('Days prior to Intervention');
    ax.YAxis(1).Color = 'blue';
    ax.YAxis(1).FontSize = 8;
    ylabel('Normalised Measure', 'FontSize', 8);
    xlim(xl);
    ylim(yl);
    
    yyaxis right
    ax.YAxis(2).Color = 'black';
    ax.YAxis(2).FontSize = 8;
    ylabel('Count of Data points');
    bar([-1 * (max_offset + align_wind - 1): -1], best_meancurvecount(:,m)', 0.5, 'FaceColor', 'black', 'FaceAlpha', 0.25, 'LineWidth', 0.2);
    ylim([0 max(best_meancurvecount(:,m) * 4)]);
    if measures.Mask(m) == 1
        title(measures.DisplayName(m), 'BackgroundColor', 'g');
    else
        title(measures.DisplayName(m));
    end
    
    hold off;
    
end

subplot(plotsdown, plotsacross, nmeasures + 1, 'Parent', p)
histogram(-1 * best_offsets)
xlim([(-1 * max_offset) + 0.5, 0.5]);
ylim([0 50]);
title('Histogram of Alignment Offsets')
