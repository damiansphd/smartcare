function [xl, yl] = plotHorizontalLine(ax, yval, xl, yl, colour, linestyle, linewidth)

% plotHotizontalLine - plots a horizontal line

% plot horizontal line
line(ax, xl, [yval yval], ...
    'Color', colour, ...
    'LineStyle',linestyle, ...
    'LineWidth', linewidth);
yl = [min(min(yval * 0.99), yl(1)) max(max(yval * 1.01), yl(2))];
ylim(yl);

end

