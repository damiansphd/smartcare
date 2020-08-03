function plotLCSetByHospital(tmpInterventions, plotname, plotsubfolder, tmpnlc)

% plotLCSetByHospital - plots barcharts of Latent Curve set by hospital

hosplcdata = tmpInterventions(:, {'Hospital', 'LatentCurve'});

barvartext = unique(hosplcdata.Hospital);
nhosp = size(barvartext, 1);

barvardata = zeros(nhosp, tmpnlc);
for n = 1:nhosp
    for i = 1:tmpnlc
        barvardata(n, i) = sum(hosplcdata.LatentCurve == i & ismember(hosplcdata.Hospital, barvartext(n)));
    end
end

legendtext = cell(1, tmpnlc);
for i = 1:tmpnlc
    legendtext{i} = sprintf('Class %d', i);
end
plotsdown   = 1; 
plotsacross = 1;
widthinch = 8.5;
heightinch = 4;
fontname = 'Arial';
plottitle = sprintf('%s LCbyHosp', plotname);
X = categorical(barvartext);
X = reordercats(X,barvartext);
[f, p] = createFigureAndPanelForPaper(plottitle, widthinch, heightinch);
ax = subplot(plotsdown, plotsacross, 1, 'Parent', p);
bar(ax, X, barvardata, 'grouped');
xlabel(ax, 'Hospital', 'FontSize', 8);
ylabel(ax, 'Count by class', 'FontSize', 8);
legend(ax, legendtext, 'FontSize', 8, 'Location', 'eastoutside');


%for i = 1:nlatentcurves
%    ax = subplot(plotsdown, plotsacross, i, 'Parent', p);
%    bar(ax, 1:nhosp, barvardata(:, i));
%    ax.FontSize = 6;
%    ax.FontName = fontname;
%    xlabel(ax, 'Hospital', 'FontSize', 8);
%    ylabel(ax, sprintf('Count for Class %d', i), 'FontSize', 8);
%    %xlim(ax, [0.5, nhosp + 0.5]);
%end

basedir = setBaseDir();
if ~exist(fullfile(basedir, plotsubfolder), 'dir')
    mkdir(fullfile(basedir, plotsubfolder));
end

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
savePlotInDirAsSVG(f, plottitle, plotsubfolder);
close(f);


end

