clc; clear; close all;

tic
fprintf('Loading Clinical data\n');
load('clinicaldata.mat');
fprintf('Loading SmartCare measurement data\n');
load('smartcaredata.mat');
toc

filenameprefix = 'ClinicalVsHomeFEV1';

% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(physdata);

% extract study date and join with offsets to keep only those patients who
% have enough data (ie the patients left after outlier date handling
pclinicalfev = sortrows(cdPFT(:,{'ID', 'LungFunctionDate', 'FEV1_'}), {'ID', 'LungFunctionDate'}, 'ascend');
pclinicalfev.Properties.VariableNames{'ID'} = 'SmartCareID';
pclinicalfev = innerjoin(pclinicalfev, patientoffsets);

% create a scaleddatenum to translate the study date to the same normalised
% scale as measurement data scaled date num
pclinicalfev.ScaledDateNum = datenum(pclinicalfev.LungFunctionDate) - offset - pclinicalfev.PatientOffset;


% extract just the weight measures from smartcare data
pmeasuresfev = physdata(ismember(physdata.RecordingType,'LungFunctionRecording'),{'SmartCareID', 'ScaledDateNum', 'FEV1_'});

% store min and max to scale x-axis of plot display
mindays = min(pmeasuresfev.ScaledDateNum);
maxdays = max(pmeasuresfev.ScaledDateNum);

% loop over all patients, create a plot for each of home weight measurements
% with the clinical weight overlaid as a horizontal line
% six plots per page
figurearray = [];
page = 0;
plotsacross = 2;
plotsdown = 4;
plotsperpage = plotsacross * plotsdown;

patientlist = unique(pmeasuresfev.SmartCareID);

% uncomment to create plots just for anomalous clinical weight measures identified
%patientlist = patientlist(ismember(patientlist, [54, 82, 94, 141, 153, 175, 196, 197, 201, 207, 212, 213, 214, 215, 216, 223, 227, 229]));
%filenameprefix = 'ClinicalVsHomeFEV1 - Different Values';

% uncomment to create plots just for anomalous clinical weight measures identified
%patientlist = patientlist(ismember(patientlist, [130]));
%filenameprefix = 'ClinicalVsHomeFEV1 - Outlier Clinical Values';

for i = 1:size(patientlist,1)
%for i = 1:13
    scid = patientlist(i);
    % get home weight measures just for current patient
    pmeasures = pmeasuresfev(pmeasuresfev.SmartCareID == scid,:);
    % get clinical weight measures just for current patient
    pclinical = pclinicalfev(pclinicalfev.SmartCareID == scid,:);
    % store min and max for patient (and handle case where there are no
    % clinical measures
    minpmfev = min(pmeasures.FEV1_);
    maxpmfev = max(pmeasures.FEV1_);
    if size(pclinical,1) > 0
        minpcfev = min(pclinical.FEV1_);
        maxpcfev = max(pclinical.FEV1_);
    else
        minpcfev = minpmfev;
        minpcfev = minpmfev;
    end
    
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
    hold on;
    plot(pmeasures.ScaledDateNum,pmeasures.FEV1_,'y-o',...
        'LineWidth',1,...
        'MarkerSize',3,...
        'MarkerEdgeColor','b',...
        'MarkerFaceColor','g');
    plot(pclinical.ScaledDateNum,pclinical.FEV1_,'c-o',...
        'LineWidth',1,...
        'MarkerSize',3,...
        'MarkerEdgeColor','m',...
        'MarkerFaceColor','w');
    xl = [mindays maxdays];
    xlim(xl);
    yl = [min(minpcfev, minpmfev)*.9 max(maxpcfev, maxpmfev)*1.1];
    ylim(yl);
    title(sprintf('Patient %3d',scid));
    hold off
    fprintf('Row %3d, Patient %3d\n', ...
        i, scid);   
end

for i = 1:size(figurearray,2)
    imagefilename = sprintf('%s - page %2d.png', filenameprefix, i);
    saveas(figurearray(i),imagefilename);
end