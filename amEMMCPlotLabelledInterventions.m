function amEMMCPlotLabelledInterventions(amIntrDatacube, amInterventions, amLabelledInterventions, ...
    measures, normmean, max_offset, align_wind, study, nmeasures)

% amEMMCPlotLabelledInterventions - plots all the labelled test data

plotsdown = 4;
plotsacross = 2;

days = [-1 * (max_offset + align_wind - 1): -1];
xl  = zeros(nmeasures + 1, 2);
yl  = zeros(nmeasures + 1, 2);

for i = 1:size(amInterventions,1)
    if (amInterventions.SmartCareID(i) ~= amLabelledInterventions.SmartCareID(i)) || (amInterventions.IVScaledDateNum(i) ~= amLabelledInterventions.IVScaledDateNum(i))
        fprintf('**** Mismatch between Intervention Data and amLabelledInterventions ****\n');
        return;
    end
    scid = amLabelledInterventions.SmartCareID(i);
    fprintf('Intervention %2d: ID %3d, Date %s, Data Window Completeness = %.2f%%\n', i, scid, ...
        datestr(amLabelledInterventions.IVStartDate(i),29), amLabelledInterventions.DataWindowCompleteness(i));
    name = sprintf('%s_AM Labelled Test Data - Ex %d (ID %d Date %s)', study, i, scid, ...
        datestr(amLabelledInterventions.IVStartDate(i),29));
    
    [f, p] = createFigureAndPanel(name, 'portrait', 'a4');
    
    for m = 1:nmeasures
        if all(isnan(amIntrDatacube(i, :, m)))
            continue;
        end
        % initialise plot areas
        xl(m,:) = [min(days) max(days)];
        yl(m,:) = [min(amIntrDatacube(i, 1:max_offset + align_wind - 1, m) * 0.99) ...
              max(amIntrDatacube(i, 1:max_offset + align_wind - 1, m) * 1.01)];
                    
        % create subplot and plot required data arrays
        ax(m) = subplot(plotsdown, plotsacross, m, 'Parent',p);
        
        [xl(m,:), yl(m,:)] = plotMeasurementData(ax(m), days, amIntrDatacube(i, :, m), xl(m,:), yl(m,:), measures(m,:), [0, 0.65, 1], ':', 1.0, 'o', 2.0, 'blue', 'green');
        [xl(m,:), yl(m,:)] = plotMeasurementData(ax(m), days, movmean(amIntrDatacube(i, :, m), 4, 'omitnan'), xl(m,:), yl(m,:), measures(m,:), [0, 0.65, 1], '-', 1.0, 'none', 2.0, 'blue', 'green');
        title(measures.DisplayName(m), 'FontSize', 6);
        [xl(m,:), yl(m,:)] = plotHorizontalLine(ax(m), normmean(i, m), xl(m,:), yl(m,:), 'blue', '--', 0.5); % plot mean
        xlim(ax(m), xl(m, :));
        
        [xl(m,:), yl(m,:)] = plotVerticalLine(ax(m), amLabelledInterventions.LowerBound1(i), xl(m,:), yl(m,:),  'red', '-', 0.5);
        [xl(m,:), yl(m,:)] = plotVerticalLine(ax(m), amLabelledInterventions.UpperBound1(i), xl(m,:), yl(m,:),  'red', '-', 0.5);
        if amLabelledInterventions.LowerBound2(i) ~= 0
            [xl(m,:), yl(m,:)] = plotVerticalLine(ax(m), amLabelledInterventions.LowerBound2(i), xl(m,:), yl(m,:),  'red', '-', 0.5);
            [xl(m,:), yl(m,:)] = plotVerticalLine(ax(m), amLabelledInterventions.UpperBound2(i), xl(m,:), yl(m,:),  'red', '-', 0.5);
        end
        hold on;
        fill(ax(m), [ amLabelledInterventions.LowerBound1(i) amLabelledInterventions.UpperBound1(i)    ...
                      amLabelledInterventions.UpperBound1(i) amLabelledInterventions.LowerBound1(i) ], ...
                      [yl(m,1) yl(m,1) yl(m,2) yl(m,2)], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        if amLabelledInterventions.LowerBound2(i) ~= 0        
            fill(ax(m), [ amLabelledInterventions.LowerBound2(i) amLabelledInterventions.UpperBound2(i)    ...
                          amLabelledInterventions.UpperBound2(i) amLabelledInterventions.LowerBound2(i) ], ...
                          [yl(m,1) yl(m,1) yl(m,2) yl(m,2)], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        end        
        hold off;
            
    end
    
    plotsubfolder = 'Plots';
    savePlotInDir(f, name, plotsubfolder);
    close(f);

end

