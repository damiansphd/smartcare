function amEMPlotAndSaveAlignedCurves(profile_pre, meancurvemean, meancurvecount, meancurvestd, offsets, ...
    measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, sigmamethod, plotname, plotsubfolder)

% amEMPlotAndSaveAlignedCurves - plots the curves pre and post alignment for
% each measure, and the histogram of offsets

if (nmeasures + 1) <= 9
    plotsacross = 3;
else
    plotsacross = 4;
end
plotsdown = ceil((nmeasures + 1) / plotsacross);

plottitle = sprintf('%s - %s', plotname, run_type);
anchor = 1; % latent curve is to be anchored on the plot (right side at min_offset)

[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');

for m = 1:nmeasures    
    subplottitle = measures.DisplayName{m};
    ax = subplot(plotsdown,plotsacross,m,'Parent',p);
    amEMPlotAlignedCurve(ax, profile_pre(:, m), meancurvemean(:, m), meancurvecount(:, m), meancurvestd(:, m), ...
        measures(m, :), max_points, min_offset, max_offset, align_wind, run_type, ex_start, sigmamethod, anchor, subplottitle); 
end

ax = subplot(plotsdown, plotsacross, nmeasures + 1, 'Parent', p);
amEMPlotOffsetHistogram(ax, offsets, max_offset);

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
close(f);

% thesis - extra plot of just two measures + offset histogram
plotsdown = 1;
plotsacross = 3;
plottitle = sprintf('%s - %s - Subset', plotname, run_type);
pghght = 2.75;
pgwdth = 7.5;
[f, p] = createFigureAndPanelForPaper('', pgwdth, pghght);
thisplot = 1;
for m = 1:nmeasures
    if ismember(measures.DisplayName(m), {'LungFunction', 'Wellness'})
        subplottitle = measures.DisplayName{m};
        ax = subplot(plotsdown, plotsacross, thisplot,'Parent',p);
        amEMPlotAlignedCurve(ax, profile_pre(:, m), meancurvemean(:, m), meancurvecount(:, m), meancurvestd(:, m), ...
            measures(m, :), max_points, min_offset, max_offset, align_wind, run_type, ex_start, sigmamethod, anchor, subplottitle);
        thisplot = thisplot + 1;
    end
end

ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
amEMPlotOffsetHistogram(ax, offsets, max_offset);

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
close(f);

% thesis - extra plot of just the offset histogram

plotsdown = 1;
plotsacross = 1;
plottitle = sprintf('%s - %s - OffsetHistogram', plotname, run_type);
pghght = 5;
pgwdth = 4;
[f, p] = createFigureAndPanelForPaper('', pgwdth, pghght);
thisplot = 1;
ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
amEMPlotOffsetHistogram(ax, offsets, max_offset);

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
close(f);


end

