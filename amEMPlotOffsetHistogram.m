function amEMPlotOffsetHistogram(ax, offsets, max_offset)

% amEMPlotOffsetHistogram - plots the histogram of offsets for a given
% alignment model run

nsamples = size(offsets, 1);
if nsamples <= 100
    ymax = 30;
else
    ymax = 60;
end
histogram(ax, -1 * offsets);
xlim(ax, [(-1 * max_offset) + 0.5, 0.5]);
ylim(ax, [0 ymax]);
title(ax, sprintf('Offsets (%d Examples)', size(offsets, 1)), 'FontSize', 8);
xlabel(ax, 'Offset (Inverted)');
ylabel(ax, 'Example Count');

end

