function compareMultipleModelRunToTestData(amLabelledInterventions, modelrun, modelidx, models)

% compareMultipleModelRunToTestData - compares the output of multiple model runs to
% the labelled test data (but doesn't plot results)

amLabelledInterventions = [array2table([1:size(amLabelledInterventions,1)]'), amLabelledInterventions];
amLabelledInterventions.Properties.VariableNames{'Var1'} = 'InterNbr';

testidx = amLabelledInterventions.IncludeInTestSet=='Y';

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

datatable = table('Size',[1 3], ...
    'VariableTypes', {'double',   'double',     'double'}, ...
    'VariableNames', {'ModelRun', 'TestSetNbr', 'Count'});

rowtoadd = datatable;
datatable(1:size(datatable,1),:) = [];
ylabels = {'Dummy'};
modelrunlist = 0;
qualityscore = 0;

for midx = modelidx:size(models,1)
    if (~isequal(models{midx}, 'placeholder') && ~contains(models{midx}, 'xxx'))
        load(fullfile(basedir, subfolder, sprintf('%s.mat', models{midx})));
        
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
        
        modeloffsets = amInterventions.Offset(testidx);
        testset = amLabelledInterventions(testidx,:);
        testsetsize = size(testset,1);
        testset_ex_start = testset.ExStart(1);

        diff_ex_start = testset_ex_start - ex_start;

        matchidx = ((ex_start + modeloffsets >= (testset.LowerBound1)) & (ex_start + modeloffsets <= (testset.UpperBound1))) | ...
                   ((ex_start + modeloffsets >= (testset.LowerBound2)) & (ex_start + modeloffsets <= (testset.UpperBound2)));
        if diff_ex_start < 0
            matchidx2 = (modeloffsets >= max_offset + diff_ex_start) & ((testset.UpperBound1 - testset_ex_start == max_offset - 1) | (testset.UpperBound2 - testset_ex_start == max_offset - 1)) ;
        elseif diff_ex_start > 0
            matchidx2 = (modeloffsets <= min_offset + diff_ex_start) & ((testset.LowerBound1 - testset_ex_start == min_offset)     | (testset.LowerBound2 - testset_ex_start == min_offset)) ;
        else
            matchidx2 = (modeloffsets == -10);
        end
        matchidx = matchidx | matchidx2;

        fprintf('For model %s%d: %s:\n', mversion, midx, models{midx});
        fprintf('%2d of %2d results match labelled test data, ', sum(matchidx), testsetsize); 
        rowtoadd.ModelRun = midx;
        
        for i = 1:size(testset,1)
            rowtoadd.TestSetNbr = testset.InterNbr(i);
            if matchidx(i)
                rowtoadd.Count = 0;
            else
                dist1 = min(abs(testset.LowerBound1(i) - (ex_start + modeloffsets(i))), abs(testset.LowerBound2(i) - (ex_start + modeloffsets(i))));
                dist2 = min(abs(testset.UpperBound1(i) - (ex_start + modeloffsets(i))), abs(testset.UpperBound2(i) - (ex_start + modeloffsets(i))));
                dist = min(dist1, dist2);
                rowtoadd.Count = dist;
            end
            %fprintf('For intervention %2d, Match = %d, Dist = %d\n', testset.InterNbr(i), matchidx(i), rowtoadd.Count);
            datatable = [datatable ; rowtoadd];
        end
        
        fprintf('Quality score = %d\n', sum(datatable.Count(datatable.ModelRun==midx)));
        fprintf('\n');
        modelrunlist = [modelrunlist; midx];
        qualityscore = [qualityscore; sum(datatable.Count(datatable.ModelRun==midx))];
        ylabels = [ylabels; sprintf('%2d (%2d:%3d)', midx, sum(matchidx), sum(datatable.Count(datatable.ModelRun==midx)))];
    end
end

% remove dummy row
modelrunlist(1) = [];
qualityscore(1) = [];
ylabels(1) = [];

labelsandquality = [array2table(modelrunlist), array2table(ylabels), array2table(qualityscore)];
%labelsandquality = sortrows(labelsandquality, {'qualityscore', 'modelrunlist'}, {'ascend', 'ascend'});

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
end

