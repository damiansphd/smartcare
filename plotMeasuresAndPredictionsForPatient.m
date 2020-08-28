function plotMeasuresAndPredictionsForPatient(patientrow, pabs, pexsts, prawdata, pinterpdata, pinterpvoldata, ...
    testfeatidx, testlabels, pmModelRes, pmOverallStats, ...
    pmeasstats, measures, nmeasures, mvolstats, labelidx, pmFeatureParamsRow, ...
    lbdisplayname, plotsubfolder, basefilename)

% plotMeasuresAndPredictionsForPatient - for a given patient, plot the measures along
% with the predictions from the predictive classification model and the 
% true labels.

basedir = setBaseDir();

smfn       = pmFeatureParamsRow.smfunction;
smwin      = pmFeatureParamsRow.smwindow;
smln       = pmFeatureParamsRow.smlength;
normwindow = pmFeatureParamsRow.normwindow;

patientnbr = patientrow.PatientNbr;
pmaxdays = patientrow.LastMeasdn - patientrow.FirstMeasdn + 1;

mfev1idx = measures.Index(ismember(measures.DisplayName, 'LungFunction'));

baseplotname1 = sprintf('%s-%s%dDPredP%d(%s%d)', ...
    basefilename, lbdisplayname, labelidx, patientnbr, patientrow.Study{1}, patientrow.ID);

pivabsdates = pabs(ismember(pabs.Route, 'IV'),{'Startdn', 'Stopdn', 'RelStartdn','RelStopdn'});
for ab = 1:size(pivabsdates,1)
    if pivabsdates.Startdn(ab) < patientrow.FirstMeasdn
        pivabsdates.Startdn(ab)    = patientrow.FirstMeasdn;
        pivabsdates.RelStartdn(ab) = 1;
    end
    if pivabsdates.Stopdn(ab) > patientrow.LastMeasdn
        pivabsdates.Stopdn(ab)    = patientrow.LastMeasdn;
        pivabsdates.RelStopdn(ab) = pmaxdays;
    end
end

poralabsdates = pabs(ismember(pabs.Route, 'Oral'),{'Startdn', 'Stopdn', 'RelStartdn','RelStopdn'});
for ab = 1:size(poralabsdates,1)
    if poralabsdates.Startdn(ab) < patientrow.FirstMeasdn
        poralabsdates.Startdn(ab)    = patientrow.FirstMeasdn;
        poralabsdates.RelStartdn(ab) = 1;
    end
    if poralabsdates.Stopdn(ab) > patientrow.LastMeasdn
        poralabsdates.Stopdn(ab)    = patientrow.LastMeasdn;
        poralabsdates.RelStopdn(ab) = pmaxdays;
    end
end

pexstsdates = pexsts(:, {'IVStartDate', 'IVDateNum', 'Offset', 'Ex_Start', ...
    'LowerBound1', 'UpperBound1', 'LowerBound2', 'UpperBound2', ...
    'Pred', 'RelLB1', 'RelUB1', 'RelLB2', 'RelUB2'});

fidx = (testfeatidx.PatientNbr == patientnbr & testfeatidx.ScenType == 0);
pfeatindex = testfeatidx(fidx,:);
ppred  = pmModelRes.pmNDayRes(labelidx).Pred(fidx);
plabel = testlabels(fidx,labelidx);

ppreddata = nan(1, pmaxdays);
plabeldata = nan(1, pmaxdays);
for d = 1:size(ppred,1)
    ppreddata(pfeatindex.CalcDatedn(d))  = ppred(d);
    plabeldata(pfeatindex.CalcDatedn(d)) = plabel(d);
end

plotsacross = 1;
plotsdown = 10;
page = 1;
npages = ceil((nmeasures + 1) / plotsdown);

plotname = sprintf('%s-P%dof%d', baseplotname1, page, npages);
[f1,p1] = createFigureAndPanel(plotname, 'Portrait', 'A4');
left_color = [0, 0.65, 1];
right_color = [0.13, 0.55, 0.13];
set(f1,'defaultAxesColorOrder',[left_color; right_color]);

thisplot = 1;

for m = 1:nmeasures
    
    days = (1:pmaxdays);
    mrawdata = prawdata(1, 1:pmaxdays, m);
    mdata = pinterpdata(1, 1:pmaxdays, m);
    vdata = pinterpvoldata(1, 1:pmaxdays, m);
    interppts = mdata;
    interppts(~isnan(mrawdata)) = nan;
    intervppts = vdata;
    intervppts(~isnan(mrawdata)) = nan;
    [combinedmask, plottext, left_color, lint_color, right_color, rint_color] = setPlotColorsAndText(measures(m, :));
    
    xl = [1 pmaxdays];

    % set minimum y display range to be mean +/- 1 stddev (using patient/
    % measure level stats where they exist, otherwise overall study level
    % stats
    if size(pmeasstats.Mean(pmeasstats.MeasureIndex == m), 1) == 0
        yl = [(pmOverallStats.Mean(m) - pmOverallStats.StdDev(m)) (pmOverallStats.Mean(m) + pmOverallStats.StdDev(m))];
    else
        yl = [(pmeasstats.Mean(pmeasstats.MeasureIndex == m) - pmeasstats.StdDev(pmeasstats.MeasureIndex == m)) ...
            (pmeasstats.Mean(pmeasstats.MeasureIndex == m) + pmeasstats.StdDev(pmeasstats.MeasureIndex == m))];
    end
    
    ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
    yyaxis(ax1(thisplot),'left');
    
    [xl, yl] = plotMeasurementData(ax1(thisplot), days, mdata, xl, yl, plottext, combinedmask, left_color, ':', 1.0, 'none', 1.0, 'blue', 'green');
    %[xl, yl] = plotMeasurementData(ax1(thisplot), days, smooth(mdata,5), xl, yl, plottext, combinedmask, left_color, '-', 1.0, 'none', 1.0, 'blue', 'green');
    [xl, yl] = plotMeasurementData(ax1(thisplot), days, applySmoothMethodToInterpRow(mdata, smfn, smwin, smln, m, mfev1idx), xl, yl, plottext, combinedmask, left_color, '-', 1.0, 'none', 1.0, 'blue', 'green');
    [xl, yl] = plotMeasurementData(ax1(thisplot), days, interppts, xl, yl, plottext, combinedmask, left_color, 'none', 1.0, 'o', 1.0, lint_color, lint_color);
    
    for ab = 1:size(poralabsdates,1)
        hold on;
        plotFillArea(ax1(thisplot), poralabsdates.RelStartdn(ab), poralabsdates.RelStopdn(ab), yl(1), yl(2), 'yellow', 0.1, 'none');
        hold off;
    end
    
    for ab = 1:size(pivabsdates,1)
        hold on;
        plotFillArea(ax1(thisplot), pivabsdates.RelStartdn(ab), pivabsdates.RelStopdn(ab), yl(1), yl(2), 'red', 0.1, 'none');
        hold off;
    end
    
    for ex = 1:size(pexstsdates, 1)
        hold on;
        [xl, yl] = plotVerticalLine(ax1(thisplot), pexstsdates.Pred(ex), xl, yl, 'blue', '-', 1.0);
        plotFillArea(ax1(thisplot), pexstsdates.RelLB1(ex), pexstsdates.RelUB1(ex), yl(1), yl(2), 'blue', 0.1, 'none');
        if pexstsdates.RelLB2(ex) ~= -1
            plotFillArea(ax1(thisplot), pexstsdates.RelLB2(ex), pexstsdates.RelUB2(ex), yl(1), yl(2), 'blue', 0.1, 'none');
        end
    end
    
    yl2 = [0 mvolstats(thisplot, 6)];
    yyaxis(ax1(thisplot),'right');
    
    [xl, yl2] = plotMeasurementData(ax1(thisplot), days(normwindow+2:end), vdata(normwindow+2:end), xl, yl2, plottext, combinedmask, right_color, ':', 1.0, 'none', 1.0, 'blue', 'green');
    [xl, yl2] = plotMeasurementData(ax1(thisplot), days(normwindow+2:end), smooth(vdata(normwindow+2:end),5), xl, yl2, plottext, combinedmask, right_color, '-', 1.0, 'none', 1.0, 'blue', 'green');
    [xl, yl2] = plotMeasurementData(ax1(thisplot), days(normwindow+2:end), intervppts(normwindow+2:end), xl, yl2, plottext, combinedmask, right_color, 'none', 1.0, 'o', 1.0, rint_color, rint_color);

    thisplot = thisplot + 1;
    if thisplot > plotsdown
        savePlotInDir(f1, plotname, basedir, plotsubfolder);
        close(f1);
        thisplot = 1;
        page = page + 1;
        plotname = sprintf('%s-P%dof%d', baseplotname1, page, npages);
        [f1,p1] = createFigureAndPanel(plotname, 'Portrait', 'A4');
        left_color = [0, 0.65, 1];
        right_color = [0.13, 0.55, 0.13];
        set(f1,'defaultAxesColorOrder',[left_color; right_color]);
    end
end

% Predictions for Labels

ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
xlim(xl);
yl = [0 1];
ylim(yl);
plottitle = sprintf('%d Day Prediction for %s Labels', labelidx, lbdisplayname);
[xl, yl] = plotMeasurementData(ax1(thisplot), days, plabeldata, xl, yl, plottitle, 0, 'green', '-', 1.0, 'none', 1.0, 'blue', 'green');
[xl, yl] = plotMeasurementData(ax1(thisplot), days, ppreddata, xl, yl, plottitle, 0, 'black', '-', 1.0, 'none', 1.0, 'blue', 'green');

for ab = 1:size(poralabsdates, 1)
    hold on;
    plotFillArea(ax1(thisplot), poralabsdates.RelStartdn(ab), poralabsdates.RelStopdn(ab), yl(1), yl(2), 'yellow', 0.1, 'none');
    hold off;
end
for ab = 1:size(pivabsdates, 1)
    hold on;
    plotFillArea(ax1(thisplot), pivabsdates.RelStartdn(ab), pivabsdates.RelStopdn(ab), yl(1), yl(2), 'red', 0.1, 'none');
    hold off;
end
for ex = 1:size(pexstsdates, 1)
    hold on;
    [xl, yl] = plotVerticalLine(ax1(thisplot), pexstsdates.Pred(ex), xl, yl, 'blue', '-', 1.0);
    plotFillArea(ax1(thisplot), pexstsdates.RelLB1(ex), pexstsdates.RelUB1(ex), yl(1), yl(2), 'blue', 0.1, 'none');
    if pexstsdates.RelLB2(ex) ~= -1
        plotFillArea(ax1(thisplot), pexstsdates.RelLB2(ex), pexstsdates.RelUB2(ex), yl(1), yl(2), 'blue', 0.1, 'none');
    end
end

basedir = setBaseDir();
savePlotInDir(f1, plotname, basedir, plotsubfolder);
close(f1);


predictionduration = size(pmModelRes.pmNDayRes, 2);
if predictionduration > 1
    plotsacross = 1;
    plotsdown = pmFeatureParamsRow.predictionduration;

    baseplotname2 = sprintf('%s-%sAllPredP%d(%s%d)', ...
                        basefilename, lbdisplayname, patientnbr, patientrow.Study{1}, patientrow.ID);
    [f2,p2] = createFigureAndPanel(baseplotname2, 'Portrait', 'A4');

    ax2 = gobjects(predictionduration,1);

    for n = 1:predictionduration
        ppred  = pmModelRes.pmNDayRes(n).Pred(fidx);
        plabel = testlabels(fidx, n);
    
        ppreddata = nan(1, pmaxdays);
        plabeldata = nan(1, pmaxdays);

        for d = 1:size(ppred,1)
            ppreddata(pfeatindex.CalcDatedn(d))  = ppred(d);
            plabeldata(pfeatindex.CalcDatedn(d)) = plabel(d);
        end

        ax2(n) = subplot(plotsdown, plotsacross, n, 'Parent',p2);
        xlim(xl);
        yl = [0 1];
        ylim(yl);
        plottitle = sprintf('%d Day Prediction for %s Labels', n, lbdisplayname);
        [xl, yl] = plotMeasurementData(ax2(n), days, plabeldata, xl, yl, plottitle, 0, 'green', '-', 1.0, 'none', 1.0, 'blue', 'green');
        [xl, yl] = plotMeasurementData(ax2(n), days, ppreddata,  xl, yl, plottitle, 0, 'black', '-', 1.0, 'none', 1.0, 'blue', 'green');

        for ab = 1:size(poralabsdates,1)
            hold on;
            plotFillArea(ax2(n), poralabsdates.RelStartdn(ab), poralabsdates.RelStopdn(ab), yl(1), yl(2), 'yellow', 0.1, 'none');
            hold off;
        end
    
        for ab = 1:size(pivabsdates,1)
            hold on;
            plotFillArea(ax2(n), pivabsdates.RelStartdn(ab), pivabsdates.RelStopdn(ab), yl(1), yl(2), 'red', 0.1, 'none');
            hold off;
        end
        
        for ex = 1:size(pexstsdates, 1)
            hold on;
            [xl, yl] = plotVerticalLine(ax2(n), pexstsdates.Pred(ex), xl, yl, 'blue', '-', 1.0);
            plotFillArea(ax2(n), pexstsdates.RelLB1(ex), pexstsdates.RelUB1(ex), yl(1), yl(2), 'blue', 0.1, 'none');
            if pexstsdates.RelLB2(ex) ~= -1
                plotFillArea(ax2(n), pexstsdates.RelLB2(ex), pexstsdates.RelUB2(ex), yl(1), yl(2), 'blue', 0.1, 'none');
            end
        end    
    end

    basedir = setBaseDir();
    savePlotInDir(f2, baseplotname2, basedir, plotsubfolder);
    close(f2);

end

end

