function amEMMCPlotsAndSavePredictions(amInterventions, amIntrcube, measures, pdoffset, ...
    overall_pdoffset, hstg, overall_hist, vshift, meancurvemean, normmean, normstd, isOutlier, ...
    ex_start_array, thisinter, nmeasures, max_offset, align_wind, sigmamethod, plotname, plotsubfolder, normmode)

% amEMMCPlotsAndSavePredictions - plots measures prior to
% treatment with alignment model predictions and overlaid with the mean
% curve for visual comparison, as well as plots of the posterior
% probability distributions by measure (handling multiple sets of latent
% curves)


if nmeasures <= 8
    plotsdown = 9;
    plotsacross = 5;
    mpos = [ 1  2  6  7 ;  3  4  8  9 ; 
            11 12 16 17 ; 13 14 18 19 ; 
            21 22 26 27 ; 23 24 28 29 ; 
            31 32 36 37 ; 33 34 38 39 ];
    hpos = [ 5 ; 10 ; 
            15 ; 20 ; 
            25 ; 30 ; 
            35 ; 40 ; 
            45      ];
    %hpos = [ 5 ; 10 ; 15 ; 20 ; 25 ; 30 ; 35 ; 40 ; 45 ; 44 ; 43 ; 42 ; 41 ];
elseif nmeasures > 8 && nmeasures <= 18
    plotsdown = 14;
    plotsacross = 8;
    mpos = [ 1  2  9 10 ;  3  4 11 12 ;  5  6 13 14 ; 
            17 18 25 26 ; 19 20 27 28 ; 21 22 29 30 ; 
            33 34 41 42 ; 35 36 43 44 ; 37 38 45 46 ; 
            49 50 57 58 ; 51 52 59 60 ; 53 54 61 62 ;
            65 66 73 74 ; 67 68 75 76 ; 69 70 77 78 ; 
            81 82 89 90 ; 83 84 91 92 ; 85 86 93 94 ];
    hpos = [  7 ;  8 ; 15 ; 
             23 ; 24 ; 31 ;  
             39 ; 40 ; 47 ; 
             55 ; 56 ; 63 ; 
             71 ; 72 ; 79 ;
             87 ; 88 ; 95 ;
             103          ];
end

dayset = [-1 * (max_offset + align_wind - 1): -1];
anchor = 0; % latent curve is to be shifted by offset on the plot

if normmode == 2
    normtxt = 'Norm';
else
    normtxt = '';
end

scid = amInterventions.SmartCareID(thisinter);
lc = amInterventions.LatentCurve(thisinter);
ex_start = ex_start_array(lc);
noutliers = sum(sum(isOutlier(lc, thisinter, :, :, amInterventions.Offset(thisinter) + 1)));
name = sprintf('%s-%s-%d_ID_%d_Dt_%s_Off_%d_C%d_Out_%d', plotname, normtxt, thisinter, ...
    scid, datestr(amInterventions.IVStartDate(thisinter),29), amInterventions.Offset(thisinter), amInterventions.LatentCurve(thisinter), noutliers);
fprintf('%s\n', name);

[f, p] = createFigureAndPanel(name, 'portrait', 'a4');

for m = 1:nmeasures
    if all(isnan(amIntrcube(thisinter, :, m)))
        continue;
    end
    if normmode == 1
        adjmeasdata = amIntrcube(thisinter, :, m);
        if sigmamethod == 4
            adjmeancurvemean = ((meancurvemean(lc, :, m) - vshift(lc, thisinter, m, amInterventions.Offset(thisinter) + 1)) * normstd(thisinter, m)) + normmean(thisinter, m)  ;
            %adjmeancurvemean = (meancurvemean(lc, :, m) * normstd(thisinter, m)) + normmean(thisinter, m)  ;
        else
            adjmeancurvemean =  meancurvemean(lc, :, m) - vshift(lc, thisinter, m, amInterventions.Offset(thisinter) + 1) + normmean(thisinter, m) ;
            %adjmeancurvemean =  meancurvemean(lc, :, m) + normmean(thisinter, m) ;
        end
    else
        adjmeasdata = amIntrcube(thisinter, :, m) + vshift(lc, thisinter, m, amInterventions.Offset(thisinter) + 1);
        adjmeancurvemean = meancurvemean(lc, :, m);
    end
    
    % initialise plot areas
    xl = [0 0];
    yl = [min(adjmeancurvemean(1:max_offset + align_wind - 1 - amInterventions.Offset(thisinter)) * .99) ...
          max(adjmeancurvemean(1:max_offset + align_wind - 1 - amInterventions.Offset(thisinter)) * 1.01)];
    if yl(1) == yl(2)
        rangelimit = setMinYDisplayRangeForMeasure(measures.Name{m});
        yl(1) = yl(1) - rangelimit * 0.5;
        yl(2) = yl(2) + rangelimit * 0.5;
    end
    
    % create subplot and plot required data arrays
    ax = subplot(plotsdown, plotsacross, mpos(m,:), 'Parent',p);               
    %[xl, yl] = plotMeasurementData(ax, dayset, amIntrcube(thisinter, :, m), xl, yl, measures(m,:), [0, 0.65, 1], '-', 1.0, 'o', 2.0, 'blue', 'green');
    [xl, yl] = plotMeasurementData(ax, dayset, adjmeasdata, xl, yl, measures(m,:), [0, 0.65, 1], '-', 1.0, 'o', 2.0, 'blue', 'green');
    
    if normmode == 1
        [xl, yl] = plotHorizontalLine(ax, normmean(thisinter, m), xl, yl, 'blue', '--', 0.5); % plot stable mean
    end
    
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, amInterventions.Offset(thisinter), adjmeancurvemean, xl, yl, 'red', ':', 1.0, anchor);
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, amInterventions.Offset(thisinter), smooth(adjmeancurvemean,5), xl, yl, 'red', '-', 1.0, anchor);

    [xl, yl] = plotExStart(ax, ex_start, amInterventions.Offset(thisinter), xl, yl,  'black', '-', 0.5);            
    [xl, yl] = plotVerticalLine(ax, 0, xl, yl, 'cyan', '-', 0.5); % plot treatment start
    
    %plotOutlierDataPoints(ax, dayset, amIntrcube(thisinter, :, m), isOutlier(lc, thisinter, :, m, amInterventions.Offset(thisinter) + 1), ...
    %    max_offset, align_wind, [0, 0.65, 1], 'none', 1.0, 'o', 4.0, 'red', 'yellow');
    plotOutlierDataPoints(ax, dayset, adjmeasdata, isOutlier(lc, thisinter, :, m, amInterventions.Offset(thisinter) + 1), ...
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
    [xl2, yl2] = plotProbDistribution(ax2, max_offset, pdoffset(lc, m, thisinter,:), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');
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
        title(sprintf('%s (%.1f)', measures.DisplayName{m}, hstg(lc, m, thisinter, amInterventions.Offset(thisinter) + 1)), 'BackgroundColor', 'g');
    else
        title(sprintf('%s (%.1f)', measures.DisplayName{m}, hstg(lc, m, thisinter, amInterventions.Offset(thisinter) + 1)));
    end
                    
end

% plot the overall posterior distributions
xl2 = [0 max_offset-1];
yl2 = [0 0.25];
ax2 = subplot(plotsdown, plotsacross, hpos(nmeasures + 1,:),'Parent',p); 
[xl2, yl2] = plotProbDistribution(ax2, max_offset, overall_pdoffset(lc, thisinter, :), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');                
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
title(sprintf('Overall (%.1f)', overall_hist(lc, thisinter, amInterventions.Offset(thisinter) + 1)), 'BackgroundColor', 'g');

infostring = [ {sprintf('Latent Curve Set:             %11d', lc)} ; ...
               {sprintf('Treatment Date:               %11s', datestr(amInterventions.IVStartDate(thisinter), 1))} ; ...
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
                'BackgroundColor', 'white', ...
                'String', infostring);
            
% save plot
savePlotInDir(f, name, plotsubfolder);
close(f);

end
