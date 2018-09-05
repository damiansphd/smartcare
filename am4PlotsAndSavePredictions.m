function am4PlotsAndSavePredictions(amInterventions, amIntrDatacube, measures, pdoffset, overall_pdoffset, ...
    overall_pdoffset_all, overall_pdoffset_xAL, hstg, overall_hist, overall_hist_all, overall_hist_xAL, offsets, ...
    meancurvemean, normmean, ex_start, thisinter, nmeasures, max_offset, align_wind, study, version)

% am4PlotsAndSavePredictions - plots measures prior to
% treatment with alignment model predictions and overlaid with the mean
% curve for visual comparison, as well as plots of the posterior
% probability distributions by measure

plotsdown = 9;
plotsacross = 5;
mpos = [ 1 2 6 7 ; 3 4 8 9 ; 11 12 16 17 ; 13 14 18 19 ; 21 22 26 27 ; 23 24 28 29 ; 31 32 36 37 ; 33 34 38 39];
hpos = [ 5 ; 10 ; 15 ; 20 ; 25 ; 30 ; 35 ; 40 ; 45 ; 44 ; 43 ; 42 ; 41 ];
days = [-1 * (max_offset + align_wind - 1): -1];
anchor = 0; % latent curve is to be shifted by offset on the plot

scid = amInterventions.SmartCareID(thisinter);
name = sprintf('%s_AM%s Exacerbation %d - ID %d Date %s, Offset %d', study, version, thisinter, scid, datestr(amInterventions.IVStartDate(thisinter),29), offsets(thisinter));
fprintf('%s - Best Offset = %d\n', name, offsets(thisinter));

[f, p] = createFigureAndPanel(name, 'portrait', 'a4');

for m = 1:nmeasures
    if all(isnan(amIntrDatacube(thisinter, :, m)))
        continue;
    end
    % initialise plot areas
    xl = [0 0];
    yl = [min((meancurvemean(1:max_offset + align_wind - 1 - offsets(thisinter), m) + normmean(thisinter, m)) * .99) ...
          max((meancurvemean(1:max_offset + align_wind - 1 - offsets(thisinter), m) + normmean(thisinter, m)) * 1.01)];
    
    % create subplot and plot required data arrays
    ax = subplot(plotsdown, plotsacross, mpos(m,:), 'Parent',p);               
    [xl, yl] = plotMeasurementData(ax, days, amIntrDatacube(thisinter, :, m), xl, yl, measures(m,:), [0, 0.65, 1], '-', 1.0, 'o', 2.0, 'blue', 'green');
    [xl, yl] = plotHorizontalLine(ax, normmean(thisinter, m), xl, yl, 'blue', '--', 0.5); % plot mean
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, offsets(thisinter), (meancurvemean(:, m) + normmean(thisinter, m)), xl, yl, 'red', ':', 1.0, anchor);
    [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, offsets(thisinter), smooth(meancurvemean(:, m) + normmean(thisinter, m),5), xl, yl, 'red', '-', 1.0, anchor);
    [xl, yl] = plotExStart(ax, ex_start, offsets(thisinter), xl, yl,  'green', '-', 0.5);            
    [xl, yl] = plotVerticalLine(ax, 0, xl, yl, 'cyan', '-', 0.5); % plot treatment start
                    
    xl2 = [0 max_offset-1];
    yl2 = [0 0.25];            
    ax2 = subplot(plotsdown, plotsacross, hpos(m,:),'Parent',p);           
    [xl2, yl2] = plotProbDistribution(ax2, max_offset, pdoffset(m, thisinter,:), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');
    [xl2, yl2] = plotVerticalLine(ax2, offsets(thisinter), xl2, yl2, 'green', '-', 0.5); % plot predicted offset
                    
    set(gca,'fontsize',6);
    if measures.Mask(m) == 1
        title(sprintf('%s (%.1f)', measures.DisplayName{m}, hstg(m, thisinter, offsets(thisinter) + 1)), 'BackgroundColor', 'g');
    else
        title(sprintf('%s (%.1f)', measures.DisplayName{m}, hstg(m, thisinter, offsets(thisinter) + 1)));
    end
                    
end

% plot the overall posterior distributions
xl2 = [0 max_offset-1];
yl2 = [0 0.25];
ax2 = subplot(plotsdown, plotsacross, hpos(nmeasures + 1,:),'Parent',p); 
[xl2, yl2] = plotProbDistribution(ax2, max_offset, overall_pdoffset(thisinter,:), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');                
[xl2, yl2] = plotVerticalLine(ax2, offsets(thisinter), xl2, yl2, 'green', '-', 0.5); % plot predicted offset
set(gca,'fontsize',6);
title(sprintf('Overall (%.1f)', overall_hist(thisinter, offsets(thisinter) + 1)), 'BackgroundColor', 'g');

xl2 = [0 max_offset-1];
yl2 = [0 0.25];
ax2 = subplot(plotsdown, plotsacross, hpos(nmeasures + 2,:),'Parent',p); 
[xl2, yl2] = plotProbDistribution(ax2, max_offset, overall_pdoffset_all(thisinter,:), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');                
[xl2, yl2] = plotVerticalLine(ax2, offsets(thisinter), xl2, yl2, 'green', '-', 0.5); % plot predicted offset
set(gca,'fontsize',6);
title(sprintf('Overall - All (%.1f)', overall_hist_all(thisinter, offsets(thisinter) + 1)));

xl2 = [0 max_offset-1];
yl2 = [0 0.25];
ax2 = subplot(plotsdown, plotsacross, hpos(nmeasures + 3,:),'Parent',p); 
[xl2, yl2] = plotProbDistribution(ax2, max_offset, overall_pdoffset_xAL(thisinter,:), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');                
[xl2, yl2] = plotVerticalLine(ax2, offsets(thisinter), xl2, yl2, 'green', '-', 0.5); % plot predicted offset
set(gca,'fontsize',6);
title(sprintf('Overall - xAL (%.1f)', overall_hist_xAL(thisinter, offsets(thisinter) + 1)));

% save plot
savePlot(f, name);
close(f);

end
