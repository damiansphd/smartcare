function createMeasuresHeatmapWithStudyPeriod(physdata, offset, cdPatient, study)

% createMeasuresHeatmapWithStudyPeriod - creates the Patient/Measures
% heatmap, and overlays study period start and end

fprintf('Creating Heatmap of Measures with Study Period\n');
fprintf('----------------------------------------------\n');
tic

temp = hsv(64);
brightness = 0.9;


if ismember(study, {'SC', 'TM'})
    colors(1,:)  = temp(4,:);
    colors(2,:)  = temp(6,:);
    colors(3,:)  = temp(8,:);
    colors(4,:)  = temp(10,:);
    colors(5,:)  = temp(12,:);
    colors(6,:)  = temp(14,:);
    colors(7,:)  = temp(16,:);
    colors(8,:)  = temp(18,:);
    colors(9,:)  = temp(20,:);
    colors(10,:)  = [1 0 1];
    nmeasures = 9;
elseif ismember(study, {'CL'})
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
    colors(16,:)  = [1 0 1];
    nmeasures = 15;
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
    colors(18,:)  = [1 0 1];
    nmeasures = 17;
else
    fprintf('**** Unknown Study ****');
    return;
end

colors(1:end - 1, :) = colors(1:end - 1,:) .* brightness;

% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(physdata);

% create a table of counts of measures by patient/day (@max function here
% is irrelevant as we just want the group counts
pdcountmtable = varfun(@max, physdata(:, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});

% extract study date and join with offsets to keep only those patients who
% have enough data (ie the patients left after outlier date handling
patientstudydate = sortrows(cdPatient(:,{'ID', 'StudyDate'}), 'ID', 'ascend');
patientstudydate.Properties.VariableNames{'ID'} = 'SmartCareID';
patientstudydate = innerjoin(patientoffsets, patientstudydate);

% create a scaleddatenum to translate the study date to the same normalised
% scale as measurement data scaled date num
patientstudydate.ScaledDateNum = datenum(patientstudydate.StudyDate) - offset - patientstudydate.PatientOffset;

% add rows to the count table to mark the study start and end dates (use a count
% of 10 to allow it to be highlighted in a different colour on the heatmap
studyduration = 183;
fixedcount = ones(size(patientstudydate, 1), 1) * (nmeasures + 1);
fixedcount = array2table(fixedcount);
fixedcount.Properties.VariableNames{'fixedcount'} = 'GroupCount';
rowstoadd = [patientstudydate(:,{'SmartCareID', 'ScaledDateNum'}) fixedcount];   
pdcountmtable = [pdcountmtable ; rowstoadd];
rowstoadd.ScaledDateNum = rowstoadd.ScaledDateNum + studyduration;
pdcountmtable = [pdcountmtable ; rowstoadd];

% create the min and max smartcareid to allow me to hide the dummy row
% below
dispmin = min(pdcountmtable.SmartCareID);
dispmax = max(pdcountmtable.SmartCareID);

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
title = sprintf('%s-Heatmap of Measures with Study Period', study);

[f, p] = createFigureAndPanel(title, 'portrait', 'a4');
h = heatmap(p, pdcountmtable, 'ScaledDateNum', 'SmartCareID', 'Colormap', colors, 'MissingDataColor', 'black', ...
    'ColorVariable','GroupCount','ColorMethod','max', 'MissingDataLabel', 'No data');
h.Title = ' ';
h.XLabel = 'Days';
h.YLabel = 'Patients';
h.YLimits = {dispmin,dispmax};
h.CellLabelColor = 'none';
h.GridVisible = 'off';

%[C,x] = sortx(h);

% save results
basedir = setBaseDir();
filename = sprintf('%s-HeatmapAllPatientsWithStudyPeriod', study);
subfolder = sprintf('Plots/%s', study);
if ~exist(strcat(basedir, subfolder), 'dir')
    mkdir(strcat(basedir, subfolder));
end
savePlotInDir(f, filename, subfolder);
close(f);

toc
fprintf('\n');

end
