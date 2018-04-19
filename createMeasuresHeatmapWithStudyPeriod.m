clc; clear; close all;

tic
fprintf('Loading Clinical data\n');
load('clinicaldata.mat');
fprintf('Loading SmartCare measurement data\n');
load('smartcaredata.mat');
toc

temp = hsv;
brightness = .75;
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
colors(10,:)  = [1 0 1];

patientoffsets = getPatientOffsets(physdata);

pdcountmtable = varfun(@max, physdata(:, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});

patientstudydate = sortrows(cdPatient(:,{'ID', 'StudyDate'}), 'ID', 'ascend');
patientstudydate.Properties.VariableNames{'ID'} = 'SmartCareID';

patientstudydate = innerjoin(patientoffsets, patientstudydate);

patientstudydate.ScaledDateNum = datenum(patientstudydate.StudyDate) - offset - patientstudydate.PatientOffset;

fixedcount = ones(size(patientstudydate,1),1)*10;
fixedcount = array2table(fixedcount);
fixedcount.Properties.VariableNames{'fixedcount'} = 'GroupCount';


rowstoadd = [patientstudydate(:,{'SmartCareID', 'ScaledDateNum'}) fixedcount];   
pdcountmtable = [pdcountmtable ; rowstoadd];
rowstoadd.ScaledDateNum = rowstoadd.ScaledDateNum + 183;
pdcountmtable = [pdcountmtable ; rowstoadd];

title = 'Heatmap of Measures with Study Period';
f = figure('Name', title);
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = title; 
p.TitlePosition = 'centertop';
p.FontSize = 20;
p.FontWeight = 'bold'; 
set(gcf, 'Units', 'normalized', 'OuterPosition', [0.2, 0.2, 0.8, 0.8], 'PaperOrientation', 'landscape', ...
    'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a3');
h = heatmap(p, pdcountmtable, 'ScaledDateNum', 'SmartCareID', 'Colormap', colors, 'MissingDataColor', 'black', ...
    'ColorVariable','GroupCount','ColorMethod','max', 'MissingDataLabel', 'No data');
h.Title = ' ';
h.XLabel = 'Days';
h.YLabel = 'Patients';
h.CellLabelColor = 'none';
h.GridVisible = 'off';


filename = 'HeatmapAllPatientsWithStudyPeriod.png';
saveas(f,filename);
