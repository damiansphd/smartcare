function plotExByMonth(pmampred, testfeatidx, testlabels, testpatsplit, ...
    pmModelRes, basemodelresultsfile, plotsubfolder, lbdisplayname)

% plotExByMonth - plots a histogram of the exacerbations by month

predictionduration = size(pmModelRes.pmNDayRes,2);

monthorder = table('Size', [12, 2], 'VariableType', {'cell', 'double'}, 'VariableNames', {'Month', 'Order'});
monthorder.Month = [{'Jan'}; {'Feb'}; {'Mar'}; {'Apr'}; {'May'}; {'Jun'}; {'Jul'}; {'Aug'}; {'Sep'}; {'Oct'}; {'Nov'}; {'Dec'}];
monthorder.Order = (1:12)';

for n = 1:predictionduration
    plotsacross = 1;
    plotsdown = 4;

    [pmampredtest] = getPredictedIntr(pmampred, testfeatidx, testpatsplit, pmModelRes.pmNDayRes(n));
    
    name1 = sprintf('%s-%s%dDIntrMnth', basemodelresultsfile, lbdisplayname, n);
    [f1, p1] = createFigureAndPanel(name1, 'Portrait', 'A4');
    ax1 = gobjects(plotsacross * plotsdown,1);
    
    thisplot = 1;
    exmonths = datetime(0, month(pmampred.IVStartDate), 1);
    ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
    h = histogram(ax1(thisplot), exmonths, 'BinMethod', 'month');
    title('All Treatment Starts by month');
    
    thisplot = thisplot + 1;
    exmonths = datetime(0, month(pmampredtest.IVStartDate), 1);
    ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
    h = histogram(ax1(thisplot), exmonths, 'BinMethod', 'month');
    title('Predicted Treatment Starts by month');
    
    thisplot = thisplot + 1;
    hdata = testfeatidx(testfeatidx.ScenType == 0, :);
    hdata.Month(:) = month(testfeatidx.CalcDate, 'shortname');
    hdata.Label = testlabels;
    hdata = hdata(:, {'Month', 'Label'});

    totals = varfun(@sum, hdata, 'GroupingVariables', {'Month'});
    totals = innerjoin(totals, monthorder);
    totals = sortrows(totals, {'Order'}, 'ascend');
    totals.PosPct = 100 * totals.sum_Label./totals.GroupCount;
    ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
    b = bar(ax1(thisplot), totals.Order, totals.PosPct, 0.75, 'FaceColor', 'blue', 'EdgeColor', 'black');
    title('Positive Label % for Predicted Treatments By Month');
    
    basedir = setBaseDir();
    savePlotInDir(f1, name1, basedir, plotsubfolder);
    close(f1);

end

end

