function amEMPlotsAndSavePredictions(amInterventions, amIntrDatacube, measures, pdoffset, ...
    overall_pdoffset, hstg, overall_hist, meancurvemean, normmean, normstd, isOutlier, ...
    ex_start, thisinter, nmeasures, max_offset, align_wind, sigmamethod, plotname, plotsubfolder)

% amEMPlotsAndSavePredictions - plots measures prior to
% treatment with alignment model predictions and overlaid with the mean
% curve for visual comparison, as well as plots of the posterior
% probability distributions by measure

plotsdown = 9;
plotsacross = 5;
mpos = [ 1 2 6 7 ; 3 4 8 9 ; 11 12 16 17 ; 13 14 18 19 ; 21 22 26 27 ; 23 24 28 29 ; 31 32 36 37 ; 33 34 38 39];
hpos = [ 5 ; 10 ; 15 ; 20 ; 25 ; 30 ; 35 ; 40 ; 45 ; 44 ; 43 ; 42 ; 41 ];
dayset = [-1 * (max_offset + align_wind - 1): -1];
anchor = 0; % latent curve is to be shifted by offset on the plot
noutliers = sum(sum(isOutlier(thisinter, :, :, amInterventions.Offset(thisinter) + 1)));
scid = amInterventions.SmartCareID(thisinter);
name = sprintf('%s-%d_ID_%d_Dt_%s_Off_%d_Out_%d', plotname, thisinter, ...
    scid, datestr(amInterventions.IVStartDate(thisinter),29), amInterventions.Offset(thisinter), noutliers);
fprintf('%s\n', name);

[f, p] = createFigureAndPanel(name, 'portrait', 'a4');

for m = 1:nmeasures
    if all(isnan(amIntrDatacube(thisinter, :, m)))
        continue;
    end
    if sigmamethod == 4
        adjmeancurvemean = (meancurvemean(:,m) * normstd(thisinter, m)) + normmean(thisinter, m);
    else
        adjmeancurvemean =  meancurvemean(:,m) + normmean(thisinter, m);
    end
    
    % initialise plot areas
    xl = [0 0];
    yl = [min(adjmeancurvemean(1:max_offset + align_wind - 1 - amInterventions.Offset(thisinter)) * .99) ...
          max(adjmeancurvemean(1:max_offset + align_wind - 1 - amInterventions.Offset(thisinter)) * 1.01)];
    
    % create subplot and plot required data arrays
    ax = subplot(plotsdown, plotsacross, mpos(m,:), 'Parent',p);               
    [xl, yl] = plotMeasurementData(ax, dayset, amIntrDatacube(thisinter, :, m), xl, yl, measures(m,:), [0, 0.65, 1], '-', 1.0, 'o', 2.0, 'blue', 'green');
    [xl, yl] = plotHorizontalLine(ax, normmean(thisinter, m), xl, yl, 'blue', '--', 0.5); % plot mean
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, amInterventions.Offset(thisinter), adjmeancurvemean, xl, yl, 'red', ':', 1.0, anchor);
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, amInterventions.Offset(thisinter), smooth(adjmeancurvemean,5), xl, yl, 'red', '-', 1.0, anchor);

    [xl, yl] = plotExStart(ax, ex_start, amInterventions.Offset(thisinter), xl, yl,  'black', '-', 0.5);            
    [xl, yl] = plotVerticalLine(ax, 0, xl, yl, 'cyan', '-', 0.5); % plot treatment start
    plotOutlierDataPoints(ax, dayset, amIntrDatacube(thisinter, :, m), isOutlier(thisinter, :, m, amInterventions.Offset(thisinter) + 1), ...
        max_offset, align_wind, [0, 0.65, 1], 'none', 1.0, 'o', 4.0, 'red', 'yellow');
    hold on;
    plotFillArea(ax, ex_start + amInterventions.LowerBound1(thisinter), ex_start + amInterventions.UpperBound1(thisinter), ...
        yl(1), yl(2), 'red', '0.1', 'none');
    if amInterventions.LowerBound2(thisinter) ~= -1
        plotFillArea(ax, ex_start + amInterventions.LowerBound2(thisinter), ex_start + amInterventions.UpperBound2(thisinter), ...
            yl(1), yl(2), 'red', '0.1', 'none');
    end
    hold off;
        
    xl2 = [0 max_offset-1];
    yl2 = [0 0.25];            
    ax2 = subplot(plotsdown, plotsacross, hpos(m,:),'Parent',p);           
    [xl2, yl2] = plotProbDistribution(ax2, max_offset, pdoffset(m, thisinter,:), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');
    [xl2, yl2] = plotVerticalLine(ax2, amInterventions.Offset(thisinter), xl2, yl2, 'black', '-', 0.5); % plot predicted offset
    hold on;
    plotFillArea(ax2, amInterventions.LowerBound1(thisinter), amInterventions.UpperBound1(thisinter), ...
        yl2(1), yl2(2), 'red', '0.1', 'none');
    if amInterventions.LowerBound2(thisinter) ~= -1
        plotFillArea(ax2, amInterventions.LowerBound2(thisinter), amInterventions.UpperBound2(thisinter), ...
            yl2(1), yl2(2), 'red', '0.1', 'none');
    end
    hold off;
    set(gca,'fontsize',6);
    if measures.Mask(m) == 1
        title(sprintf('%s (%.1f)', measures.DisplayName{m}, hstg(m, thisinter, amInterventions.Offset(thisinter) + 1)), 'BackgroundColor', 'g');
    else
        title(sprintf('%s (%.1f)', measures.DisplayName{m}, hstg(m, thisinter, amInterventions.Offset(thisinter) + 1)));
    end
                    
end

% plot the overall posterior distributions
xl2 = [0 max_offset-1];
yl2 = [0 0.25];
ax2 = subplot(plotsdown, plotsacross, hpos(nmeasures + 1,:),'Parent',p); 
[xl2, yl2] = plotProbDistribution(ax2, max_offset, overall_pdoffset(thisinter,:), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');                
[xl2, yl2] = plotVerticalLine(ax2, amInterventions.Offset(thisinter), xl2, yl2, 'black', '-', 0.5); % plot predicted offset
hold on;
plotFillArea(ax2, amInterventions.LowerBound1(thisinter), amInterventions.UpperBound1(thisinter), ...
        yl2(1), yl2(2), 'red', '0.1', 'none');
if amInterventions.LowerBound2(thisinter) ~= -1
    plotFillArea(ax2, amInterventions.LowerBound2(thisinter), amInterventions.UpperBound2(thisinter), ...
        yl2(1), yl2(2), 'red', '0.1', 'none');
end
hold off;
set(gca,'fontsize',6);
title(sprintf('Overall (%.1f)', overall_hist(thisinter, amInterventions.Offset(thisinter) + 1)), 'BackgroundColor', 'g');

infostring = [ {sprintf('Treatment Date:               %11s', datestr(amInterventions.IVStartDate(thisinter), 1))} ; ...
               {sprintf('Predicted Exacerbation Start: %11s', datestr((amInterventions.IVStartDate(thisinter) + days(ex_start + amInterventions.Offset(thisinter))), 1))} ; ...
               {sprintf('90%% confidence Lower Bound1:  %11s', datestr((amInterventions.IVStartDate(thisinter) + days(ex_start + amInterventions.LowerBound1(thisinter))), 1))} ; ...
               {sprintf('90%% confidence Upper Bound2:  %11s', datestr((amInterventions.IVStartDate(thisinter) + days(ex_start + amInterventions.UpperBound1(thisinter) + 1)), 1))} ; ...
             ];

if amInterventions.LowerBound2(thisinter) ~= -1
    rowstring = sprintf('90%% confidence Lower Bound2:  %11s', datestr((amInterventions.IVStartDate(thisinter) + days(ex_start + amInterventions.LowerBound2(thisinter))),1));
    infostring = [infostring ; rowstring];
    rowstring = sprintf('90%% confidence Upper Bound2:  %11s', datestr((amInterventions.IVStartDate(thisinter) + days(ex_start + amInterventions.UpperBound2(thisinter) + 1)),1));
    infostring = [infostring ; rowstring];
else
    rowstring = sprintf('90%% confidence Lower Bound2:  %11s', 'N/A');
    infostring = [infostring ; rowstring];
    rowstring = sprintf('90%% confidence Upper Bound2:  %11s', 'N/A');
    infostring = [infostring ; rowstring];
end

sp1 = uicontrol('Parent', p, ...
                'Units', 'normalized', ...
                'OuterPosition', [0.2, 0.075, 0.5, 0.1], ...
                'Style', 'text', ...
                'FontName', 'FixedWidth', ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'left', ...
                'String', infostring);
            
% save plot
savePlotInDir(f, name, plotsubfolder);
close(f);

end
