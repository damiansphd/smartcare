function plotSuperimposedAlignedCurves(ax, meancurvemean, xl, yl, ...
    measures, min_offset, max_offset, align_wind, ex_start, lc, nlcex, invmeasarray, posarray)

% plotSuperimposedAlignedCurves - plots the aligned curves for each of the
% measures superimposed on a single plot to show any timing differences in
% the declines

anchor = 1; % latent curve is to be anchored on the plot (right side at min_offset)

% comment out/uncomment out one of these depending on whether all measures
% wanted or just those used for alignment
tmpmeasures = measures;
tmpmeasures = measures(logical(measures.Mask), :);
tmpnmeasures = size(tmpmeasures, 1);

% add colour array here and use it in the call to plotLatentCurve
% lines only has 7 unique colours, so change line style after this
colorthresh = 7;
colors = lines(tmpnmeasures);

% add legend text cell array
legendtext = tmpmeasures.DisplayName;
pridx = ismember(tmpmeasures.DisplayName, invmeasarray);
if sum(pridx) > 0
    % need to edit this now there are multiple inverted measures
    for i = 1:size(legendtext, 1)
        if pridx(i) == 1
            legendtext{i} = sprintf('%s %s', legendtext{i}, '(Inverted)');
        end
    end
end
legendtext = [legendtext; {'ExStart'}];

for m = 1:tmpnmeasures 
    if m <= colorthresh
        lstyle = '-';
    else
        lstyle = '-.';
    end
    [xl, yl] = plotLatentCurve(ax, max_offset, (align_wind + ex_start), (min_offset + ex_start), meancurvemean(:, tmpmeasures.Index(m)), xl, yl, colors(m, :), lstyle, 0.5, anchor);
end

if ex_start ~= 0
    [xl, yl] = plotVerticalLine(ax, 0, xl, yl, 'black', ':', 0.5); % plot ex_start
end

legend(ax, legendtext, 'Position', posarray, 'FontSize', 6);

ax.XAxis.FontSize = 6;
xlabel(ax, 'Days before/after exacerbation start');
ax.YAxis.FontSize = 6;
ylabel(ax, 'Number of standard deviation moves');
title(ax, sprintf('Curve Set %d (nexamples = %d)', lc, nlcex));

end

