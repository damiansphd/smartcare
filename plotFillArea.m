function plotFillArea(ax, xlower, xupper, ylower, yupper, color, facealpha, edgecolor)

% plotFillArea - plots a shaded area on the graph (eg for confidence bounds
% or labelled test data ranges


fill(ax, [xlower (xupper + 1) (xupper + 1) xlower], ...
            [ylower ylower yupper yupper], ...
            color, 'FaceAlpha', facealpha, 'EdgeColor', edgecolor);

end

