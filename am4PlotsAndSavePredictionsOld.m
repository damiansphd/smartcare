function am4PlotsAndSavePredictions(amInterventions, amDatacube, measures, pdoffset, overall_pdoffset, overall_pdoffset_all, overall_pdoffset_xAL, offsets, meancurvemean, hstg, normmean, ex_start, thisinter, nmeasures, max_offset, align_wind, study, version)

% am4PlotsAndSavePredictions - plots measures prior to
% treatment with alignment model predictions and overlaid with the mean
% curve for visual comparison, as well as the histograms showing the 
% objective function results by measure. 

plotsdown = 9;
plotsacross = 5;
mpos = [ 1 2 6 7 ; 3 4 8 9 ; 11 12 16 17 ; 13 14 18 19 ; 21 22 26 27 ; 23 24 28 29 ; 31 32 36 37 ; 33 34 38 39];
hpos = [ 5 ; 10 ; 15 ; 20 ; 25 ; 30 ; 35 ; 40 ; 45 ; 44 ; 43 ; 42 ; 41 ];
days = [-1 * (max_offset + align_wind): 0];

scid = amInterventions.SmartCareID(thisinter);
start = amInterventions.IVScaledDateNum(thisinter);
name = sprintf('%s_AM%s Exacerbation %d - ID %d Date %s, Offset %d', study, version, thisinter, scid, datestr(amInterventions.IVStartDate(thisinter),29), offsets(thisinter));
f = figure('Name', name);
set(gcf, 'Units', 'normalized', 'OuterPosition', [0.45, 0, 0.35, 0.92], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
p = uipanel('Parent',f,'BorderType','none');
fprintf('%s - Best Offset = %d\n', name, offsets(thisinter));
p.Title = name;
p.TitlePosition = 'centertop';
p.FontSize = 12;
p.FontWeight = 'bold'; 
for m = 1:nmeasures
    current = NaN(1,max_offset + align_wind + 1);
    for j=0:max_offset + align_wind
        if start - j > 0
            current(max_offset + align_wind + 1 - j) = amDatacube(scid, start - j, m);    
        end
    end
    if all(isnan(current))
        continue;
    end
    subplot(plotsdown, plotsacross, mpos(m,:), 'Parent',p)
    % plot measurement data
    plot(days, current, ...
            'Color', [0, 0.65, 1], ...
            'LineStyle', '-', ...
            'Marker', 'o', ...
            'LineWidth',1, ...
            'MarkerSize',2,...
            'MarkerEdgeColor','b',...
            'MarkerFaceColor','g');
    set(gca,'fontsize',6);
    xl = [(min(days) + 1) max(days)];
    xlim(xl);
    ydisplaymin = min(min(current * 0.99), min(meancurvemean(1:max_offset + align_wind - 1 - offsets(thisinter), m) + normmean(thisinter, m) * 0.99));
    ydisplaymax = max(max(current * 1.01), max(meancurvemean(1:max_offset + align_wind - 1 - offsets(thisinter), m) + normmean(thisinter, m) * 1.01));
    yl = [ydisplaymin ydisplaymax];
    ylim(yl);
    if measures.Mask(m) == 1
        title(measures.DisplayName(m), 'FontSize', 8, 'BackgroundColor', 'g');
    else
        title(measures.DisplayName(m),'FontSize', 8);
    end
    %title(measures.DisplayName{m}, 'FontSize', 8);
    xlabel('Days Prior', 'FontSize', 6);
    ylabel('Measure', 'FontSize', 6);
    hold on
    % plot mean curve (actual in dotted line, smoothed in solid line)
    plot([(-1 * (max_offset + align_wind - 1)) + offsets(thisinter): -1], ...
        meancurvemean(1:max_offset + align_wind - 1 - offsets(thisinter), m) + normmean(thisinter, m), ...
        'Color', 'red', ...
        'LineStyle', ':', ...
        'LineWidth', 1);
    plot([(-1 * (max_offset + align_wind - 1)) + offsets(thisinter): -1], ...
        smooth(meancurvemean(1:max_offset + align_wind - 1 - offsets(thisinter), m) + normmean(thisinter, m), 5), ...
        'Color', 'red', ...
        'LineStyle', '-', ...
        'LineWidth', 1);
    % plot vertical line for predicted exacerbation start
    line( [ex_start + offsets(thisinter) ex_start + offsets(thisinter)] , yl, ...
        'Color', 'green', ...
        'LineStyle', '-', ...
        'LineWidth', 0.5);
    
    % plot short vertical line for average exacerbation start indicator
    line( [ex_start ex_start], [yl(1), yl(1) + ((yl(2)-yl(1)) * 0.1)], ...
        'Color', 'black', ...
        'LineStyle', ':', ...
        'LineWidth', 0.5);
    % plot vertical line indicating treatment start
    line( [0 0] , yl, ...
        'Color', 'magenta', ...
        'LineStyle',':', ...
        'LineWidth', 0.5);
    line( xl,[normmean(thisinter, m) normmean(thisinter, m)], ...
        'Color', 'blue', ...
        'LineStyle', '--', ...
        'LineWidth', 0.5);
    hold off;
end

% plot the posterior distributions for each measure
for m=1:nmeasures
    subplot(plotsdown, plotsacross, hpos(m,:),'Parent',p) 
    plot([0:max_offset-1], reshape(pdoffset(m,thisinter,:), [max_offset,1]), ...
            'Color', 'none', ...
            'LineStyle', 'none', ...
            'Marker', 'o', ...
            'LineWidth', 1, ...
            'MarkerSize', 2,...
            'MarkerEdgeColor', 'blue',...
            'MarkerFaceColor', 'green');
    set(gca,'fontsize',6);
    hold on;
    if (max(pdoffset(m,thisinter,:)) > 0.25)
        yl = [0 max(pdoffset(m,thisinter,:))];
    else
        yl = [0 0.25];
    end
    line( [offsets(thisinter) offsets(thisinter)], yl, ...
        'Color', 'green', 'LineStyle', '-', 'LineWidth', 0.5);
    if measures.Mask(m) == 1
        title(sprintf('%s (%.1f)', measures.DisplayName{m}, hstg(m, thisinter, offsets(thisinter) + 1)), 'BackgroundColor', 'g');
    else
        title(sprintf('%s (%.1f)', measures.DisplayName{m}, hstg(m, thisinter, offsets(thisinter) + 1)));
    end
    xlim([0 max_offset-1]);
    ylim(yl);
    hold off;
end

% plot the overall posterior distributions
subplot(plotsdown, plotsacross, hpos(nmeasures + 1,:),'Parent',p)
plot([0:max_offset-1], overall_pdoffset(thisinter,:), ...
    'Color', 'none', ...
    'LineStyle', 'none', ...
    'Marker', 'o', ...
    'LineWidth', 1, ...
    'MarkerSize', 2,...
    'MarkerEdgeColor', 'blue',...
    'MarkerFaceColor', 'green');
set(gca,'fontsize',6);
hold on;
if (max(overall_pdoffset(thisinter,:)) > 0.25)
    yl = [0 max(overall_pdoffset(thisinter,:))];
else
    yl = [0 0.25];
end
line( [offsets(thisinter) offsets(thisinter)] , yl, ...
    'Color', 'green', 'LineStyle', '-', 'LineWidth', 0.5);
title('Overall', 'BackgroundColor', 'g');
xlim([0 max_offset-1]);
ylim(yl);
hold off;

subplot(plotsdown, plotsacross, hpos(nmeasures + 2,:),'Parent',p)
plot([0:max_offset-1], overall_pdoffset_all(thisinter,:), ...
    'Color', 'none', ...
    'LineStyle', 'none', ...
    'Marker', 'o', ...
    'LineWidth', 1, ...
    'MarkerSize', 2,...
    'MarkerEdgeColor', 'blue',...
    'MarkerFaceColor', 'green');
set(gca,'fontsize',6);
hold on;
if (max(overall_pdoffset_all(thisinter,:)) > 0.25)
    yl = [0 max(overall_pdoffset_all(thisinter,:))];
else
    yl = [0 0.25];
end
line( [offsets(thisinter) offsets(thisinter)] , yl, ...
    'Color', 'green', 'LineStyle', '-', 'LineWidth', 0.5);
title('Overall - All');
xlim([0 max_offset-1]);
ylim(yl);
hold off;

subplot(plotsdown, plotsacross, hpos(nmeasures + 3,:),'Parent',p)
plot([0:max_offset-1], overall_pdoffset_xAL(thisinter,:), ...
    'Color', 'none', ...
    'LineStyle', 'none', ...
    'Marker', 'o', ...
    'LineWidth', 1, ...
    'MarkerSize', 2,...
    'MarkerEdgeColor', 'blue',...
    'MarkerFaceColor', 'green');
set(gca,'fontsize',6);
hold on;
if (max(overall_pdoffset_xAL(thisinter,:)) > 0.25)
    yl = [0 max(overall_pdoffset_xAL(thisinter,:))];
else
    yl = [0 0.25];
end
line( [offsets(thisinter) offsets(thisinter)] , yl, ...
    'Color', 'green', 'LineStyle', '-', 'LineWidth', 0.5);
title('Overall ex Act/Lung');
xlim([0 max_offset-1]);
ylim(yl);
hold off;

% save plot
basedir = './';
subfolder = 'Plots';
filename = [name '.png'];
saveas(f,fullfile(basedir, subfolder, filename));
filename = [name '.svg'];
saveas(f,fullfile(basedir, subfolder, filename));
close(f);

end

