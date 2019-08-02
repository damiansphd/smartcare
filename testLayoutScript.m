
close all;

widthinch = 8.25;
heightinch = 11.75;
name = '';
singlehght = 1/24;
doublehght  = singlehght * 2;
labelwidth = 0.25;
plotwidth  = 0.75;

ntitles = 2;
nclinicalmeasures = 2;
nmeasures = 9;
nlabels = nclinicalmeasures + nmeasures;

typearray = [1, 2, 3, 2, 3, 1, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3];

labeltext = {'A.'; 'Clinical CRP'; ' '; 'Clinical FEV1'; ' '; 'B.'};

[measures] = sortMeasuresForPaper(study, measures);
for m = 1:nmeasures
    labeltext = [labeltext; cellstr(measures.DisplayName{m}); ' '];
end

[f, p] = createFigureAndPanelForPaper(name, widthinch, heightinch);

currhght = 1.0;
for i = 1:(ntitles + nclinicalmeasures + nmeasures + nlabels)
    type = typearray(i);
        
    if type == 1
        % title
        currhght = currhght - singlehght;
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'OuterPosition', [0, currhght, 1.0, singlehght]);
        displaytext = sprintf('\\bf %s\\rm', labeltext{i});
        annotation(sp(i), 'textbox',  ...
                        'String', displaytext, ...
                        'Interpreter', 'tex', ...
                        'Units', 'normalized', ...
                        'Position', [0, 0, 1, 1], ...
                        'HorizontalAlignment', 'left', ...
                        'VerticalAlignment', 'middle', ...
                        'LineStyle', 'none', ...
                        'FontSize', 13);
    elseif type == 2
        % label
        currhght = currhght - doublehght;
        displaytext = {formatTexDisplayMeasure(labeltext{i}); sprintf('(%s)', getUnitsForMeasure(labeltext{i}))};
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'OuterPosition', [0, currhght, labelwidth, doublehght]);
        annotation(sp(i), 'textbox',  ...
                        'String', displaytext, ...
                        'Interpreter', 'tex', ...
                        'Units', 'normalized', ...
                        'Position', [0, 0, 1, 1], ...
                        'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'middle', ...
                        'LineStyle', 'none', ...
                        'FontSize', 10);
    elseif type == 3
        % plot
        sp(i) = uipanel('Parent', p, ...
                        'BorderType', 'none', ...
                        'OuterPosition', [labelwidth, currhght, plotwidth, doublehght]);

        
    end

end



