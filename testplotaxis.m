%---------------------------------------------
% Example of how to turn off the X-axis in the
% top subplot.
% Define some data
x = linspace(0,8*pi,100);
y1 = sin(x);
y2 = cos(x);
% Create the plots
ax(1) = subplot(211);
plot(x,y1)
ax(2) = subplot(212);
plot(x,y1)
% Set the X-axis tick locations and limits of
% each plot to the same values
set(ax,'XTick',get(ax(1),'XTick'), ...
     'XLim',get(ax(1),'XLim'))
% Turn off the X-tick labels in the top axes
set(ax(1),'XTickLabel','')
% Set the color of the X-axis in the top axes
% to the axes background color
set(ax(1),'XColor',get(gca,'Color'))
% Turn off the box so that only the left 
% vertical axis and bottom axis are drawn
set(ax,'box','off')
%---------------------------------------------

x1 = [0:.1:40];
y1 = 4.*cos(x1)./(x1+2);
x2 = [1:.2:20];
y2 = x2.^2./x2.^3;
hl1 = line(x1,y1,'Color','r');
ax1 = gca;
set(ax1,'XColor','r','YColor','r')
ax2 = axes('XAxisLocation','top',...
         'YAxisLocation','right',...
         'Color','none',...
         'XColor','k','YColor','k');
hl2 = line(x2,y2,'Color','k','Parent',ax2);





hXLbl=xlabel('XLabel','Position',[Xlb Ylb],'VerticalAlignment','top','HorizontalAlignment','center'); 








