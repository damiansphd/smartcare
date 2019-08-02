function [f, p] = createFigureAndPanelForPaper(name, widthinch, heightinch)

% createFigureAndPanel - creates a figure with a ui panel and returns
% handles to each

f = figure('Name', name, 'Units', 'inches', 'Position', [2, 4, widthinch, heightinch], 'Color', 'white');
%set(gcf, 'Units', 'normalized', 'OuterPosition', [0.65, 0, 0.35, 0.92], 'PaperOrientation', orientation, ...
%    'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', pagesize);

p = uipanel('Parent',f,'BorderType','none', 'BackgroundColor', 'white', 'Units', 'normalized');
p.Title = name;
p.TitlePosition = 'centertop';
p.FontSize = 8;
p.FontWeight = 'bold'; 

end

