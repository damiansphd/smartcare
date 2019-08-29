function visualiseExacerbationForPaperFcn(amDatacube, amInterventions, measures, nmeasures, npatients, study)

% visualiseExacerbationForPaperFcn - plots measures around an exacerbation
% time

basedir = setBaseDir();
subfolder = sprintf('Plots/%s', study);
if ~exist(strcat(basedir, subfolder), 'dir')
    mkdir(strcat(basedir, subfolder));
end


titlefontsize = 14;
labelfontsize = 12;
axisfontsize = 10;
unitfontsize = 10;

widthinch = 6;
heightinch = 3.5;
name = '';
singlehght = 1/5.5;
halfhght = singlehght * 0.5;
doublehght = singlehght * 2;
twoandhalfhght = singlehght * 2.5;
triplehght = singlehght * 3;
plotwidth  = 0.85/2;
labelwidth = 0.15;

ntitles = 3;
nlabels = 2;
nplots = 4;
nfooters = 3;

typearray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

typehght = [singlehght, singlehght, singlehght, doublehght, doublehght, doublehght, doublehght, doublehght, doublehght, halfhght, halfhght, halfhght];

imagefilename = sprintf('%s - Early and Late Exacerbation Examples', study);

[f, p] = createFigureAndPanelForPaper(name, widthinch, heightinch);

currhght = 1.0;
subsetintr = [6, 1];
subsetmeasures = {'Cough', 'Wellness'};
intridx = ismember(1:size(amInterventions, 1), subsetintr);
measidx = ismember(measures.DisplayName, subsetmeasures);
scids   = amInterventions.SmartCareID(intridx);
scididx = ismember(1:npatients, scids);

miny = min(min(min(amDatacube(scididx, :, measidx), [], 1, 'omitnan'), [], 2, 'omitnan'), [], 3, 'omitnan');
maxy = max(max(max(amDatacube(scididx, :, measidx), [], 1, 'omitnan'), [], 2, 'omitnan'), [], 3, 'omitnan');


for i = 1:(ntitles + nlabels + nplots + nfooters)
    type = typearray(i);
    if type == 1
        % title 1
        currhght = currhght - typehght(type);
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [0, currhght, labelwidth, typehght(type)]);
    elseif type == 2 || type == 3
        % title 2 & 3
        if type ==  2
            displaytext = 'Early';
            afrom = labelwidth;
            awidth = plotwidth;
        elseif type == 3
            displaytext = 'Late';
            afrom = labelwidth + plotwidth;
            awidth = plotwidth;
        end   
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [afrom, currhght, awidth, typehght(type)]);
        annotation(sp(i), 'textbox',  ...
                        'String', displaytext, ...
                        'Interpreter', 'tex', ...
                        'Units', 'normalized', ...
                        'Position', [0, 0, 1, 1], ...
                        'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'middle', ...
                        'LineStyle', 'none', ...
                        'FontSize', labelfontsize, ...
                        'FontWeight', 'bold');
    elseif type == 4 || type == 7
        % label
        currhght = currhght - typehght(type);
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [0, currhght, labelwidth, typehght(type)]);
        if type == 4
            ltext = subsetmeasures{1};
        elseif type == 7
            ltext = subsetmeasures{2};
        end
        displaytext = {formatTexDisplayMeasure(ltext); sprintf('\\fontsize{%d} (%s)', unitfontsize, getUnitsForMeasure(ltext))};
        
        annotation(sp(i), 'textbox',  ...
                        'String', displaytext, ...
                        'Interpreter', 'tex', ...
                        'Units', 'normalized', ...
                        'Position', [0, 0, 1, 1], ...
                        'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'middle', ...
                        'LineStyle', 'none', ...
                        'FontSize', labelfontsize, ...
                        'FontWeight', 'bold');
    elseif type == 5 || type == 6 || type == 8 || type == 9
        if type == 5 || type == 8
            intr = subsetintr(1);
            afrom = labelwidth;
            awidth = plotwidth;
        elseif type == 6 || type == 9
            intr = subsetintr(2);
            afrom = labelwidth + plotwidth;
            awidth = plotwidth;
        end
        if type == 5 || type == 6
            m = measures.Index(ismember(measures.DisplayName, subsetmeasures(1)));
        elseif type == 8 || type == 9
            m = measures.Index(ismember(measures.DisplayName, subsetmeasures(2)));
        end
        % early or late plot
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [afrom, currhght, awidth, typehght(type)]);
        
        ax = subplot(1, 1, 1, 'Parent', sp(i));

        scid         = amInterventions.SmartCareID(intr);
        hospital     = amInterventions.Hospital{intr};
        trstartdn    = amInterventions.IVScaledDateNum(intr);
        trstopdn     = amInterventions.IVScaledStopDateNum(intr);
        daysfrom     = max(1, trstartdn - 40);
        daysto       = trstartdn + 1;
        dispdaysfrom = daysfrom - trstartdn;
        dispdaysto   = daysto - trstartdn;
        xl           = [dispdaysfrom, dispdaysto];
        
        fprintf('Visualising measures for exacerbation %d, patient %d, hospital %s, date %s\n', intr, scid, hospital, datestr(amInterventions.IVStartDate(intr), 29));
        
        allpatdata = amDatacube(scid, :, m);
        measdata = amDatacube(scid, daysfrom:daysto, m);
        rangelimit = setMinYDisplayRangeForMeasure(measures.Name{m});
        if sum(~isnan(measdata)) > 0
            yl = setYDisplayRange(miny, maxy, rangelimit);
        else
            yl = [0, rangelimit];
        end
        tablemeasure   = measures.Name{m};
        displaymeasure = measures.DisplayName{m};
        units          = getUnitsForMeasure(displaymeasure);
        [smcolour, rwcolour] = getColourForMeasure(displaymeasure);
        ax.FontSize = axisfontsize;
        yticks = setTicks(yl(1), yl(2), 3);
        ax.YTick = yticks;
        ax.TickDir = 'out';
        if type == 5 || type == 6
            ax.XTickLabel = '';
            ax.XColor = 'white';
        end
        xlim(xl);
        ylim(yl);
                
        if sum(~isnan(measdata)) > 0
            %actx = find(~isnan(measdata));
            %acty = measdata(~isnan(measdata));
            %fullx = (1:size(measdata, 2));
            %fully = interp1(actx, acty, fullx, 'linear');
            hold on;
            %plot(ax, dispdaysfrom:dispdaysto, fully, ...
            plot(ax, dispdaysfrom:dispdaysto, measdata, ...
                'Color', rwcolour, ...
                'LineStyle', '-', ...
                'Marker', 'o', ...
                'LineWidth',1, ...
                'MarkerSize',2, ...
                'MarkerEdgeColor', rwcolour, ...
                'MarkerFaceColor', rwcolour);

            %plot(ax, dispdaysfrom:dispdaysto, movmean(fully, 4, 'omitnan'), ...
            %    'Color', smcolour, ...
            %    'LineStyle', '-', ...
            %    'Marker', 'none', ...
            %    'LineWidth', 2);

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
    elseif type == 10
        % footer 1
        currhght = currhght - typehght(type);
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [0, currhght, labelwidth, typehght(type)]);
    elseif type == 11 || type == 12
        % footer 2 & 3
        if type ==  11           
            afrom = labelwidth;
            awidth = plotwidth;
        elseif type == 12
            afrom = labelwidth + plotwidth;
            awidth = plotwidth;
        end   
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [afrom, currhght, awidth, typehght(type)]);
        displaytext = 'Days prior to treatment';
        annotation(sp(i), 'textbox',  ...
                        'String', displaytext, ...
                        'Interpreter', 'tex', ...
                        'Units', 'normalized', ...
                        'Position', [0, 0, 1, 1], ...
                        'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'top', ...
                        'LineStyle', 'none', ...
                        'FontSize', axisfontsize);                
    end
end

savePlotInDir(f, imagefilename, subfolder);
savePlotInDirAsSVG(f, imagefilename, subfolder);
close(f);

    
end

 