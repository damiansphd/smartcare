function [pdcountmtable] = calcDataComplianceStats(dataset, totdays, totmeas, studyduration, meastype, filttype, measfilter, bccolor, tickrange, ticklabels, subfolder, study)

% calcDataComplianceStats - calculate the data collection compliance
% statistics for all or a subset of measurement types

% create a table of counts of measures by patient/day (@max function here
% is irrelevant as we just want the group counts

if ismember(filttype, 'All')
    % no filtering
elseif ismember(filttype, 'Inc')
    dataset = dataset(ismember(dataset.RecordingType, measfilter), :);
elseif ismember(filttype, 'Exc')
    dataset = dataset(~ismember(dataset.RecordingType, measfilter), :);
end

dataset = dataset(:, {'SmartCareID', 'ScaledDateNum'});

pdcountmtable = varfun(@max, dataset, 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});

% create two different sort orders - 1) most days with measures 2) longest
% period of measures (with a max of the study period)
%pcountmtable = varfun(@sum, pdcountmtable(:,{'SmartCareID'}), 'GroupingVariables', {'SmartCareID'});
%pcountmtable = sortrows(pcountmtable, 'GroupCount', 'descend');
%ysortmostdays = pcountmtable.SmartCareID;

pcountmtable = varfun(@max, pdcountmtable(:,{'SmartCareID', 'ScaledDateNum'}), 'GroupingVariables', {'SmartCareID'});
pcountmtable = sortrows(pcountmtable, {'max_ScaledDateNum', 'SmartCareID'}, {'descend', 'ascend'});
ysortmaxdays = pcountmtable.SmartCareID;

% print some stats on distribution of patients duration of measurements

fprintf('Total participant study days         = %d\n', totdays);
fprintf('Total number of measurements         = %d\n', totmeas);
fprintf('Max duration days                    = %d\n', max(pcountmtable.max_ScaledDateNum));
fprintf('Days with measurements               = %d\n', sum(pcountmtable.GroupCount));
fprintf('Percentage of days with measurements = %.1f%%\n', 100 * sum(pcountmtable.GroupCount) / totdays);
fprintf('Number of measurements               = %d\n', sum(pdcountmtable.GroupCount));
fprintf('Percentage of measurements           = %.1f%%\n', 100 * sum(pdcountmtable.GroupCount) / totmeas);

fprintf('Median participant study duration = %.1f\n', median(pcountmtable.max_ScaledDateNum));

measperday = groupcounts(pdcountmtable, 'GroupCount');

[f, p] = createFigureAndPanelForPaper('', 5, 3);
ax = subplot(1, 1, 1, 'Parent', p);
bar(ax, measperday.GroupCount, measperday.GroupCount_1, 'FaceColor', bccolor);
ax.YTick = tickrange;
ax.YTickLabel = ticklabels;
ax.Title.String = sprintf('%s - Histogram of measures per day (%s)', study, meastype);
ax.Title.FontWeight = 'Bold';
xlabel(ax, '\bfMeasures per day');
ylabel(ax, '\bfStudy Days');
filename = sprintf('%s-MeasuresPerDay-%s', study, meastype);
savePlotInDir(f, filename, subfolder);
close(f);

if ismember(study, {'SC'})
    totpats  = size(pcountmtable, 1);
    patgr5   = sum(pcountmtable.max_ScaledDateNum >= 150);
    pat3to5  = sum(pcountmtable.max_ScaledDateNum >= 90 & pcountmtable.max_ScaledDateNum < 150);
    pat2to3  = sum(pcountmtable.max_ScaledDateNum >= 60 & pcountmtable.max_ScaledDateNum < 90);

    fprintf('Total patients              : %d\n', totpats);
    fprintf('Patients >= 5m          data: %d (%.0f%%)\n', patgr5 , 100 * patgr5/totpats);
    fprintf('Patients >= 3m and < 5m data: %d (%.0f%%)\n', pat3to5 , 100 * pat3to5/totpats);
    fprintf('Patients >= 2m and < 3m data: %d (%.0f%%)\n', pat2to3 , 100 * pat2to3/totpats);
    
    fprintf('The average number of measures per day was %.1f\n', sum(pdcountmtable.GroupCount)/size(pdcountmtable, 1));
    fprintf('At least 6 measures were submitted on %d days (%.0f%%)\n', sum(pdcountmtable.GroupCount >=6), 100 * sum(pdcountmtable.GroupCount >=6)/size(pdcountmtable, 1));

elseif ismember(study, {'BR'})
    totpats   = size(pcountmtable, 1);
    patgr2    = sum(pcountmtable.max_ScaledDateNum >= 730);
    pat1to2   = sum(pcountmtable.max_ScaledDateNum >= 365 & pcountmtable.max_ScaledDateNum < 730);
    pat05to1  = sum(pcountmtable.max_ScaledDateNum >= 182 & pcountmtable.max_ScaledDateNum < 365);
    patle05   = sum(pcountmtable.max_ScaledDateNum <  182);

    fprintf('Patients >= 2yr             data: %d (%.1f%%)\n', patgr2   , 100 * patgr2  /totpats);
    fprintf('Patients >= 1yr   and < 2yr data: %d (%.1f%%)\n', pat1to2  , 100 * pat1to2 /totpats);
    fprintf('Patients >= 0.5yr and < 1yr data: %d (%.1f%%)\n', pat05to1 , 100 * pat05to1/totpats);
    fprintf('Patients <  0.5yr           data: %d (%.1f%%)\n', patle05  , 100 * patle05 /totpats);
    
    fprintf('The average number of measures per day was %.1f\n', sum(pdcountmtable.GroupCount)/size(pdcountmtable, 1));
    
end

% now plot heatmap

fontname = 'Arial';

temp = hsv(64);
brightness = .9;

nmeasures = max(measperday.GroupCount);
crange = 20 - 4 + 1;
incrstep = crange/nmeasures ;

fprintf('nmeasures = %d, crange = %.1f, incrstep = %.2f\n', nmeasures, crange, incrstep);

for i = 1:nmeasures
    fprintf('i = %d, unrounded = %.2f, colidx = %d\n', i, 4+((i - 1) * incrstep), 4+ceil((i - 1) * incrstep));
    colors(i,:)  = temp(4+ceil((i - 1) * incrstep), :);
end

% add dummy rows to create a record for every day in the range of the data
% so the heatmap is scaled correctly for missing days
% but excluded from display limits so the row doesn't show on the heatmap
dummymin = min(pdcountmtable.ScaledDateNum);
dummymax = max(pdcountmtable.ScaledDateNum);
dummymeasures = pdcountmtable(1:dummymax-dummymin+1,:);
dummymeasures.SmartCareID(:) = 0;
dummymeasures.GroupCount(:) = 1;
for i = 1:dummymax-dummymin+1
    dummymeasures.ScaledDateNum(i) = i+dummymin-1;
end
pdcountmtable = [pdcountmtable ; dummymeasures];

labelinterval = 50;
xdisplaylabels = cell(studyduration, 1);
xdisplaylabels{1} = sprintf('%d', 0);
for i = 2:studyduration
    if (i / labelinterval == round(i / labelinterval))
        xdisplaylabels{i} = sprintf('%d', i);
    else
        xdisplaylabels{i} = ' ';
    end
end

ydisplaylabels = cell(size(unique(pdcountmtable.SmartCareID), 1) - 1, 1);
ydisplaylabels(:) = {' '};

% create the heatmap

%title = 'Recorded Measures by Participant for the Study Period';
title = '';

%[f, p] = createFigureAndPanelForPaper(title, 8.25, 3.92);
bordertype = 'none';
fullwidthinch = 8.25;
fullheightinch = 3.92;
p1widthinch = 7;
p2widthinch = 1.25;
p2heightinch = 2.53;
p3heightinch = 0.5;
p2yoffsetinch = 0.3;
verticalbuffer = 0.2;

f = figure('Units', 'inches', 'Position', [2, 4, fullwidthinch, fullheightinch + verticalbuffer], 'Color', 'white');

p1 = uipanel('Parent', f, 'BorderType', bordertype, 'BackgroundColor', 'white', 'Units', 'Inches', 'OuterPosition', [0, verticalbuffer, p1widthinch, fullheightinch]);
%p1.Title = 'A.';
%p1.TitlePosition = 'lefttop';
p1.FontSize      = 16;
p1.FontWeight    = 'normal';
p1.FontName      = fontname;

h = heatmap(p1, pdcountmtable, 'ScaledDateNum', 'SmartCareID', 'Colormap', colors, 'MissingDataColor', 'black', ...
    'ColorVariable','GroupCount','ColorMethod','max', 'MissingDataLabel', 'No data');
h.Title = ' ';
h.FontSize = 12;
h.FontName = fontname;
h.XLabel = '\bfTime (days)';
if ismember(study, {'SC'})
    h.YLabel = '\bfParticipants (n=104)';
elseif ismember(study, {'BR'})
    h.YLabel = '\bfParticipants (n=236)';
else
    h.YLabel = '\bfParticipants (n=xxx)';
end
h.YDisplayData = ysortmaxdays;
h.XDisplayLabels = xdisplaylabels;
h.YDisplayLabels = ydisplaylabels;
h.CellLabelColor = 'none';
h.GridVisible = 'off';
h.ColorbarVisible = 'off';


p2 = uipanel('Parent', f, 'BorderType', bordertype, 'BackgroundColor', 'white', 'Units', 'Inches', 'OuterPosition', [p1widthinch + 0.40, p2yoffsetinch + verticalbuffer, p2widthinch - 0.75, p2heightinch + p2yoffsetinch]);
barcolors = [[0,0,0]; colors];
ax = subplot(1, 1, 1, 'Parent', p2);
ax.YAxisLocation = 'right';

hold on;
for i = 1:size(barcolors, 1)
    plotFillAreaForPaper(ax, -1, 0, (i - 1.5), (i - 0.5), barcolors(i, :), 1.0, 'black')
end
ylim(ax, [-0.5, nmeasures + 0.5]);
ax.XTickLabel = '';
ax.XColor = 'white';
ydisplaylabels = cell(size(barcolors, 1), 1);
for i = 0:size(barcolors, 1) - 1
    ydisplaylabels{i + 1} = sprintf('%d', i);
end
yticks(ax, (0: nmeasures));
ax.YTickLabel = ydisplaylabels;

p3 = uipanel('Parent', f, 'BorderType', bordertype, 'BackgroundColor', 'white', 'Units', 'Inches', 'OuterPosition', [p1widthinch, p2yoffsetinch + verticalbuffer + p2heightinch + 0.1, p2widthinch, p3heightinch]);
sp3 = uicontrol('Parent', p3, ... 
                    'Style', 'text', ...
                    'BackgroundColor', 'white', ...
                    'Units', 'normalized', ...
                    'Position', [0, 0, 1, 1], ...
                    'HorizontalAlignment', 'Center', ...
                    'FontName', fontname, ...
                    'String', sprintf('Data uploads\nper day'));

% save results
filename = sprintf('%s-Heatmap-RecordedMeasuresByParticipantForThesis-%s', study, meastype);
savePlotInDir(f, filename, subfolder);
%savePlotInDirAsSVG(f, filename, subfolder);
close(f);

toc
fprintf('\n');


end

