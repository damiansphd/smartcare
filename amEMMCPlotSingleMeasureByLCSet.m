function amEMMCPlotSingleMeasureByLCSet(amInterventions, amIntrDatacube, normmean, measure, measures, ...
    ex_start_array, max_offset, align_wind, plotname, plotsubfolder, nlatentcurves)

% amEMMCPlotSingleMeasureByLCSet - plots a given measure prior to
% treatment with alignment model predictions for each examples assigned to
% a given LC set. Separate plots for each LC set

plotsdown = 4;
plotsacross = 4;
plotsperpage = plotsacross * plotsdown;

dayset = (-1 * (max_offset + align_wind - 1): -1);


for lc = 1:nlatentcurves
    lcamintr       = amInterventions(amInterventions.LatentCurve == lc, :);
    lcmsamintrcube = amIntrDatacube(amInterventions.LatentCurve == lc, :, measure);
    lcmsnormmean   = normmean(amInterventions.LatentCurve == lc, measure);
    ex_start   = ex_start_array(lc);
    
    thisplot = 1;
    thispage = 1;
    npages   = ceil(size(lcamintr, 1) / plotsperpage);
    
    basename = sprintf('%s-%s-C%d', plotname, measures.DisplayName{measure}, lc);
    name = sprintf('%s Pg%dof%d', basename, thispage, npages);
    
    fprintf('%s\n', name);
    [f, p] = createFigureAndPanel(name, 'portrait', 'a4');
    
    for i = 1:size(lcamintr, 1)
        scid = lcamintr.SmartCareID(i);
        
        % initialise plot areas
        xl = [0 0];
        yl = [(min(lcmsamintrcube(i, :)) *.99) ...
              (max(lcmsamintrcube(i, :)) * 1.01)];
    
        % create subplot and plot required data arrays
        ax = subplot(plotsdown, plotsacross, thisplot, 'Parent',p);               
        [xl, yl] = plotMeasurementData(ax, dayset, lcmsamintrcube(i, :), xl, yl, measures(measure,:), [0, 0.65, 1], ':', 1.0, 'o', 2.0, 'blue', 'green');
        [xl, yl] = plotMeasurementData(ax, dayset, movmean(lcmsamintrcube(i, :), 5, 'omitnan'), xl, yl, measures(measure,:), [0, 0.65, 1], '-', 1.0, 'none', 2.0, 'blue', 'green');
        %[xl, yl] = plotMeasurementData(ax, dayset, smooth(lcmsamintrcube(i, :), 5), xl, yl, measures(measure,:), [0, 0.65, 1], '-', 1.0, 'none', 2.0, 'blue', 'green');
        [xl, yl] = plotHorizontalLine(ax, lcmsnormmean(i), xl, yl, 'blue', '--', 0.5); % plot mean
        
        [xl, yl] = plotExStart(ax, ex_start, lcamintr.Offset(i), xl, yl,  'black', '-', 0.5);            
        [xl, yl] = plotVerticalLine(ax, 0, xl, yl, 'cyan', '-', 0.5); % plot treatment start
        
        hold on;
        plotFillArea(ax, ex_start + lcamintr.LowerBound1(i), ex_start + lcamintr.UpperBound1(i), ...
        yl(1), yl(2), 'red', '0.1', 'none');
        if lcamintr.LowerBound2(i) ~= -1
            plotFillArea(ax, ex_start + lcamintr.LowerBound2(i), ex_start + lcamintr.UpperBound2(i), ...
                yl(1), yl(2), 'red', '0.1', 'none');
        end
        
        if measures.Mask(measure) == 1
            title(ax, sprintf('ID%d-Dt%s-Off%d', scid, datestr(lcamintr.IVStartDate(i), 29), lcamintr.Offset(i)), 'BackgroundColor', 'g');
        else
            title(ax, sprintf('ID%d-Dt%s-Off%d', scid, datestr(lcamintr.IVStartDate(i), 29), lcamintr.Offset(i)));
        end
                    
        thisplot = thisplot + 1;
        if thisplot > plotsacross * plotsdown
            savePlotInDir(f, name, plotsubfolder);
            close(f);
            thisplot = 1;
            thispage = thispage + 1;
            name = sprintf('%s Pg%dof%d', basename, thispage, npages);
            fprintf('%s\n', name);
            [f, p] = createFigureAndPanel(name, 'portrait', 'a4');
        end
    end
    if thispage <= npages
        savePlotInDir(f, name, plotsubfolder);
        close(f);
    end
end

end
