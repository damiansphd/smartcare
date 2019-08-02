function amEMMCPlotSuperimposedAlignedCurvesForPaper(meancurvemean, meancurvecount, amIntrNormcube, amInterventions, ...
    measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, nlatentcurves, ...
    countthreshold, shiftmode, study, examplemode, lcexamples)

% amEMMCPlotSuperimposedAlignedCurves - wrapper around the
% plotSuperimposedAlignedCurves to plot for each set of latent curves

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
    pridx = measures.Index(ismember(measures.DisplayName, {'PulseRate'}));
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

titlefontsize = 14;
labelfontsize = 12;
axisfontsize = 10;
unitfontsize = 10;
legendfontsize = 8;

widthinch = 12;
heightinch = 17;
name = '';
singlehght = 1/17.25;
oneandhalfhght = singlehght * 1.5;
doublehght = singlehght * 2;
triplehght = singlehght * 2.75;
quadhght   = singlehght * 4;
labelwidth = 0.2;
plotwidth  = 0.8;

ntitles = 2;
nlcrow = 1;
nmeasrows = sum(logical(measures.Mask));
nlabels = nlcrow + nmeasrows;

typearray = [1, 3, 6, 1, 2, 5, 2, 5, 2, 5, 2, 5, 2, 5, 4, 7];

typehght = [singlehght, doublehght, triplehght, oneandhalfhght, doublehght, triplehght, oneandhalfhght];

labeltext = {'A.'; 'Change from'; ' '; 'B.'};

tmpmeasures = measures(logical(measures.Mask), :);
tmpnmeasures = size(tmpmeasures, 1);
[tmpmeasures] = sortMeasuresForPaper(study, tmpmeasures);
for m = 1:tmpnmeasures
    labeltext = [labeltext; cellstr(tmpmeasures.DisplayName{m}); ' '];
end

plottitle   = sprintf('%s - %s Superimposed %s For Paper 2', plotname, run_type, shifttext);

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
    if type == 1
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
                        'FontSize', titlefontsize);
        if i == 1
            txt = 'Group';
        else
            txt = 'Example';
        end
        annotation(sp(i), 'textbox',  ...
                        'String', sprintf('%s 1', txt), ...
                        'Interpreter', 'tex', ...
                        'Units', 'normalized', ...
                        'Position', [0.32, 0, 0.1, 1], ...
                        'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'bottom', ...
                        'LineStyle', 'none', ...
                        'FontSize', titlefontsize);
        annotation(sp(i), 'textbox',  ...
                        'String', sprintf('%s 2', txt), ...
                        'Interpreter', 'tex', ...
                        'Units', 'normalized', ...
                        'Position', [0.5, 0, 0.1, 1], ...
                        'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'bottom', ...
                        'LineStyle', 'none', ...
                        'FontSize', titlefontsize);
        annotation(sp(i), 'textbox',  ...
                        'String', sprintf('%s 3', txt), ...
                        'Interpreter', 'tex', ...
                        'Units', 'normalized', ...
                        'Position', [0.67, 0, 0.1, 1], ...
                        'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'bottom', ...
                        'LineStyle', 'none', ...
                        'FontSize', titlefontsize);
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
                        'FontSize', labelfontsize);
    elseif type == 6
        % plot
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [labelwidth, currhght, plotwidth, typehght(type)]);
        %lcsort = getLCSortOrder(amInterventions, nlatentcurves);

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

                ax = subplot(nlcrow, panelsacross, panels, 'Parent', sp(i));
                ax.FontSize = 8;
                ax.TickDir = 'out';
                % comment out/uncomment out one of these depending on whether all measures
                % wanted or just those used for alignment
                %tmpmeasures = measures;
                %tmpmeasures = measures(logical(measures.Mask), :);
                %tmpnmeasures = size(tmpmeasures, 1);

                % add legend text cell array
                %tmp = sortMeasuresForPaper(study, tmpmeasures);
                %legendtext = tmp.DisplayName;
                legendtext = tmpmeasures.DisplayName;
                for m = 1:tmpnmeasures
                    legendtext{m} = formatDisplayMeasure(legendtext{m});
                end
                pridx = ismember(tmpmeasures.DisplayName, {'PulseRate'});
                legendtext{pridx} = sprintf('%s %s', legendtext{pridx}, '(Inverted)');

                plotSuperimposedAlignedCurvesForPaper(ax, tmp_meancurvemean, xl, yl, ...
                        tmpmeasures, tmpnmeasures, min_offset, max_offset, align_wind, ex_start(lc), study);

                xlabel(ax, 'Days from exacerbation start');
                if n ~= 1
                    ax.YTickLabel = '';
                    ax.YColor = 'white';
                end
                if n == nlatentcurves
                    legend(ax, legendtext, 'Location', 'eastoutside', 'FontSize', legendfontsize);
                end
                %if nlatentcurves > 1
                %    title(ax, sprintf('Group %d (n = %d)', n, sum(amInterventions.LatentCurve == lc)), 'Units', 'normalized', 'Position', [titlexpos, titleypos, 0]);
                %end
            end
        end
    elseif type == 5 || type == 7
        % now plot examples for each latent curve set
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [labelwidth, currhght, plotwidth, typehght(type)]);
        
        lcexrow = lcexamples(lcsort);

        for n = 1:nlatentcurves
            a = lcexrow(n);
            amnormcubesingleintr = amIntrNormcube(a, :, tmpmeasures.Index(currmeas));
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
            pridx = find(ismember(tmpmeasures.DisplayName, {'PulseRate'}));
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
                    vertshift = mean(amnormcubesingleintrsmth(1, (align_wind + max_offset + tmp_ex_start + tmp_offset - meanwindow):(align_wind + max_offset + tmp_ex_start + tmp_offset), 1), 'omitnan');
                end
            end
            amnormcubesingleintr(1, :, 1) = amnormcubesingleintr(1, :, 1) - vertshift;
            amnormcubesingleintrsmth(1, :, 1) = amnormcubesingleintrsmth(1, :, 1) - vertshift;
            fprintf('For intervention %3d, measure %13s, vertical shift is %.3f\n', a, tmpmeasures.DisplayName{1}, -vertshift);

            xfrom = -1 * (align_wind + max_offset - 1 + ex_start(lc));
            xto   = -1 * (1 + ex_start(lc));
            xl = [xfrom, xto];

            %yl = [min(min(amnormcubesingleintrsmth(1, :, logical(measures.Mask)))) ...
            %      max(max(amnormcubesingleintrsmth(1, :, logical(measures.Mask))))];
            yl = [-4, 2.75];
            
            panels = (((n - 1) * (plotpanels + paddingpanels)) + 1): (((n - 1) * (plotpanels + paddingpanels)) + plotpanels);

            % plot all measures superimposed
            ax = subplot(plotsdown, panelsacross, panels, 'Parent', sp(i));
            ax.FontSize = 8;

            hold on;
            [smcolour, rwcolour] = getColourForMeasure(tmpmeasures.DisplayName{currmeas});
            lstyle = '-';
            lwidth = 1.5;
            days = xl(1):xl(2);
            dfrom = 1; 
            dto   = max_offset + align_wind - 1 - tmp_offset;
            mfrom = 1 + tmp_offset; 
            mto   = max_offset + align_wind - 1;
            plot(ax, days(dfrom:dto), amnormcubesingleintr(1, mfrom:mto, 1), ...
                'Color', rwcolour, ...
                'LineStyle', ':', ...
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

            %plotSuperimposedMeasuresB4IntrForPaper(ax, tmp_amnormcubesingleintr, tmp_amnormcubesingleintrsmth, xl, yl, ...
            %        tmpmeasures, tmpnmeasures, max_offset, align_wind, tmp_offset, tmp_ex_start, study);
            hold off;
            if currmeas == tmpnmeasures
                xlabel(ax, 'Days from exacerbation start');
            else
                ax.XTickLabel = '';
                ax.XColor = 'white';
            end
            ylabelposmult = 1.125;
            %if n == 1
            %    ylabeltext = 'Change from stable baseline (s.d.)';
            %    ylabel(ax, ylabeltext, 'Position',[(xl(1) - 12) (yl(1) + (yl(2) - yl(1) * ylabelposmult))], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Rotation', 0);
            %else
            if n ~= 1
                ax.YTickLabel = '';
                ax.YColor = 'white';
            end
        end
        currmeas = currmeas + 1;
    end
end

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
savePlotInDirAsSVG(f, plottitle, plotsubfolder);
close(f);

end
