function amEMPlotOffsetHistogram(ax, offsets, max_offset)

% amEMPlotOffsetHistogram - plots the histogram of offsets for a given
% alignment model run

nsamples = size(offsets, 1);
if nsamples <= 25
    ymax = 15;
elseif nsamples <= 100
    ymax = 50;
else
    ymax = 100;
end
histogram(ax, -1 * offsets);
xlim(ax, [(-1 * max_offset) + 0.5, 0.5]);
ylim(ax, [0 ymax]);
title(ax, sprintf('Offsets (%d Interventions)', size(offsets, 1)), 'FontSize', 6);

end

