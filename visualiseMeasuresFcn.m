function visualiseMeasuresFcn(physdata, offset, cdPatient, cdAdmissions, cdAntibiotics, cdClinicVisits, cdCRP, cdPFT, measures, study)

% visualiseMeasuresFcn - plots clinical and home measures

basedir = setBaseDir();
subfolder = sprintf('Plots/%s', study);
if ~exist(strcat(basedir, subfolder), 'dir')
    mkdir(strcat(basedir, subfolder));
end

patientoffsets = getPatientOffsets(physdata);
patientlist = unique(physdata.SmartCareID);

clinpghght = 3.5;
clinpgwdth = 6;
measpghght = 6;
measpgwdth = 6;

for pat = 1:size(patientlist,1)
%for pat = 59:59
%for pat = 7:7
    tic
    scid       = patientlist(pat);
    fprintf('Visualising measures for patient %d\n', scid);
    poffset    = patientoffsets.PatientOffset(patientoffsets.SmartCareID == scid);
    hospital   = cdPatient.Hospital{cdPatient.ID == scid};
    spstart    = cdPatient.StudyDate(cdPatient.ID == scid);
    spstartdn  = datenum(spstart) - offset - poffset + 1;
    %spend      = cdPatient.StudyDate(cdPatient.ID == scid)+days(183);
    spenddn    = spstartdn + 183;
    %hmstart    = min(physdata.Date_TimeRecorded(physdata.SmartCareID == scid));
    hmstartdn  = min(physdata.ScaledDateNum(physdata.SmartCareID == scid));
    %hmend      = max(physdata.Date_TimeRecorded(physdata.SmartCareID == scid));
    hmenddn    = max(physdata.ScaledDateNum(physdata.SmartCareID == scid));
    
    imagefilename = sprintf('%s - Participant Clinical Measures - ID %d Hosp %s', study, scid, hospital);
    [f, p] = createFigureAndPanelForPaper('', clinpgwdth, clinpghght);
    
    plotsacross = 1;
    plotsdown = 3;
    fontsize = 10;
    ylabelposmult = 1.3;
    
    daysfrom = min(spstartdn, hmstartdn);
    daysto   = max(spenddn, hmenddn);
    xl = [daysfrom daysto];
    yl = [0 4];
    
    % plot events
    ax = subplot(plotsdown, plotsacross, 1,'Parent', p);
    hold on;
    ax.FontSize = fontsize;
    %ylabeltext = 'Clinic Visits ({\color{green}g}), Admissions ({\color{magenta}m}), IV Antibiotics ({\color{red}r}) and Oral Antibiotics ({\color{cyan}c})';
    ylabeltext = 'Events';
    ylabel(ylabeltext, 'Position',[0 yl(2) * ylabelposmult], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Rotation', 0);
    ax.YTick = [0.5, 1.5, 2.5, 3.5];
    ax.YTickLabel = {'Oral Antibiotics', 'IV Antibiotics', 'Admissions', 'Clinic Visits'};
    ax.XTickLabel = '';
    ax.XColor = 'white';
    xlim(xl);
    ylim(yl);
   
    linewidth = 10;
   
    cvset     = cdClinicVisits(cdClinicVisits.ID == scid,:);
    cvset.AttendanceDatedn = datenum(cvset.AttendanceDate) - offset - poffset + 1;
    for a = 1:size(cvset,1)
        line(ax, [cvset.AttendanceDatedn(a) cvset.AttendanceDatedn(a) + 1], [3.5, 3.5], 'Color', 'green', 'LineStyle', '-', 'LineWidth', linewidth);
    end
    admset    = cdAdmissions(cdAdmissions.ID == scid,:);
    admset.Admitteddn = datenum(admset.Admitted) - offset - poffset + 1;
    admset.Dischargedn = datenum(admset.Discharge) - offset - poffset + 1;
    %admdates = unique([admset.Admitteddn ; admset.Dischargedn]);
    for a = 1:size(admset,1)
        line(ax, [admset.Admitteddn(a) admset.Dischargedn(a)], [2.5, 2.5], 'Color', 'magenta', 'LineStyle', '-', 'LineWidth', linewidth);
    end
    ivabset   = cdAntibiotics(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, {'IV'}),:);
    ivabset.Startdn = datenum(ivabset.StartDate) - offset - poffset + 1;
    ivabset.Stopdn = datenum(ivabset.StopDate) - offset - poffset + 1;
    ivabgroupeddates = getGroupedIVTreatmentDates(ivabset);
    ivabgroupeddates.Startdn = datenum(ivabgroupeddates.StartDate) - offset - poffset + 1;
    ivabgroupeddates.Stopdn = datenum(ivabgroupeddates.StopDate) - offset - poffset + 1;
    %ivabdates = unique([ivabgroupeddates.Startdn ; ivabgroupeddates.Stopdn]);
    for a = 1:size(ivabset,1)
        line(ax, [ivabset.Startdn(a) ivabset.Stopdn(a)], [1.5, 1.5], 'Color', 'red', 'LineStyle', '-', 'LineWidth', linewidth);
    end
    oralabset = cdAntibiotics(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, {'Oral'}),:);
    oralabset.Startdn = datenum(oralabset.StartDate) - offset - poffset + 1;
    oralabset.Stopdn = datenum(oralabset.StopDate) - offset - poffset + 1;
    for a = 1:size(oralabset,1)
        line(ax, [oralabset.Startdn(a) oralabset.Stopdn(a)], [0.5, 0.5], 'Color', 'cyan', 'LineStyle', '-', 'LineWidth', linewidth);
    end
    
    for a = 1:size(ivabgroupeddates, 1)
        plotFillAreaForPaper(ax, ivabgroupeddates.Startdn(a), ivabgroupeddates.Stopdn(a), ...
            yl(1), yl(2), 'red', '0.1', 'none');
    end 
    hold off;
    
    % plot CRP levels
    pcrp = cdCRP(cdCRP.ID == scid,:);
    pcrp.ScaledDateNum = datenum(pcrp.CRPDate) - offset - poffset + 1;
    rangelimit = setMinYDisplayRangeForMeasure('ClinicalCRP');
    if size(pcrp,1) > 0
        yl = setYDisplayRange(0, max(pcrp.NumericLevel), rangelimit);
    else
        yl = [0, rangelimit];
    end
    
    ax = subplot(plotsdown, plotsacross, 2,'Parent', p);
    displaymeasure = 'Clinical CRP Level';
    units = getUnitsForMeasure(displaymeasure);
    ylabeltext = sprintf(' %s (%s)', displaymeasure, units);
    ylabel(ylabeltext, 'Position',[0 yl(2) * ylabelposmult], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Rotation', 0);
    ax.FontSize = fontsize;
    ax.XTickLabel = '';
    ax.XColor = 'white';
    xlim(xl);
    ylim(yl);
    hold on;
    if size(pcrp,1) > 0
        plot(ax, pcrp.ScaledDateNum,pcrp.NumericLevel, ...
            'Color', [0, 0.65, 1], ...
            'LineStyle', ':', ...
            'Marker', 'o', ...
            'LineWidth',1,...
            'MarkerSize',2,...
            'MarkerEdgeColor','b',...
            'MarkerFaceColor','g');
    end
    for a = 1:size(ivabgroupeddates, 1)
        plotFillAreaForPaper(ax, ivabgroupeddates.Startdn(a), ivabgroupeddates.Stopdn(a), ...
            yl(1), yl(2), 'red', '0.1', 'none');
    end 
    hold off;
    
    % plot clinical lung function
    ppft = cdPFT(cdPFT.ID == scid,:);
    ppft.ScaledDateNum = datenum(ppft.LungFunctionDate) - offset - poffset + 1;
    rangelimit = setMinYDisplayRangeForMeasure('ClinicalFEV1');
    if size(ppft,1) > 0
        yl = setYDisplayRange(0, max(ppft.CalcFEV1_), rangelimit);
    else
        yl = [0, rangelimit];
    end
    ax = subplot(plotsdown, plotsacross, 3,'Parent', p);
    displaymeasure = 'Clinical FEV1';
    units = getUnitsForMeasure(displaymeasure);
    ylabeltext = sprintf(' %s (%s)', displaymeasure, units);
    ylabel(ylabeltext, 'Position',[0, yl(1) + ((yl(2) - yl(1)) * ylabelposmult)], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Rotation', 0);
    ax.FontSize = fontsize;
    xlabel(ax, 'Days since start of study');
    xlim(xl);
    ylim(yl);
    hold on;
    if size(ppft,1) > 0
        plot(ax, ppft.ScaledDateNum, ppft.CalcFEV1_, ...
            'Color', [0, 0.65, 1], ...
            'LineStyle', ':', ...
            'Marker', 'o', ...
            'LineWidth',1,...
            'MarkerSize',2,...
            'MarkerEdgeColor','b',...
            'MarkerFaceColor','g');

    end
    for a = 1:size(ivabgroupeddates, 1)
        plotFillAreaForPaper(ax, ivabgroupeddates.Startdn(a), ivabgroupeddates.Stopdn(a), ...
            yl(1), yl(2), 'red', '0.1', 'none');
    end
    hold off;
    
    savePlotInDir(f, imagefilename, subfolder);
    savePlotInDirAsSVG(f, imagefilename, subfolder);
    close(f);
    fprintf('Next Page\n');
    
    plotsacross = 1;
    plotsdown = 6;
    plotsperpage = plotsacross * plotsdown;
    
    % remove unwanted measures
    measures(ismember(measures.Name, {'ActivityRecording', 'TemperatureRecording', 'WeightRecording'}), :) = [];
    nmeasures = size(measures, 1);
    
    page = 1;
    npages = ceil(nmeasures / plotsperpage);
    colors = lines(nmeasures);
    
    filenameprefix = sprintf('%s - Participant Home Measures - ID %d Hosp %s', study, scid, hospital);
    imagefilename = sprintf('%s - Page %d of %d', filenameprefix, page, npages);
    [f, p] = createFigureAndPanelForPaper('', measpgwdth,  measpghght);
    
    for m = 1:nmeasures
        tablemeasure = measures.Name{m};
        column = getColumnForMeasure(tablemeasure);
        scdata = physdata(physdata.SmartCareID == scid & ismember(physdata.RecordingType, tablemeasure), :);
        scdata = scdata(:, {'SmartCareID','ScaledDateNum' 'Date_TimeRecorded', column});
        scdata.Properties.VariableNames{column} = 'Measurement';
        
        rangelimit = setMinYDisplayRangeForMeasure(tablemeasure);
        if size(scdata,1) > 0
            yl = setYDisplayRange(min(scdata.Measurement), max(scdata.Measurement), rangelimit);
        else
            yl = [0, rangelimit];
        end
        
        ax = subplot(plotsdown, plotsacross, m - (page - 1) * plotsperpage,'Parent',p);
        displaymeasure = measures.DisplayName{m};
        units = getUnitsForMeasure(displaymeasure);
        ylabeltext = sprintf(' %s (%s)', displaymeasure, units);
        ylabel(ylabeltext, 'Position',[0 yl(1) + ((yl(2) - yl(1)) * ylabelposmult)], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Rotation', 0);
        ax.FontSize = fontsize;
        yticks = setTicks(yl(1), yl(2), 3);
        ax.YTick = yticks;
        if m == nmeasures
            xlabel(ax, 'Days since start of study');
        else
            ax.XTickLabel = '';
            ax.XColor = 'white';
        end
        xlim(xl);
        ylim(yl);
        hold on;
        if size(scdata,1) > 0    
            plot(ax, scdata.ScaledDateNum, scdata.Measurement, ...
                'Color', colors(m, :), ...
                'LineStyle', ':', ...
                'Marker', 'o', ...
                'LineWidth',1, ...
                'MarkerSize',2, ...
                'MarkerEdgeColor', colors(m, :), ...
                'MarkerFaceColor',colors(m, :));
            
            plot(ax, scdata.ScaledDateNum, movmean(scdata.Measurement, 4, 'omitnan'), ...
                'Color', colors(m, :), ...
                'LineStyle', '-', ...
                'Marker', 'none', ...
                'LineWidth', 1);
            
            for a = 1:size(ivabgroupeddates, 1)
                plotFillAreaForPaper(ax, ivabgroupeddates.Startdn(a), ivabgroupeddates.Stopdn(a), ...
                    yl(1), yl(2), 'red', '0.1', 'none');
            end
            
            %ddcolumn = sprintf('Fun_%s',column);
            %mmean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(1);
            %mstd  = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(2);
            %plotFillArea(ax, xl(1), xl(2), ...
            %    mmean - mstd, mmean + mstd, [0.4, 0.4, 0.4], '0.1', 'none');
            hold off;
        end
        
        if round(a/plotsperpage) == a/plotsperpage
            savePlotInDir(f, imagefilename, subfolder);
            savePlotInDirAsSVG(f, imagefilename, subfolder);
            close(f);
            clear('f');
            page = page + 1;
            if page <= npages
                fprintf('Next Page\n');
                imagefilename = sprintf('%s - Page %d of %d', filenameprefix, page, npages);
                [f, p] = createFigureAndPanelForPaper('', measpgwdth,  measpghght);
            end
        end
    end
    
    if exist('f', 'var')
        savePlotInDir(f, imagefilename, subfolder);
        savePlotInDirAsSVG(f, imagefilename, subfolder);
        close(f);
    end

    toc
    
end

    
    