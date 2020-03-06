function amEMMCPlotSuperimposedAlignedCurves(meancurvemean, meancurvecount, amInterventions, ...
    measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, countthreshold, compactplot, shiftmode, study)

% amEMMCPlotSuperimposedAlignedCurves - wrapper around the
% plotSuperimposedAlignedCurves to plot for each set of latent curves

invmeasarray = getInvertedMeasures(study);

if shiftmode == 1
    shifttext = 'MeanShift';
elseif shiftmode == 2
    shifttext = 'MaxShift';
elseif shiftmode == 3
    shifttext = 'ExZeroShift';
elseif shiftmode == 4
    meanwindow = 7;
    shifttext = sprintf('%ddMeanShift', meanwindow);
else
    fprintf('**** Unknown shift mode ****\n');
end

plottitle   = sprintf('%s - %s Superimposed %s', plotname, run_type, shifttext);

if compactplot
    plotsacross = 2;
    plotsdown   = 2;
    [f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');
    posarray = [0.7, 0.1, 0.2, 0.2];
else
    plotsacross = 1;
    plotsdown   = 1;
    posarray    = [0.2, 0.2, 0.2, 0.2]
end

smoothwdth = 4;

% Preprocess the latent curve :-
% 1) invert pulse rate
% 2) remove points with fewer than count threshold underlying data poins
% contributing
% 3) apply mean smoothing
% 4) apply a vertical shift (by the average of the points to the left of
% ex_start)
for n = 1:nlatentcurves
    pridx = ismember(measures.DisplayName, invmeasarray);
    meancurvemean(n, :, pridx) = meancurvemean(n, :, pridx) * -1;
    for m = 1:nmeasures
        meancurvemean(n, meancurvecount(n, :, m) < countthreshold, m) = NaN;
        meancurvemean(n, :, m) = movmean(meancurvemean(n, :, m), smoothwdth, 'omitnan');
        if shiftmode == 1
            vertshift = mean(meancurvemean(n, 1:(align_wind + max_offset + ex_start(n)), m));
        elseif shiftmode == 2
            vertshift = max(meancurvemean(n, 1:(align_wind + max_offset + ex_start(n)), m));
        elseif shiftmode == 3
            vertshift = meancurvemean(n, (align_wind + max_offset + ex_start(n)), m);
        elseif shiftmode == 4
            vertshift = mean(meancurvemean(n, (align_wind + max_offset + ex_start(n) - meanwindow):(align_wind + max_offset + ex_start(n)), m));
        end
        meancurvemean(n, :, m) = meancurvemean(n, :, m) - vertshift;
        fprintf('For curve %d and measure %13s, vertical shift is %.3f\n', n, measures.DisplayName{m}, -vertshift);
    end
end

% set the plot range over all curves to ensure comparable visual scaling
xfrom = -1 * (align_wind + max_offset - 1 + ex_start);
xto   = -1 * (1 + ex_start);
xl = [xfrom, xto];
%xl = [((-1 * (max_offset + align_wind)) + 1 - 0.5), -0.5];
yl = [min(min(min(meancurvemean))) ...
      max(max(max(meancurvemean)))];

% for each curve, plot all measures superimposed
for n = 1:nlatentcurves
    xfrom = -1 * (align_wind + max_offset - 1 + ex_start(n));
    xto   = -1 * (1 + ex_start(n));
    xl = [xfrom, xto];
    tmp_meancurvemean  = reshape(meancurvemean(n, :, :),  [max_offset + align_wind - 1, nmeasures]);
    %tmp_meancurvecount = reshape(meancurvecount(n, :, :), [max_offset + align_wind - 1, nmeasures]);
    tmp_ninterventions   = sum(amInterventions.LatentCurve == n);
    
    if tmp_ninterventions ~= 0
        if compactplot
            ax = subplot(plotsdown, plotsacross, n, 'Parent',p);
        else
            plottitle   = sprintf('%s - %s Superimposed %s C%d', plotname, run_type, shifttext, n);
            [f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');
            ax = subplot(plotsdown, plotsacross, 1, 'Parent',p);
        end
        plotSuperimposedAlignedCurves(ax, tmp_meancurvemean, xl, yl, ...
                measures, min_offset, max_offset, align_wind, ex_start(n), n, sum(amInterventions.LatentCurve == n), invmeasarray, posarray);
        if ~compactplot
            % save plot
            savePlotInDir(f, plottitle, plotsubfolder);
            savePlotInDirAsSVG(f, plottitle, plotsubfolder);
            close(f);
        end
    end
end

if compactplot
    % save plot
    savePlotInDir(f, plottitle, plotsubfolder);
    savePlotInDirAsSVG(f, plottitle, plotsubfolder);
    close(f);
end

end
