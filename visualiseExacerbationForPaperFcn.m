function visualiseExacerbationForPaperFcn(amDatacube, amInterventions, measures, nmeasures, npatients, study)

% visualiseExacerbationForPaperFcn - plots measures around an exacerbation
% time

basedir = setBaseDir();
subfolder = sprintf('Plots/%s', study);
if ~exist(strcat(basedir, subfolder), 'dir')
    mkdir(strcat(basedir, subfolder));
end

measpghght = 2.75;
measpgwdth = 6;

plotsacross = 2;
plotsdown = 2;
nrows = 2;
fontsize = 10;
ylabelposmult = 1.25;

imagefilename = sprintf('%s - Early and Late Exacerbation Examples', study);
[f, p] = createFigureAndPanelForPaper('', measpgwdth,  measpghght);

row = 1;
subsetintr = [1, 6];
subsetmeasures = {'Cough', 'Wellness'};

intridx = ismember(1:size(amInterventions, 1), subsetintr);
measidx = ismember(measures.DisplayName, subsetmeasures);
scids   = amInterventions.SmartCareID(intridx);
scididx = ismember(1:npatients, scids);

miny = min(min(min(amDatacube(scididx, :, measidx), [], 1, 'omitnan'), [], 2, 'omitnan'), [], 3, 'omitnan');
maxy = max(max(max(amDatacube(scididx, :, measidx), [], 1, 'omitnan'), [], 2, 'omitnan'), [], 3, 'omitnan');

for intr= size(amInterventions, 1):-1:1
    if ismember(intr, subsetintr) 
        tic
        scid         = amInterventions.SmartCareID(intr);
        hospital     = amInterventions.Hospital{intr};
        trstartdn    = amInterventions.IVScaledDateNum(intr);
        trstopdn     = amInterventions.IVScaledStopDateNum(intr);
        daysfrom     = max(1, trstartdn - 40);
        daysto       = trstartdn + 15;
        dispdaysfrom = daysfrom - trstartdn;
        dispdaysto   = daysto - trstartdn;
        xl           = [dispdaysfrom, dispdaysto];
        
            
        fprintf('Visualising measures for exacerbation %d, patient %d, hospital %s, date %s\n', intr, scid, hospital, datestr(amInterventions.IVStartDate(intr), 29));
        
        measure = 1;
        for m = 1:nmeasures
            if ismember(measures.DisplayName{m}, subsetmeasures)
                allpatdata = amDatacube(scid, :, m);
                measdata = amDatacube(scid, daysfrom:daysto, m);
                rangelimit = setMinYDisplayRangeForMeasure(measures.Name{m});
                if sum(~isnan(measdata)) > 0
                    yl = setYDisplayRange(miny, maxy, rangelimit);
                else
                    yl = [0, rangelimit];
                end
                if measure == 1
                    labeloffset = 21;
                    if row == 1
                        patienttext = 'Patient A:   ';
                    elseif row == 2
                        patienttext = 'Patient B:   ';
                    elseif row == 3
                        patienttext = 'Patient C:   ';
                    else
                        fprintf('***** too many rows ****\n');
                        return;
                    end
                else
                    patienttext = '';
                    labeloffset = 0;
                end
                
                ax = subplot(plotsdown, plotsacross, measure + ((row - 1) * plotsacross), 'Parent', p);
                tablemeasure   = measures.Name{m};
                displaymeasure = measures.DisplayName{m};
                units          = getUnitsForMeasure(displaymeasure);
                [smcolour, rwcolour] = getColourForMeasure(displaymeasure);
                ylabeltext = sprintf('%s%s (%s)', patienttext, displaymeasure, units);
                ylabel(ylabeltext, 'Position',[dispdaysfrom - labeloffset, yl(1) + ((yl(2) - yl(1)) * ylabelposmult)], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Rotation', 0);
                ax.FontSize = fontsize;
                yticks = setTicks(yl(1), yl(2), 3);
                ax.YTick = yticks;
                ax.TickDir = 'out';
                if row == nrows
                    xlabel(ax, 'Days prior to treatment');
                else
                    ax.XTickLabel = '';
                    ax.XColor = 'white';
                end
                xlim(xl);
                ylim(yl);
                
                if sum(~isnan(measdata)) > 0
                    actx = find(~isnan(measdata));
                    acty = measdata(~isnan(measdata));
                    fullx = (1:size(measdata, 2));
                    fully = interp1(actx, acty, fullx, 'linear');
                    hold on;
                    plot(ax, dispdaysfrom:dispdaysto, fully, ...
                        'Color', rwcolour, ...
                        'LineStyle', '-', ...
                        'Marker', 'o', ...
                        'LineWidth',1, ...
                        'MarkerSize',2, ...
                        'MarkerEdgeColor', rwcolour, ...
                        'MarkerFaceColor', rwcolour);

                    plot(ax, dispdaysfrom:dispdaysto, movmean(fully, 4, 'omitnan'), ...
                        'Color', smcolour, ...
                        'LineStyle', '-', ...
                        'Marker', 'none', ...
                        'LineWidth', 2);

                    plotFillAreaForPaper(ax, 0, min(dispdaysto, trstopdn), ...
                        yl(1), yl(2), 'red', '0.1', 'none');
                    
                    % use exclude upper quartile mean/std for pulse rate,
                    % otherwise use exclude bottom quartile mean/std
                    if ismember(displaymeasure, {'PulseRate'})
                        mmean = xu25mean(allpatdata(~isnan(allpatdata)));
                        mstd  = xu25std(allpatdata(~isnan(allpatdata)));
                    else
                        mmean = xb25mean(allpatdata(~isnan(allpatdata)));
                        mstd  = xb25std(allpatdata(~isnan(allpatdata)));
                    end
                    plotFillArea(ax, xl(1), xl(2), ...
                        mmean - (0.5 * mstd), mmean + (0.5 * mstd), [0.4, 0.4, 0.4], '0.2', 'none');
                    line(xl, [mmean mmean] , 'Color', [0.6, 0.6, 0.6], 'LineStyle', '-', 'LineWidth', .5)
                    hold off;
                end
                measure = measure + 1;
            end
        end
        row = row + 1;
    end
end

savePlotInDir(f, imagefilename, subfolder);
savePlotInDirAsSVG(f, imagefilename, subfolder);
close(f);

    
end

 