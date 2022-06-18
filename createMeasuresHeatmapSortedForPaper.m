function createMeasuresHeatmapSortedForPaper(physdata, offset, cdPatient, study)

% createMeasuresHeatmapSortedForPaper - creates the Patient/Measures
% heatmap just for study period, sorted by number of days with measures

fprintf('Creating Sorted Heatmap of Measures for Study Period\n');
fprintf('----------------------------------------------------\n');
tic

basedir = setBaseDir();
subfolder = sprintf('Plots/%s', study);

temp = hsv(64);
brightness = .9;
fontname = 'Arial';

if ismember(study, {'SC', 'TM'})
    %colors(1,:)  = [0 0 0];     % black for no measures
    colors(1,:)  = temp(4,:);
    colors(2,:)  = temp(6,:);
    colors(3,:)  = temp(8,:);
    colors(4,:)  = temp(10,:);
    colors(5,:)  = temp(12,:);
    colors(6,:)  = temp(14,:);
    colors(7,:)  = temp(16,:);
    colors(8,:)  = temp(18,:);
    colors(9,:)  = temp(20,:);
    %colors(10,:)  = [1 0 1];
    nmeasures     = 9;
    studyduration = 184;
elseif ismember(study, {'CL'})
    %colors(1,:)  = [0 0 0];     % black for no measures
    colors(1,:)  = temp(4,:);
    colors(2,:)  = temp(6,:);
    colors(3,:)  = temp(7,:);
    colors(4,:)  = temp(8,:);
    colors(5,:)  = temp(9,:);
    colors(6,:)  = temp(10,:);
    colors(7,:)  = temp(11,:);
    colors(8,:)  = temp(12,:);
    colors(9,:)  = temp(13,:);
    colors(10,:)  = temp(14,:);
    colors(11,:)  = temp(15,:);
    colors(12,:)  = temp(16,:);
    colors(13,:)  = temp(17,:);
    colors(14,:)  = temp(18,:);
    colors(15,:)  = temp(20,:);
    %colors(16,:)  = [1 0 1];
    nmeasures = 15;
    studyduration = 184;
elseif ismember(study, {'BR'})
    colors(1,:)  = temp(4,:);
    colors(2,:)  = temp(5,:);
    colors(3,:)  = temp(6,:);
    colors(4,:)  = temp(7,:);
    colors(5,:)  = temp(8,:);
    colors(6,:)  = temp(9,:);
    colors(7,:)  = temp(10,:);
    colors(8,:)  = temp(11,:);
    colors(9,:)  = temp(12,:);
    colors(10,:)  = temp(13,:);
    colors(11,:)  = temp(14,:);
    colors(12,:)  = temp(15,:);
    colors(13,:)  = temp(16,:);
    colors(14,:)  = temp(17,:);
    colors(15,:)  = temp(18,:);
    colors(16,:)  = temp(19,:);
    colors(17,:)  = temp(20,:);
    %colors(18,:)  = [1 0 1];
    nmeasures = 17;
    studyduration = max(physdata.ScaledDateNum);
else
    fprintf('**** Unknown Study ****');
    return;
end

% get the date scaling offset for each patient
%patientoffsets = getPatientOffsets(physdata);

if ismember(study, {'SC'})

    % create a table of counts of measures by patient/day (@max function here
    % is irrelevant as we just want the group counts
    %pdcountmtable = varfun(@max, physdata(:, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});
    pdcountmtable = varfun(@max, physdata(physdata.ScaledDateNum < (studyduration + 1), {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});

    % create two different sort orders - 1) most days with measures 2) longest
    % period of measures (with a max of the study period)
    pcountmtable = varfun(@sum, pdcountmtable(:,{'SmartCareID'}), 'GroupingVariables', {'SmartCareID'});
    pcountmtable = sortrows(pcountmtable, 'GroupCount', 'descend');
    ysortmostdays = pcountmtable.SmartCareID;

    pcountmtable = varfun(@max, pdcountmtable(:,{'SmartCareID', 'ScaledDateNum'}), 'GroupingVariables', {'SmartCareID'});
    pcountmtable = sortrows(pcountmtable, {'max_ScaledDateNum', 'SmartCareID'}, {'descend', 'ascend'});
    ysortmaxdays = pcountmtable.SmartCareID;

    % extract study date and join with offsets to keep only those patients who
    % have enough data (ie the patients left after outlier date handling
    %patientstudydate = sortrows(cdPatient(:,{'ID', 'StudyDate'}), 'ID', 'ascend');
    %patientstudydate.Properties.VariableNames{'ID'} = 'SmartCareID';
    %patientstudydate = innerjoin(patientoffsets, patientstudydate);

    % create a scaleddatenum to translate the study date to the same normalised
    % scale as measurement data scaled date num
    %patientstudydate.ScaledDateNum = datenum(patientstudydate.StudyDate) - offset - patientstudydate.PatientOffset;

    % create the min and max smartcareid to allow me to hide the dummy row
    % below
    %dispmin = min(pdcountmtable.SmartCareID);
    %dispmax = max(pdcountmtable.SmartCareID);

    % new bit to give some stats on distribution of patients duration of
    % measurements

    totpats  = size(pcountmtable, 1);
    patgr5   = sum(pcountmtable.max_ScaledDateNum >= 150);
    pat3to5  = sum(pcountmtable.max_ScaledDateNum >= 90 & pcountmtable.max_ScaledDateNum < 150);
    pat2to3  = sum(pcountmtable.max_ScaledDateNum >= 60 & pcountmtable.max_ScaledDateNum < 90);

    fprintf('Patients >= 5m          data: %d (%.0f%%)\n', patgr5 , 100 * patgr5/totpats);
    fprintf('Patients >= 3m and < 5m data: %d (%.0f%%)\n', pat3to5 , 100 * pat3to5/totpats);
    fprintf('Patients >= 2m and < 3m data: %d (%.0f%%)\n', pat2to3 , 100 * pat2to3/totpats);

    measperday = groupcounts(pdcountmtable, 'GroupCount');

    fprintf('The average number of measures per day was %.1f\n', sum(pdcountmtable.GroupCount)/size(pdcountmtable, 1));
    fprintf('At least 6 measures were submitted on %d days (%.0f%%)\n', sum(pdcountmtable.GroupCount >=6), 100 * sum(pdcountmtable.GroupCount >=6)/size(pdcountmtable, 1));


    mandatorymeas = physdata(ismember(physdata.RecordingType, ...
        {'ActivityRecording', 'CoughRecording', 'LungFunctionRecording', 'O2SaturationRecording', 'PulseRateRecording', 'WeightRecording', 'WellnessRecording'}), :);     

    mandpdcountmtable = varfun(@max, mandatorymeas(mandatorymeas.ScaledDateNum < (studyduration + 1), {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});
    mandmeasperday = groupcounts(mandpdcountmtable, 'GroupCount');

    fprintf('The average number of measures per day was %.1f\n', sum(mandpdcountmtable.GroupCount)/size(mandpdcountmtable, 1));
    fprintf('At least 6 of the 7 mandatory measures were submitted on %d days (%.0f%%)\n', sum(mandpdcountmtable.GroupCount >=6), 100 * sum(mandpdcountmtable.GroupCount >=6)/size(mandpdcountmtable, 1));

    % need to create a figure and add formatting if I want to use the bar
    % chart)
    %bar(mandmeasperday.GroupCount, mandmeasperday.GroupCount_1);

    %sum(mandmeasperday.GroupCount_1);
    %sum(mandmeasperday.GroupCount_1>=6);
    
elseif ismember(study, {'BR'})
    
    % remove calculated measurement type
    physdata = physdata(~ismember(physdata.RecordingType, {'LungFunctionRecording'}), :);
    
    % create a table of counts of measures by patient/day (@max function here
    % is irrelevant as we just want the group counts
    %pdcountmtable = varfun(@max, physdata(:, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});
    pdcountmtable = varfun(@max, physdata(: , {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});

    % create two different sort orders - 1) most days with measures 2) longest
    % period of measures (with a max of the study period)
    pcountmtable = varfun(@sum, pdcountmtable(:,{'SmartCareID'}), 'GroupingVariables', {'SmartCareID'});
    pcountmtable = sortrows(pcountmtable, 'GroupCount', 'descend');
    ysortmostdays = pcountmtable.SmartCareID;

    pcountmtable = varfun(@max, pdcountmtable(:,{'SmartCareID', 'ScaledDateNum'}), 'GroupingVariables', {'SmartCareID'});
    pcountmtable = sortrows(pcountmtable, {'max_ScaledDateNum', 'SmartCareID'}, {'descend', 'ascend'});
    ysortmaxdays = pcountmtable.SmartCareID;
    
    fprintf('All Measures\n');
    fprintf('------------\n');
    fprintf('\n');
    fprintf('Total participant study days = %d\n', sum(pcountmtable.max_ScaledDateNum));
    fprintf('Max duration days            = %d\n', max(pcountmtable.max_ScaledDateNum));
    fprintf('Total days with measurements = %d\n', sum(pcountmtable.GroupCount));
    fprintf('Percentage of days with measurements = %.1f%%\n', 100 * sum(pcountmtable.GroupCount) / sum(pcountmtable.max_ScaledDateNum));
    
    totpats   = size(pcountmtable, 1);
    patgr2    = sum(pcountmtable.max_ScaledDateNum >= 730);
    pat1to2   = sum(pcountmtable.max_ScaledDateNum >= 365 & pcountmtable.max_ScaledDateNum < 730);
    pat05to1  = sum(pcountmtable.max_ScaledDateNum >= 182 & pcountmtable.max_ScaledDateNum < 365);
    patle05   = sum(pcountmtable.max_ScaledDateNum <  182);

    fprintf('Patients >= 2yr             data: %d (%.1f%%)\n', patgr2   , 100 * patgr2  /totpats);
    fprintf('Patients >= 1yr   and < 2yr data: %d (%.1f%%)\n', pat1to2  , 100 * pat1to2 /totpats);
    fprintf('Patients >= 0.5yr and < 1yr data: %d (%.1f%%)\n', pat05to1 , 100 * pat05to1/totpats);
    fprintf('Patients <  0.5yr           data: %d (%.1f%%)\n', patle05  , 100 * patle05 /totpats);
    
    fprintf('Median participant study duration = %.1f\n', median(pcountmtable.max_ScaledDateNum));
    
    measperday = groupcounts(pdcountmtable, 'GroupCount');
    fprintf('The average number of measures per day was %.1f\n', sum(pdcountmtable.GroupCount)/size(pdcountmtable, 1));
    fprintf('At least 6 measures were submitted on %d days (%.0f%%)\n', sum(pdcountmtable.GroupCount >=6), 100 * sum(pdcountmtable.GroupCount >=6)/size(pdcountmtable, 1));

    [f1, p1] = createFigureAndPanelForPaper('', 5, 3);
    ax = subplot(1, 1, 1, 'Parent', p1);
    
    bar(ax, measperday.GroupCount, measperday.GroupCount_1);
    
    % exclude passively collected measures to see counts of active measures
    % per day and re do days with measures as well
    
    activemeas = physdata(~ismember(physdata.RecordingType, ...
        {'CalorieRecording', 'MinsAsleepRecording', 'MinsAwakeRecording', 'RestingHRRecording'}), :);     

    pdcountamtable = varfun(@max, activemeas(:, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});
    pcountamtable = varfun(@max, pdcountamtable(:,{'SmartCareID', 'ScaledDateNum'}), 'GroupingVariables', {'SmartCareID'});
    pcountamtable = sortrows(pcountamtable, {'max_ScaledDateNum', 'SmartCareID'}, {'descend', 'ascend'});
    %ysortmaxdays = pcountamtable.SmartCareID;
    
    fprintf('\n');
    fprintf('Active Measures\n');
    fprintf('---------------\n');
    fprintf('\n');
    
    fprintf('Total participant study days = %d\n', sum(pcountmtable.max_ScaledDateNum));
    fprintf('Max duration days            = %d\n', max(pcountamtable.max_ScaledDateNum));
    fprintf('Total days with measurements = %d\n', sum(pcountamtable.GroupCount));
    fprintf('Percentage of days with measurements = %.1f%%\n', 100 * sum(pcountamtable.GroupCount) / sum(pcountmtable.max_ScaledDateNum));
    
    totpats   = size(pcountamtable, 1);
    patgr2    = sum(pcountamtable.max_ScaledDateNum >= 730);
    pat1to2   = sum(pcountamtable.max_ScaledDateNum >= 365 & pcountamtable.max_ScaledDateNum < 730);
    pat05to1  = sum(pcountamtable.max_ScaledDateNum >= 182 & pcountamtable.max_ScaledDateNum < 365);
    patle05   = sum(pcountamtable.max_ScaledDateNum <  182);

    fprintf('Patients >= 2yr             data: %d (%.1f%%)\n', patgr2   , 100 * patgr2  /totpats);
    fprintf('Patients >= 1yr   and < 2yr data: %d (%.1f%%)\n', pat1to2  , 100 * pat1to2 /totpats);
    fprintf('Patients >= 0.5yr and < 1yr data: %d (%.1f%%)\n', pat05to1 , 100 * pat05to1/totpats);
    fprintf('Patients <  0.5yr           data: %d (%.1f%%)\n', patle05  , 100 * patle05 /totpats);
    
    fprintf('Median participant study duration = %.1f\n', median(pcountamtable.max_ScaledDateNum));
    
    ameasperday = groupcounts(pdcountamtable, 'GroupCount');
    fprintf('The average number of measures per day was %.1f\n', sum(pdcountamtable.GroupCount)/size(pdcountamtable, 1));
    fprintf('At least 6 measures were submitted on %d days (%.0f%%)\n', sum(pdcountamtable.GroupCount >=6), 100 * sum(pdcountamtable.GroupCount >=6)/size(pdcountamtable, 1));

    [f2, p2] = createFigureAndPanelForPaper('', 5, 3);
    ax = subplot(1, 1, 1, 'Parent', p2);
    
    bar(ax, ameasperday.GroupCount, ameasperday.GroupCount_1);

    
    
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
filename = sprintf('%s-Heatmap - RecordedMeasuresByParticipantForPaper', study);
savePlotInDir(f, filename, subfolder);
%savePlotInDirAsSVG(f, filename, subfolder);
close(f);

toc
fprintf('\n');

end
