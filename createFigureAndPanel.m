function [f, p] = createFigureAndPanel(name, orientation, pagesize)

% createFigureAndPanel - creates a figure with a ui panel and returns
% handles to each

f = figure('Name', name);
%set(gcf, 'Units', 'normalized', 'OuterPosition', [0.65, 0, 0.35, 0.92], 'PaperOrientation', orientation, 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', pagesize);
set(gcf, 'Units', 'normalized', 'OuterPosition', [0.65, 0, 0.35, 0.92], 'PaperOrientation', orientation, ...
    'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', pagesize);

p = uipanel('Parent',f,'BorderType','none', 'BackgroundColor', 'white');
p.Title = name;
p.TitlePosition = 'centertop';
p.FontSize = 8;
p.FontWeight = 'bold'; 

end

