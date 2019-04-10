function [amLabelledInterventions] = createLabelledInterventions(amIntrDatacube, amLabelledInterventions, ...
    pdoffset, overall_pdoffset, interfrom, interto, measures, normmean, max_offset, align_wind, ex_start, ...
    study, nmeasures)

% createLabelledInterventions - plots measurement data and asks for lower
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

i = interfrom;
while i <= interto 
    scid = amLabelledInterventions.SmartCareID(i);
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
    
    lower1 = input('Enter lowerbound1 for exacerbation start (<= -1) ? ');
    if isequal(lower1,'')
        fprintf('Invalid choice\n');
        return;
    end
    if lower1 >= 0
        fprintf('Invalid choice\n');
        return;
    end
    
    amLabelledInterventions.LowerBound1(i) = lower1;
        
    upper1 = input(sprintf('Enter upperbound1 for exacerbation start (%2d:-1) ? ', lower1 + 1));
    if isequal(upper1,'')
        fprintf('Invalid choice\n');
        return;
    end
    if upper1 <= lower1 || upper1 >= 0
        fprintf('Invalid choice\n');
        return;
    end
    
    amLabelledInterventions.UpperBound1(i) = upper1;
    
    secondrange = input('Enter a second range for exacerbation (1=Y, 2=N) ? ');
    if isequal(secondrange,'')
        fprintf('Invalid choice\n');
        return;
    end
    if secondrange < 1 || secondrange > 2
        fprintf('Invalid choice\n');
        return;
    end
    
    if secondrange == 1
        lower2 = input(sprintf('Enter lowerbound2 for exacerbation start (%2d:-1) ? ', upper1 + 1));
        if isequal(lower2,'')
            fprintf('Invalid choice\n');
            return;
        end
        if lower2 <= upper1 || lower2 >= 0
            fprintf('Invalid choice\n');
            return;
        end
    
        amLabelledInterventions.LowerBound2(i) = lower2;
        
        upper2 = input(sprintf('Enter upperbound2 for exacerbation start (%2d:-1) ? ', lower2 + 1));
        if isequal(upper2,'')
            fprintf('Invalid choice\n');
            return;
        end
        if upper2 <= lower2 || upper2 >= 0
            fprintf('Invalid choice\n');
            return;
        end
        
        amLabelledInterventions.UpperBound2(i) = upper2;
    else
        amLabelledInterventions.LowerBound2(i) = 0;
        amLabelledInterventions.UpperBound2(i) = 0;
    end
    
    for m = 1:nmeasures
        if all(isnan(amIntrDatacube(i, :, m)))
            continue;
        end
        subplot(ax(m));
        ax(m).XGrid = 'off';
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
        
        subplot(ax2(m));
        ax2(m).XGrid = 'off';
        [xl2(m,:), yl2(m,:)] = plotVerticalLine(ax2(m), amLabelledInterventions.LowerBound1(i) - ex_start, xl2(m,:), yl2(m,:), 'red', '-', 0.5);
        [xl2(m,:), yl2(m,:)] = plotVerticalLine(ax2(m), amLabelledInterventions.UpperBound1(i) - ex_start, xl2(m,:), yl2(m,:), 'red', '-', 0.5);
        if amLabelledInterventions.LowerBound2(i) ~= 0
            [xl2(m,:), yl2(m,:)] = plotVerticalLine(ax2(m), amLabelledInterventions.LowerBound2(i) - ex_start, xl2(m,:), yl2(m,:), 'red', '-', 0.5);
            [xl2(m,:), yl2(m,:)] = plotVerticalLine(ax2(m), amLabelledInterventions.UpperBound2(i) - ex_start, xl2(m,:), yl2(m,:), 'red', '-', 0.5); 
        end
        
        hold on;
        fill(ax2(m), [ (amLabelledInterventions.LowerBound1(i) - ex_start) (amLabelledInterventions.UpperBound1(i) - ex_start)    ...
                       (amLabelledInterventions.UpperBound1(i) - ex_start) (amLabelledInterventions.LowerBound1(i) - ex_start) ], ...
                       [ yl2(m,1) yl2(m,1) yl2(m,2) yl2(m,2) ], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        if amLabelledInterventions.LowerBound2(i) ~= 0  
            fill(ax2(m), [ (amLabelledInterventions.LowerBound2(i) - ex_start) (amLabelledInterventions.UpperBound2(i) - ex_start)    ...
                           (amLabelledInterventions.UpperBound2(i) - ex_start) (amLabelledInterventions.LowerBound2(i) - ex_start) ], ...
                           [ yl2(m,1) yl2(m,1) yl2(m,2) yl2(m,2) ], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        end
        hold off
    end
    
    subplot(ax2(nmeasures+1));
    ax2(nmeasures+1).XGrid = 'off';    
    
    [xl2(nmeasures+1,:), yl2(nmeasures+1,:)] = plotVerticalLine(ax2(nmeasures+1), amLabelledInterventions.LowerBound1(i) - ex_start, ...
        xl2(nmeasures+1,:), yl2(nmeasures+1,:), 'red', '-', 0.5);
    [xl2(nmeasures+1,:), yl2(nmeasures+1,:)] = plotVerticalLine(ax2(nmeasures+1), amLabelledInterventions.UpperBound1(i) - ex_start, ...
        xl2(nmeasures+1,:), yl2(nmeasures+1,:), 'red', '-', 0.5);
    if amLabelledInterventions.LowerBound2(i) ~= 0
        [xl2(nmeasures+1,:), yl2(nmeasures+1,:)] = plotVerticalLine(ax2(nmeasures+1), amLabelledInterventions.LowerBound2(i) - ex_start, ...
            xl2(nmeasures+1,:), yl2(nmeasures+1,:), 'red', '-', 0.5);
        [xl2(nmeasures+1,:), yl2(nmeasures+1,:)] = plotVerticalLine(ax2(nmeasures+1), amLabelledInterventions.UpperBound2(i) - ex_start, ...
            xl2(nmeasures+1,:), yl2(nmeasures+1,:), 'red', '-', 0.5);
    end
    
    hold on;
    fill(ax2(nmeasures+1), [ (amLabelledInterventions.LowerBound1(i) - ex_start) (amLabelledInterventions.UpperBound1(i) - ex_start)   ...
                             (amLabelledInterventions.UpperBound1(i) - ex_start) (amLabelledInterventions.LowerBound1(i) - ex_start) ], ...
                             [ yl2(nmeasures+1,1) yl2(nmeasures+1,1) yl2(nmeasures+1,2) yl2(nmeasures+1,2) ], ...
                             'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
    if amLabelledInterventions.LowerBound2(i) ~= 0
        fill(ax2(nmeasures+1), [ (amLabelledInterventions.LowerBound2(i) - ex_start) (amLabelledInterventions.UpperBound2(i) - ex_start)   ...
                                 (amLabelledInterventions.UpperBound2(i) - ex_start) (amLabelledInterventions.LowerBound2(i) - ex_start) ], ...
                                 [ yl2(nmeasures+1,1) yl2(nmeasures+1,1) yl2(nmeasures+1,2) yl2(nmeasures+1,2) ], ...
                                 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
    end
    hold off
        
    set(gca,'fontsize',6);
    title(sprintf('%s', 'Overall'), 'BackgroundColor', 'green');
    
    ub1 = min(amLabelledInterventions.UpperBound1(i), (ex_start + max_offset - 1));
    if amLabelledInterventions.UpperBound2(i) < 0
        ub2 = min(amLabelledInterventions.UpperBound2(i), (ex_start + max_offset - 1));
    else
        ub2 = amLabelledInterventions.UpperBound2(i);
    end
    lb1 = max(amLabelledInterventions.LowerBound1(i), ex_start);
    if amLabelledInterventions.LowerBound2(i) < 0
        lb2 = max(amLabelledInterventions.LowerBound2(i), ex_start);
    else
        lb2 = amLabelledInterventions.LowerBound2(i);
    end
    
    %if ((amLabelledInterventions.DataWindowCompleteness(i) >= 60) ...
    %        && (((amLabelledInterventions.UpperBound1(i) - amLabelledInterventions.LowerBound1(i)) + (amLabelledInterventions.UpperBound2(i) - amLabelledInterventions.LowerBound2(i))) <= 9))
    if ((amLabelledInterventions.DataWindowCompleteness(i) >= 60) ...
            && (((ub1 - lb1) + (ub2 - lb2)) <= 9))
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
        plotsubfolder = 'Plots';
        savePlotInDir(f, name, plotsubfolder);
        close(f);
        i = i + 1;
    else
        close(f);
    end
    
end
        
end


