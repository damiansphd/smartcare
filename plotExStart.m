function [xl, yl] = plotExStart(ax, ex_start, offset, xl, yl, colour, linestyle, linewidth)

% plotExStart - plots the predicted exacerbation start plus average
% ex_start

% plot vertical line for predicted exacerbation start
[xl, yl] = plotVerticalLine(ax, ex_start + offset, xl, yl, colour, linestyle, linewidth);

% plot short vertical line for average exacerbation start indicator
tempyl = yl;
tempyl(2) = yl(1) + ((yl(2)-yl(1)) * 0.1);
plotVerticalLine(ax, ex_start, xl, tempyl, 'black', linestyle, linewidth);

end

