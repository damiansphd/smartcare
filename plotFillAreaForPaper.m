function plotFillAreaForPaper(ax, xlower, xupper, ylower, yupper, color, facealpha, edgecolor)

% plotFillAreaForPaper - plots a shaded area on the graph 

fill(ax, [xlower (xupper) (xupper) xlower], ...
            [ylower ylower yupper yupper], ...
            color, 'FaceAlpha', facealpha, 'EdgeColor', edgecolor);

end

