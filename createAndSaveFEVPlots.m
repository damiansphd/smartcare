function [figurearray] = createAndSaveFEVPlots(patientlist, pmeasuresfev, pclinicalfev, pstudydate, ...
    mindays, maxdays, plotsacross, plotsdown, plotsperpage, basedir, subfolder, filenameprefix)

% createAndSaveFEVPlots - function to create plots of FEV home vs clinical 
% measures and save results to file

figurearray = [];
page = 0;

for i = 1:size(patientlist,1)
    scid = patientlist(i);
    % get home weight measures just for current patient
    pmeasures = pmeasuresfev(pmeasuresfev.SmartCareID == scid,:);
    % get clinical weight measures just for current patient
    pclinical = pclinicalfev(pclinicalfev.SmartCareID == scid,:);
    
    % get study start and end dates just for current patient
    studystart = pstudydate.ScaledDateNum(i);
    studyend = studystart + 183;
    
    % store min and max for patient (and handle case where there are no
    % clinical measures
    minpmfev = min(pmeasures.FEV1_);
    maxpmfev = max(pmeasures.FEV1_);
    if size(pclinical,1) > 0
        minpcfev = min(pclinical.FEV1_);
        maxpcfev = max(pclinical.FEV1_);
    else
        minpcfev = minpmfev;
        maxpcfev = maxpmfev;
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
    
    % plot FEV1 measures
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
    yl = setYDisplayRange(min(minpcfev, minpmfev), max(maxpcfev, maxpmfev), 50);
    ylim(yl);
    title(sprintf('Patient %3d',scid));
    % add study start and end as vertical lines
    line( [studystart studystart], yl, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1);
    line( [studyend studyend],     yl, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1);
    hold off
    fprintf('Row %3d, Patient %3d\n', ...
        i, scid);   
end

for i = 1:size(figurearray,2)
    imagefilename = sprintf('%s - page %2d.png', filenameprefix, i);
    saveas(figurearray(i),fullfile(basedir, subfolder, imagefilename));
end

end
