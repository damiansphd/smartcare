function ex_start = calcExStartFromTestLabels(amLabelledInterventions, amInterventions, ...
    align_wind, max_offset, modelrun)

% calcExStartFromTestLabels - derives the ex_start date for a given
% alignment model run from the test labels.

plotsacross = 1;
plotsdown = 4;

name1 = sprintf('%s - Ex_Start from TestLabels', modelrun);
[f1, p1] = createFigureAndPanel(name1, 'Portrait', 'A4');
ax1 = gobjects(plotsacross * plotsdown,1);

days = (-1 * (align_wind + max_offset - 1):-1);
votesarray = calcVotesArray(amLabelledInterventions, amInterventions, ...
                                align_wind, max_offset);
thisplot = 1;
ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
b = bar(ax1(thisplot), days, sum(votesarray), 0.75, 'FaceColor', 'blue', 'EdgeColor', 'black');
title(sprintf('ExStart votes by day - All %d Examples', size(amInterventions, 1)));

thisplot = thisplot + 1;
idx = amLabelledInterventions.IncludeInTestSet == 'Y';
votesarray = calcVotesArray(amLabelledInterventions(idx, :), amInterventions(idx, :), ...
                                align_wind, max_offset);
ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
b = bar(ax1(thisplot), days, sum(votesarray), 0.75, 'FaceColor', 'blue', 'EdgeColor', 'black');
title(sprintf('ExStart votes by day (%d Test Set examples)', size(amInterventions(idx,:),1)));                            

basedir = setBaseDir();
plotsubfolder = sprintf('Plots/%s',modelrun);
savePlotInDir(f1, name1, plotsubfolder);
close(f1);
    
[~, maxpt] = max(sum(votesarray));

ex_start = maxpt - 49 - 1;


end

