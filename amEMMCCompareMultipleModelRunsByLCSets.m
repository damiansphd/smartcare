function amEMMCCompareMultipleModelRunsByLCSets(modelrun, modelidx, models)

% amEMMCCompareMultipleModelRunsByLCSets - compares the the latent curve set populations
% for multiple model runs

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

datatable = table('Size',[1 3], ...
    'VariableTypes', {'double',   'double',  'double'}, ...
    'VariableNames', {'ModelRun', 'IntrNbr', 'LatentCurve'});

rowtoadd = datatable;
datatable(1:size(datatable,1),:) = [];

ylabels = {'Dummy'};
modelrunlist = 0;


colors      = [ 0.4, 0.8, 0.2 ];
colors(2,:) = [ 0, 0, 1 ];
colors(3,:) = [ 1, 0, 0 ];
colors(4,:) = [ 1 0 1 ];

for midx = modelidx:size(models,1)
    if (~isequal(models{midx}, 'placeholder') && ~contains(models{midx}, 'xxx'))
        clear randomseed;
        clear datasmoothmethod;
        clear vshiftmode;
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
        if (~exist('intrmode','var'))
            intrmode = 1;
        end
        if (~exist('scenario','var'))
            scenario = '';
        end
        if (~exist('vshiftmode','var'))
            vshiftmode = 0;
        end
       
        modellcs   = amInterventions.LatentCurve;
        
        lcs = 1:nlatentcurves;
        nlcs = zeros(nlatentcurves, 1);
        for i = 1:nlatentcurves
            nlcs(i) = sum(modellcs==i);
        end
        [~, nlcsidx] = sort(nlcs, 'descend');
        
        rowtoadd.ModelRun = midx;
        
        for i = 1:ninterventions
            rowtoadd.IntrNbr = i;
            %rowtoadd.LatentCurve = modellcs(i);
            rowtoadd.LatentCurve = lcs(nlcsidx==modellcs(i));
            datatable = [datatable ; rowtoadd];
        end
        
        modelrunlist = [modelrunlist; midx];
        %if niterations == 200
        %    convergeflag = '*';
        %else
        %    convergeflag = ' ';
        %end
        ylabels = [ylabels; sprintf('mm%dmo%dds%drm%drs%dct%dlm%dvs%dsc%sni%d', measuresmask, max_offset, ...
            datasmoothmethod, runmode, randomseed, countthreshold, testlabelmthd, vshiftmode, scenario, niterations)];
    end
end

% remove dummy row
modelrunlist(1) = [];
ylabels(1) = [];

labels = [array2table(modelrunlist), array2table(ylabels)];
labels = sortrows(labels, {'ylabels'}, {'ascend'});
   
plotsacross = 1;
plotsdown = 1;
plottitle = sprintf('Model Runs %s_gp%d_lm%d_in%d_nl%d(%d-%d) By Latent Curve Set', mversion, treatgap, testlabelmthd, intrmode, nlatentcurves, modelidx, size(models,1));

[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');

subplot(plotsdown,plotsacross,[1],'Parent',p);
h = heatmap(p, datatable, 'IntrNbr', 'ModelRun', 'Colormap', colors(1:max(datatable.LatentCurve),:), 'MissingDataColor', 'white', ...
    'ColorVariable','LatentCurve','ColorMethod','max', 'MissingDataLabel', 'No data', 'ColorBarVisible', 'off', 'FontSize', 8);
h.Title = ' ';
h.FontName = 'Monaco';
h.FontSize = 6;
h.XLabel = 'Intervention Nbr';
h.YLabel = 'Model Run';
h.YDisplayData = labels.modelrunlist;
h.YDisplayLabels = labels.ylabels;
h.CellLabelColor = 'none';
h.GridVisible = 'on';

plotsubfolder = 'Plots';
savePlotInDir(f, plottitle, plotsubfolder);
close(f);
    
end

