function [xl, yl] = plotMeasurementDataAndMean(ax, days, mdata, xl, yl, nmean, measures)

% plotMeasurementDataAndMean - plots the measurement data along with the mean and
% treatment start line

% plot measurement data
line(ax, days, mdata, ...
    'Color', [0, 0.65, 1], ...
    'LineStyle', '-', ...
    'Marker', 'o', ...
    'LineWidth', 1, ...
    'MarkerSize',2,...
    'MarkerEdgeColor', 'b', ...
    'MarkerFaceColor','g');
xl = [min(min(days), xl(1)) max(max(days), xl(2))];
xlim(xl);
yl = [min(min(mdata * 0.99), yl(1)) max(max(mdata * 1.01), yl(2))];
ylim(yl);

% plot horizontal dashed line indicating mu
line(ax, xl,[nmean nmean], ...
    'Color', 'blue', ...
    'LineStyle', '--', ...
    'LineWidth', 0.5);
yl = [min(min(nmean * 0.99), yl(1)) max(max(nmean * 1.01), yl(2))];
ylim(yl);

set(gca,'fontsize',6);
if measures.Mask == 1
    title(measures.DisplayName, 'FontSize', 8, 'BackgroundColor', 'g');
else
    title(measures.DisplayName,'FontSize', 8);
end
xlabel('Days Prior', 'FontSize', 6);
ylabel('Measure', 'FontSize', 6);
    
end

