function visualiseExacerbationForPaperFcn3(amDatacube, amInterventions, measures, nmeasures, npatients, study)

% visualiseExacerbationForPaperFcn3 - plots measures around an exacerbation
% time

invmeasarray = getInvertedMeasures(study);

basedir = setBaseDir();
subfolder = sprintf('Plots/%s', study);
if ~exist(strcat(basedir, subfolder), 'dir')
    mkdir(strcat(basedir, subfolder));
end


titlefontsize = 8;
labelfontsize = 10;
footerfontsize = 8;
axisfontsize = 6;
unitfontsize = 8;
fontname = 'Arial';

widthinch = 3;
heightinch = 5.5;
name = '';

singlehght     = 1/10.5;
halfhght       = singlehght * 0.5;
doublehght     = singlehght * 2;
%twoandhalfhght = singlehght * 2.5;
%triplehght     = singlehght * 3;

plotwidth   = 0.65;
labelwidth  = 0.25;
padwidth    = 0.1;
title2width = 0.4;
title3width = 0.35;
shortshift = 0.3;

ntitles  = 6;
nlabels  = 4;
nplots   = 4;
npads    = 4;
nfooters = 3;

typearray = [1, 2, 15, 3, 4, 16, 5, 6, 16, 1, 8, 17, 9, 10, 16, 11, 12, 16, 13, 14, 17];

typehght = [singlehght, singlehght, doublehght, doublehght, doublehght, doublehght, ...
            singlehght, singlehght, doublehght, doublehght, doublehght, doublehght, ...
            halfhght,   halfhght,   singlehght, doublehght, halfhght];

imagefilename = sprintf('%s - LongShortDelay Examples', study);

[f, p] = createFigureAndPanelForPaper(name, widthinch, heightinch);

currhght = 1.0;
subsetintr = [6, 1];
subsetmeasures = {'Wellness', 'Cough'};
intridx = ismember(1:size(amInterventions, 1), subsetintr);
measidx = ismember(measures.DisplayName, subsetmeasures);
scids   = amInterventions.SmartCareID(intridx);
scididx = ismember(1:npatients, scids);

miny = min(min(min(amDatacube(scididx, :, measidx), [], 1, 'omitnan'), [], 2, 'omitnan'), [], 3, 'omitnan');
maxy = max(max(max(amDatacube(scididx, :, measidx), [], 1, 'omitnan'), [], 2, 'omitnan'), [], 3, 'omitnan');


for i = 1:(ntitles + nlabels + nplots + npads + nfooters)
    type = typearray(i);
    if type == 1 || type == 13
        % blank titles 
        currhght = currhght - typehght(type);
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [0, currhght, labelwidth, typehght(type)]);
    elseif type == 2 || type == 8 || type == 15
        % title 2 & 8
        tangle  = 'italic';
        tcolor  = 'red';
        tweight = 'bold';
        if type ==  2
            displaytext = {'Long'; 'delay'};
            afrom = labelwidth;
            awidth = plotwidth;
        elseif type == 8
            displaytext = {'Short'; 'delay'};
            afrom = labelwidth + shortshift;
            awidth = title2width;
        elseif type == 15
            displaytext = {'Antibiotic'; 'start'};
            afrom = labelwidth + title2width;
            awidth = title3width;
            tcolor = 'black';
            tangle = 'normal';
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
                        'VerticalAlignment', 'bottom', ...
                        'LineStyle', 'none', ...
                        'Color', tcolor, ...
                        'FontSize', titlefontsize, ...
                        'FontWeight', tweight, ...
                        'FontName', fontname, ...
                        'FontAngle', tangle);
    elseif type == 3 || type == 5 || type == 9 || type == 11
        % label
        currhght = currhght - typehght(type);
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [0, currhght, labelwidth, typehght(type)]);
        if type == 3 || type == 9
            ltext = subsetmeasures{1};
        elseif type == 5 || type == 11
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
                        'FontName', fontname, ...
                        'FontWeight', 'bold');
    elseif type == 4 || type == 6 || type == 10 || type == 12
        if type == 4 || type == 6
            intr = subsetintr(1);
            afrom = labelwidth;
            awidth = plotwidth;
            linept = -21;
        elseif type == 10 || type == 12
            intr = subsetintr(2);
            afrom = labelwidth;
            awidth = plotwidth;
            linept = -6;
        end
        if type == 6 || type == 12
            m = measures.Index(ismember(measures.DisplayName, subsetmeasures(1)));
        elseif type == 4 || type == 10
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
        measdata = amDatacube(scid, daysfrom:(daysto - 1), m);
        rangelimit = setMinYDisplayRangeForMeasure(measures.Name{m});
        if sum(~isnan(measdata)) > 0
            yl = setYDisplayRange(miny, maxy, rangelimit);
        else
            yl = [0, rangelimit];
        end
        %tablemeasure   = measures.Name{m};
        displaymeasure = measures.DisplayName{m};
        %units          = getUnitsForMeasure(displaymeasure);
        [smcolour, rwcolour] = getColourForMeasure(displaymeasure);
        ax.FontSize = axisfontsize;
        ax.FontName = fontname;
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
            actx = find(~isnan(measdata));
            acty = measdata(~isnan(measdata));
            fullx = (1:size(measdata, 2));
            fully = interp1(actx, acty, fullx, 'linear');
            hold on;
            plot(ax, dispdaysfrom:(dispdaysto - 1), fully, ...
                'Color', rwcolour, ...
                'LineStyle', '-', ...
                'Marker', 'none', ...
                'LineWidth',1, ...
                'MarkerSize',2, ...
                'MarkerEdgeColor', rwcolour, ...
                'MarkerFaceColor', rwcolour);
            plot(ax, dispdaysfrom:(dispdaysto - 1), measdata, ...
                'Color', smcolour, ...
                'LineStyle', 'none', ...
                'Marker', 'o', ...
                'LineWidth',1, ...
                'MarkerSize',2, ...
                'MarkerEdgeColor', smcolour, ...
                'MarkerFaceColor', smcolour);

            %plot(ax, dispdaysfrom:dispdaysto, movmean(fully, 4, 'omitnan'), ...
            %    'Color', smcolour, ...
            %    'LineStyle', '-', ...
            %    'Marker', 'none', ...
            %    'LineWidth', 2);

            % shade treatment
            plotFillAreaForPaper(ax, 0, min(dispdaysto, trstopdn), ...
                yl(1), yl(2), 'red', '0.1', 'none');
            
            % plot ex_start line
            line([linept, linept], yl , 'Color', 'red', 'LineStyle', '-', 'LineWidth', 1)
                    
            % use exclude upper quartile mean/std for pulse rate,
            % otherwise use exclude bottom quartile mean/std
            if ismember(displaymeasure, invmeasarray)
                mmean = xu25mean(allpatdata(~isnan(allpatdata)));
                mstd  = xu25std(allpatdata(~isnan(allpatdata)));
            else
                mmean = xb25mean(allpatdata(~isnan(allpatdata)));
                mstd  = xb25std(allpatdata(~isnan(allpatdata)));
            end
            % plot mean +/- 0.5 stddev
            plotFillArea(ax, xl(1), (xl(2) - 2), ...
                mmean - (0.5 * mstd), mmean + (0.5 * mstd), [0.4, 0.4, 0.4], '0.2', 'none');
            line([xl(1), xl(2) - 1], [mmean mmean] , 'Color', [0.6, 0.6, 0.6], 'LineStyle', '-', 'LineWidth', .5)
            hold off;
        end
    %elseif type == 10
    %    % footer 1
    %    currhght = currhght - typehght(type);
    %    sp(i) = uipanel('Parent', p, ...
    %                    'BorderType', 'none', ...
    %                    'BackgroundColor', 'white', ...
    %                    'OuterPosition', [0, currhght, labelwidth, typehght(type)]);
    elseif type == 14 
        % footer        
        afrom  = labelwidth;
        awidth = plotwidth;
     
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
                        'FontName', fontname, ...
                        'FontSize', footerfontsize);
    elseif type == 16 || type == 17
        afrom  = labelwidth + plotwidth;
        awidth = padwidth;
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [afrom, currhght, awidth, typehght(type)]);
    end
end

savePlotInDir(f, imagefilename, subfolder);
savePlotInDirAsSVG(f, imagefilename, subfolder);
close(f);

    
end

 