function [sorted_interventions, max_points] = amEMVisualiseAlignmentDetail(amDatacube, amInterventions, meancurvemean, meancurvecount, meancurvestd, pdoffset, offsets, measures, max_offset, align_wind, nmeasures, run_type, study, ex_start, version)

% amEMVisualiseAlignmentDetail - creates a plot of horizontal bars showing 
% the alignment of the data window (including the best_offset) for all 
%interventions. Also indicates missing data in each of the horizontal bars

datatable = table('Size',[1 3], ...
    'VariableTypes', {'double',       'double',     'double'}, ...
    'VariableNames', {'Intervention', 'ScaledDateNum', 'Count'});

rowtoadd = datatable;
max_points = zeros(1, max_offset + align_wind - 1);
ninterventions = size(amInterventions,1);
sorted_interventions = array2table(offsets);
sorted_interventions.Intervention = [1:ninterventions]';
sorted_interventions = sortrows(sorted_interventions, {'offsets', 'Intervention'}, {'descend', 'ascend'});
for i = 1:max_offset+align_wind-1
    max_points(1, i) = size(sorted_interventions.offsets(sorted_interventions.offsets <= (max_offset + align_wind - i) ...
            & sorted_interventions.offsets > (align_wind - i)),1);
end

for m = 1:nmeasures
    datatable(1:size(datatable,1),:) = [];
    for i = 1:ninterventions
        scid = amInterventions.SmartCareID(i);
        start = amInterventions.IVScaledDateNum(i);
        offset = offsets(i);

        fprintf('Intervention %2d, patient %3d, start %3d, best_offset %2d\n', i, scid, start, offset);
    
        rowtoadd.Intervention = i;
        rowtoadd.Count = 2;
        for d = 1:align_wind
            if start - d <= 0
              continue;
            end
            if ~isnan(amDatacube(scid, start - d, m))
                rowtoadd.ScaledDateNum = 0 - d - offset;
                datatable = [datatable ; rowtoadd];
            end
        end
    end

    temp = hsv;
    brightness = .9;
    colors(1,:)  = temp(8,:)  .* brightness;
    colors(2,:)  = temp(16,:)  .* brightness;

    basedir = './';
    subfolder = 'Plots';

    plotsacross = 2;
    plotsdown = 8;
    plottitle = sprintf('%sAlignment Model%s %s - %s', study, version, run_type, measures.DisplayName{m});
    f = figure('Name', plottitle);
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0.45, 0, 0.35, 0.92], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
    p = uipanel('Parent',f,'BorderType','none'); 
    p.Title = plottitle; 
    p.TitlePosition = 'centertop';
    p.FontSize = 20;
    p.FontWeight = 'bold';
    
    xl = [((-1 * (max_offset + align_wind)) + 1 - 0.5), -0.5];
    yl = [min(meancurvemean(:, m)) max(meancurvemean(:, m))];
    
    ax = subplot(plotsdown,plotsacross,[1:6],'Parent',p);
    yyaxis left;
    
    ax.XAxis.FontSize = 8;
    xlabel('Days prior to Intervention');
    ax.YAxis(1).Color = 'blue';
    ax.YAxis(1).FontSize = 8;
    ylabel('Normalised Measure', 'FontSize', 8);
    xlim(xl);
    ylim(yl);
    hold on;
    plot([-1 * (max_offset + align_wind - 1): -1], meancurvemean(:, m), 'Color', 'blue','LineStyle', ':');
    plot([-1 * (max_offset + align_wind - 1): -1], smooth(meancurvemean(:, m), 5), 'Color', 'blue', 'LineStyle', '-');
    if ex_start ~= 0
        line([ex_start ex_start], yl, 'Color', 'blue', 'LineStyle', '--');
    end
    
    yyaxis right
    ax.YAxis(2).Color = 'black';
    ax.YAxis(2).FontSize = 8;
    ylabel('Count of Data points');
    bar([-1 * (max_offset + align_wind - 1): -1], max_points, 0.5, 'FaceColor', 'white','FaceAlpha', 0.1);
    bar([-1 * (max_offset + align_wind - 1): -1], meancurvecount(:, m), 0.5, 'FaceColor', 'black', 'FaceAlpha', 0.15);
    ylim([0 (max(max_points) * 4)]);
    
    hold off;
    
    subplot(plotsdown,plotsacross,[7:16],'Parent',p);
    h = heatmap(p, datatable, 'ScaledDateNum', 'Intervention', 'Colormap', colors, 'MissingDataColor', 'white', ...
        'ColorVariable','Count','ColorMethod','max', 'MissingDataLabel', 'No data', 'ColorBarVisible', 'off', 'FontSize', 8);
    h.Title = ' ';
    h.XLabel = 'Days Prior to Intervention';
    h.YLabel = 'Intervention';
    h.YDisplayData = sorted_interventions.Intervention;
    h.XLimits = {-1 * (max_offset + align_wind - 1), -1};
    h.CellLabelColor = 'none';
    h.GridVisible = 'on';
    
    filename = sprintf('%s.png', plottitle);
    saveas(f,fullfile(basedir, subfolder, filename));
    filename = sprintf('%s.svg', plottitle);
    saveas(f,fullfile(basedir, subfolder, filename));
    
    close(f);
    
    if measures.Mask(m) == 1
        
        nbuckets = 5;
        plotsacross = 2;
        plotsdown = round(nbuckets/plotsacross);
        plottitle = sprintf('%sAlignment Model%s - Alignment By Quintile - %s', study, version, measures.DisplayName{m});
        f = figure('Name', plottitle);
        set(gcf, 'Units', 'normalized', 'OuterPosition', [0.45, 0, 0.35, 0.92], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
        p = uipanel('Parent',f,'BorderType','none'); 
        p.Title = plottitle; 
        p.TitlePosition = 'centertop';
        p.FontSize = 20;
        p.FontWeight = 'bold';
        
        for q = 1:nbuckets
            qlower = 1 + round((ninterventions * (q - 1))/nbuckets);
            qupper = round((ninterventions * q)/nbuckets);
            qnbr   = qupper - qlower + 1;
            fprintf('Quintile %d, Lower = %d, Upper = %d, Size = %d\n', q, qlower, qupper, qnbr);
            
            temp_meancurvedata     = nan(max_offset + align_wind - 1, nmeasures, qnbr);
            temp_meancurvesum      = zeros(max_offset + align_wind - 1, nmeasures);
            temp_meancurvecount    = zeros(max_offset + align_wind - 1, nmeasures);
            temp_meancurvemean     = zeros(max_offset + align_wind - 1, nmeasures);
            temp_meancurvestd      = zeros(max_offset + align_wind - 1, nmeasures);
            
            for i = 1:qnbr
                [temp_meancurvedata, temp_meancurvesum, temp_meancurvecount, temp_meancurvemean, temp_meancurvestd] = amEMAddToMean(temp_meancurvedata, temp_meancurvesum, ...
                    temp_meancurvecount, temp_meancurvemean, temp_meancurvestd, pdoffset(:, sorted_interventions.Intervention(qlower:qupper), :), amDatacube, amInterventions(sorted_interventions.Intervention(qlower:qupper),:), ...
                    i, max_offset, align_wind, nmeasures);
            end
            
            qintrminoffset = min(amInterventions.Offset(sorted_interventions.Intervention(qlower:qupper)));
            qdataminoffset = max_offset + align_wind - max(find(max(temp_meancurvecount, [], 2)~=0)) + 1;
            qto = max(qintrminoffset, qdataminoffset);
            
            qintrmaxoffset = max(amInterventions.Offset(sorted_interventions.Intervention(qlower:qupper))) + align_wind;
            qdatamaxoffset = max_offset + align_wind - min(find(min(temp_meancurvecount, [], 2)~=0));
            qfrom = max(qintrmaxoffset, qdatamaxoffset);
            
            xl = [((-1 * (max_offset + align_wind)) + 1 - 0.5), -0.5];
            yl = [min(min(temp_meancurvemean(:, m)), min(meancurvemean(:, m))) max(max(temp_meancurvemean(:, m)), max(meancurvemean(:, m)))];
    
            ax = subplot(plotsdown, plotsacross, q, 'Parent', p);
            ax.Title.FontSize = 8;
            ax.Title.String = sprintf('Quintile %d', q);
            
            yyaxis left;
            ax.XAxis.FontSize = 8;
            xlabel('Days prior to Intervention');
            ax.YAxis(1).Color = 'blue';
            ax.YAxis(1).FontSize = 8;
            ylabel('Normalised Measure', 'FontSize', 8);
            xlim(xl);
            ylim(yl);
            hold on;
            line([-1 * (max_offset + align_wind - 1): -1], meancurvemean(:, m), 'Color', 'blue','LineStyle', ':');
            line([-1 * (max_offset + align_wind - 1): -1], smooth(meancurvemean(:, m), 5), 'Color', 'blue', 'LineStyle', '-');
            line([-1 * qfrom: -1 * qto], temp_meancurvemean(max_offset + align_wind - qfrom : max_offset + align_wind - qto, m), 'Color', 'red','LineStyle', ':');
            line([-1 * qfrom: -1 * qto], smooth(temp_meancurvemean(max_offset + align_wind - qfrom : max_offset + align_wind - qto, m), 5), 'Color', 'red','LineStyle', '-');
            if ex_start ~= 0
                line([ex_start ex_start], yl, 'Color', 'blue', 'LineStyle', '--');
            end
            hold off;

            yyaxis right
            ax.YAxis(2).Color = 'black';
            ax.YAxis(2).FontSize = 8;
            ylabel('Count of Data points');
            bar([-1 * (max_offset + align_wind - 1): -1], temp_meancurvecount(1:max_offset + align_wind - 1, m), 0.5, 'FaceColor', 'black', 'FaceAlpha', 0.15);
            ylim([0 (max(max_points) * 4 / nbuckets)]);
        end
        
        filename = sprintf('%s.png', plottitle);
        saveas(f,fullfile(basedir, subfolder, filename));
        filename = sprintf('%s.svg', plottitle);
        saveas(f,fullfile(basedir, subfolder, filename));
    
        close(f);
            
    end
end

end

    
