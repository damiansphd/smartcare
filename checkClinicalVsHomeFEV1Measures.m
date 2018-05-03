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

% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(physdata);

% extract clinical FEV1 measures and join with offsets to keep only those patients who
% have enough data (ie the patients left after outlier date handling
pclinicalfev = sortrows(cdPFT(:,{'ID', 'LungFunctionDate', 'FEV1_'}), {'ID', 'LungFunctionDate'}, 'ascend');
pclinicalfev.Properties.VariableNames{'ID'} = 'SmartCareID';
pclinicalfev = innerjoin(pclinicalfev, patientoffsets);

% create a scaleddatenum to translate the study date to the same normalised
% scale as measurement data scaled date num
pclinicalfev.ScaledDateNum = datenum(pclinicalfev.LungFunctionDate) - offset - pclinicalfev.PatientOffset + 1;

% extract study date and join with offsets to keep only those patients who
% have enough data (ie the patients left after outlier date handling
pstudydate = sortrows(cdPatient(:,{'ID', 'StudyDate'}), 'ID', 'ascend');
pstudydate.Properties.VariableNames{'ID'} = 'SmartCareID';
pstudydate = innerjoin(patientoffsets, pstudydate);

% create a scaleddatenum to translate the study date to the same normalised
% scale as measurement data scaled date num
pstudydate.ScaledDateNum = datenum(pstudydate.StudyDate) - offset - pstudydate.PatientOffset;


% extract just the weight measures from smartcare data
pmeasuresfev = physdata(ismember(physdata.RecordingType,'LungFunctionRecording'),{'SmartCareID', 'ScaledDateNum', 'FEV1_'});

% store min and max to scale x-axis of plot display. Set min to -5 if less
% than, to avoid wasting plot space for the one patient with a larger delay
% between study date and active measurement period
mindays = min([pmeasuresfev.ScaledDateNum ; pstudydate.ScaledDateNum]);
if mindays < -5
    mindays = -5;
end
maxdays = max([pmeasuresfev.ScaledDateNum ; pstudydate.ScaledDateNum + 183]);

% loop over all patients, create a plot for each of home weight measurements
% with the clinical weight overlaid as a horizontal line
% six plots per page
plotsacross = 2;
plotsdown = 4;
plotsperpage = plotsacross * plotsdown;
basedir = './';
subfolder = 'Plots';

% create plots for patients with differences home vs clinical
fprintf('FEV Plots for diff values home vs clinical\n');
patientlist = [54 ; 82 ; 141 ; 153 ; 175 ; 196 ; 197 ; 201 ; 212 ; 213 ; 214 ; 215 ; 216 ; 223 ; 227 ; 229];
filenameprefix = 'ClinicalVsHomeFEV1 - Different Values';
figurearray = createAndSaveFEVPlots(patientlist, pmeasuresfev, pclinicalfev, pstudydate, ...
    mindays, maxdays, plotsacross, plotsdown, plotsperpage, basedir, subfolder, filenameprefix);
close all;

% create plots for potential anomalous clinical FEV1 measures identified
fprintf('FEV Plots for potential anomalous clinical measures\n');
patientlist = [130];
filenameprefix = 'ClinicalVsHomeFEV1 - Outlier Clinical Values';
figurearray = createAndSaveFEVPlots(patientlist, pmeasuresfev, pclinicalfev, pstudydate, ...
    mindays, maxdays, plotsacross, plotsdown, plotsperpage, basedir, subfolder, filenameprefix);
close all;

fprintf('FEV Plots for all patients\n');
patientlist = unique(pmeasuresfev.SmartCareID);
filenameprefix = 'ClinicalVsHomeFEV1';
figurearray = createAndSaveFEVPlots(patientlist, pmeasuresfev, pclinicalfev, pstudydate, ...
    mindays, maxdays, plotsacross, plotsdown, plotsperpage, basedir, subfolder, filenameprefix);
close all;


%for i = 1:size(patientlist,1)
%    scid = patientlist(i);
    % get home weight measures just for current patient
%    pmeasures = pmeasuresfev(pmeasuresfev.SmartCareID == scid,:);
    % get clinical weight measures just for current patient
%    pclinical = pclinicalfev(pclinicalfev.SmartCareID == scid,:);
    
    % get study start and end dates just for current patient
%    studystart = pstudydate.ScaledDateNum(i);
%    studyend = studystart + 183;
    
    % store min and max for patient (and handle case where there are no
    % clinical measures
%    minpmfev = min(pmeasures.FEV1_);
%    maxpmfev = max(pmeasures.FEV1_);
%    if size(pclinical,1) > 0
%        minpcfev = min(pclinical.FEV1_);
%        maxpcfev = max(pclinical.FEV1_);
%    else
%        minpcfev = minpmfev;
%        minpcfev = minpmfev;
%    end
    
    % create a new page as necessary
%    if round((i-1)/plotsperpage) == (i-1)/plotsperpage
%        page = page + 1;
%        fprintf('Next Page\n');
%        figurearray(page) = figure('Name',sprintf('%s - page %2d', filenameprefix, page));
%        set(gcf, 'Units', 'normalized', 'OuterPosition', [0.2, 0.2, 0.8, 0.8], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, .75], 'PaperType', 'a4');
%        p = uipanel('Parent',figurearray(page),'BorderType','none'); 
%        p.Title = sprintf('%s - page %2d', filenameprefix, page); 
%        p.TitlePosition = 'centertop';
%        p.FontSize = 20;
%        p.FontWeight = 'bold';
        
%    end
    
    % plot weight measures
%    subplot(plotsdown,plotsacross,i-(page-1)*plotsperpage,'Parent',p);
%    hold on;
%    plot(pmeasures.ScaledDateNum,pmeasures.FEV1_,'y-o',...
%        'LineWidth',1,...
%        'MarkerSize',3,...
%        'MarkerEdgeColor','b',...
%        'MarkerFaceColor','g');
%    plot(pclinical.ScaledDateNum,pclinical.FEV1_,'c-o',...
%        'LineWidth',1,...
%        'MarkerSize',3,...
%        'MarkerEdgeColor','m',...
%        'MarkerFaceColor','w');
%    xl = [mindays maxdays];
%    xlim(xl);
%    yl = [min(minpcfev, minpmfev)*.9 max(maxpcfev, maxpmfev)*1.1];
%    ylim(yl);
%    title(sprintf('Patient %3d',scid));
    % add study start and end as vertical lines
%    line( [studystart studystart], yl, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1);
%    line( [studyend studyend],     yl, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1);
%    hold off
%    fprintf('Row %3d, Patient %3d\n', ...
%        i, scid);   
%end

%for i = 1:size(figurearray,2)
%    imagefilename = sprintf('%s - page %2d.png', filenameprefix, i);
%    saveas(figurearray(i),fullfile(basedir, subfolder, imagefilename));
%end