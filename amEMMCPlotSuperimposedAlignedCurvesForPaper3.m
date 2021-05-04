function amEMMCPlotSuperimposedAlignedCurvesForPaper3(meancurvemean, meancurvecount, amIntrNormcube, amInterventions, normmean, normstd, ...
    measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, ...
    countthreshold, shiftmode, study, examplemode, lcexamples)

% amEMMCPlotSuperimposedAlignedCurves3 - wrapper around the
% plotSuperimposedAlignedCurves to plot for each set of latent curves along
% with examples below

invmeasarray = getInvertedMeasures(study);

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
            if (align_wind + max_offset + ex_start(n) - meanwindow) < 1
                shiftfrom = 1;
            else
                shiftfrom = (align_wind + max_offset + ex_start(n) - meanwindow);
            end 
            vertshift = mean(meancurvemean(n, shiftfrom:(align_wind + max_offset + ex_start(n)), m));
        end
        meancurvemean(n, :, m) = meancurvemean(n, :, m) - vertshift;
        fprintf('For curve %d and measure %13s, vertical shift is %.3f\n', n, measures.DisplayName{m}, -vertshift);
    end
end

titlefontsize = 14;
labelfontsize = 12;
axisfontsize = 6;
unitfontsize = 10;
legendfontsize = 8;
smallfontsize = 8;
fontname = 'Arial';

widthinch = 12;
heightinch = 12.5;
name = '';
singlehght = 1/12.5;
halfhght = singlehght * .5;
oneandhalfhght = singlehght * 2;
doublehght = singlehght * 2.5;
triplehght = singlehght * 3;
quadhght   = singlehght * 4;
labelwidth = 0.15;
plotwidth  = 0.85;



typearray = [1, 3, 6, 9, 3, 8, 10, 2, 5, 4, 7];

typehght = [halfhght, oneandhalfhght, triplehght, doublehght, oneandhalfhght, triplehght, doublehght, triplehght, halfhght, halfhght];

labeltext = {'A.'; 'Change from'; ' '; 'B.'; 'Change from'; ' '; 'C.'};


tmpmeasures = measures(logical(measures.Mask), :);
tmpmeasures.PaperMask(:) = 0;
tmpmeasures.PaperMask(ismember(tmpmeasures.DisplayName, {'LungFunction', 'FEV1', 'Wellness'})) = 1;
tmpnmeasures = size(tmpmeasures, 1);
[tmpmeasures] = sortMeasuresForPaper(study, tmpmeasures);
tmpsubsetmeasures = tmpmeasures(logical(tmpmeasures.PaperMask), :);
tmpnsubsetmeasures = size(tmpsubsetmeasures, 1);

ntitles = 3;
nlcrow = 2;
nmeasrows = sum(logical(tmpmeasures.PaperMask));
nlabels = nlcrow + nmeasrows;

for m = 1:tmpnsubsetmeasures
    labeltext = [labeltext; cellstr(tmpsubsetmeasures.DisplayName{m}); ' '];
end

extext = sprintf('_%d', lcexamples);
plottitle   = sprintf('%s - %s S-Imp %s FPv3 pc%d Ex%s', plotname, run_type, shifttext, countthreshold, extext);

plotsacross = nlatentcurves;
plotsdown   = 1;
plotpanels = 5;
legendpanels = 5;
if nlatentcurves == 1
    paddingpanels = 0;
else
    paddingpanels = 1;
end
panelsacross = ((plotpanels + paddingpanels) * nlatentcurves) + legendpanels - 1;

lcsort = getLCSortOrder(amInterventions, nlatentcurves);

[f, p] = createFigureAndPanelForPaper(name, widthinch, heightinch);

currhght = 1.0;
currmeas = 1;
for i = 1:(ntitles + nlcrow + nmeasrows + nlabels)
    type = typearray(i);
    if type == 1 || type == 9 || type == 10
        % title
        currhght = currhght - typehght(type);
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [0, currhght, 1.0, typehght(type)]);
        displaytext = sprintf('\\bf %s\\rm', labeltext{i});            
        annotation(sp(i), 'textbox',  ...
                        'String', displaytext, ...
                        'Interpreter', 'tex', ...
                        'Units', 'normalized', ...
                        'Position', [0, 0, 0.2, 1], ...
                        'HorizontalAlignment', 'left', ...
                        'VerticalAlignment', 'middle', ...
                        'LineStyle', 'none', ...
                        'FontName', fontname, ...
                        'FontSize', titlefontsize);
        if type == 1 
            txt = 'Group';
        elseif type == 10
            txt = 'Example';
        end
        if type == 1 || type == 10
            if nlatentcurves == 3
                annotation(sp(i), 'textbox',  ...
                                'String', {sprintf('%s 1', txt); sprintf('\\fontsize{%d} (n=%d)', unitfontsize, sum(amInterventions.LatentCurve == lcsort(1)))}, ...
                                'Interpreter', 'tex', ...
                                'Units', 'normalized', ...
                                'Position', [0.28, 0, 0.1, 1], ...
                                'HorizontalAlignment', 'center', ...
                                'VerticalAlignment', 'bottom', ...
                                'LineStyle', 'none', ...
                                'FontName', fontname, ...
                                'FontSize', labelfontsize);
                annotation(sp(i), 'textbox',  ...
                                'String', {sprintf('%s 2', txt); sprintf('\\fontsize{%d} (n=%d)', unitfontsize, sum(amInterventions.LatentCurve == lcsort(2)))}, ...
                                'Interpreter', 'tex', ...
                                'Units', 'normalized', ...
                                'Position', [0.47, 0, 0.1, 1], ...
                                'HorizontalAlignment', 'center', ...
                                'VerticalAlignment', 'bottom', ...
                                'LineStyle', 'none', ...
                                'FontName', fontname, ...
                                'FontSize', labelfontsize);
                annotation(sp(i), 'textbox',  ...
                                'String', {sprintf('%s 3', txt); sprintf('\\fontsize{%d} (n=%d)', unitfontsize, sum(amInterventions.LatentCurve == lcsort(3)))}, ...
                                'Interpreter', 'tex', ...
                                'Units', 'normalized', ...
                                'Position', [0.65, 0, 0.1, 1], ...
                                'HorizontalAlignment', 'center', ...
                                'VerticalAlignment', 'bottom', ...
                                'LineStyle', 'none', ...
                                'FontName', fontname, ...
                                'FontSize', labelfontsize);
            elseif nlatentcurves == 2
                annotation(sp(i), 'textbox',  ...
                                'String', {sprintf('%s 1', txt); sprintf('\\fontsize{%d} (n=%d)', unitfontsize, sum(amInterventions.LatentCurve == lcsort(1)))}, ...
                                'Interpreter', 'tex', ...
                                'Units', 'normalized', ...
                                'Position', [0.31, 0, 0.1, 1], ...
                                'HorizontalAlignment', 'center', ...
                                'VerticalAlignment', 'bottom', ...
                                'LineStyle', 'none', ...
                                'FontName', fontname, ...
                                'FontSize', labelfontsize);
                annotation(sp(i), 'textbox',  ...
                                'String', {sprintf('%s 2', txt); sprintf('\\fontsize{%d} (n=%d)', unitfontsize, sum(amInterventions.LatentCurve == lcsort(2)))}, ...
                                'Interpreter', 'tex', ...
                                'Units', 'normalized', ...
                                'Position', [0.57, 0, 0.1, 1], ...
                                'HorizontalAlignment', 'center', ...15
                                'VerticalAlignment', 'bottom', ...
                                'LineStyle', 'none', ...
                                'FontName', fontname, ...
                                'FontSize', labelfontsize);
                
            end
        end
    elseif type == 2 || type == 3 || type == 4
        % label
        currhght = currhght - typehght(type);
        if type == 3
            displaytext1 = sprintf('\\bf %s\\rm', 'Change from');
            displaytext2 = sprintf('\\bf %s\\rm', 'stable baseine');
            displaytext3 = sprintf('\\bf %s\\rm', '(s.d.)');
            displaytext = {displaytext1; displaytext2; displaytext3};
        else
            displaytext = {formatTexDisplayMeasure(labeltext{i}); sprintf('\\fontsize{%d} (%s)', unitfontsize, getUnitsForMeasure(labeltext{i}))};
        end
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [0, currhght, labelwidth, typehght(type)]);
        annotation(sp(i), 'textbox',  ...
                        'String', displaytext, ...
                        'Interpreter', 'tex', ...
                        'Units', 'normalized', ...
                        'Position', [0, 0, 1, 1], ...
                        'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'middle', ...
                        'LineStyle', 'none', ...
                        'FontName', fontname, ...
                        'FontSize', labelfontsize);
    elseif type == 6 || type == 8
        % plot superimposed curves (all measures or just 2 measures)
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [labelwidth, currhght, plotwidth, typehght(type)]);

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
                if type == 6 && n == nlatentcurves
                    panels = (((n - 1) * (plotpanels + paddingpanels)) + 1): (((n - 1) * (plotpanels + paddingpanels)) + plotpanels + legendpanels);
                else
                    panels = (((n - 1) * (plotpanels + paddingpanels)) + 1): (((n - 1) * (plotpanels + paddingpanels)) + plotpanels);
                end

                ax = subplot(1, panelsacross, panels, 'Parent', sp(i));
                ax.FontSize = axisfontsize;
                ax.FontName = fontname;
                ax.TickDir = 'out';
                
                if type == 6
                    % add legend text cell array
                    legendtext = tmpmeasures.DisplayName;
                    for m = 1:tmpnmeasures
                        legendtext{m} = formatDisplayMeasure(legendtext{m});
                    end
                    pridx = ismember(tmpmeasures.DisplayName, invmeasarray);
                    if sum(pridx) > 0
                        for a = 1:size(legendtext, 1)
                            if pridx(a) == 1
                                legendtext{a} = sprintf('%s %s', legendtext{a}, '(Inverted)');
                            end
                        end
                    end

                    plotSuperimposedAlignedCurvesForPaper(ax, tmp_meancurvemean, xl, yl, ...
                            tmpmeasures, tmpnmeasures, min_offset, max_offset, align_wind, ex_start(lc), study);
                elseif type == 8
                    plotSuperimposedAlignedCurvesForPaper(ax, tmp_meancurvemean, xl, yl, ...
                            tmpsubsetmeasures, tmpnsubsetmeasures, min_offset, max_offset, align_wind, ex_start(lc), study);
                    if n == 2 && ismember(study, {'SC'})
                        % hardcode plot of time delay arrow    
                        hold on;
                        arrow([0, 0.5], [12, 0.5], ...
                            'Length', 5, 'Ends', 'both', 'FaceColor', 'k', 'LineWidth', 1.0, 'EdgeColor', 'k');
                        hold off;
                        annotation(sp(i), 'textbox',  ...
                            'String', 'Delay of 12 days', ...
                            'Interpreter', 'tex', ...
                            'Units', 'normalized', ...
                            'Position', [0.43, 0.9, 0.10, 0.07], ...
                            'HorizontalAlignment', 'left', ...
                            'VerticalAlignment', 'middle', ...
                            'BackgroundColor', 'white', ...
                            'LineStyle', '-', ...
                            'FontName', fontname, ...
                            'FontSize', smallfontsize);
                    end
                end

                xlabel(ax, 'Days from exacerbation start');
                if n ~= 1
                    ax.YTickLabel = '';
                    ax.YColor = 'white';
                end
                if type == 6 && n == nlatentcurves
                    legend(ax, legendtext, 'Location', 'eastoutside', 'FontSize', legendfontsize);
                end
            end
        end
    elseif type == 5 || type == 7
        if (examplemode ~= 0)
            % now plot examples for each latent curve set
            sp(i) = uipanel('Parent', p, ...
                            'BorderType', 'none', ...
                            'BackgroundColor', 'white', ...
                            'OuterPosition', [labelwidth, currhght, plotwidth, typehght(type)]);

            lcexrow = lcexamples(lcsort);

            for n = 1:nlatentcurves
                a = lcexrow(n);
                amnormcubesingleintr = amIntrNormcube(a, :, tmpsubsetmeasures.Index(currmeas));
                aminterventionsrow   = amInterventions(a, :);
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
                pridx = find(ismember(tmpsubsetmeasures.DisplayName, invmeasarray));
                if currmeas == pridx
                    amnormcubesingleintr(1, :, 1) = amnormcubesingleintr(1, :, 1) * -1;
                end
                actx = find(~isnan(amnormcubesingleintr(1, :, 1)));
                acty = amnormcubesingleintr(1, ~isnan(amnormcubesingleintr(1, :, 1)), 1);
                fullx = (1:size(amnormcubesingleintr(1, :, 1), 2));
                amnormcubesingleintr(1, :, 1) = interp1(actx, acty, fullx, 'linear');
                amnormcubesingleintrsmth(1, :, 1) = movmean(amnormcubesingleintr(1, :, 1), smoothwdth, 'omitnan');

                if all(isnan(amnormcubesingleintrsmth(1, 1:(align_wind + max_offset + tmp_ex_start + tmp_offset), 1)))
                        vertshift = 0;
                else
                    if shiftmode == 1
                        vertshift = mean(amnormcubesingleintrsmth(1, 1:(align_wind + max_offset + tmp_ex_start + tmp_offset), 1), 'omitnan');
                    elseif shiftmode == 2
                        vertshift = max(amnormcubesingleintrsmth(1, 1:(align_wind + max_offset + tmp_ex_start + tmp_offset), 1), 'omitnan');
                    elseif shiftmode == 3
                        vertshift = amnormcubesingleintrsmth(1, find(~isnan(amnormcubesingleintrsmth(1, 1:(align_wind + max_offset + tmp_ex_start + tmp_offset), 1)), 1, 'last'), 1);
                    elseif shiftmode == 4
                        if (align_wind + max_offset + tmp_ex_start + tmp_offset - meanwindow) < 1
                            shiftfrom = 1;
                        else
                            shiftfrom = (align_wind + max_offset + tmp_ex_start + tmp_offset - meanwindow);
                        end 
                        vertshift = mean(amnormcubesingleintrsmth(1, shiftfrom:(align_wind + max_offset + tmp_ex_start + tmp_offset), 1), 'omitnan');
                    end
                end
                amnormcubesingleintr(1, :, 1) = amnormcubesingleintr(1, :, 1) - vertshift;
                amnormcubesingleintrsmth(1, :, 1) = amnormcubesingleintrsmth(1, :, 1) - vertshift;
                fprintf('For intervention %3d, measure %13s, vertical shift is %.3f\n', a, tmpsubsetmeasures.DisplayName{1}, -vertshift);

                xfrom = -1 * (align_wind + max_offset - 1 + ex_start(lc));
                xto   = -1 * (1 + ex_start(lc));
                xl = [xfrom, xto];

                %yl = [min(min(amnormcubesingleintrsmth(1, :, logical(measures.Mask)))) ...
                %      max(max(amnormcubesingleintrsmth(1, :, logical(measures.Mask))))];
                yl = [-3, 2];

                panels = (((n - 1) * (plotpanels + paddingpanels)) + 1): (((n - 1) * (plotpanels + paddingpanels)) + plotpanels);

                % plot all measures superimposed
                ax = subplot(1, panelsacross, panels, 'Parent', sp(i));
                ax.FontSize = axisfontsize;
                ax.FontName = fontname;

                hold on;
                [smcolour, rwcolour] = getColourForMeasure(tmpsubsetmeasures.DisplayName{currmeas});
                lstyle = '-';
                lwidth = 1.5;
                days = xl(1):xl(2);
                dfrom = 1; 
                dto   = max_offset + align_wind - 1 - tmp_offset;
                mfrom = 1 + tmp_offset; 
                mto   = max_offset + align_wind - 1;
                plot(ax, days(dfrom:dto), amnormcubesingleintr(1, mfrom:mto, 1), ...
                    'Color', rwcolour, ...
                    'LineStyle', '-', ...
                    'Marker', 'o', ...
                    'LineWidth',1, ...
                    'MarkerSize',2, ...
                    'MarkerEdgeColor', rwcolour, ...
                    'MarkerFaceColor', rwcolour);

                plot(ax, days(dfrom:dto), amnormcubesingleintrsmth(1, mfrom:mto, 1), ...
                    'Color', smcolour, ...
                    'LineStyle', lstyle, ...
                    'Marker', 'none', ...
                    'LineWidth', lwidth);
                if tmp_ex_start ~= 0
                    [~, ~] = plotVerticalLine(ax, 0, xl, yl, 'black', '-', 0.5); % plot ex_start
                end

                mmean = 0;
                mstd = 1;

                plotFillArea(ax, xl(1), xl(2), ...
                    mmean - (0.5 * mstd), mmean + (0.5 * mstd), [0.4, 0.4, 0.4], '0.2', 'none');
                line(xl, [mmean mmean] , 'Color', [0.6, 0.6, 0.6], 'LineStyle', '-', 'LineWidth', .5)

                hold off;
                if currmeas == tmpnsubsetmeasures
                    xlabel(ax, 'Days from exacerbation start');
                else
                    ax.XTickLabel = '';
                    ax.XColor = 'white';
                end
                if n ~= 1
                    ax.YTickLabel = '';
                    ax.YColor = 'white';
                end
                ylim(yl);
            end
            currmeas = currmeas + 1;
        end
    end
end

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
savePlotInDirAsSVG(f, plottitle, plotsubfolder);
close(f);

end
