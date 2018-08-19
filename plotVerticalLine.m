function [xl, yl] = plotVerticalLine(ax, xval, xl, yl, colour, linestyle, linewidth)

% plotVerticalLine - plots a vertical line

line(ax, [xval xval] , yl, ...
    'Color', colour, ...
    'LineStyle',linestyle, ...
    'LineWidth', linewidth);
xl = [min(min(xval), xl(1)) max(max(xval), xl(2))];
xlim(xl);

end

