function [xl, yl] = plotMeasurementData(ax, days, mdata, xl, yl, measure, colour, linestyle, linewidth, marker, markersize, markerec, markerfc)

% plotMeasurementDataAndMean - plots the measurement data along with the mean and
% treatment start line

% plot measurement data
line(ax, days, mdata, ...
    'Color', colour, ...
    'LineStyle', linestyle, ...
    'LineWidth', linewidth, ...
    'Marker', marker, ...
    'MarkerSize', markersize,...
    'MarkerEdgeColor', markerec, ...
    'MarkerFaceColor', markerfc);
xl = [min(min(days), xl(1)) max(max(days), xl(2))];
xlim(xl);
yl = [min(min(mdata * 0.99), yl(1)) max(max(mdata * 1.01), yl(2))];
ylim(yl);

set(gca,'fontsize',6);
if measure.Mask == 1
    title(measure.DisplayName, 'FontSize', 6, 'BackgroundColor', 'green');
else
    title(measure.DisplayName, 'FontSize', 6, 'BackgroundColor', 'white');
end
xlabel('Days Prior', 'FontSize', 6);
ylabel('Measure', 'FontSize', 6);
    
end

