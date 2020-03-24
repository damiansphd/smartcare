function createAndSaveWeightPlots(pmeasuresweight, pstudydateweight, ...
    mindays, maxdays, plotsacross, plotsdown, plotsperpage, basedir, subfolder, filenameprefix)

% createAndSaveWeightPlots - function to create plots of Weight home vs clinical 
% measures and save results to file

npages = ceil(size(pstudydateweight, 1) / plotsperpage);

page = 1;
imagefilename = sprintf('%s - Page %2d of %2d', filenameprefix, page, npages);
[f, p] = createFigureAndPanel(imagefilename, 'Portrait', 'a4');

for i = 1:size(pstudydateweight,1)
    scid     = pstudydateweight.SmartCareID(i);
    studyid  = pstudydateweight.StudyNumber{i};
    hospital = pstudydateweight.Hospital{i};
    pweight  = pstudydateweight.Weight(i);
    % get weight measures just for current patient
    pmeasures = pmeasuresweight(pmeasuresweight.SmartCareID == scid,:);
    % store min and max for patient
    minpmweight = min(pmeasures.WeightInKg);
    if size(minpmweight, 1) == 0
        minpmweight = 100;
    end
    maxpmweight = max(pmeasures.WeightInKg);
    if size(maxpmweight, 1) == 0
        maxpmweight = 0;
    end
    
    studystart = pstudydateweight.ScaledDateNum(i);
    studyend = studystart + 183;
    
    % plot weight measures
    ax = subplot(plotsdown, plotsacross, i - (page - 1) * plotsperpage, 'Parent', p);
    hold on;
    plot(ax, pmeasures.ScaledDateNum,pmeasures.WeightInKg,'y-o',...
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
    title(ax, sprintf('ID%3d (%s %s)',scid, hospital, studyid), 'fontsize', 10);
    
    % add clinical weight as a horizontal line
    line(ax, xl, [pweight pweight], 'Color', 'r', 'LineStyle','--', 'LineWidth',1);
    
    % add study start and end as vertical lines
    line(ax, [studystart studystart], yl, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1);
    line(ax, [studyend studyend],     yl, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1);
    
    fprintf('Row %3d, Patient %3d: Clinical Weight = %2.2f Min Home Weight = %2.2f Max Home Weight = %2.2f\n', ...
        i, scid, pweight, minpmweight, maxpmweight);
    
    % create a new page as necessary
    if round((i)/plotsperpage) == (i)/plotsperpage
        savePlotInDir(f, imagefilename, subfolder);
        close(f);
        page = page + 1;
        imagefilename = sprintf('%s - Page %2d of %2d', filenameprefix, page, npages);
        [f, p] = createFigureAndPanel(imagefilename, 'Portrait', 'a4');
        fprintf('Next Page\n');
    end
end

if exist('f', 'var')
    savePlotInDir(f, imagefilename, subfolder);
    close(f);
end

end
