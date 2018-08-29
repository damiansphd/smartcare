function [amLabelledInterventions] = createLabelledInterventions(amIntrDatacube, amLabelledInterventions, ...
    pdoffset, overall_pdoffset, interfrom, interto, measures, normmean, max_offset, align_wind, ex_start, ...
    study, ninterventions, nmeasures)

% createLanelledInterventions - plots measurement data and asks for lower
% and upper bounds for predicted exacerbation start in order to create a
% test data set that can be compared to model results going forward

plotsdown = 9;
plotsacross = 5;
mpos = [ 1 2 6 7 ; 3 4 8 9 ; 11 12 16 17 ; 13 14 18 19 ; 21 22 26 27 ; 23 24 28 29 ; 31 32 36 37 ; 33 34 38 39];
hpos = [ 5 ; 10 ; 15 ; 20 ; 25 ; 30 ; 35 ; 40 ; 45 ; 44 ; 43 ; 42 ; 41 ];
days = [-1 * (max_offset + align_wind - 1): -1];
xl  = zeros(nmeasures + 1, 2);
yl  = zeros(nmeasures + 1, 2);
xl2 = zeros(nmeasures + 1, 2);
yl2 = zeros(nmeasures + 1, 2);

%for i=1:ninterventions
i = interfrom;

while i <= interto 
    scid = amLabelledInterventions.SmartCareID(i);
    actualpoints = 0;
    maxpoints = 0;
    for m = 1:nmeasures
        if (measures.Mask(m) == 1)
            actualpoints = actualpoints + sum(~isnan(amIntrDatacube(i, max_offset:max_offset+align_wind-1, m)));
            maxpoints = maxpoints + align_wind;
        end
    end
    amLabelledInterventions.DataWindowCompleteness(i) = 100 * actualpoints/maxpoints;
    if i >= 2
        if (amLabelledInterventions.SmartCareID(i) == amLabelledInterventions.SmartCareID(i-1) ...
                && amLabelledInterventions.IVDateNum(i) - amLabelledInterventions.IVDateNum(i-1) < 50)
            amLabelledInterventions.SequentialIntervention(i) = 'Y';
        end
    end
  
    fprintf('Intervention %2d: ID %3d, Date %s, Data Window Completeness = %.2f%%\n', i, scid, ...
        datestr(amLabelledInterventions.IVStartDate(i),29), amLabelledInterventions.DataWindowCompleteness(i));
    name = sprintf('%s_AM Labelling Data - Ex %d (ID %d Date %s)', study, i, scid, ...
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
        ax(m) = subplot(plotsdown, plotsacross, mpos(m,:), 'Parent',p);
        ax(m).XGrid = 'on';
        
        [xl(m,:), yl(m,:)] = plotMeasurementData(ax(m), days, amIntrDatacube(i, :, m), xl(m,:), yl(m,:), measures(m,:), [0, 0.65, 1], '-', 1.0, 'o', 2.0, 'blue', 'green');
        if measures.Mask(m) == 1
            title(measures.DisplayName(m), 'FontSize', 6, 'BackgroundColor', 'green');
        else
            title(measures.DisplayName(m), 'FontSize', 6);
        end
        [xl(m,:), yl(m,:)] = plotHorizontalLine(ax(m), normmean(i, m), xl(m,:), yl(m,:), 'blue', '--', 0.5); % plot mean
            
        xl2(m,:) = [0 max_offset-1];
        yl2(m,:) = [0 0.25];
                    
        ax2(m) = subplot(plotsdown, plotsacross, hpos(m,:),'Parent',p); 
        ax2(m).XGrid = 'on';
                    
        [xl2(m,:), yl2(m,:)] = plotProbDistribution(ax2(m), max_offset, pdoffset(m, i,:), xl2(m,:), yl2(m,:), 'o', 0.5, 2.0, 'blue', 'blue');
                    
        set(gca,'fontsize',6);
        if measures.Mask(m) == 1
            title(sprintf('%s', measures.DisplayName{m}), 'BackgroundColor', 'green');
        else
            title(sprintf('%s', measures.DisplayName{m}));
        end
    end
    
    xl2(nmeasures+1,:) = [0 max_offset-1];
    yl2(nmeasures+1,:) = [0 0.25];
    
    ax2(nmeasures+1) = subplot(plotsdown, plotsacross, hpos(nmeasures + 1,:),'Parent',p); 
    ax2(nmeasures+1).XGrid = 'on';          
    
    [xl2(nmeasures+1,:), yl2(nmeasures+1,:)] = plotProbDistribution(ax2(nmeasures+1), max_offset, ...
        overall_pdoffset(i,:), xl2(nmeasures+1,:), yl2(nmeasures+1,:), 'o', 0.5, 2.0, 'blue', 'blue');
    
    set(gca,'fontsize',6);
    title(sprintf('%s', 'Overall'), 'BackgroundColor', 'green');
    
    lower = input('Enter upperbound for exacerbation start ? ');
    if isequal(lower,'')
        fprintf('Invalid choice\n');
        return;
    end
    if lower < ex_start || lower > -1
        fprintf('Invalid choice\n');
        return;
    end
    
    amLabelledInterventions.LowerBound(i) = lower - ex_start;
        
    upper = input('Enter upperbound for exacerbation start ? ');
    if isequal(upper,'')
        fprintf('Invalid choice\n');
        return;
    end
    if upper < lower || upper > 0
        fprintf('Invalid choice\n');
        return;
    end
    
    if (upper - ex_start) > max_offset -1
        amLabelledInterventions.UpperBound(i) = max_offset -1;
    else
        amLabelledInterventions.UpperBound(i) = upper - ex_start;
    end
    
    for m = 1:nmeasures
        if all(isnan(amIntrDatacube(i, :, m)))
            continue;
        end
        subplot(ax(m));
        ax(m).XGrid = 'off';
        [xl(m,:), yl(m,:)] = plotExStart(ax(m), ex_start, amLabelledInterventions.LowerBound(i), xl(m,:), yl(m,:),  'red', '-', 0.5);
        [xl(m,:), yl(m,:)] = plotExStart(ax(m), ex_start, amLabelledInterventions.UpperBound(i), xl(m,:), yl(m,:),  'red', '-', 0.5);
        hold on;
        fill(ax(m), [ (ex_start + amLabelledInterventions.LowerBound(i)) (ex_start + amLabelledInterventions.UpperBound(i))    ...
                      (ex_start + amLabelledInterventions.UpperBound(i)) (ex_start + amLabelledInterventions.LowerBound(i)) ], ...
                    [yl(m,1) yl(m,1) yl(m,2) yl(m,2)], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        hold off;
        
        subplot(ax2(m));
        ax2(m).XGrid = 'off';
        [xl2(m,:) yl2(m,:)] = plotVerticalLine(ax2(m), amLabelledInterventions.LowerBound(i), xl2(m,:), yl2(m,:), 'red', '-', 0.5);
        [xl2(m,:) yl2(m,:)] = plotVerticalLine(ax2(m), amLabelledInterventions.UpperBound(i), xl2(m,:), yl2(m,:), 'red', '-', 0.5);
        hold on;
        fill(ax2(m), [ amLabelledInterventions.LowerBound(i) amLabelledInterventions.UpperBound(i)    ...
                       amLabelledInterventions.UpperBound(i) amLabelledInterventions.LowerBound(i) ], ...
                     [ yl2(m,1) yl2(m,1) yl2(m,2) yl2(m,2) ], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        hold off
    end
    
    subplot(ax2(nmeasures+1));
    ax2(nmeasures+1).XGrid = 'off';    
    
    [xl2(nmeasures+1,:), yl2(nmeasures+1,:)] = plotVerticalLine(ax2(nmeasures+1), amLabelledInterventions.LowerBound(i), ...
        xl2(nmeasures+1,:), yl2(nmeasures+1,:), 'red', '-', 0.5);
    [xl2(nmeasures+1,:), yl2(nmeasures+1,:)] = plotVerticalLine(ax2(nmeasures+1), amLabelledInterventions.UpperBound(i), ...
        xl2(nmeasures+1,:), yl2(nmeasures+1,:), 'red', '-', 0.5);
    
    hold on;
    fill(ax2(nmeasures+1), [ amLabelledInterventions.LowerBound(i) amLabelledInterventions.UpperBound(i)    ...
                             amLabelledInterventions.UpperBound(i) amLabelledInterventions.LowerBound(i) ], ...
                           [ yl2(nmeasures+1,1) yl2(nmeasures+1,1) yl2(nmeasures+1,2) yl2(nmeasures+1,2) ], ...
                           'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
    hold off
        
    set(gca,'fontsize',6);
    title(sprintf('%s', 'Overall'), 'BackgroundColor', 'green');
    
    if ((amLabelledInterventions.DataWindowCompleteness(i) >= 60) ...
            && ((amLabelledInterventions.UpperBound(i) - amLabelledInterventions.LowerBound(i)) <= 8))
        amLabelledInterventions.IncludeInTestSet(i) = 'Y';
    else
        amLabelledInterventions.IncludeInTestSet(i) = 'N';
    end
        
    temp = input('Re-do labelling (1=No, 2= Yes) ? ');
    if isequal(temp,'')
        fprintf('Invalid choice\n');
        return;
    end
    if temp < 1 || temp > 2
        fprintf('Invalid choice\n');
        return;
    end
    
    if temp == 1
        savePlot(f, name);
        close(f);
        i = i + 1;
    else
        close(f);
    end
    
end
        
end


