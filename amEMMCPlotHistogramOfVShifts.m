function amEMMCPlotHistogramOfVShifts(amInterventions, vshift, measures, nmeasures, ninterventions, nlatentcurves, plotname, plotsubfolder, vshiftmode, vshiftmax)

% amEMMCPlotHistogramOfVShifts - plot a histogram of the vertical shifts
% for a given model run, for each latent curve set, by measure and overall

vshiftfin = zeros(nlatentcurves, ninterventions, nmeasures);

for lc = 1:nlatentcurves
    for i = 1:ninterventions
        for m = 1:nmeasures
            vshiftfin(lc, i, m) = vshift(lc, i, m, amInterventions.Offset(i) + 1);
        end
    end
end

if vshiftmax >= 10
    nbins = 100;
elseif vshiftmax >=1
    nbins = vshiftmax * 10;
else
    nbins = 10;
end
nplots = nmeasures + 1;
plotsacross = 3;
plotsdown = ceil(nplots / plotsacross);
edges = -vshiftmax:(2 * vshiftmax) / nbins:vshiftmax;

for lc = 1:nlatentcurves
    plottitle   = sprintf('%s - V-Shift Histograms C%d', plotname, lc);
    [f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');
    
    for m = 1:nmeasures
        ax = subplot(plotsdown, plotsacross, m, 'Parent', p);
        h = histogram(ax, vshiftfin(lc, :, m), edges);
        title(ax, measures.DisplayName{m});
        xlabel(ax, 'Vertical Shift');
        ylabel(ax, 'Count');
    end
    m = m + 1;
    ax = subplot(plotsdown, plotsacross, m, 'Parent', p);
    h = histogram(ax, vshiftfin(lc, :, :), edges);
    title(ax, 'Overall');
    xlabel(ax, 'Vertical Shift');
    ylabel(ax, 'Count');
    
    % save plot
    savePlotInDir(f, plottitle, plotsubfolder);
    close(f);
end

