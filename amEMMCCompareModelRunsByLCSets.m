function amEMMCCompareModelRunsByLCSets(modelrun1, modelidx1, modelrun2, modelidx2)

% amEMMCCompareModelRunsByLCSets - compares populations of latent curve
% sets across 2 model runs

fprintf('\n');
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
fprintf('Loading output from first model run\n');
load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun1)), 'amInterventions', 'ex_start', 'nlatentcurves', 'study', 'mversion', 'scenario', 'runmode', 'randomseed');

amInterventions1 = amInterventions;
ex_start1        = ex_start;
nlatentcurves1   = nlatentcurves;
study1           = study;
mversion1        = mversion;
scenario1        = scenario;
runmode1         = runmode;
randomseed1      = randomseed;


fprintf('Loading output from second model run\n');
load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun2)), 'amInterventions', 'ex_start', 'nlatentcurves', 'study', 'mversion', 'scenario', 'runmode', 'randomseed');

amInterventions2 = amInterventions;
ex_start2        = ex_start;
nlatentcurves2   = nlatentcurves;
study2           = study;
mversion2        = mversion;
scenario2        = scenario;
runmode2         = runmode;
randomseed2      = randomseed;

textstring = [{sprintf('Comparing latent curve set populations for models:')}; ...
              {sprintf('%2d: %s', modelidx1, modelrun1)}                     ; ...
              {sprintf('%2d: %s', modelidx2, modelrun2)}
             ];
fprintf('\n');
fprintf('%s', textstring{:});
fprintf('\n');
         
intersectresults = zeros(nlatentcurves1, nlatentcurves2);
lclabels1        = cell(nlatentcurves1, 1);
lclabels2        = cell(nlatentcurves2, 1);

for lc1 = 1:nlatentcurves1
    lcamintr1 = amInterventions1(amInterventions1.LatentCurve == lc1,:);
    lcintrids1    = lcamintr1.IntrNbr;
    lclabels1{lc1} = sprintf('LC%d (%d)', lc1, size(lcintrids1, 1));
    fprintf('Model %ssc%srm%drs%d Latent Curve Set %d size = %2d\n', mversion1, scenario1, runmode1, randomseed1, lc1, size(lcintrids1, 1));
    for lc2 = 1:nlatentcurves2
        lcamintr2 = amInterventions2(amInterventions2.LatentCurve == lc2,:);
        lcintrids2    = lcamintr2.IntrNbr;
        lclabels2{lc2} = sprintf('LC%d (%d)', lc2, size(lcintrids2, 1));
        
        intersectresults(lc1, lc2) = size(intersect(lcintrids1, lcintrids2), 1);
        fprintf('In Model %ssc%srm%drs%d LC set %d: %2d\n', mversion2, scenario2, runmode2, randomseed2, lc2, intersectresults(lc1, lc2));
    end
end

plotsacross = 1;
plotsdown = 1;
plottitle = sprintf('%s LC Popn %ssc%srm%drs%d vs %ssc%srm%drs%d', study1, mversion1, scenario1, runmode1, randomseed1, mversion2, scenario2, runmode2, randomseed2);

[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');
sp1 = uicontrol('Parent', p, ... 
                'Units', 'normalized', ...
                'OuterPosition', [0.1, 0.92, 0.9, 0.05], ...
                'Style', 'text', ...
                'FontName', 'FixedWidth', ...
                'FontSize', 6, ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'left', ...
                'String', textstring);
sp2 =   uipanel('Parent', p, ...
                'BorderType', 'none', ...
                'OuterPosition', [0.0, 0.0, 1.0, 0.92]);

h = heatmap(sp2, intersectresults, 'ColorMethod', 'none', 'ColorbarVisible', 'off', 'GridVisible', 'on', 'CellLabelColor', 'black');
h.Title = ' ';
h.YLabel = sprintf('%ssc%srm%drs%d', mversion1, scenario1, runmode1, randomseed1);
h.XLabel = sprintf('%ssc%srm%drs%d', mversion2, scenario2, runmode2, randomseed2);
h.YData  = lclabels1;
h.XData  = lclabels2;

% save plot
savePlotInDir(f, plottitle, 'Plots');
close(f);


end

