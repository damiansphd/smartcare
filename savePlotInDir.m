function savePlotInDir(f, name, subfolder)

% savePlots - saves the figure to png and svp file types in the specified
% subfolder

% save plot
basedir = setBaseDir();
filename = [name '.png'];
saveas(f,fullfile(basedir, subfolder, filename));

% only add in when necessary to save space
%filename = [name '.svg'];
%saveas(f,fullfile(basedir, subfolder, filename));

end

