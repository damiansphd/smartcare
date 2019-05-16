function amEMMCPlotAlignedCurvesSideBySide(profile_pre, meancurvemean, meancurvecount, meancurvestd, offsets, latentcurve, ...
    measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, sigmamethod, plotname, plotsubfolder, nlatentcurves)

% amEMPlotAlignedCurvesSideBySide - for 2 or 3 sets of latent curves, plots
% them side by side (by measure)

anchor = 1; % latent curve is to be anchored on the plot (right side at min_offset)

if nlatentcurves > 4
    fprintf('Up to 3 sets of latent curves supported with this plot\n');
    return;
elseif nlatentcurves == 4
    plotsacross = 4;
    plotsdown   = 3;
elseif nlatentcurves == 3
    plotsacross = 3;
    plotsdown   = 3;
else
    plotsacross = 4;
    plotsdown   = 4;
end

thisplot = 1;
thispage = 1;
npages = ceil((nlatentcurves * (nmeasures + 1)) / (plotsacross * plotsdown));
if npages == 1
    plottitle = sprintf('%s - %s SideBySide', plotname, run_type);
else
    plottitle = sprintf('%s - %s SideBySide Pg%dof%d', plotname, run_type, thispage, npages);
end
[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');


for m = 1:nmeasures
    yl = [min(min(meancurvemean(:, :, m) - meancurvestd(:, :, m))), max(max(meancurvemean(:, :, m) + meancurvestd(:, :, m)))];
    if yl(1) < 0
        yl(1) = yl(1) * 1.01;
    else
        yl(1) = yl(1) * .99;
    end
    if yl(2) > 0
        yl(2) = yl(2) * 1.01;
    else
        yl(2) = yl(2) * .99;
    end
    for n = 1:nlatentcurves
        subplottitle = sprintf('%s: C%d', measures.DisplayName{m}, n);
        ax = subplot(plotsdown,plotsacross,thisplot,'Parent',p);
        amEMPlotAlignedCurve(ax, profile_pre(n, :, m), meancurvemean(n, :, m), meancurvecount(n, :, m), meancurvestd(n, :, m), ...
            measures(m, :), max_points(n, :), min_offset, max_offset, align_wind, run_type, ex_start(n), sigmamethod, anchor, subplottitle);
        yyaxis left;
        ylim(ax, yl);
        thisplot = thisplot + 1;
        if thisplot > (plotsacross * plotsdown)
            thispage = thispage + 1;
            thisplot = 1;
            savePlotInDir(f, plottitle, plotsubfolder);
            close(f);
            plottitle = sprintf('%s - %s SideBySide Pg%dof%d', plotname, run_type, thispage, npages);
            [f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');
        end
    end
end

for n = 1:nlatentcurves
    ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
    amEMPlotOffsetHistogram(ax, offsets(latentcurve == n), max_offset);
    thisplot = thisplot + 1;
    if thisplot > (plotsacross * plotsdown)
        thispage = thispage + 1;
        thisplot = 1;
        savePlotInDir(f, plottitle, plotsubfolder);
        close(f);
        plottitle = sprintf('%s - %s SideBySide Pg%dof%d', plotname, run_type, thispage, npages);
        [f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');
    end
end

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
close(f);

end

