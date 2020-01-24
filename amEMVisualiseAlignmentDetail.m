function [sorted_interventions, max_points] = amEMVisualiseAlignmentDetail(amIntrCube, amHeldBackcube, amInterventions, ...
    meancurvemean, meancurvecount, meancurvestd, overall_pdoffset, measures, min_offset, max_offset, align_wind, ...
    nmeasures, ninterventions, run_type, ex_start, curveaveragingmethod, plotname, plotsubfolder)

% amEMVisualiseAlignmentDetail - creates a plot of horizontal bars showing 
% the alignment of the data window (including the best_offset) for all 
%interventions. Also indicates missing data in each of the horizontal bars
    
datatable = table('Size',[1 3], ...
    'VariableTypes', {'double',       'double',     'double'}, ...
    'VariableNames', {'Intervention', 'ScaledDateNum', 'Count'});

rowtoadd = datatable;
max_points = zeros(1, max_offset + align_wind - 1);
sorted_interventions = amInterventions(:, {'IntrNbr','Offset'});
sorted_interventions = sortrows(sorted_interventions, {'Offset', 'IntrNbr'}, {'descend', 'ascend'});

for i = 1:max_offset + align_wind - 1
    if curveaveragingmethod == 1
        max_points(1, i) = size(sorted_interventions.Offset(sorted_interventions.Offset <= (max_offset + align_wind - i) ...
            & sorted_interventions.Offset > (align_wind - i)),1);
    else
        if (i - align_wind) <= 0
            max_points(1, i) = ninterventions;
        else
            max_points(1,i) = size(sorted_interventions.Offset(sorted_interventions.Offset <= (max_offset + align_wind - i)),1);
        end
    end
end

for m = 1:nmeasures
    datatable(1:size(datatable,1),:) = [];
    
    % add a dummy rows to ensure all days from -49 to -1 show on the heatmap
    rowtoadd.Intervention = 0;
    rowtoadd.Count = 2;
    for d = (-1 * (max_offset + align_wind - 1)): -1
        rowtoadd.ScaledDateNum = d;
        datatable = [datatable ; rowtoadd];
    end
    
    for i = 1:ninterventions
        scid = amInterventions.SmartCareID(i);
        start = amInterventions.IVScaledDateNum(i);
        offset = amInterventions.Offset(i);

        %fprintf('Intervention %2d, patient %3d, start %3d, best_offset %2d\n', i, scid, start, offset);
        rowtoadd.Intervention = amInterventions.IntrNbr(i);
        rowtoadd.Count = 2;
        for d = 1:align_wind
            if ~isnan(amIntrCube(i, max_offset + align_wind - d, m))
                rowtoadd.ScaledDateNum = 0 - d - offset;
                datatable = [datatable ; rowtoadd];
            end
        end
        rowtoadd.Count = 1;
        if curveaveragingmethod == 2
            for d = 1:max_offset - 1
                if ~isnan(amIntrCube(i, max_offset - d, m))
                    rowtoadd.ScaledDateNum = 0 - align_wind - d - offset;
                    datatable = [datatable ; rowtoadd];
                end
            end
        end
    end

    temp = hsv(64);
    brightness = .9;
    colors(1,:)  = temp(8,:)  .* brightness;
    colors(2,:)  = temp(16,:)  .* brightness;

    plotsacross = 2;
    plotsdown = 8;
    plottitle = sprintf('%s_%s', plotname, measures.DisplayName{m});
    anchor = 1; % latent curve is to be anchored on the plot (right side at min_offset)
    
    [f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');
    
    xl = [((-1 * (max_offset + align_wind)) + 1 - 0.5), -0.5];
    yl = [min(meancurvemean(:, m)) max(meancurvemean(:, m))];
    
    if isnan(yl(1))
        yl(1) = 0;
    end
    if isnan(yl(2))
        yl(2) = 1;
    end
    
    ax = subplot(plotsdown,plotsacross, 1:6,'Parent',p);
    yyaxis left;
    
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, (meancurvemean(:, m)), xl, yl, 'blue', ':', 0.5, anchor);
    %[xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, smooth(meancurvemean(:, m), 5), xl, yl, 'blue', '-', 0.5, anchor);
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, movmean(meancurvemean(:, m), 3, 'omitnan'), xl, yl, 'blue', '-', 0.5, anchor);
    
    ax.XAxis.FontSize = 8;
    xlabel('Days prior to Intervention');
    ax.YAxis(1).Color = 'blue';
    ax.YAxis(1).FontSize = 8;
    ylabel('Normalised Measure', 'FontSize', 8);
    
    if ex_start ~= 0
        [xl, yl] = plotVerticalLine(ax, ex_start, xl, yl, 'blue', '--', 0.5); % plot ex_start
    end
    
    yyaxis right
    ax.YAxis(2).Color = 'black';
    ax.YAxis(2).FontSize = 8;
    ylabel('Count of Data points');
    
    if isequal(run_type,'Best Alignment')
        bar([-1 * (max_offset + align_wind - 1): -1], max_points, 0.5, 'FaceColor', 'white', 'FaceAlpha', 0.1);
    end
    hold on;
    bar([-1 * (max_offset + align_wind - 1): -1], meancurvecount(:, m), 0.5, 'FaceColor', 'black', 'FaceAlpha', 0.25, 'LineWidth', 0.2);
    hold off;
    if isequal(run_type,'Best Alignment')
        ylbar = [0 max(max_points) * 4];
    else
        ylbar = [0 max(meancurvecount(:, m) * 4)];
    end
    if isnan(ylbar(2))
        ylbar(2) = 100;
    end
    ylim(ylbar);
    
    subplot(plotsdown,plotsacross, 7:16,'Parent',p);
    h = heatmap(p, datatable, 'ScaledDateNum', 'Intervention', 'Colormap', colors, 'MissingDataColor', 'white', ...
        'ColorVariable','Count','ColorMethod','max', 'MissingDataLabel', 'No data', 'ColorBarVisible', 'off', 'FontSize', 8);
    h.Title = ' ';
    h.XLabel = 'Days Prior to Intervention';
    h.YLabel = 'Intervention';
    h.YDisplayData = sorted_interventions.IntrNbr;
    h.XLimits = {-1 * (max_offset + align_wind - 1), max(datatable.ScaledDateNum)};
    h.CellLabelColor = 'none';
    h.GridVisible = 'on';
    
    savePlotInDir(f, plottitle, plotsubfolder);
    close(f);
    
    if measures.Mask(m) == 1
        
        nbuckets = 5;
        plotsacross = 2;
        plotsdown = round(nbuckets/plotsacross);
        plottitle = sprintf('%s_%s_Quintile', plotname, measures.DisplayName{m});
        
        [f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');
        
        for q = 1:nbuckets
            qlower = 1 + round((ninterventions * (q - 1))/nbuckets);
            qupper = round((ninterventions * q)/nbuckets);
            qnbr   = qupper - qlower + 1;
            fprintf('Quintile %d, Lower = %d, Upper = %d, Size = %d\n', q, qlower, qupper, qnbr);
            
            temp_meancurvesumsq    = zeros(max_offset + align_wind - 1, nmeasures);
            temp_meancurvesum      = zeros(max_offset + align_wind - 1, nmeasures);
            temp_meancurvecount    = zeros(max_offset + align_wind - 1, nmeasures);
            temp_meancurvemean     = zeros(max_offset + align_wind - 1, nmeasures);
            temp_meancurvestd      = zeros(max_offset + align_wind - 1, nmeasures);
            
            %problem here
            temp_interventions = amInterventions(ismember(amInterventions.IntrNbr, sorted_interventions.IntrNbr(qlower:qupper)),:);
            
            for i = 1:qnbr
                [temp_meancurvesumsq, temp_meancurvesum, temp_meancurvecount] = amEMAddToMean(temp_meancurvesumsq, temp_meancurvesum, temp_meancurvecount, ...
                    overall_pdoffset(ismember(amInterventions.IntrNbr, sorted_interventions.IntrNbr(qlower:qupper)), :), amIntrCube(ismember(amInterventions.IntrNbr, sorted_interventions.IntrNbr(qlower:qupper)), :, :), ...
                    amHeldBackcube(ismember(amInterventions.IntrNbr, sorted_interventions.IntrNbr(qlower:qupper)), :, :), i, ...
                    min_offset, max_offset, align_wind, nmeasures);
                [temp_meancurvemean, temp_meancurvestd] = calcMeanAndStd(temp_meancurvesumsq, temp_meancurvesum, temp_meancurvecount, min_offset, max_offset, align_wind);
            end
            
            qintrminoffset = min(amInterventions.Offset(ismember(amInterventions.IntrNbr, sorted_interventions.IntrNbr(qlower:qupper))));
            qdataminoffset = max_offset + align_wind - max(find(max(temp_meancurvecount, [], 2)~=0)) + 1;
            qto = max(qintrminoffset, qdataminoffset);
            
            %qintrmaxoffset = max(amInterventions.Offset(sorted_interventions.Intervention(qlower:qupper))) + align_wind;
            %qdatamaxoffset = max_offset + align_wind - min(find(min(temp_meancurvecount, [], 2)~=0));
            %qfrom = max(qintrmaxoffset, qdatamaxoffset);
            
            if curveaveragingmethod == 1
                qintrmaxoffset = max(amInterventions.Offset(ismember(amInterventions.IntrNbr, sorted_interventions.IntrNbr(qlower:qupper)))) + align_wind;
                qdatamaxoffset = max_offset + align_wind - min(find(min(temp_meancurvecount, [], 2)~=0));
                qfrom = max(qintrmaxoffset, qdatamaxoffset);
            else
                qfrom = max_offset + align_wind - 1;
            end
            
            xl = [((-1 * (max_offset + align_wind)) + 1 - 0.5), -0.5];
            yl = [min(min(temp_meancurvemean(:, m)), min(meancurvemean(:, m))) max(max(temp_meancurvemean(:, m)), max(meancurvemean(:, m)))];
            
            if isnan(yl(1))
                yl(1) = 0;
            end
            if isnan(yl(2))
                yl(2) = 1;
            end
    
            ax = subplot(plotsdown, plotsacross, q, 'Parent', p);
            ax.Title.FontSize = 8;
            ax.Title.String = sprintf('Quintile %d', q);
            
            yyaxis left;
            
            % plot latent curve and vertical line for ex_start (if chosen at this point)
            [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, (meancurvemean(:, m)), xl, yl, 'blue', ':', 0.5, anchor);
            %[xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, smooth(meancurvemean(:, m), 5), xl, yl, 'blue', '-', 0.5, anchor);
            [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, min_offset, movmean(meancurvemean(:, m), 3, 'omitnan'), xl, yl, 'blue', '-', 0.5, anchor);
            
            if ex_start ~= 0
                [xl, yl] = plotVerticalLine(ax, ex_start, xl, yl, 'blue', '--', 0.5); % plot ex_start
            end
            
            ax.XAxis.FontSize = 8;
            xlabel('Days prior to Intervention');
            ax.YAxis(1).Color = 'blue';
            ax.YAxis(1).FontSize = 8;
            ylabel('Normalised Measure', 'FontSize', 8);
            
            % plot latent curve for the quintile of interventions
            line([-1 * qfrom: -1 * qto], temp_meancurvemean(max_offset + align_wind - qfrom : max_offset + align_wind - qto, m), 'Color', 'red','LineStyle', ':');
            line([-1 * qfrom: -1 * qto], smooth(temp_meancurvemean(max_offset + align_wind - qfrom : max_offset + align_wind - qto, m), 5), 'Color', 'red','LineStyle', '-');

            yyaxis right
            ax.YAxis(2).Color = 'black';
            ax.YAxis(2).FontSize = 8;
            ylabel('Count of Data points');
            bar([-1 * (max_offset + align_wind - 1): -1], temp_meancurvecount(1:max_offset + align_wind - 1, m), 0.5, 'FaceColor', 'black', 'FaceAlpha', 0.15);
            ylim([0 (max(max_points) * 4 / nbuckets)]);
        end
        
        % save plot
        savePlotInDir(f, plottitle, plotsubfolder);
        close(f);
    end
end

end

    
