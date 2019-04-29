function amEMMCPlotFEV1VsLatentCurveSet(amInterventions, initial_latentcurve, pmPatientMeasStats, ...
        measures, plotname, plotsubfolder, nlatentcurves)
    
% amEMMCPlotFEV1VsLatentCurveSet - plots the robust FEV1 max vs the latent
% curve set allocated from the model run

plotsacross = 1;
plotsdown   = 2;
pointsize = 36;
if nlatentcurves == 2
    cmap = [0, 1, 0 ; 0, 0, 1 ];
elseif nlatentcurves == 3
    cmap = [0, 1, 0 ; 0, 0, 1 ; 1, 0, 0 ];
else
    fprintf('Add more colours to the palette\n');
end

plottitle = sprintf('%s - FEV1 vs Latent Curve Set', plotname);
[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');
colormap(f, cmap);

amInterventions.InitialLC = initial_latentcurve;

mfev1idx  = measures.Index(ismember(measures.DisplayName, 'LungFunction'));
fev1max  = pmPatientMeasStats(pmPatientMeasStats.MeasureIndex == mfev1idx, {'PatientNbr', 'Study', 'ID', 'RobustMax'});
fev1max = sortrows(fev1max, {'Study', 'ID'}, 'ascend');
lc = innerjoin(amInterventions, fev1max, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'}, 'LeftVariables', {'SmartCareID', 'LatentCurve', 'InitialLC'}, 'RightVariables', {'RobustMax'});

thisplot    = 1;
ax = subplot(plotsdown,plotsacross,thisplot,'Parent',p);
scatter(ax, lc.InitialLC, lc.RobustMax, pointsize, lc.InitialLC, 'MarkerFaceAlpha', 0.3);
title(ax, 'Initial State', 'FontSize', 8);
xlim(ax, [0 nlatentcurves + 1]);
xlabel(ax, 'Latent Curve Set');
ylabel(ax, 'Patient FEV1 Robust Max');

thisplot = thisplot + 1; 
ax = subplot(plotsdown,plotsacross,thisplot,'Parent',p);
scatter(ax, lc.LatentCurve, lc.RobustMax, pointsize, lc.LatentCurve, 'MarkerFaceAlpha', 0.3);
title(ax, 'Final State', 'FontSize', 8);
xlim(ax, [0 nlatentcurves + 1]);
xlabel(ax, 'Latent Curve Set');
ylabel(ax, 'Patient FEV1 Robust Max');

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
close(f);

end

