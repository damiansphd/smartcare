function [lcbymodelrun, offsetbymodelrun] = amEMMCCompareMultipleModelRunToTestData(amLabelledInterventions, modelidx, models, plotmode, study)

% amEMMCCompareMultipleModelRunToTestData - compares the output of multiple model runs to
% the labelled test data. Able to handle multiple latent curve sets.

lcbymodelrun     = zeros(size(amLabelledInterventions, 1), size(models,1));
offsetbymodelrun = zeros(size(amLabelledInterventions, 1), size(models,1));

testidx = amLabelledInterventions.IncludeInTestSet=='Y';
testsetsize = sum(testidx);

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

nmodelruns = size(models, 1) - modelidx + 1;

datatable = table('Size',[(nmodelruns * testsetsize), 4], ...
    'VariableTypes', {'double',   'double',     'double',      'double'}, ...
    'VariableNames', {'ModelRun', 'TestSetNbr', 'LatentCurve', 'Count'});

%rowtoadd = datatable(1, :);
%datatable(1:size(datatable,1),:) = [];

resulttable = [];

ylabels = cell(size(models, 1) - modelidx + 1, 1);
modelrunlist = zeros(size(models, 1) - modelidx + 1, 1);
qualityscore = zeros(size(models, 1) - modelidx + 1, 1);

rc = 1;

for idx = 1:nmodelruns
    % first get index into models array corresponding to the current
    % iteration
    midx = modelidx + idx - 1;
    if (~isequal(models{midx}, 'placeholder') && ~contains(models{midx}, 'xxx'))
        clear randomseed;
        clear datasmoothmethod;
        clear vshiftmode;
        clear vshiftmax;
        load(fullfile(basedir, subfolder, sprintf('%s.mat', models{midx})), 'amInterventions', 'ninterventions', ...
            'mversion', 'study', 'treatgap', 'testlabelmthd', 'sigmamethod', 'mumethod', ...
                        'curveaveragingmethod', 'smoothingmethod', 'datasmoothmethod', 'measuresmask', ...
                        'runmode', 'randomseed', 'intrmode', 'imputationmode', 'confidencemode', 'max_offset', ...
                        'align_wind', 'outprior', 'heldbackpct', 'confidencethreshold', 'countthreshold', 'nlatentcurves', ...
                        'niterations', 'vshiftmode', 'vshiftmax', 'scenario', 'ex_start', 'qual', 'measures', 'nmeasures');
        % for backward compatibility
        if (~exist('randomseed','var'))
            randomseed = 0;
        end
        if (~exist('datasmoothmethod','var'))
            datasmoothmethod = 1;
        end
        if (~exist('heldbackpct','var'))
            heldbackpct = 0;
        end
        if (~exist('intrmode','var'))
            intrmode = 1;
        end
        if (~exist('scenario','var'))
            scenario = '';
        end
        if (~exist('vshiftmode','var'))
            vshiftmode = 0;
        end
        if (~exist('vshiftmax','var'))
            if vshiftmode == 0
                vshiftmax = 0.0;
            else
                vshiftmax = 0.3;
            end
        end
        temp = hsv(64);
        brightness = .9;
        colors(1,:) = temp(20,:) .* brightness;
        
        for i = 2:15
            colors(i,:)  = temp(16 - (i-1),:)  .* brightness;
        end
        for i = 16:max_offset - 1
            colors(i,:)  = temp(1,:)  .* brightness;
        end
        
        testset   = innerjoin(amLabelledInterventions(testidx, :), amInterventions, 'LeftKeys', {'SmartCareID', 'IVDateNum'}, 'RightKeys', {'SmartCareID', 'IVDateNum'}, 'RightVariables', {});
        amintrtst = innerjoin(amInterventions, amLabelledInterventions(testidx, :), 'LeftKeys', {'SmartCareID', 'IVDateNum'}, 'RightKeys', {'SmartCareID', 'IVDateNum'}, 'RightVariables', {});
        testsetsize = size(testset,1);    
        modelpreds = amintrtst.Pred;

        matchidx   = (modelpreds >= (testset.IVScaledDateNum + testset.LowerBound1) & modelpreds <= (testset.IVScaledDateNum + testset.UpperBound1)) | ...
                     (modelpreds >= (testset.IVScaledDateNum + testset.LowerBound2) & modelpreds <= (testset.IVScaledDateNum + testset.UpperBound2));
        
        fprintf('For model %s%d: %s:\n', mversion, midx, models{midx});
        fprintf('%2d of %2d results match labelled test data, ', sum(matchidx), testsetsize); 
        %rowtoadd.ModelRun = midx;
        
        distArr = zeros(1,4);
        for i = 1:size(testset,1)
            if (testset.SmartCareID(i) ~= amintrtst.SmartCareID(i) || testset.IVDateNum(i) ~= amintrtst.IVDateNum(i))
                fprintf('**** WARNING - Mismatch between Labelled test data and Model Interventions for intrnbr %d ****\n', testset.InterNbr(i));
            end
         
            %rowtoadd.TestSetNbr = testset.IntrNbr(i);
            %rowtoadd.LatentCurve = amintrtst.LatentCurve(i);
            
            datatable.ModelRun(rc)    = midx;
            datatable.TestSetNbr(rc)  = testset.IntrNbr(i);
            datatable.LatentCurve(rc) = amintrtst.LatentCurve(i);

            if matchidx(i)
                %rowtoadd.Count = 0;
                datatable.Count(rc) = 0;
            else
                distArr(1) = abs(testset.IVScaledDateNum(i) + testset.LowerBound1(i) - modelpreds(i));
                distArr(2) = abs(testset.IVScaledDateNum(i) + testset.UpperBound1(i) - modelpreds(i));
                if testset.LowerBound2(i) ~= 0
                    distArr(3) = abs(testset.IVScaledDateNum(i) + testset.LowerBound2(i) - modelpreds(i));
                    distArr(4) = abs(testset.IVScaledDateNum(i) + testset.UpperBound2(i) - modelpreds(i));
                else
                    distArr(3) = 100;
                    distArr(4) = 100;
                end
                dist = min(distArr);
                if dist > (max_offset - 1)
                    dist = max_offset - 1;
                end
                %rowtoadd.Count = dist;
                datatable.Count(rc) = dist;
            end
            %fprintf('For intervention %2d, Match = %d, Dist = %d\n', testset.InterNbr(i), matchidx(i), rowtoadd.Count);
            %datatable = [datatable ; rowtoadd];
            rc = rc + 1;
        end
        
        fprintf('Quality score = %d\n', sum(datatable.Count(datatable.ModelRun==midx)));
        fprintf('\n');
        modelrunlist(idx) = midx;
        qualityscore(idx) = sum(datatable.Count(datatable.ModelRun==midx));
        
        ylabels{idx} = sprintf('mm%dmo%dds%drm%drs%dct%dlm%dvs%dvm%.1fsc%sni%dex%d\n(%2d:%2d)', measuresmask, ...
            max_offset, datasmoothmethod, runmode, randomseed, countthreshold, testlabelmthd, vshiftmode, vshiftmax, scenario, niterations, ...
            ex_start, sum(matchidx), sum(datatable.Count(datatable.ModelRun==midx)));

        [resultrow] = setResultTableDisplayRow(mversion, study, treatgap, testlabelmthd, sigmamethod, mumethod, ...
                        curveaveragingmethod, smoothingmethod, datasmoothmethod, measuresmask, runmode, randomseed, ...
                        intrmode, imputationmode, confidencemode, max_offset, align_wind, ...
                        outprior, heldbackpct, confidencethreshold, countthreshold, nlatentcurves, ...
                        niterations, vshiftmode, vshiftmax, scenario, ex_start, qual, ...
                        sum(matchidx), testsetsize, sum(datatable.Count(datatable.ModelRun==midx)), measures, nmeasures);
        resulttable = [resulttable; resultrow];
        
        for i = 1:ninterventions
            lcbymodelrun(i, midx)     = amInterventions.LatentCurve(i);
            offsetbymodelrun(i, midx) = amInterventions.Offset(i);
        end
    end
end

labelsandquality = [array2table(modelrunlist), array2table(ylabels), array2table(qualityscore)];
labelsandquality = sortrows(labelsandquality, {'ylabels'}, {'ascend'});
resulttable = sortrows(resulttable, {'NumLCSets', 'Measures', 'MaxOffset', 'DataSmooth', 'RunMode', 'RandomSeed'});

if ismember(plotmode, {'Overall'})
    plotsacross = 1;
    plotsdown = 1;
    plottitle = sprintf('%s Model Run Results %s_gp%d_lm%d_in%d_nl%d(%d-%d) vs Labelled Test Data', study, mversion, treatgap, testlabelmthd, intrmode, nlatentcurves,  modelidx, size(models,1));

    [f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');

    subplot(plotsdown, plotsacross, 1, 'Parent', p);
    h = heatmap(p, datatable, 'TestSetNbr', 'ModelRun', 'Colormap', colors(1:max(datatable.Count),:), 'MissingDataColor', 'white', ...
        'ColorVariable','Count','ColorMethod','max', 'MissingDataLabel', 'No data', 'ColorBarVisible', 'on', 'FontSize', 8);
    h.Title = ' ';
    h.FontName = 'Monaco';
    h.FontSize = 6;
    h.XLabel = 'Intervention Nbr';
    h.YLabel = 'Model Run';
    h.YDisplayData = labelsandquality.modelrunlist;
    h.YDisplayLabels = labelsandquality.ylabels;
    h.CellLabelColor = 'none';
    h.GridVisible = 'on';

    plotsubfolder = 'Plots';
    savePlotInDir(f, sprintf('%s %s', plottitle, datestr(clock(),30)), plotsubfolder);
    close(f);

    writetable(resulttable, fullfile(basedir, 'ExcelFiles', sprintf('%s.xlsx', plottitle)));
elseif ismember(plotmode, {'ByLCSet'})
    % add dummy rows to ensure a column for each entry in the test set is
    % shown on all latent curve heatmaps
    dispmin = min(datatable.ModelRun);
    dispmax = max(datatable.ModelRun);
    rowtoadd = datatable(1, :);
    rowtoadd.ModelRun = 0;
    for i = 1:testsetsize
        rowtoadd.TestSetNbr = testset.IntrNbr(i);
        rowtoadd.Count      = 0;
        for n = 1:nlatentcurves
            rowtoadd.LatentCurve = n;
            datatable = [datatable ; rowtoadd];
        end
    end
    
    for n = 1:nlatentcurves
        plotsacross = 1;
        plotsdown = 1;
        plottitle = sprintf('%s Model Run Results %s_in%d_nl%d_tg%d(%d-%d) vs Labelled Test Data C%d', study, mversion, intrmode, nlatentcurves, treatgap, modelidx, size(models,1), n);

        [f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');

        subplot(plotsdown,plotsacross, 1,'Parent',p);
        h = heatmap(p, datatable(datatable.LatentCurve==n,:), 'TestSetNbr', 'ModelRun', 'Colormap', colors(1:max(datatable.Count),:), 'MissingDataColor', 'white', ...
            'ColorVariable','Count','ColorMethod','max', 'MissingDataLabel', 'No data', 'ColorBarVisible', 'on', 'FontSize', 8);
        h.Title = ' ';
        h.FontName = 'Monaco';
        h.FontSize = 6;
        h.XLabel = 'Intervention Nbr';
        h.YLabel = 'Model Run';
        h.YDisplayData = labelsandquality.modelrunlist;
        h.YDisplayLabels = labelsandquality.ylabels;
        h.YLimits = {dispmin,dispmax};
        h.CellLabelColor = 'none';
        h.GridVisible = 'on';

        plotsubfolder = 'Plots';
        savePlotInDir(f, sprintf('%s %s', plottitle, datestr(clock(),30)), plotsubfolder);
        close(f);
    end
else
    fprintf('**** Unknown plot mode ****\n');
end

