function savePlotInDirAsSVG(f, name, subfolder)

% savePlots - saves the figure to png and svp file types in the specified
% subfolder

% save plot
basedir = setBaseDir();
filename = [name '.svg'];
saveas(f,fullfile(basedir, subfolder, filename));

end

