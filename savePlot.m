function savePlot(f, name)

% savePlots - saves the figure to png and svp file types

% save plot
basedir = './';
subfolder = 'Plots';
filename = [name '.png'];
saveas(f,fullfile(basedir, subfolder, filename));
filename = [name '.svg'];
saveas(f,fullfile(basedir, subfolder, filename));

end

