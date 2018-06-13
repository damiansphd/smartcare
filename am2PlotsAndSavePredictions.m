function am2PlotsAndSavePredictions(amInterventions, amDatacube, measures, demographicstable, best_histogram, best_offsets, best_profile_post, ex_start, thisinter, nmeasures, max_offset, align_wind)

% am2PlotsAndSavePredictions - plots measures prior to
% treatment with alignment model predictions and overlaid with the mean
% curve for visual comparison, as well as the histograms showing the 
% objective function results by measure. 

plotsdown = 8;
plotsacross = 5;
mpos = [ 1 2 6 7 ; 3 4 8 9 ; 11 12 16 17 ; 13 14 18 19 ; 21 22 26 27 ; 23 24 28 29 ; 31 32 36 37 ; 33 34 38 39];
hpos = [ 5 ; 10 ; 15 ; 20 ; 25 ; 30 ; 35 ; 40];
days = [-1 * (max_offset + align_wind): 0];

scid = amInterventions.SmartCareID(thisinter);
start = amInterventions.IVScaledDateNum(thisinter);
name = sprintf('Alignment Model2 Prediction - Exacerbation %d - ID %d Date %s', thisinter, scid, datestr(amInterventions.IVStartDate(thisinter),29));
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
    xl = [min(days) max(days)];
    xlim(xl);
    column = getColumnForMeasure(measures.Name{m});
    ddcolumn = sprintf('Fun_%s',column);
    pmmid50mean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(5);
    pmmid50std  = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(6);
    ydisplaymin = min(min(min(current) * 0.95, pmmid50mean * 0.95), min(best_profile_post(m,:)) * 0.95);
    ydisplaymax = max(max(max(current) * 1.05, pmmid50mean * 1.05), max(best_profile_post(m,:)) * 1.05);
    yl = [ydisplaymin ydisplaymax];
    ylim(yl);
    title(measures.DisplayName{m}, 'FontSize', 8);
    xlabel('Days Prior', 'FontSize', 6);
    ylabel('Measure', 'FontSize', 6);
    hold on
    % plot mean surve (actual in dotted line, smoothed in solid line)
    plot([(-1 * (max_offset + align_wind)) + best_offsets(thisinter): -1], ...
        best_profile_post(m,1:max_offset + align_wind - best_offsets(thisinter)), ...
        'Color', 'red', ...
        'LineStyle', ':', ...
        'LineWidth', 1);
    plot([(-1 * (max_offset + align_wind)) + best_offsets(thisinter): -1], ...
        smooth(best_profile_post(m,1:max_offset + align_wind - best_offsets(thisinter)), 5), ...
        'Color', 'red', ...
        'LineStyle', '-', ...
        'LineWidth', 1);
    % plot vertical line for predicted exacerbation start
    line( [ex_start + best_offsets(thisinter) ex_start + best_offsets(thisinter)] , yl, ...
        'Color', 'green', ...
        'LineStyle', '-', ...
        'LineWidth', 1);
    
    % plot confidence bounds
    %fill([(ex_start + problower(thisinter)) (ex_start + probupper(thisinter)) (ex_start + probupper(thisinter)) (ex_start + problower(thisinter))], ...
    %        [ydisplaymin ydisplaymin ydisplaymax ydisplaymax], ...
    %        'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
    
    % plot short vertical line for average exacerbation start indicator
    line( [ex_start ex_start], [yl(1), yl(1) + ((yl(2)-yl(1)) * 0.1)], ...
        'Color', 'black', ...
        'LineStyle', ':', ...
        'LineWidth', 1);
    % plot vertical line indicating treatment start
    line( [0 0] , yl, ...
        'Color', 'magenta', ...
        'LineStyle',':', ...
        'LineWidth', 1);
    % plot horizontal line for mid50mean and shading for +/-1 std
    line( xl,[pmmid50mean pmmid50mean], ...
        'Color', 'blue', ...
        'LineStyle', '--', ...
        'LineWidth', 1);
    fill([xl(1) xl(2) xl(2) xl(1)], ...
        [pmmid50mean - pmmid50std pmmid50mean - pmmid50std pmmid50mean + pmmid50std pmmid50mean + pmmid50std], ...
        'blue', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
    hold off;
end

%plot the histograms
for m=1:nmeasures
    subplot(plotsdown, plotsacross, hpos(m,:),'Parent',p) 
    plot([0:max_offset-1],reshape(best_histogram(m,thisinter,:), 30, 1), ...
            'Color', 'none', ...
            'LineStyle', 'none', ...
            'Marker', 'o', ...
            'LineWidth',0.5, ...
            'MarkerSize',2,...
            'MarkerEdgeColor','black',...
            'MarkerFaceColor','g');
    %scatter([0:max_offset-1],best_histogram(m,thisinter,:), ...
    %    'o','MarkerFaceColor','g', 'MarkerSize', 1);    
    set(gca,'fontsize',6);
    hold on;
    line( [best_offsets(thisinter) best_offsets(thisinter)] , [0 1],'Color','red', 'LineStyle',':','LineWidth',1);
    %fill([problower(thisinter) probupper(thisinter) probupper(thisinter) problower(thisinter)], ...
    %        [0 0 1 1], ...
    %        'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
    title(measures.DisplayName(m));
    xlim([0 max_offset-1]);
    ylim([min(best_histogram(m, thisinter, :)) max(best_histogram(m, thisinter, :))]);
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

