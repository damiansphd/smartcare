function createMeasuresHeatmapSorted(physdata, offset, cdPatient)

% createMeasuresHeatmapSorted - creates the Patient/Measures
% heatmap just for study period, sorted by number of days with measures

fprintf('Creating Sorted Heatmap of Measures for Study Period\n');
fprintf('----------------------------------------------------\n');
tic

basedir = setBaseDir();
subfolder = 'Plots';

temp = hsv;
brightness = .9;
%colors(1,:)  = [0 0 0];     % black for no measures
colors(1,:)  = temp(4,:)  .* brightness;
colors(2,:)  = temp(6,:)  .* brightness;
colors(3,:)  = temp(8,:)  .* brightness;
colors(4,:)  = temp(10,:) .* brightness;
colors(5,:)  = temp(12,:) .* brightness;
colors(6,:)  = temp(14,:) .* brightness;
colors(7,:)  = temp(16,:) .* brightness;
colors(8,:)  = temp(18,:) .* brightness;
colors(9,:)  = temp(20,:) .* brightness;
%colors(10,:)  = [1 0 1];

% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(physdata);

% create a table of counts of measures by patient/day (@max function here
% is irrelevant as we just want the group counts
%pdcountmtable = varfun(@max, physdata(:, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});
pdcountmtable = varfun(@max, physdata(physdata.ScaledDateNum<184, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});

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

% create the heatmap
  
title = 'Recorded Measures by Patient for the Study Period';
f = figure('Name', title);
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = title; 
p.TitlePosition = 'centertop';
p.FontSize = 18;
p.FontWeight = 'bold';
set(gcf, 'Units', 'normalized', 'OuterPosition', [0.2, 0.2, 0.8, 0.8], 'PaperOrientation', 'portrait', ...
    'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
h = heatmap(p, pdcountmtable, 'ScaledDateNum', 'SmartCareID', 'Colormap', colors, 'MissingDataColor', 'black', ...
    'ColorVariable','GroupCount','ColorMethod','max', 'MissingDataLabel', 'No data');
h.Title = ' ';
h.XLabel = 'Days';
h.YLabel = 'Patients';
h.YDisplayData = ysortmaxdays;
%h.YLimits = {dispmin,dispmax};
h.CellLabelColor = 'none';
h.GridVisible = 'off';

%[C,x] = sortx(h);

% save results
filename = 'Heatmap - RecordedMeasuresByPatientForStudyPeriod';
savePlotInDir(f, filename, subfolder);
close(f);

toc
fprintf('\n');

end
