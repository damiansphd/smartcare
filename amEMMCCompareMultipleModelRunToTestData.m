function amEMMCCompareMultipleModelRunToTestData(amLabelledInterventions, modelrun, modelidx, models)

% amEMMCCompareMultipleModelRunToTestData - compares the output of multiple model runs to
% the labelled test data. Able to handle multiple latent curve sets.

amLabelledInterventions = [array2table([1:size(amLabelledInterventions,1)]'), amLabelledInterventions];
amLabelledInterventions.Properties.VariableNames{'Var1'} = 'InterNbr';

testidx = amLabelledInterventions.IncludeInTestSet=='Y';
testset    = amLabelledInterventions(testidx, :);
testsetsize = sum(testidx);

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

datatable = table('Size',[1 4], ...
    'VariableTypes', {'double',   'double',     'double',      'double'}, ...
    'VariableNames', {'ModelRun', 'TestSetNbr', 'LatentCurve', 'Count'});

rowtoadd = datatable;
datatable(1:size(datatable,1),:) = [];

resulttable = [];

ylabels = {'Dummy'};
modelrunlist = 0;
qualityscore = 0;

for midx = modelidx:size(models,1)
    if (~isequal(models{midx}, 'placeholder') && ~contains(models{midx}, 'xxx'))
        clear randomseed;
        clear datasmoothmethod;
        load(fullfile(basedir, subfolder, sprintf('%s.mat', models{midx})));
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
        temp = hsv;
        brightness = .9;
        colors(1,:) = temp(20,:) .* brightness;
        
        %for i = 2:12
        %    colors(i,:)  = temp(13 - (i-1),:)  .* brightness;
        %end
        %for i = 13:max_offset - 1
        %    colors(i,:)  = temp(1,:)  .* brightness;
        %end
        for i = 2:15
            colors(i,:)  = temp(16 - (i-1),:)  .* brightness;
        end
        for i = 16:max_offset - 1
            colors(i,:)  = temp(1,:)  .* brightness;
        end

        modelpreds = amInterventions.Pred(testidx);
        
        matchidx   = (modelpreds >= (testset.IVScaledDateNum + testset.LowerBound1) & modelpreds <= (testset.IVScaledDateNum + testset.UpperBound1)) | ...
                     (modelpreds >= (testset.IVScaledDateNum + testset.LowerBound2) & modelpreds <= (testset.IVScaledDateNum + testset.UpperBound2));
        
        fprintf('For model %s%d: %s:\n', mversion, midx, models{midx});
        fprintf('%2d of %2d results match labelled test data, ', sum(matchidx), testsetsize); 
        rowtoadd.ModelRun = midx;
        
        for i = 1:size(testset,1)
            rowtoadd.TestSetNbr = testset.InterNbr(i);
            if matchidx(i)
                rowtoadd.Count = 0;
            else
                dist1 = min(abs(testset.IVScaledDateNum(i) + testset.LowerBound1(i) - modelpreds(i)), abs(testset.IVScaledDateNum(i) + testset.LowerBound2(i) - modelpreds(i)));
                dist2 = min(abs(testset.IVScaledDateNum(i) + testset.UpperBound1(i) - modelpreds(i)), abs(testset.IVScaledDateNum(i) + testset.UpperBound2(i) - modelpreds(i)));
                dist = min(dist1, dist2);
                if dist > (max_offset - 1)
                    dist = max_offset - 1;
                end
                rowtoadd.Count = dist;
            end
            %fprintf('For intervention %2d, Match = %d, Dist = %d\n', testset.InterNbr(i), matchidx(i), rowtoadd.Count);
            datatable = [datatable ; rowtoadd];
        end
        
        fprintf('Quality score = %d\n', sum(datatable.Count(datatable.ModelRun==midx)));
        fprintf('\n');
        modelrunlist = [modelrunlist; midx];
        qualityscore = [qualityscore; sum(datatable.Count(datatable.ModelRun==midx))];
        if niterations == 200
            convergeflag = '*';
        else
            convergeflag = ' ';
        end
        ylabels = [ylabels; sprintf('nl%dmm%dmo%dds%drm%drs%d%s\n(%2d:%2d)', nlatentcurves, measuresmask, max_offset, datasmoothmethod, runmode, randomseed,convergeflag, sum(matchidx), sum(datatable.Count(datatable.ModelRun==midx)))];

        [resultrow] = setResultTableDisplayRow(mversion, study, sigmamethod, mumethod, ...
                        curveaveragingmethod, smoothingmethod, datasmoothmethod, measuresmask, runmode, randomseed, ...
                        imputationmode, confidencemode, max_offset, align_wind, ...
                        outprior, heldbackpct, confidencethreshold, nlatentcurves, niterations, ex_start, qual, ...
                        sum(matchidx), testsetsize, sum(datatable.Count(datatable.ModelRun==midx)), measures, nmeasures);
        resulttable = [resulttable; resultrow];
    end
end

% remove dummy row
modelrunlist(1) = [];
qualityscore(1) = [];
ylabels(1) = [];

labelsandquality = [array2table(modelrunlist), array2table(ylabels), array2table(qualityscore)];
labelsandquality = sortrows(labelsandquality, {'ylabels'}, {'ascend'});
resulttable = sortrows(resulttable, {'NumLCSets', 'Measures', 'MaxOffset', 'DataSmooth', 'RunMode', 'RandomSeed'});

plotsacross = 1;
plotsdown = 1;
plottitle = sprintf('Model Run Results %s(%d-%d) vs Labelled Test Data', mversion, modelidx, size(models,1));

[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');

subplot(plotsdown,plotsacross,[1],'Parent',p);
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
savePlotInDir(f, plottitle, plotsubfolder);
close(f);

writetable(resulttable, fullfile(basedir, 'ExcelFiles', sprintf('%s.xlsx', plottitle)));

end

