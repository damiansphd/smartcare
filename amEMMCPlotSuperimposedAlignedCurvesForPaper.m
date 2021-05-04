function amEMMCPlotSuperimposedAlignedCurvesForPaper(meancurvemean, meancurvecount, amIntrNormcube, amInterventions, ...
    measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, ...
    countthreshold, shiftmode, study, examplemode, lcexamples)

% amEMMCPlotSuperimposedAlignedCurves - wrapper around the
% plotSuperimposedAlignedCurves to plot for each set of latent curves

invmeasarray = getInvertedMeasures(study);

% latest format changes have broken examplemode ~= 0
if examplemode ~= 0
    if (size(lcexamples, 2) ~= nlatentcurves)
        fprintf('**** Number of latent curve examples in each set does not match the number of latent curve sets ****\n');
        return;
    end
end

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

plottitle   = sprintf('%s - %s S-imp %s FP pc%d', plotname, run_type, shifttext, countthreshold);

plotsacross = nlatentcurves;
plotsdown   = 1;
plotpanels = 5;
legendpanels = 4;
if nlatentcurves == 1
    paddingpanels = 0;
else
    paddingpanels = 1;
end
panelsacross = ((plotpanels + paddingpanels) * nlatentcurves) + legendpanels;

nplotrows = 1 + size(lcexamples, 1);

labelfontsize = 8;
fontname = 'Arial';
pghght = 3 * nplotrows;
pgwdth = 0.5 * (panelsacross + 3);
labelwidth = 0.15;
plotwidth  = 0.85;

titlexpos = 0.5;
titleypos = -0.24;

[f, p] = createFigureAndPanelForPaper('', pgwdth, pghght);

displaytext1 = sprintf('%s', 'Change from');
displaytext2 = sprintf('%s', 'stable baseine');
displaytext3 = sprintf('%s', '(s.d.)');
displaytext = {displaytext1; displaytext2; displaytext3};

sp(1) = uipanel('Parent', p, ...
                'BorderType', 'none', ...
                'BackgroundColor', 'white', ...
                'OuterPosition', [0, 0, labelwidth, 1]);
annotation(sp(1), 'textbox',  ...
                'String', displaytext, ...
                'Interpreter', 'tex', ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1], ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'LineStyle', 'none', ...
                'FontName', fontname, ...
                'FontSize', labelfontsize);
            
sp(2) = uipanel('Parent', p, ...
                'BorderType', 'none', ...
                'BackgroundColor', 'white', ...
                'OuterPosition', [labelwidth, 0, plotwidth, 1]);

smoothwdth = 4;

% Preprocess the latent curve :-
% 1) invert pulse rate
% 2) remove points with fewer than count threshold underlying data poins
% contributing
% 3) apply mean smoothing
% 4) apply a vertical shift (by the average of the points to the left of
% ex_start)


for n = 1:nlatentcurves
    pridx = measures.Index(ismember(measures.DisplayName, invmeasarray));
    meancurvemean(n, :, pridx) = meancurvemean(n, :, pridx) * -1;
    for m = 1:nmeasures
        %meancurvemean(n, meancurvecount(n, :, m) < countthreshold, m) = NaN;
        %meancurvemean(n, :, m) = movmean(meancurvemean(n, :, m), smoothwdth, 'omitnan');
        meancurvemean(n, :, m) = movmean(meancurvemean(n, :, m), smoothwdth, 'includenan');
        meancurvemean(n, meancurvecount(n, :, m) < countthreshold, m) = NaN;
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

lcsort = getLCSortOrder(amInterventions, nlatentcurves);

% set the plot range over all curves to ensure comparable visual scaling
yl = [min(min(min(meancurvemean))) ...
      max(max(max(meancurvemean)))];

% for each curve, plot all measures superimposed
for n = 1:nlatentcurves
    lc = lcsort(n);
    xfrom = -1 * (align_wind + max_offset - 1 + ex_start(lc));
    xto   = -1 * (1 + ex_start(lc));
    xl = [xfrom, xto];
    tmp_meancurvemean  = reshape(meancurvemean(lc, :, :),  [max_offset + align_wind - 1, nmeasures]);
    tmp_ninterventions   = sum(amInterventions.LatentCurve == lc);
    
    if tmp_ninterventions ~= 0
        if n == nlatentcurves
            panels = (((n - 1) * (plotpanels + paddingpanels)) + 1): (((n - 1) * (plotpanels + paddingpanels)) + plotpanels + legendpanels);
        else
            panels = (((n - 1) * (plotpanels + paddingpanels)) + 1): (((n - 1) * (plotpanels + paddingpanels)) + plotpanels);
        end
        ax = subplot(nplotrows, panelsacross, panels, 'Parent',sp(2));
        ax.FontSize = 8;
        ax.FontName = 'Arial';
        ax.TickDir = 'out';
        
        % comment out/uncomment out one of these depending on whether all measures
        % wanted or just those used for alignment
        %tmpmeasures = measures;
        tmpmeasures = sortMeasuresForPaper(study, measures(logical(measures.Mask), :));
        tmpnmeasures = size(tmpmeasures, 1);

         % add legend text cell array
        legendtext = tmpmeasures.DisplayName;
        for m = 1:tmpnmeasures
            legendtext{m} = formatDisplayMeasure(legendtext{m});
        end
        pridx = ismember(tmpmeasures.DisplayName, invmeasarray);
        if sum(pridx) > 0
            % need to edit this now there are multiple inverted measures
            for i = 1:size(legendtext, 1)
                if pridx(i) == 1
                    legendtext{i} = sprintf('%s %s', legendtext{i}, '(Inverted)');
                end
            end
        end
        
        plotSuperimposedAlignedCurvesForPaper(ax, tmp_meancurvemean, xl, yl, ...
                tmpmeasures, tmpnmeasures, min_offset, max_offset, align_wind, ex_start(lc), study);

        xlabel(ax, 'Days from exacerbation start');
        ylabelposmult = 1.1;
        if n == 1
            %ylabeltext = 'Change from stable baseline (s.d.)';
            %ylabel(ax, ylabeltext, 'Position',[(xl(1) - 12) (yl(1) + (yl(2) - yl(1) * ylabelposmult))], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Rotation', 0);
        else
            ax.YTickLabel = '';
            ax.YColor = 'white';
        end
        if n == nlatentcurves
            legend(ax, legendtext, 'Location', 'eastoutside', 'FontSize', 6);
        end
        if nlatentcurves > 1
            title(ax, sprintf('Group %d (n = %d)', n, sum(amInterventions.LatentCurve == lc)), 'Units', 'normalized', 'Position', [titlexpos, titleypos, 0]);
        end
    end
end

% now plot examples for each latent curve set
for row = 1:size(lcexamples, 1)
    lcexrow = lcexamples(row, lcsort);
    
    for n = 1:nlatentcurves
        i = lcexrow(n);
        amnormcubesingleintr = amIntrNormcube(i, :, :);
        aminterventionsrow   = amInterventions(i, :);
        lc = aminterventionsrow.LatentCurve;
        if lc ~= lcsort(n)
            fprintf('**** Example is from a different sub-population than the latent curve ****');
            return;
        end
        amnormcubesingleintrsmth = amnormcubesingleintr;
        tmp_ex_start = ex_start(lc);
        tmp_offset   = aminterventionsrow.Offset;
        
        
        % Preprocess the measures :-
        % 1) invert pulse rate
        % 2) apply a vertical shift (using methodology selected)
        pridx = ismember(measures.DisplayName, {'PulseRate'});
        amnormcubesingleintr(1, :, pridx) = amnormcubesingleintr(1, :, pridx) * -1;
        for m = 1:nmeasures
            actx = find(~isnan(amnormcubesingleintr(1, :, m)));
            acty = amnormcubesingleintr(1, ~isnan(amnormcubesingleintr(1, :, m)), m);
            fullx = (1:size(amnormcubesingleintr(1, :, m), 2));
            amnormcubesingleintr(1, :, m) = interp1(actx, acty, fullx, 'linear');
            amnormcubesingleintrsmth(1, :, m) = movmean(amnormcubesingleintr(1, :, m), smoothwdth, 'omitnan');
            
            if all(isnan(amnormcubesingleintrsmth(1, 1:(align_wind + max_offset + tmp_ex_start + tmp_offset), m)))
                    vertshift = 0;
            else
                if shiftmode == 1
                    vertshift = mean(amnormcubesingleintrsmth(1, 1:(align_wind + max_offset + tmp_ex_start + tmp_offset), m), 'omitnan');
                elseif shiftmode == 2
                    vertshift = max(amnormcubesingleintrsmth(1, 1:(align_wind + max_offset + tmp_ex_start + tmp_offset), m), 'omitnan');
                elseif shiftmode == 3
                    vertshift = amnormcubesingleintrsmth(1, find(~isnan(amnormcubesingleintrsmth(1, 1:(align_wind + max_offset + tmp_ex_start + tmp_offset), m)), 1, 'last'), m);
                elseif shiftmode == 4
                    vertshift = mean(amnormcubesingleintrsmth(1, (align_wind + max_offset + tmp_ex_start + tmp_offset - meanwindow):(align_wind + max_offset + tmp_ex_start + tmp_offset), m), 'omitnan');
                end
            end
            amnormcubesingleintr(1, :, m) = amnormcubesingleintr(1, :, m) - vertshift;
            amnormcubesingleintrsmth(1, :, m) = amnormcubesingleintrsmth(1, :, m) - vertshift;
            fprintf('For intervention %3d, measure %13s, vertical shift is %.3f\n', i, measures.DisplayName{m}, -vertshift);
        end
        
        xfrom = -1 * (align_wind + max_offset - 1 + ex_start(lc));
        xto   = -1 * (1 + ex_start(lc));
        xl = [xfrom, xto];
        
        %yl = [min(min(amnormcubesingleintrsmth(1, :, logical(measures.Mask)))) ...
        %      max(max(amnormcubesingleintrsmth(1, :, logical(measures.Mask))))];
        yl = [-4, 2.75];

        tmp_amnormcubesingleintr  = reshape(amnormcubesingleintr(1, :, :),  [max_offset + align_wind - 1, nmeasures]);
        tmp_amnormcubesingleintrsmth  = reshape(amnormcubesingleintrsmth(1, :, :),  [max_offset + align_wind - 1, nmeasures]);
 
        if n == nlatentcurves
            panels = (((n - 1) * (plotpanels + paddingpanels)) + 1): (((n - 1) * (plotpanels + paddingpanels)) + plotpanels + legendpanels);
            
        else
            panels = (((n - 1) * (plotpanels + paddingpanels)) + 1): (((n - 1) * (plotpanels + paddingpanels)) + plotpanels);
        end
        panels = panels + row * panelsacross;
        
        % plot all measures superimposed
        ax = subplot(nplotrows, panelsacross, panels, 'Parent',p);
        ax.FontSize = 8;
        ax.FontName = fontname;
        ax.TickDir = 'out';
        
        % comment out/uncomment out one of these depending on whether all measures
        % wanted or just those used for alignment
        %tmpmeasures = measures;
        tmpmeasures = sortMeasuresForPaper(study, measures(logical(measures.Mask), :));
        tmpnmeasures = size(tmpmeasures, 1);

         % add legend text cell array
        legendtext = tmpmeasures.DisplayName;
        for m = 1:tmpnmeasures
            legendtext{m} = formatDisplayMeasure(legendtext{m});
        end
        pridx = ismember(tmpmeasures.DisplayName, invmeasarray);
        if sum(pridx) > 0
            % need to edit this now there are multiple inverted measures
            for i = 1:size(legendtext, 1)
                if pridx(i) == 1
                    legendtext{i} = sprintf('%s %s', legendtext{i}, '(Inverted)');
                end
            end
        end
        
        hold on;
        plotSuperimposedMeasuresB4IntrForPaper(ax, tmp_amnormcubesingleintr, tmp_amnormcubesingleintrsmth, xl, yl, ...
                tmpmeasures, tmpnmeasures, max_offset, align_wind, tmp_offset, tmp_ex_start, study);
        hold off;
        xlabel(ax, 'Days from exacerbation start');
        ylabelposmult = 1.125;
        if n == 1
            ylabeltext = 'Change from stable baseline (s.d.)';
            ylabel(ax, ylabeltext, 'Position',[(xl(1) - 12) (yl(1) + (yl(2) - yl(1) * ylabelposmult))], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Rotation', 0);
        else
            ax.YTickLabel = '';
            ax.YColor = 'white';
        end
        if n == nlatentcurves
            legend(ax, legendtext, 'Location', 'eastoutside', 'FontName', fontname, 'FontSize', 6);
        end
        if nlatentcurves > 1
            title(ax, sprintf('Example %d', n), 'Units', 'normalized', 'FontName', fontname, 'Position', [titlexpos, titleypos, 0]);
        end
    end
end

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
savePlotInDirAsSVG(f, plottitle, plotsubfolder);
close(f);

end
