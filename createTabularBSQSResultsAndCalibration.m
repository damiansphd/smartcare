function [combtable, qsarray, calibtable] = createTabularBSQSResultsAndCalibration(pmBSAllQS, ncombinations, nbssamples, ...
    qualmeasures, nqualmeas, basedir, subfolder, bsqsfile)

% createTabularBSQSResultsAndCalibration - create table and sample arrays for bootstrap
% quality scores, along with an array for calibration results.

combtable = [];
calibtable = [];
qsarray   = nan(ncombinations, nqualmeas, nbssamples);

% set the number of bins to calibrate over
nbins = 10;
smalldatathresh = 30;

% calculate bin edges & midpoints
binedges = zeros(1, nbins + 1);
for n = 1:nbins
    binedges(n + 1) = n / nbins;
end
binmids = zeros(1, nbins);
for n = 2:nbins + 1
    binmids(n - 1) = (binedges(n) + binedges(n - 1))/ 2;
end

plotsubfolder = 'Plots';
plotsperpage = 4;
plotsdownperpanel = 1;
plotsacross = 2;
npages = ceil(ncombinations/plotsperpage);
cpage = 1;
cplot = 1;

basename = strrep(strrep(bsqsfile, '.mat',''), 'BSQ','Calib');
name = sprintf('%s Pg%dof%d', basename, cpage, npages);
[f, p] = createFigureAndPanel(name, 'Portrait', 'A4');

for i = 1:ncombinations
    
    featureparamsrow  = pmBSAllQS(i).FeatureParams;
    modelparamsrow    = pmBSAllQS(i).ModelParams;
    otherrunparamsrow = pmBSAllQS(i).OtherRunParams;
    hpsuffix          = pmBSAllQS(i).hpsuffix;
    rtsuffix          = pmBSAllQS(i).rtsuffix;
    btsuffix          = pmBSAllQS(i).btsuffix;
    
    featureparamsfile = generateFileNameFromFullFeatureParams(featureparamsrow);
    featureparamsmatfile = sprintf('%s.mat', featureparamsfile);
    fprintf('Loading predictive model input data for %s\n', featureparamsfile);
    load(fullfile(basedir, subfolder, featureparamsmatfile), 'measures', 'nmeasures');
    mbasefilename = generateFileNameFromFullModelParams(featureparamsfile, modelparamsrow);
    mresultsfilename = sprintf('%s%s%s%s ModelResults', mbasefilename, hpsuffix, rtsuffix, btsuffix);
    modelparamsmatfile = sprintf('%s.mat', mresultsfilename);
    fprintf('Loading predictive model results for %s\n', mresultsfilename);
    load(fullfile(basedir, subfolder, modelparamsmatfile), 'pmModelRes', 'pmTrCVFeatureIndex', 'pmTestFeatureIndex', ...
        'pmTrCVIVLabels', 'pmTrCVExLabels', 'pmTrCVABLabels', 'pmTrCVExLBLabels', 'pmTrCVExABLabels', 'pmTrCVExABxElLabels', ...
        'pmTestIVLabels', 'pmTestExLabels', 'pmTestABLabels', 'pmTestExLBLabels', 'pmTestExABLabels', 'pmTestExABxElLabels');
    % added for backward compatibility
    if exist('pmTrCVExABxElLabels', 'var') ~= 1
        pmTrCVExABxElLabels = [];
        pmTestExABxElLabels = [];
    end
    labelidx = min(size(pmModelRes.pmNDayRes, 2), 5);
    
    trainlabels   = setLabelsForLabelMethod(modelparamsrow.labelmethod, pmTrCVIVLabels, pmTrCVExLabels, pmTrCVABLabels, pmTrCVExLBLabels, pmTrCVExABLabels, pmTrCVExABxElLabels);
    testlabels    = setLabelsForLabelMethod(modelparamsrow.labelmethod, pmTestIVLabels, pmTestExLabels, pmTestABLabels, pmTestExLBLabels, pmTestExABLabels, pmTestExABxElLabels);
    
    trainlabels = trainlabels(pmTrCVFeatureIndex.ScenType == 0, :);
    testlabels = testlabels(pmTestFeatureIndex.ScenType == 0, :);
    
    [~, ~, trainlabels, ~, ~, ~, testlabels, ~] = setTrainTestArraysForRunType([], [], trainlabels, [], ...
                                                        [], [], testlabels, [], otherrunparamsrow.runtype);
    
    %[trcvlabels] = setLabelsForLabelMethod(modelparamsrow.labelmethod, pmTrCVIVLabels, pmTrCVExLabels, pmTrCVABLabels, pmTrCVExLBLabels, pmTrCVExABLabels, pmTrCVExABxElLabels);

    [resultrow, resultstring] = setBSQSTableDisplayRow(featureparamsrow, modelparamsrow, pmBSAllQS(i).NDayQS, measures, nmeasures);
    combtable = [combtable; resultrow];
    
    for n = 1:nqualmeas
        qsarray(i, n, :) = pmBSAllQS(i).NDayQS.(sprintf('bs%s',qualmeasures{n}));
    end
    
    fold = 0;
    modelcalibration = calcModelCalibration(testlabels(:, labelidx), pmModelRes.pmNDayRes(labelidx).Pred, binedges, nbins, fold);
    [calibrow] = setCalibrationTableDisplayRow(resultrow, modelcalibration, nbins);
    calibtable = [calibtable; calibrow];
    
    uipypos = 1 - cplot/plotsperpage;
    uipysz  = 1/plotsperpage;
    uiptitle = resultstring;
    sp(cplot) = uipanel('Parent', p, ...
                  'BorderType', 'none', ...
                  'OuterPosition', [0.0,uipypos, 1.0, uipysz], ...
                  'Title', uiptitle, 'TitlePosition', 'centertop', 'FontSize', 8);
    ax1 = gobjects(plotsdownperpanel * plotsacross, 1);
    
    ax1(1) = subplot(plotsdownperpanel, plotsacross, 1, 'Parent', sp(cplot));
    sdidx = (modelcalibration.NbrInBin(modelcalibration.Fold == fold) <= smalldatathresh);
    plotModelCalibration(ax1(1), binmids, modelcalibration.Calibration(modelcalibration.Fold == fold), sdidx, [0.7, 0.7, 0.7], 'Blue', 'Red', 'Overall');
    ax1(2) = plottextModelCalibrationTable(sp(cplot), ax1(1), modelcalibration(modelcalibration.Fold == fold, :), fold, plotsacross, sdidx, resultrow);
    
    cplot = cplot + 1;
    
    if (i == ncombinations)
        basedir = setBaseDir();
        savePlotInDir(f, name, basedir, plotsubfolder);
        close(f); 
    elseif ((cplot - 1) == plotsperpage) 
        basedir = setBaseDir();
        savePlotInDir(f, name, basedir, plotsubfolder);
        close(f);
        cpage = cpage + 1;
        cplot = 1;
        name = sprintf('%s Pg%dof%d', basename, cpage, npages);
        [f,p] = createFigureAndPanel(name, 'Portrait', 'A4');    
    end
    
end

end


