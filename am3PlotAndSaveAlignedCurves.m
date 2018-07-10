function am3PlotAndSaveAlignedCurves(profile_pre, profile_post, count_post, offsets, qual, measures, max_offset, align_wind, nmeasures, run_type, study)

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
    xl = [-1 * (max_offset + align_wind) 0];
    yl = [min(min(profile_pre(m,:)), min(profile_post(m,:))) max(max(profile_pre(m,:)), max(profile_post(m,:)))];
    ax = subplot(plotsdown,plotsacross,m,'Parent',p);
    
    yyaxis left;
    plot([-1 * (max_offset + align_wind): -1], profile_pre(m,:), 'Color', 'blue','LineStyle', ':');
    ax.XAxis.FontSize = 8;
    xlabel('Days prior to Intervention');
    ax.YAxis(1).Color = 'red';
    ax.YAxis(1).FontSize = 8;
    ylabel('Normalised Measure', 'FontSize', 8);
    xlim(xl);
    ylim(yl);
    hold on;
    plot([-1 * (max_offset + align_wind): -1], smooth(profile_pre(m,:), 5), 'Color', 'blue', 'LineStyle', '-');
    plot([-1 * (max_offset + align_wind): -1], profile_post(m,:), 'Color', 'red', 'LineStyle', ':');
    plot([-1 * (max_offset + align_wind): -1], smooth(profile_post(m,:), 5), 'Color', 'red', 'LineStyle', '-');
    
    yyaxis right
    ax.YAxis(2).Color = 'black';
    ax.YAxis(2).FontSize = 8;
    ylabel('Count of Data points');
    plot([-1 * (max_offset + align_wind): -1], count_post(m, :), 'Color', 'black','LineStyle', ':');
    
    title(measures.DisplayName(m));
    hold off;
    
end

subplot(plotsdown, plotsacross, nmeasures + 1, 'Parent', p)
histogram(offsets)
xlim([-0.5 (max_offset - 0.5)]);
ylim([0 50]);
title('Histogram of Alignment Offsets')

%filename = sprintf('Alignment Model - %s - Err Function.png', run_type);
filename = sprintf('%s.png', plottitle);
saveas(f,fullfile(basedir, subfolder, filename));
%filename = sprintf('Alignment Model - %s - Err Function.svg', run_type);
filename = sprintf('%s.svg', plottitle);
saveas(f,fullfile(basedir, subfolder, filename));

close(f);

end

