function amEMMCPlotHistogramOfTimeToTreatForPaper(amInterventions, plotname, plotsubfolder, nlatentcurves, study)

% amEMMCPlotHistogramOfTimeToTreatForPaper - plots a historgram of the time
% to treatment over all interventions (diff between pred and treat start)

plottitle   = sprintf('%s - Histogram of Time to Treat For Paper', plotname);

pghght = 5;
pgwdth = 8;

[f, p] = createFigureAndPanelForPaper('', pgwdth, pghght);

temp = amInterventions(:, {'SmartCareID', 'IVScaledDateNum', 'Pred'});
temp.TimeToTreat = temp.IVScaledDateNum - temp.Pred;

binedges = [0, 4, 8, 12, 16, 20, 24, 28, 32];

ax = subplot(1, 1, 1,'Parent', p);
histogram(ax, temp.TimeToTreat, 'BinEdges', binedges, 'LineWidth', 1);
ax.XLim = [0, 32];
ax.XTick = [2, 6, 10, 14, 18, 22, 26, 30];
xlabel(ax, 'Days to Treatment');
ylabel(ax, 'Number of Exacerbations');
ax.FontSize = 14;
ax.FontWeight = 'bold';

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
savePlotInDirAsSVG(f, plottitle, plotsubfolder);
close(f);

end
