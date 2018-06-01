function amPlotsAndSavePredictions(amInterventions, amDatacube, measures, demographicstable, best_histogram, best_offsets, problower, probupper, ex_start, thisinter, nmeasures, max_offset, align_wind)

% amPlotsAndSavePredictions - plots measures prior to
% treatment with alignment model predictions, as well as the histograms
% showing the objective function results by measure

plotsdown = 8;
plotsacross = 5;
mpos = [ 1 2 6 7 ; 3 4 8 9 ; 11 12 16 17 ; 13 14 18 19 ; 21 22 26 27 ; 23 24 28 29 ; 31 32 36 37 ; 33 34 38 39];
hpos = [ 5 ; 10 ; 15 ; 20 ; 25 ; 30 ; 35 ; 40];
days = [-1 * (max_offset + align_wind): 0];

scid = amInterventions.SmartCareID(thisinter);
start = amInterventions.IVScaledDateNum(thisinter);
name = sprintf('Alignment Model Prediction - Exacerbation %d - ID %d Date %s', thisinter, scid, datestr(amInterventions.IVStartDate(thisinter),29));
f = figure('Name', name);
set(gcf, 'Units', 'normalized', 'OuterPosition', [0.45, 0, 0.35, 0.92], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
p = uipanel('Parent',f,'BorderType','none');
fprintf('%s - Best Offset = %d\n', name, best_offsets(thisinter));
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
    plot(days, current, ...
            'Color', [0, 0.65, 1], ...
            'LineStyle', '-', ...
            'Marker', 'o', ...
            'LineWidth',1, ...
            'MarkerSize',3,...
            'MarkerEdgeColor','b',...
            'MarkerFaceColor','g');
    set(gca,'fontsize',6);
    xl = [min(days) max(days)];
    xlim(xl);
    column = getColumnForMeasure(measures.Name{m});
    ddcolumn = sprintf('Fun_%s',column);
    pmmid50mean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(5);
    pmmid50std  = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(6);
    ydisplaymin = min(min(current) * 0.9, pmmid50mean * 0.9);
    ydisplaymax = max(max(current) * 1.1, pmmid50mean * 1.1);
    yl = [ydisplaymin ydisplaymax];
    ylim(yl);
    title(measures.DisplayName{m}, 'FontSize', 8);
    xlabel('Days Prior', 'FontSize', 6);
    ylabel('Measure', 'FontSize', 6);
    hold on
    line( [ex_start + best_offsets(thisinter) ex_start + best_offsets(thisinter)] , yl, 'Color', 'red', 'LineStyle', ':', 'LineWidth', 1);
    fill([(ex_start + problower(thisinter)) (ex_start + probupper(thisinter)) (ex_start + probupper(thisinter)) (ex_start + problower(thisinter))], ...
            [ydisplaymin ydisplaymin ydisplaymax ydisplaymax], ...
            'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
    line( [ex_start ex_start], [yl(1), yl(1) + ((yl(2)-yl(1)) * 0.1)], 'Color', 'black', 'LineStyle', ':', 'LineWidth', 1);
    line( [0 0] , yl, 'Color', 'magenta', 'LineStyle',':', 'LineWidth', 1);
    line( xl,[pmmid50mean pmmid50mean], 'Color', 'blue', 'LineStyle', '--', 'LineWidth', 1);
    line( xl, [pmmid50mean - pmmid50std pmmid50mean - pmmid50std] , 'Color', 'blue', 'LineStyle', ':', 'LineWidth', 1)
    line( xl, [pmmid50mean + pmmid50std pmmid50mean + pmmid50std] , 'Color', 'blue', 'LineStyle', ':', 'LineWidth', 1)
    hold off;
end

%plot the histograms
for m=1:nmeasures
    subplot(plotsdown, plotsacross, hpos(m,:),'Parent',p)    
    scatter([0:max_offset-1],best_histogram(m,thisinter,:),'o','MarkerFaceColor','g');    
    set(gca,'fontsize',6);
    hold on;
    line( [best_offsets(thisinter) best_offsets(thisinter)] , [0 1],'Color','red', 'LineStyle',':','LineWidth',1);
    fill([problower(thisinter) probupper(thisinter) probupper(thisinter) problower(thisinter)], ...
            [0 0 1 1], ...
            'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
    title(measures.DisplayName(m));
    xlim([0 max_offset-1]);
    ylim([0 1]);
    hold off;
end

basedir = './';
subfolder = 'Plots';
filename = [name '.png'];
saveas(f,fullfile(basedir, subfolder, filename));
filename = [name '.svg'];
saveas(f,fullfile(basedir, subfolder, filename));
close(f);

end

