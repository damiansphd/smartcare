function createAndSaveBreatheWeightPlots(patientlist, pmeaswght, pclinwght, pstudydate, ...
    plotsacross, plotsdown, plotsperpage, subfolder, filenameprefix)

% createAndSaveBreatheWeightPlots - function to create plots of weight home vs clinical 
% measures and save results to file

npages = ceil(size(patientlist, 1) / plotsperpage);

page = 1;
imagefilename = sprintf('%s - Page %2d of %2d', filenameprefix, page, npages);
[f, p] = createFigureAndPanel(imagefilename, 'Portrait', 'a4');

for i = 1:size(patientlist, 1)
    scid = patientlist(i);
    hospital = pstudydate.Hospital{pstudydate.SmartCareID == scid};
    studyid  = pstudydate.StudyNumber{pstudydate.SmartCareID == scid};
    % get home weight measures just for current patient
    pmeasures = pmeaswght(pmeaswght.SmartCareID == scid,:);
    % get clinical weight measures just for current patient
    pclinical = pclinwght(pclinwght.SmartCareID == scid,:);
    
    % store min and max to scale x-axis of plot display. Set min to -5 if less
    % than, to avoid wasting plot space for the one patient with a larger delay
    % between study date and active measurement period
    mindays = min([pmeasures.ScaledDateNum ; pstudydate.ScaledDateNum]);
    if mindays < -5
        mindays = -5;
    end
    maxdays = max([pmeasures.ScaledDateNum ; 150]);

    % store min and max for patient (and handle case where there are no
    % clinical measures
    if size(pmeasures, 1) > 0
        minpmwght = min(pmeasures.Weight);
        maxpmwght = max(pmeasures.Weight);
    else
        minpmwght = 50;
        maxpmwght = 50;
    end
    if size(pclinical,1) > 0
        minpcwght = min(pclinical.Weight);
        maxpcwght = max(pclinical.Weight);
    else
        minpcwght = minpmwght;
        maxpcwght = maxpmwght;
    end
    
    % plot Weight measures
    ax = subplot(plotsdown, plotsacross, i - (page - 1) * plotsperpage, 'Parent', p);
    hold on;
    plot(ax, pmeasures.ScaledDateNum,pmeasures.Weight,'y-o',...
        'LineWidth',1,...
        'MarkerSize',3,...
        'MarkerEdgeColor','b',...
        'MarkerFaceColor','g');
    plot(ax, pclinical.ScaledDateNum,pclinical.Weight,'c-o',...
        'LineWidth',1,...
        'MarkerSize',3,...
        'MarkerEdgeColor','m',...
        'MarkerFaceColor','w');
    xl = [mindays maxdays];
    xlim(xl);
    rangelimit = 0.5;
    yl = setYDisplayRange(min(minpcwght, minpmwght), max(maxpcwght, maxpmwght), rangelimit);
    ylim(yl);
    title(ax, sprintf('ID%3d (%s %s)',scid, hospital, studyid), 'fontsize', 6);
    
    hold off
    fprintf('Row %3d, Patient %3d\n', ...
        i, scid); 
    
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
