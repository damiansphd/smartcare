function visualiseMeasuresForPaperFcn(physdata, offset, cdPatient, cdAdmissions, cdAntibiotics, cdClinicVisits, ...
    cdCRP, cdPFT, cdNewMeds, measures, nmeasures, study)

% visualiseMeasuresForPaperFcn - plots clinical and home measures

basedir = setBaseDir();
subfolder = sprintf('Plots/%s', study);
if ~exist(strcat(basedir, subfolder), 'dir')
    mkdir(strcat(basedir, subfolder));
end

patientoffsets = getPatientOffsets(physdata);
patientlist = unique(physdata.SmartCareID);

clinpghght = 3.5;
clinpgwdth = 6;
measpghght = 9;
measpgwdth = 6;

for pat = 1:size(patientlist,1)
    scid       = patientlist(pat);
    if ismember(scid, [78, 133])
        tic

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
        orkstart   = cdNewMeds.StartDate(cdNewMeds.ID == scid & ismember(lower(cdNewMeds.Drugs), {'orkambi'}));
        orkstartdn = datenum(orkstart) - offset - poffset + 1;
        ivastart   = cdNewMeds.StartDate(cdNewMeds.ID == scid & ismember(lower(cdNewMeds.Drugs), {'ivacaftor'}));
        ivastartdn = datenum(ivastart) - offset - poffset + 1;

        imagefilename = sprintf('%s - Participant Clinical Measures - ID %d Hosp %s', study, scid, hospital);
        [f, p] = createFigureAndPanelForPaper('', clinpgwdth, clinpghght);

        plotsacross = 1;
        plotsdown = 3;
        fontsize = 10;
        ylabelposmult = 1.3;

        %daysfrom = min(spstartdn, hmstartdn);
        daysfrom = 0;
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
        ax.YTickLabel = {'IV antibiotics', 'Oral antibiotics', 'Admissions', 'Clinic visits'};
        ax.XTickLabel = '';
        ax.XColor = 'white';
        ax.TickDir = 'out';
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
        oralabset = cdAntibiotics(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, {'Oral'}),:);
        oralabset.Startdn = datenum(oralabset.StartDate) - offset - poffset + 1;
        oralabset.Stopdn = datenum(oralabset.StopDate) - offset - poffset + 1;
        for a = 1:size(oralabset,1)
            line(ax, [oralabset.Startdn(a) oralabset.Stopdn(a)], [1.5, 1.5], 'Color', 'cyan', 'LineStyle', '-', 'LineWidth', linewidth);
        end
        ivabset   = cdAntibiotics(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, {'IV'}),:);
        ivabset.Startdn = datenum(ivabset.StartDate) - offset - poffset + 1;
        ivabset.Stopdn = datenum(ivabset.StopDate) - offset - poffset + 1;
        ivabgroupeddates = getGroupedIVTreatmentDates(ivabset);
        ivabgroupeddates.Startdn = datenum(ivabgroupeddates.StartDate) - offset - poffset + 1;
        ivabgroupeddates.Stopdn = datenum(ivabgroupeddates.StopDate) - offset - poffset + 1;
        %ivabdates = unique([ivabgroupeddates.Startdn ; ivabgroupeddates.Stopdn]);
        for a = 1:size(ivabset,1)
            line(ax, [ivabset.Startdn(a) ivabset.Stopdn(a)], [0.5, 0.5], 'Color', 'red', 'LineStyle', '-', 'LineWidth', linewidth);
        end
        
        %if size(orkstartdn, 1) ~= 0
        %    plotFillAreaForPaper(ax, orkstartdn, orkstartdn + 1, yl(1), yl(2), [0.729, 0.333, 0.827], '0.2', 'none');
        %end
        %if size(ivastartdn, 1) ~= 0
        %    plotFillAreaForPaper(ax, ivastartdn, ivastartdn + 1, yl(1), yl(2), [0.824, 0.412, 0.118], '0.2', 'none');
        %end
        %for a = 1:size(ivabgroupeddates, 1)
        %    wdth = 30 / xl(2);
        %    hght = 0.2;
        %    midxratio = ((ivabgroupeddates.Stopdn(a) + ivabgroupeddates.Startdn(a)) / 2) / xl(2);
        %    xstart = midxratio - (wdth / 2);
        %    
        %    dim = [xstart, 1 - hght, wdth, hght];
        %    annotation(f, 'textbox', 'String', 'iv Antibiotics', 'LineStyle', 'none', 'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', [0, 0, 0]);
        %    plotFillAreaForPaper(ax, ivabgroupeddates.Startdn(a), ivabgroupeddates.Stopdn(a), ...
        %        yl(1), yl(2), 'red', '0.1', 'none');
        %end 
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
        displaymeasure = 'Clinical CRP';
        units = getUnitsForMeasure(displaymeasure);
        ylabeltext = sprintf('%s (%s)', formatDisplayMeasure(displaymeasure), units);
        ylabel(ylabeltext, 'Position',[0 yl(2) * ylabelposmult], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Rotation', 0);
        ax.FontSize = fontsize;
        ax.XTickLabel = '';
        ax.XColor = 'white';
        ax.TickDir = 'out';
        xlim(xl);
        ylim(yl);
        hold on;
        if size(pcrp,1) > 0
            thiscolour = getColourForMeasure(displaymeasure);
            plot(ax, pcrp.ScaledDateNum,pcrp.NumericLevel, ...
                'Color', thiscolour, ...
                'LineStyle', '-', ...
                'Marker', 'o', ...
                'LineWidth',1, ...
                'MarkerSize',2, ...
                'MarkerEdgeColor', thiscolour, ...
                'MarkerFaceColor', thiscolour);
        end
        for a = 1:size(ivabgroupeddates, 1)
            plotFillAreaForPaper(ax, ivabgroupeddates.Startdn(a), ivabgroupeddates.Stopdn(a), ...
                yl(1), yl(2), 'red', '0.1', 'none');
        end
        if size(orkstartdn, 1) ~= 0
            plotFillAreaForPaper(ax, orkstartdn, orkstartdn + 1, yl(1), yl(2), [0.729, 0.333, 0.827], '0.2', 'none');
        end
        if size(ivastartdn, 1) ~= 0
            plotFillAreaForPaper(ax, ivastartdn, ivastartdn + 1, yl(1), yl(2), [0.824, 0.412, 0.118], '0.2', 'none');
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
        ylabeltext = sprintf('%s (%s)', formatDisplayMeasure(displaymeasure), units);
        ylabel(ylabeltext, 'Position',[0, yl(1) + ((yl(2) - yl(1)) * ylabelposmult)], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Rotation', 0);
        ax.FontSize = fontsize;
        ax.TickDir = 'out';
        xlabel(ax, 'Days since start of study');
        xlim(xl);
        ylim(yl);
        hold on;
        if size(ppft,1) > 0
            thiscolour = getColourForMeasure(displaymeasure);
            plot(ax, ppft.ScaledDateNum, ppft.CalcFEV1_, ...
                'Color', thiscolour, ...
                'LineStyle', '-', ...
                'Marker', 'o', ...
                'LineWidth',1,...
                'MarkerSize',2,...
                'MarkerEdgeColor', thiscolour,...
                'MarkerFaceColor', thiscolour);

        end
        for a = 1:size(ivabgroupeddates, 1)
            plotFillAreaForPaper(ax, ivabgroupeddates.Startdn(a), ivabgroupeddates.Stopdn(a), ...
                yl(1), yl(2), 'red', '0.1', 'none');
        end
        if size(orkstartdn, 1) ~= 0
            plotFillAreaForPaper(ax, orkstartdn, orkstartdn + 1, yl(1), yl(2), [0.729, 0.333, 0.827], '0.2', 'none');
        end
        if size(ivastartdn, 1) ~= 0
            plotFillAreaForPaper(ax, ivastartdn, ivastartdn + 1, yl(1), yl(2), [0.824, 0.412, 0.118], '0.2', 'none');
        end
        hold off;

        savePlotInDir(f, imagefilename, subfolder);
        savePlotInDirAsSVG(f, imagefilename, subfolder);
        close(f);
        fprintf('Next Page\n');

        plotsacross = 1;
        plotsdown = 9;
        plotsperpage = plotsacross * plotsdown;

        % remove unwanted measures
        %measures(ismember(measures.Name, {'ActivityRecording', 'TemperatureRecording', 'WeightRecording'}), :) = [];
        %nmeasures = size(measures, 1);

        page = 1;
        npages = ceil(nmeasures / plotsperpage);

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
            [smcolour, rwcolour] = getColourForMeasure(displaymeasure);
            ylabeltext = sprintf('%s (%s)', formatDisplayMeasure(displaymeasure), units);
            ylabel(ylabeltext, 'Position',[0 yl(1) + ((yl(2) - yl(1)) * ylabelposmult)], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Rotation', 0);
            ax.FontSize = fontsize;
            yticks = setTicks(yl(1), yl(2), 3);
            ax.YTick = yticks;
            ax.YTickLabel = addCommaFormat(yticks);
            ax.TickDir = 'out';
            if m == nmeasures
                xlabel(ax, 'Days since start of study');
            else
                ax.XTickLabel = '';
                ax.XColor = 'white';
            end
            xlim(xl);
            ylim(yl);
                
            if size(scdata,1) > 0
                hold on;
            
                actx = find(~isnan(scdata.Measurement));
                acty = scdata.Measurement(~isnan(scdata.Measurement));
                fullx = (1:size(scdata.Measurement));
                fully = interp1(actx, acty, fullx, 'linear');
            
                plot(ax, scdata.ScaledDateNum, fully, ...
                    'Color', rwcolour, ...
                    'LineStyle', '-', ...
                    'Marker', 'o', ...
                    'LineWidth',1, ...
                    'MarkerSize',2, ...
                    'MarkerEdgeColor', rwcolour, ...
                    'MarkerFaceColor', rwcolour);

                plot(ax, scdata.ScaledDateNum, movmean(fully, 4, 'omitnan'), ...
                    'Color', smcolour, ...
                    'LineStyle', '-', ...
                    'Marker', 'none', ...
                    'LineWidth', 1.5);

                for a = 1:size(ivabgroupeddates, 1)
                    plotFillAreaForPaper(ax, ivabgroupeddates.Startdn(a), ivabgroupeddates.Stopdn(a), ...
                        yl(1), yl(2), 'red', '0.1', 'none');
                end
                if size(orkstartdn, 1) ~= 0
                    plotFillAreaForPaper(ax, orkstartdn, orkstartdn + 1, yl(1), yl(2), [0.729, 0.333, 0.827], '0.2', 'none');
                end
                if size(ivastartdn, 1) ~= 0
                    plotFillAreaForPaper(ax, ivastartdn, ivastartdn + 1, yl(1), yl(2), [0.824, 0.412, 0.118], '0.2', 'none');
                end

                % use exclude upper quartile mean/std for pulse rate,
                % otherwise use exclude bottom quartile mean/std
                if ismember(displaymeasure, {'PulseRate'})
                    mmean = xu25mean(scdata.Measurement(~isnan(scdata.Measurement)));
                    mstd  = xu25std(scdata.Measurement(~isnan(scdata.Measurement)));
                else
                    mmean = xb25mean(scdata.Measurement(~isnan(scdata.Measurement)));
                    mstd  = xb25std(scdata.Measurement(~isnan(scdata.Measurement)));
                end
                plotFillArea(ax, xl(1), xl(2), ...
                    mmean - (0.5 * mstd), mmean + (0.5 * mstd), [0.4, 0.4, 0.4], '0.2', 'none');
                line(xl, [mmean mmean] , 'Color', [0.4, 0.4, 0.4], 'LineStyle', '-', 'LineWidth', .5)
                hold off;
                
            else
                ax.YTickLabel = '';
                %ax.YColor = 'white';
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
end

    
    