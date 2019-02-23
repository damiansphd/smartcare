function [figurearray] = createAndSaveWeightPlots(pmeasuresweight, pstudydateweight, ...
    mindays, maxdays, plotsacross, plotsdown, plotsperpage, basedir, subfolder, filenameprefix)

% createAndSaveWeightPlots - function to create plots of Weight home vs clinical 
% measures and save results to file

figurearray = [];
page = 0;

for i = 1:size(pstudydateweight,1)
    scid = pstudydateweight.SmartCareID(i);
    hospital = pstudydateweight.Hospital{i};
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
    rangelimit = setMinYDisplayRangeForMeasure('WeightRecording');
    yl = setYDisplayRange(min(pweight, minpmweight), max(pweight, maxpmweight), rangelimit);
    %yl = [min(pweight, minpmweight)*.9 max(pweight, maxpmweight)*1.1];
    ylim(yl);
    title(sprintf('Patient %3d (%s)',scid, hospital));
    
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
    savePlotInDir(figurearray(i), imagefilename, subfolder);
    close(figurearray(i));
end

end
