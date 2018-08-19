function [xl, yl] = plotTreatmentStart(ax, treatmentstart, xl, yl)

% plotTreatmentStart - plots the treatment start line

% plot vertical line indicating treatment start
line(ax, [treatmentstart treatmentstart] , yl, ...
    'Color', 'cyan', ...
    'LineStyle','-', ...
    'LineWidth', 0.5);
xl = [min(min(treatmentstart), xl(1)) max(max(treatmentstart), xl(2))];
xlim(xl);

end

