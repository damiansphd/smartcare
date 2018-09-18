function compareModelRunToTestData(amLabelledInterventions, modelrun, modelidx, models)

% compareMultipleModelRunToTestData - compares the output of multiple model runs to
% the labelled test data (but doesn't plot results)

temp = hsv;
brightness = .9;
colors(1,:)  = temp(4,:)  .* brightness;
colors(2,:)  = temp(16,:)  .* brightness;

amLabelledInterventions = [array2table([1:size(amLabelledInterventions,1)]'), amLabelledInterventions];
amLabelledInterventions.Properties.VariableNames{'Var1'} = 'InterNbr';

testidx = amLabelledInterventions.IncludeInTestSet=='Y';

basedir = './';
subfolder = 'MatlabSavedVariables';

datatable = table('Size',[1 3], ...
    'VariableTypes', {'double',   'double',     'double'}, ...
    'VariableNames', {'ModelRun', 'TestSetNbr', 'Count'});

rowtoadd = datatable;
datatable(1:size(datatable,1),:) = [];

for midx = modelidx:size(models,1)
    if (~isequal(models{midx}, 'placeholder') && ~contains(models{midx}, 'xxx'))
        load(fullfile(basedir, subfolder, sprintf('%s.mat', models{midx})));

        modeloffsets = offsets(testidx);
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

        fprintf('For model %d: %s:\n', midx, models{midx});
        fprintf('%2d of %2d results match labelled test data\n', sum(matchidx), testsetsize);
        fprintf('\n');
        
        rowtoadd.ModelRun = midx;
        
        for i = 1:size(testset,1)
            rowtoadd.TestSetNbr = testset.InterNbr(i);
            if matchidx(i)
                rowtoadd.Count = 2;
            else
                rowtoadd.Count = 1;
            end
            datatable = [datatable ; rowtoadd];
        end  
    end
end

plotsacross = 1;
plotsdown = 1;
plottitle = sprintf('Model Run Results (%d-%d) vs Labelled Test Data', modelidx, size(models,1));

[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');

subplot(plotsdown,plotsacross,[1],'Parent',p);
h = heatmap(p, datatable, 'TestSetNbr', 'ModelRun', 'Colormap', colors, 'MissingDataColor', 'white', ...
    'ColorVariable','Count','ColorMethod','max', 'MissingDataLabel', 'No data', 'ColorBarVisible', 'off', 'FontSize', 8);
h.Title = ' ';
h.XLabel = 'Intervention Nbr';
h.YLabel = 'Model Run';
%h.YDisplayData = sorted_interventions.Intervention;
%h.XLimits = {1,50};
h.CellLabelColor = 'none';
h.GridVisible = 'on';
    
savePlot(f, plottitle);
close(f);
end

