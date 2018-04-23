clc; clear; close all;

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'clinicaldata.mat';
scmatfile = 'smartcaredata.mat';

fprintf('Loading Clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading SmartCare measurement data\n');
load(fullfile(basedir, subfolder, scmatfile));
toc

basedir = './';
subfolder = 'Plots';
filenameprefix = 'ClinicalVsHomeWeight';

% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(physdata);

% extract study date and join with offsets to keep only those patients who
% have enough data (ie the patients left after outlier date handling
pstudydateweight = sortrows(cdPatient(:,{'ID', 'StudyDate', 'Weight'}), 'ID', 'ascend');
pstudydateweight.Properties.VariableNames{'ID'} = 'SmartCareID';
pstudydateweight = innerjoin(patientoffsets, pstudydateweight);

% create a scaleddatenum to translate the study date to the same normalised
% scale as measurement data scaled date num
pstudydateweight.ScaledDateNum = datenum(pstudydateweight.StudyDate) - offset - pstudydateweight.PatientOffset;

% extract just the weight measures from smartcare data
pmeasuresweight = physdata(ismember(physdata.RecordingType,'WeightRecording'),{'SmartCareID', 'ScaledDateNum', 'WeightInKg'});

% store min and max to scale x-axis of plot display
mindays = min([pmeasuresweight.ScaledDateNum ; pstudydateweight.ScaledDateNum]);
if mindays < -5
    mindays = -5
end
maxdays = max([pmeasuresweight.ScaledDateNum ; pstudydateweight.ScaledDateNum + 183]);

% loop over all patients, create a plot for each of home weight measurements
% with the clinical weight overlaid as a horizontal line
% six plots per page
figurearray = [];
page = 0;
plotsacross = 2;
plotsdown = 4;
plotsperpage = plotsacross * plotsdown;

% uncomment to creat plots just for anomalous clinical weight measures identified
%pstudydateweight = pstudydateweight(ismember(pstudydateweight.SmartCareID, [61,178,193,195,196,197,198,199,201]),:);
%filenameprefix = 'ClinicalVsHomeWeight - Clinical Anomalies';

% uncomment to create plots just for anomalous home weight measures identified
pstudydateweight = pstudydateweight(ismember(pstudydateweight.SmartCareID, [30, 35, 100, 102, 134, 216, 241]),:);
filenameprefix = 'ClinicalVsHomeWeight - Outlier Values';

for i = 1:size(pstudydateweight,1)
    scid = pstudydateweight.SmartCareID(i);
    pweight = pstudydateweight.Weight(i);
    % get weight measures just for current patient
    pmeasures = pmeasuresweight(pmeasuresweight.SmartCareID == scid,:);
    % store min and max for patient
    minpmweight = min(pmeasures.WeightInKg);
    maxpmweight = max(pmeasures.WeightInKg);
    
    studystart = pstudydateweight.ScaledDateNum(i);
    studyend = studystart + 183;
    
    % create a new page as necessary
    if round((i-1)/plotsperpage) == (i-1)/plotsperpage
        page = page + 1;
        fprintf('Next Page\n');
        figurearray(page) = figure('Name',sprintf('%s - page %2d', filenameprefix, page));
        set(gcf, 'Units', 'normalized', 'OuterPosition', [0.2, 0.2, 0.8, 0.8], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, .75], 'PaperType', 'a4');
        p = uipanel('Parent',figurearray(page),'BorderType','none'); 
        p.Title = sprintf('%s - page %2d', filenameprefix, page); 
        p.TitlePosition = 'centertop';
        p.FontSize = 20;
        p.FontWeight = 'bold';
        
    end
    
    % plot weight measures
    subplot(plotsdown,plotsacross,i-(page-1)*plotsperpage,'Parent',p);
    plot(pmeasures.ScaledDateNum,pmeasures.WeightInKg,'y-o',...
        'LineWidth',1,...
        'MarkerSize',3,...
        'MarkerEdgeColor','b',...
        'MarkerFaceColor','g');
    xl = [mindays maxdays];
    xlim(xl);
    yl = [min(pweight, minpmweight)*.9 max(pweight, maxpmweight)*1.1];
    ylim(yl);
    title(sprintf('Patient %3d',scid));
    
    % add clinical weight as a horizontal line
    line( xl, [pweight pweight], 'Color', 'r', 'LineStyle','--', 'LineWidth',1);
    
    % add study start and end as vertical lines
    line( [studystart studystart], yl, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1);
    line( [studyend studyend],     yl, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1);
    
    fprintf('Row %3d, Patient %3d: Clinical Weight = %2.2d Min Home Weight = %2.2d Max Home Weight = %2.2d\n', ...
        i, scid, pweight, minpmweight, maxpmweight);   
end

for i = 1:size(figurearray,2)
    imagefilename = sprintf('%s - page %2d.png', filenameprefix, i);
    saveas(figurearray(i),fullfile(basedir, subfolder, imagefilename));
end