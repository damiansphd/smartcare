function ex_start = calcExStartFromTestLabels(amLabelledInterventions, amInterventions, ...
    overall_pdoffset, max_offset, plotsubfolder, modelrun)

% calcExStartFromTestLabels - derives the ex_start date for a given
% alignment model run from the test labels.

plotsacross = 1;
plotsdown = 6;

name1 = sprintf('%s - Ex_Start from TestLabels', modelrun);
[f1, p1] = createFigureAndPanel(name1, 'Portrait', 'A4');
%ax1 = gobjects(plotsacross * plotsdown,1);


[truevotes, falsevotes] = calcVotesArray(amLabelledInterventions, amInterventions, ...
                                overall_pdoffset, max_offset);
days = (-1 * (size(truevotes,2)):-1);
thisplot = 1;
ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
b = bar(ax1(thisplot), days, sum(truevotes), 0.75, 'FaceColor', 'green', 'EdgeColor', 'black');
title(sprintf('ExStart true votes by day - All %d Examples', size(amInterventions, 1)));

thisplot = thisplot + 1;
ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
b = bar(ax1(thisplot), days, sum(falsevotes), 0.75, 'FaceColor', 'green', 'EdgeColor', 'black');
title(sprintf('ExStart false votes by day - All %d Examples', size(amInterventions, 1)));

thisplot = thisplot + 1;
ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
b = bar(ax1(thisplot), days, sum(truevotes) ./ (sum(truevotes) + sum(falsevotes)), 0.75, 'FaceColor', 'blue', 'EdgeColor', 'black');
title(sprintf('ExStart true proportion votes by day - All %d Examples', size(amInterventions, 1)));


idx = amLabelledInterventions.IncludeInTestSet == 'Y';
[truevotes, falsevotes] = calcVotesArray(amLabelledInterventions(idx, :), amInterventions(idx, :), ...
                                overall_pdoffset(idx, :), max_offset);
days = (-1 * (size(truevotes,2)):-1);
thisplot = thisplot + 1;
ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
b = bar(ax1(thisplot), days, sum(truevotes), 0.75, 'FaceColor', 'green', 'EdgeColor', 'black');
title(sprintf('ExStart true votes by day (%d Test Set examples)', size(amInterventions(idx,:),1)));                            

thisplot = thisplot + 1;
ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
b = bar(ax1(thisplot), days, sum(falsevotes), 0.75, 'FaceColor', 'green', 'EdgeColor', 'black');
title(sprintf('ExStart false votes by day (%d Test Set examples)', size(amInterventions(idx,:),1)));     

thisplot = thisplot + 1;
ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
b = bar(ax1(thisplot), days, sum(truevotes) ./ (sum(truevotes) + sum(falsevotes)), 0.75, 'FaceColor', 'blue', 'EdgeColor', 'black');
title(sprintf('ExStart true proportion votes by day (%d Test Set examples)', size(amInterventions(idx,:),1)));     

basedir = setBaseDir();
%plotsubfolder = sprintf('Plots/%s', subfolder);
savePlotInDir(f1, name1, plotsubfolder);
close(f1);
    
[~, maxpt] = max(sum(truevotes) ./ (sum(truevotes) + sum(falsevotes)));

ex_start = -1 * (size(truevotes,2)) - 1 + maxpt;

end

