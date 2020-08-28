function plotMeasuresAndPredictionsForPatientForPaper3(patientrow1, patientrow2, pabs1, pabs2, pexsts1, pexsts2, prawdata, pinterpdata, pinterpvoldata, ...
    pmFeatureIndex, trcvlabels, pmModelRes, pmOverallStats, ...
    pmeasstats1, pmeasstats2, measures, labelidx, pmFeatureParamsRow, ...
    lbdisplayname, plotsubfolder, basefilename, studydisplayname)

% plotMeasuresAndPredictionsForPatientForPaper3 - for two patients, plot the measures along
% with the predictions from the predictive classification model side by
% side

smfn       = pmFeatureParamsRow.smfunction;
smwin      = pmFeatureParamsRow.smwindow;
smln       = pmFeatureParamsRow.smlength;
normwindow = pmFeatureParamsRow.normwindow;

patientnbr1 = patientrow1.PatientNbr;
patientnbr2 = patientrow2.PatientNbr;
pmaxdays1 = patientrow1.LastMeasdn - patientrow1.FirstMeasdn + 1;
pmaxdays2 = patientrow2.LastMeasdn - patientrow2.FirstMeasdn + 1;
pmaxdays = 0;

titlefontsize = 14;
labelfontsize = 12;
axisfontsize = 10;
unitfontsize = 10;

widthinch = 8.25;
heightinch = 7.5;
name = '';
singlehght = 1/14;
halfhght = singlehght * 0.5;
doublehght = singlehght * 2;
twoandhalfhght = singlehght * 2.5;
triplehght = singlehght * 3;
labelwidth = 0.20;
plotwidth  = 0.40;

ntitles = 2;
npredictions = 1;
tmpnmeasures = sum(measures.RawMeas | measures.BucketMeas | measures.Range | measures.Volatility | measures.CChange | measures.PMean);
nlabels = npredictions + tmpnmeasures;

typearray = [8, 1];
for i = 1:tmpnmeasures
    typearray = [typearray, 2, 4, 6];
end
typearray = [typearray, 3, 5, 7];

typehght = [halfhght, doublehght, twoandhalfhght, doublehght, twoandhalfhght, doublehght, twoandhalfhght, halfhght];

labeltext = [];
labeltext = [labeltext; {' '; ' '}];
[measures] = sortMeasuresForPaper(studydisplayname, measures);
tmpmeasures = measures(measures.RawMeas | measures.BucketMeas | measures.Range | measures.Volatility | measures.CChange | measures.PMean, :);
tmpfev1idx = tmpmeasures.Index(ismember(tmpmeasures.DisplayName, 'LungFunction'));

for m = 1:tmpnmeasures
    labeltext = [labeltext; cellstr(tmpmeasures.DisplayName{m}); ' '; ' '];
end
labeltext = [labeltext; {'Prediction'; ' '; ' '}];

baseplotname1 = sprintf('%s-%s-P%d %dfP3', ...
    basefilename, lbdisplayname, patientnbr1, patientnbr2);

[f, p] = createFigureAndPanelForPaper(name, widthinch, heightinch);

pivabsdates1 = pabs1(ismember(pabs1.Route, 'IV'),{'Startdn', 'Stopdn', 'RelStartdn','RelStopdn'});
for ab = 1:size(pivabsdates1,1)
    if pivabsdates1.Startdn(ab) < patientrow1.FirstMeasdn
        pivabsdates1.Startdn(ab)    = patientrow1.FirstMeasdn;
        pivabsdates1.RelStartdn(ab) = 1;
    end
    if pivabsdates1.Stopdn(ab) > patientrow1.LastMeasdn
        pivabsdates1.Stopdn(ab)    = patientrow1.LastMeasdn;
        pivabsdates1.RelStopdn(ab) = pmaxdays1;
    end
end

poralabsdates1 = pabs1(ismember(pabs1.Route, 'Oral'),{'Startdn', 'Stopdn', 'RelStartdn','RelStopdn'});
for ab = 1:size(poralabsdates1,1)
    if poralabsdates1.Startdn(ab) < patientrow1.FirstMeasdn
        poralabsdates1.Startdn(ab)    = patientrow1.FirstMeasdn;
        poralabsdates1.RelStartdn(ab) = 1;
    end
    if poralabsdates1.Stopdn(ab) > patientrow1.LastMeasdn
        poralabsdates1.Stopdn(ab)    = patientrow1.LastMeasdn;
        poralabsdates1.RelStopdn(ab) = pmaxdays1;
    end
end

pivabsdates2 = pabs2(ismember(pabs2.Route, 'IV'),{'Startdn', 'Stopdn', 'RelStartdn','RelStopdn'});
for ab = 1:size(pivabsdates2,1)
    if pivabsdates2.Startdn(ab) < patientrow2.FirstMeasdn
        pivabsdates2.Startdn(ab)    = patientrow2.FirstMeasdn;
        pivabsdates2.RelStartdn(ab) = 1;
    end
    if pivabsdates2.Stopdn(ab) > patientrow2.LastMeasdn
        pivabsdates2.Stopdn(ab)    = patientrow2.LastMeasdn;
        pivabsdates2.RelStopdn(ab) = pmaxdays2;
    end
end

poralabsdates2 = pabs2(ismember(pabs2.Route, 'Oral'),{'Startdn', 'Stopdn', 'RelStartdn','RelStopdn'});
for ab = 1:size(poralabsdates2,1)
    if poralabsdates2.Startdn(ab) < patientrow2.FirstMeasdn
        poralabsdates2.Startdn(ab)    = patientrow2.FirstMeasdn;
        poralabsdates2.RelStartdn(ab) = 1;
    end
    if poralabsdates2.Stopdn(ab) > patientrow2.LastMeasdn
        poralabsdates2.Stopdn(ab)    = patientrow2.LastMeasdn;
        poralabsdates2.RelStopdn(ab) = pmaxdays2;
    end
end

pexstsdates1 = pexsts1(:, {'IVStartDate', 'IVDateNum', 'Offset', 'Ex_Start', ...
    'LowerBound1', 'UpperBound1', 'LowerBound2', 'UpperBound2', ...
    'Pred', 'RelLB1', 'RelUB1', 'RelLB2', 'RelUB2'});

pexstsdates2 = pexsts2(:, {'IVStartDate', 'IVDateNum', 'Offset', 'Ex_Start', ...
    'LowerBound1', 'UpperBound1', 'LowerBound2', 'UpperBound2', ...
    'Pred', 'RelLB1', 'RelUB1', 'RelLB2', 'RelUB2'});

fidx1 = (pmFeatureIndex.PatientNbr == patientnbr1 & pmFeatureIndex.ScenType == 0);
pfeatindex1 = pmFeatureIndex(fidx1,:);
ppred1  = pmModelRes.pmNDayRes(labelidx).Pred(fidx1);
plabel1 = trcvlabels(fidx1,labelidx);

ppreddata1 = nan(1, pmaxdays1);
plabeldata1 = nan(1, pmaxdays1);
for d = 1:size(ppred1,1)
    ppreddata1(pfeatindex1.CalcDatedn(d))  = ppred1(d);
    plabeldata1(pfeatindex1.CalcDatedn(d)) = plabel1(d);
end

fidx2 = (pmFeatureIndex.PatientNbr == patientnbr2 & pmFeatureIndex.ScenType == 0);
pfeatindex2 = pmFeatureIndex(fidx2,:);
ppred2  = pmModelRes.pmNDayRes(labelidx).Pred(fidx2);
plabel2 = trcvlabels(fidx2,labelidx);

ppreddata2 = nan(1, pmaxdays2);
plabeldata2 = nan(1, pmaxdays2);
for d = 1:size(ppred2,1)
    ppreddata2(pfeatindex2.CalcDatedn(d))  = ppred2(d);
    plabeldata2(pfeatindex2.CalcDatedn(d)) = plabel2(d);
end

currhght = 1.0;
currplot = 1;
for i = 1:(ntitles + nlabels + 2 * (tmpnmeasures + npredictions) )
    type = typearray(i);
    if type == 1
        % labels for left and right axes
        currhght = currhght - typehght(type);
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [0, currhght, 1, typehght(type)]);
        displaytext = 'Measure';
        annotation(sp(i), 'textbox',  ...
                        'String', displaytext, ...
                        'Interpreter', 'tex', ...
                        'Units', 'normalized', ...
                        'Position', [0.20, 0, .2, 1], ...
                        'HorizontalAlignment', 'left', ...
                        'VerticalAlignment', 'bottom', ...
                        'LineStyle', 'none', ...
                        'FontSize', labelfontsize);
        annotation(sp(i), 'textbox',  ...
                        'String', displaytext, ...
                        'Interpreter', 'tex', ...
                        'Units', 'normalized', ...
                        'Position', [0.58, 0, .2, 1], ...
                        'HorizontalAlignment', 'left', ...
                        'VerticalAlignment', 'bottom', ...
                        'LineStyle', 'none', ...
                        'FontSize', labelfontsize);
    elseif type == 8
        % Title
        currhght = currhght - typehght(type);
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'BackgroundColor', 'white', ...
                        'OuterPosition', [0, currhght, 1, typehght(type)]);
        displaytext = sprintf('\\bf %s\\rm', 'Example 1');
        annotation(sp(i), 'textbox',  ...
                        'String', displaytext, ...
                        'Interpreter', 'tex', ...
                        'Units', 'normalized', ...
                        'Position', [0.3, 0, .2, 1], ...
                        'HorizontalAlignment', 'left', ...
                        'VerticalAlignment', 'bottom', ...
                        'LineStyle', 'none', ...
                        'FontSize', labelfontsize);
        displaytext = sprintf('\\bf %s\\rm', 'Example 2');
        annotation(sp(i), 'textbox',  ...
                        'String', displaytext, ...
                        'Interpreter', 'tex', ...
                        'Units', 'normalized', ...
                        'Position', [0.75, 0, .2, 1], ...
                        'HorizontalAlignment', 'left', ...
                        'VerticalAlignment', 'bottom', ...
                        'LineStyle', 'none', ...
                        'FontSize', labelfontsize);
    elseif type == 2 || type == 3
        % Label
        currhght = currhght - typehght(type);
        displaytext = {formatTexDisplayMeasure(labeltext{i}); sprintf('\\fontsize{%d} (%s)', unitfontsize, getUnitsForMeasure(labeltext{i}))};
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
    elseif type == 4 || type == 5 || type == 6 || type == 7
        % plot
        if type == 4 || type == 5
            sp(i) = uipanel('Parent', p, ...
                            'BorderType', 'none', ...
                            'BackgroundColor', 'white', ...
                            'OuterPosition', [labelwidth, currhght, plotwidth, typehght(type)]);
        elseif type == 6 || type == 7
            sp(i) = uipanel('Parent', p, ...
                            'BorderType', 'none', ...
                            'BackgroundColor', 'white', ...
                            'OuterPosition', [labelwidth + plotwidth, currhght, plotwidth, typehght(type)]);
        end
        %set(sp(i),'defaultAxesColorOrder',[[0, 0, 0]; [0, 0, 0]]);
        
        if type == 4 || type == 5
            pmaxdays      = pmaxdays1;
            pmeasstats    = pmeasstats1;
            pivabsdates   = pivabsdates1;
            poralabsdates = poralabsdates1;
            pexstsdates   = pexstsdates1;
            ppreddata     = ppreddata1;
        elseif type == 6 || type == 7
            pmaxdays      = pmaxdays2;
            pmeasstats    = pmeasstats2;
            pivabsdates   = pivabsdates2;
            poralabsdates = poralabsdates2;
            pexstsdates   = pexstsdates2;
            ppreddata     = ppreddata2;
        end
        days = (1:pmaxdays);
        %xl = [35 pmaxdays];
        xl = [35 113];
        
        if currplot <= tmpnmeasures
            m = currplot;
            if type == 4
                mrawdata      = prawdata(1, 1:pmaxdays, tmpmeasures.Index(m));
                if tmpmeasures.Index(m) == tmpfev1idx
                    actx = find(~isnan(mrawdata));
                    acty = mrawdata(~isnan(mrawdata));
                    fullx = (1:pmaxdays);
                    mdata = interp1(actx, acty, fullx, 'linear');
                else
                    mdata     = pinterpdata(1, 1:pmaxdays, tmpmeasures.Index(m));
                end
                vdata         = pinterpvoldata(1, 1:pmaxdays, tmpmeasures.Index(m));  
            elseif type == 6
                mrawdata      = prawdata(2, 1:pmaxdays, tmpmeasures.Index(m));
                if tmpmeasures.Index(m) == tmpfev1idx
                    actx = find(~isnan(mrawdata));
                    acty = mrawdata(~isnan(mrawdata));
                    fullx = (1:pmaxdays);
                    mdata = interp1(actx, acty, fullx, 'linear');
                else
                    mdata     = pinterpdata(2, 1:pmaxdays, tmpmeasures.Index(m));
                end
                vdata         = pinterpvoldata(2, 1:pmaxdays, tmpmeasures.Index(m));
            end

            displaymeasure = tmpmeasures.DisplayName{m};
            [smcolour, rwcolour] = getColourForMeasure(displaymeasure);            

            % set minimum y display range to be mean +/- 1 stddev (using patient/
            % measure level stats where they exist, otherwise overall study level
            % stats
            if size(pmeasstats.Mean(pmeasstats.MeasureIndex == tmpmeasures.Index(m)), 1) == 0
                yl = [(pmOverallStats.Mean(tmpmeasures.Index(m)) - pmOverallStats.StdDev(tmpmeasures.Index(m))) (pmOverallStats.Mean(tmpmeasures.Index(m)) + pmOverallStats.StdDev(tmpmeasures.Index(m)))];
            else
                yl = [(pmeasstats.Mean(pmeasstats.MeasureIndex == tmpmeasures.Index(m)) - pmeasstats.StdDev(pmeasstats.MeasureIndex == tmpmeasures.Index(m))) ...
                    (pmeasstats.Mean(pmeasstats.MeasureIndex == tmpmeasures.Index(m)) + pmeasstats.StdDev(pmeasstats.MeasureIndex == tmpmeasures.Index(m)))];
            end
            
            yl(1) = min(yl(1), min(mdata));
            yl(2) = max(yl(2), max(mdata));
            rangelimit = setMinYDisplayRangeForMeasure(tmpmeasures.Name{m});
            [yl] = setYDisplayRange(yl(1), yl(2), rangelimit);
            
            ax = subplot(1, 1, 1,'Parent', sp(i));
            ax.FontSize = axisfontsize;
            ax.TickDir = 'out';
            ax.XTickLabel = '';
            ax.XColor = 'white';
            
            %plotMeasurementDataForPaper(ax, days, applySmoothMethodToInterpRow(mdata, smfn, smwin, smln, tmpmeasures.Index(m), mfev1idx), smcolour, '-', 1.5, 'none', 1.0);
            plotMeasurementDataForPaper(ax, days, mrawdata, smcolour, 'none', 1.5, 'o',     2.0);
            plotMeasurementDataForPaper(ax, days, mdata,    smcolour, '-',    1.5, 'none', 2.0);

            for ab = 1:size(poralabsdates,1)
                hold on;
                plotFillArea(ax, poralabsdates.RelStartdn(ab), poralabsdates.RelStopdn(ab), yl(1), yl(2), 'yellow', 0.1, 'none');
                hold off;
            end

            for ab = 1:size(pivabsdates,1)
                hold on;
                plotFillArea(ax, pivabsdates.RelStartdn(ab), pivabsdates.RelStopdn(ab), yl(1), yl(2), 'red', 0.1, 'none');
                hold off;
            end

            for ex = 1:size(pexstsdates, 1)
                hold on;
                plotVerticalLine(ax, pexstsdates.Pred(ex), xl, yl, 'blue', '-', 1.0);
                plotFillArea(ax, pexstsdates.RelLB1(ex), pexstsdates.RelUB1(ex), yl(1), yl(2), 'blue', 0.1, 'none');
                if pexstsdates.RelLB2(ex) ~= -1
                    plotFillArea(ax, pexstsdates.RelLB2(ex), pexstsdates.RelUB2(ex), yl(1), yl(2), 'blue', 0.1, 'none');
                end
            end
            
            yticks = setTicks(yl(1), yl(2), 3);
            ax.YTick = yticks;
            ax.YTickLabel = addCommaFormat(yticks);
            title(ax,' ');
            xlim(ax, xl);
            ylim(ax, yl);
        else 
            % Predictions for Labels
            ax = subplot(1, 1, 1,'Parent', sp(i));
            yl = [0 100];
            xlabel(ax, 'Days from start of study');
            plotMeasurementDataForPaper(ax, days, ppreddata * 100,  'black', '-', 1.5, 'none', 2.0);

            for ab = 1:size(poralabsdates, 1)
                hold on;
                plotFillArea(ax, poralabsdates.RelStartdn(ab), poralabsdates.RelStopdn(ab), yl(1), yl(2), 'yellow', 0.1, 'none');
                hold off;
            end
            for ab = 1:size(pivabsdates, 1)
                hold on;
                plotFillArea(ax, pivabsdates.RelStartdn(ab), pivabsdates.RelStopdn(ab), yl(1), yl(2), 'red', 0.1, 'none');
                hold off;
            end
            for ex = 1:size(pexstsdates, 1)
                hold on;
                plotVerticalLine(ax, pexstsdates.Pred(ex), xl, yl, 'blue', '-', 1.0);
                plotFillArea(ax, pexstsdates.RelLB1(ex), pexstsdates.RelUB1(ex), yl(1), yl(2), 'blue', 0.1, 'none');
                if pexstsdates.RelLB2(ex) ~= -1
                    plotFillArea(ax, pexstsdates.RelLB2(ex), pexstsdates.RelUB2(ex), yl(1), yl(2), 'blue', 0.1, 'none');
                end
            end
            xlim(xl);
            ylim(yl);
        end
        if type == 6 || type == 7
            currplot = currplot + 1;
        end
    end
end

basedir = setBaseDir();
savePlotInDir(f, baseplotname1, basedir, plotsubfolder);
savePlotInDirAsSVG(f, baseplotname1, plotsubfolder);
close(f);

end
