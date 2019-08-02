function amEMMCPlotProbsLCSet(overall_pdoffset, amInterventions, min_offset, max_offset, plotname, plotsubfolder, ninterventions, nlatentcurves)


% amEMMCPlotProbsLCSet - plots the probabilities of respective LC set
% assignment for all interventions.

sumpdoffset = sum(overall_pdoffset(:, :, (min_offset+1:max_offset)), 3)';

plotsdown   = 2; 
plotsacross = 2;
pointsize = 36 * ones(ninterventions, 1);
if nlatentcurves >= 1
    cmap = [ 0.4, 0.8, 0.2 ];
end
if nlatentcurves >= 2
    cmap(2,:) = [ 0, 0, 1 ];
end
if nlatentcurves >= 3
    cmap(3,:) = [ 1, 0, 0 ];
end
if nlatentcurves >= 4
    cmap(4,:) = [ 1 0 1 ];
end
if nlatentcurves >= 5
    fprintf('Add more colours to the palette\n');
    return;
end

plottitle = sprintf('%s - Probs for LC Set', plotname);
[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');

ax = subplot(plotsdown, plotsacross, 1, 'Parent',p);
h = scatter3(sumpdoffset(:, 1), sumpdoffset(:, 2), sumpdoffset(:, 3), pointsize, cmap(amInterventions.LatentCurve,:), 'MarkerFaceColor', 'auto', 'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1);

ax = subplot(plotsdown, plotsacross, 2, 'Parent',p);
scatter(sumpdoffset(:, 1), sumpdoffset(:, 2), pointsize, cmap(amInterventions.LatentCurve,:), 'MarkerFaceColor', 'auto', 'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1);

if nlatentcurves == 3
    ax = subplot(plotsdown, plotsacross, 3, 'Parent',p);
    
    projpts = zeros(ninterventions, 2);

    for i = 1:ninterventions
        projpts(i, 1) = (sumpdoffset(i, 2) - sumpdoffset(i, 1)) * cos(pi * (30/180));
        projpts(i, 2) = sumpdoffset(i, 3) - ((sumpdoffset(i, 1) + sumpdoffset(i, 2)) * sin(pi * (30/180)));
    end
    
    scatter(projpts(:,1), projpts(:,2), pointsize, cmap(amInterventions.LatentCurve,:), 'filled', ...
       'MarkerFaceColor', 'auto', 'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1);
    
end

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
close(f);


end

