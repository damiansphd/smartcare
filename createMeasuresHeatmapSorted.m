function createMeasuresHeatmapSorted(physdata, offset, cdPatient, study)

% createMeasuresHeatmapSorted - creates the Patient/Measures
% heatmap just for study period, sorted by number of days with measures

fprintf('Creating Sorted Heatmap of Measures for Study Period\n');
fprintf('----------------------------------------------------\n');
tic

basedir = setBaseDir();
subfolder = sprintf('Plots/%s', study);

temp = hsv;
brightness = .9;

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
    nmeasures = 9;
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
else
    fprintf('**** Unknown Study ****');
    return;
end

studyduration = 184;

% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(physdata);

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

labelinterval = 25;
xdisplaylabels = cell(studyduration, 1);
for i = 1:studyduration
    if i == 1 || i == studyduration || (i / labelinterval == round(i / labelinterval))
        xdisplaylabels{i} = sprintf('%d', i);
    else
        xdisplaylabels{i} = ' ';
    end
end

ydisplaylabels = cell(size(unique(pdcountmtable.SmartCareID), 1) - 1, 1);
ydisplaylabels(:) = {' '};

% create the heatmap

title = 'Recorded Measures by Participant for the Study Period';

[f, p] = createFigureAndPanel(title, 'portrait', 'a4');

h = heatmap(p, pdcountmtable, 'ScaledDateNum', 'SmartCareID', 'Colormap', colors, 'MissingDataColor', 'black', ...
    'ColorVariable','GroupCount','ColorMethod','max', 'MissingDataLabel', 'No data');
h.Title = ' ';
h.XLabel = 'Days';
h.YLabel = 'Participants';
h.YDisplayData = ysortmaxdays;
h.XDisplayLabels = xdisplaylabels;
h.YDisplayLabels = ydisplaylabels;
h.CellLabelColor = 'none';
h.GridVisible = 'off';

% save results
filename = sprintf('%s-Heatmap - RecordedMeasuresByParticipantForStudyPeriod', study);
savePlotInDir(f, filename, subfolder);
savePlotInDirAsSVG(f, filename, subfolder);
close(f);

toc
fprintf('\n');

end
