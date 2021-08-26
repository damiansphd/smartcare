function ex_start = calcExStartFromTestLabels(amLabelledInterventions, amInterventions, ...
    overall_pdoffset, max_offset, plotsubfolder, modelrun, countthresh)

% calcExStartFromTestLabels - derives the ex_start date for a given
% alignment model run from the test labels.

plotsacross = 1;
plotsdown = 6;
%countthresh = 5;

name1 = sprintf('%s - Ex_Start from TestLabels', modelrun);
[f1, p1] = createFigureAndPanel(name1, 'Portrait', 'A4');
%ax1 = gobjects(plotsacross * plotsdown,1);


[truevotes, falsevotes, nvotes] = calcVotesArray(amLabelledInterventions, amInterventions, ...
                                overall_pdoffset, max_offset);
                            
sumtrue = sum(truevotes);
sumfalse = sum(falsevotes);
sumtrue((sumtrue + sumfalse) < countthresh) = 0;
%countthresh = max(sumtrue) * 0.2;
%sumtrue(sumtrue < countthresh) = 0;

days = (-1 * (size(truevotes,2)):-1);
thisplot = 1;
ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
bar(ax1(thisplot), days, sumtrue, 0.75, 'FaceColor', 'green', 'EdgeColor', 'black');
title(sprintf('ExStart true votes by day - All %d labelled examples', nvotes));

thisplot = thisplot + 1;
ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
bar(ax1(thisplot), days, sumfalse, 0.75, 'FaceColor', 'green', 'EdgeColor', 'black');
title(sprintf('ExStart false votes by day - All %d labelled examples', nvotes));

thisplot = thisplot + 1;
ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
bar(ax1(thisplot), days, sumtrue ./ (sumtrue + sumfalse), 0.75, 'FaceColor', 'blue', 'EdgeColor', 'black');
title(sprintf('ExStart true proportion votes by day - All %d labelled examples', nvotes));


idx = amLabelledInterventions.IncludeInTestSet == 'Y';
%[truevotes, falsevotes] = calcVotesArray(amLabelledInterventions(idx, :), amInterventions(idx, :), ...
%                                overall_pdoffset(idx, :), max_offset);
[truevotes, falsevotes, nvotes] = calcVotesArray(amLabelledInterventions(idx, :), amInterventions, ...
                                overall_pdoffset, max_offset);

sumtrue = sum(truevotes);
sumfalse = sum(falsevotes);
sumtrue((sumtrue + sumfalse) < countthresh) = 0;
%countthresh = max(sumtrue) * 0.2;
%sumtrue(sumtrue < countthresh) = 0;
                            
days = (-1 * (size(truevotes,2)):-1);
thisplot = thisplot + 1;
ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
bar(ax1(thisplot), days, sumtrue, 0.75, 'FaceColor', 'green', 'EdgeColor', 'black');
title(sprintf('ExStart true votes by day (%d test set labelled examples)', nvotes));                            

thisplot = thisplot + 1;
ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
bar(ax1(thisplot), days, sumfalse, 0.75, 'FaceColor', 'green', 'EdgeColor', 'black');
title(sprintf('ExStart false votes by day (%d test set labelled examples)', nvotes));     

thisplot = thisplot + 1;
ax1(thisplot) = subplot(plotsdown, plotsacross, thisplot, 'Parent',p1);
bar(ax1(thisplot), days, sumtrue ./ (sumtrue + sumfalse), 0.75, 'FaceColor', 'blue', 'EdgeColor', 'black');
title(sprintf('ExStart true proportion votes by day (%d test set labelled examples)', nvotes));     

savePlotInDir(f1, name1, plotsubfolder);
close(f1);

if sum(sumtrue) == 0
    ex_start = -1;
else
    [~, maxpt] = max(sumtrue ./ (sumtrue + sumfalse));
    ex_start = -1 * (size(truevotes,2)) - 1 + maxpt;
end

fprintf('Derived ex_start is %d\n', ex_start);
fprintf('\n');

end

