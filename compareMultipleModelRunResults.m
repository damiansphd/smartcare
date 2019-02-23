function [modeliterations, modeloffsets] = compareMultipleModelRunResults(modelrun, modelidx, models, basedir, subfolder)

% compareMultipleModelRunResults - compares the results of multiple model 
% runs (iterations to converge, offsets, prob distributions etc

load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun)));
nmodelruns = size(models, 1);
modeliterations = nan(nmodelruns, 1);
modeloffsets = nan(nmodelruns, ninterventions);
plotsdown = 1;
plotsacross = 2;
pagebreak1 = 45;
multiplier = (162 / nmodelruns)^0.5;

if ninterventions < pagebreak1
    pagebreak1 = ninterventions;
end

name = sprintf('%s - Dispersion plot by Intervention of offsets across model runs %s %d-%d', study, mversion, modelidx, nmodelruns);

for midx = modelidx:size(models,1)
    if (~isequal(models{midx}, 'placeholder') && ~contains(models{midx}, 'xxx'))
        load(fullfile(basedir, subfolder, sprintf('%s.mat', models{midx})));
        
        modeliterations(midx) = niterations;
        modeloffsets(midx,:) = amInterventions.Offset';
         
    end
end


[f, p] = createFigureAndPanel(name, 'portrait', 'a4');
ax = subplot(plotsdown, plotsacross, 1, 'Parent',p);


for n = 1:pagebreak1
    ioffsets = array2table(modeloffsets(~isnan(modeloffsets(:,n)),n));
    ioffsets.Properties.VariableNames{'Var1'} = 'Offset';
    ioffsets.Count(:) = 1;
    counts = varfun(@mean,ioffsets, 'GroupingVariables', {'Offset'});
    line(ax, [0:(max_offset - 1)] , (n * ones(1, max_offset)), ...
        'Color', 'blue', ...
        'LineStyle', ':', ...
        'LineWidth', 0.5);
    
    for i = 1:size(counts)    
        line(ax, counts.Offset(i) , n, ...
            'Color', 'blue', ...
            'LineStyle', 'none', ...
            'Marker', 'o', ...
            'MarkerSize', multiplier * (counts.GroupCount(i))^0.5,...
            'MarkerEdgeColor', 'blue', ...
            'MarkerFaceColor', 'blue');
    end
end
yl = [1 pagebreak1];
xl = [0 (max_offset - 1)];
ylim(yl);
xlim(xl);
ax.XMinorTick = 'on';
ax.YMinorTick = 'on';
ax.TickDir = 'out';

ax2 = subplot(plotsdown, plotsacross, 2, 'Parent',p);

if ninterventions > pagebreak1
    for n = pagebreak1 + 1:ninterventions
        ioffsets = array2table(modeloffsets(~isnan(modeloffsets(:,n)),n));
        ioffsets.Properties.VariableNames{'Var1'} = 'Offset';
        ioffsets.Count(:) = 1;
        counts = varfun(@mean,ioffsets, 'GroupingVariables', {'Offset'});
        line(ax2, [0:(max_offset - 1)] , (n * ones(1, max_offset)), ...
            'Color', 'blue', ...
            'LineStyle', ':', ...
            'LineWidth', 0.5);
    
        for i = 1:size(counts)    
            line(ax2, counts.Offset(i) , n, ...
                'Color', 'blue', ...
                'LineStyle', 'none', ...
                'Marker', 'o', ...
                'MarkerSize', 3 * (counts.GroupCount(i))^0.5,...
                'MarkerEdgeColor', 'blue', ...
                'MarkerFaceColor', 'blue');
        end
    end
    yl = [pagebreak1 + 1 ninterventions];
    xl = [0 (max_offset - 1)];
    ylim(yl);
    xlim(xl);
    ax.XMinorTick = 'on';
    ax.YMinorTick = 'on';
    ax.TickDir = 'out';

end

plotsubfolder = 'Plots';
savePlotInDir(f, name, plotsubfolder);
close(f);

end
