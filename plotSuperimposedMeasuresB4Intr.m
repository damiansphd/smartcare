function plotSuperimposedMeasuresB4Intr(ax, amnormcubesingleintr, amnormcubesingleintrsmth, xl, yl, ...
    measures, max_offset, align_wind, ex_start, offset, plottitle)

% plotSuperimposedMeasuresB4Intr - plots the measures for the period prior
% to a treatment

days = -1 * (max_offset + align_wind - 1): -1;

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
pridx = ismember(tmpmeasures.DisplayName, {'PulseRate'});
legendtext{pridx} = sprintf('%s %s', legendtext{pridx}, '(Inverted)');
legendtext = [legendtext; {'ExStart'}];

for m = 1:tmpnmeasures 
    if m <= colorthresh
        lstyle = '-';
    else
        lstyle = '-.';
    end
    %plot(ax, days, amnormcubesingleintr(:, tmpmeasures.Index(m)), ...
    %    'Color', colors(m, :), ...
    %    'LineStyle', ':', ...
    %   'Marker', 'o', ...
    %    'LineWidth',1,...
    %    'MarkerSize',2,...
    %    'MarkerEdgeColor','b',...
    %    'MarkerFaceColor','g');

    plot(ax, days, amnormcubesingleintrsmth(:, tmpmeasures.Index(m)), ...
        'Color', colors(m, :), ...
        'LineStyle', lstyle, ...
        'Marker', 'none', ...
        'LineWidth', 1);
    
    xlim(ax, xl);
    ylim(ax, yl);
end

if ex_start ~= 0
    [~, ~] = plotVerticalLine(ax, ex_start + offset, xl, yl, 'black', ':', 0.5); % plot ex_start
end

legend(ax, legendtext, 'Location', 'southwest', 'FontSize', 6);

ax.XAxis.FontSize = 6;
xlabel(ax, 'Days before treatment');
ax.YAxis.FontSize = 6;
ylabel(ax, 'Number of standard deviation moves');
title(ax, plottitle, 'FontSize', 8);
end

