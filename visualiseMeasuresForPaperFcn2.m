function visualiseMeasuresForPaperFcn2(physdata, offset, amDatacube, cdPatient, cdAntibiotics, ...
    cdCRP, cdPFT, cdNewMeds, measures, nmeasures, ndays, study)

% visualiseMeasuresForPaperFcn2 - plots clinical and home measures

invmeasarray = getInvertedMeasures(study);
if ismember(study,'SC')
    expat = 133;
elseif ismember(study, 'CL')
    expat = 359;
end

basedir = setBaseDir();
subfolder = sprintf('Plots/%s', study);
if ~exist(strcat(basedir, subfolder), 'dir')
    mkdir(strcat(basedir, subfolder));
end

patientoffsets = getPatientOffsets(physdata);
patientlist = unique(physdata.SmartCareID);

orkcolour = [0.729, 0.333, 0.827];
ivacolour = [0.824, 0.412, 0.118];
meancolour = [0.4, 0.4, 0.4];

titlefontsize = 14;
labelfontsize = 12;
axisfontsize = 10;
unitfontsize = 10;
smallfontsize = 8;
fontname = 'Arial';

widthinch = 8.25;
heightinch = 11.75;
name = '';
singlehght = 1/28;
doublehght = singlehght * 2;
triplehght = singlehght * 3;
labelwidth = 0.25;
plotwidth  = 0.75;

ntitles = 2;
nclinicalmeasures = 2;
nidentifiers = 2;
nlabels = nclinicalmeasures + nmeasures;

typearray = [1, 6, 2, 4, 3, 5, 1, 6, 2, 4, 2, 4, 2, 4, 2, 4, 2, 4, 2, 4, 2, 4, 2, 4, 3, 5];

typehght = [singlehght, doublehght, triplehght, doublehght, triplehght, singlehght];

labeltext = {'A.'; 'Intravenous'; 'Clinical CRP'; ' '; 'Clinical FEV1'; ' '; 'B.'; 'Intravenous'};

[measures] = sortMeasuresForPaper(study, measures);
for m = 1:nmeasures
    labeltext = [labeltext; cellstr(measures.DisplayName{m}); ' '];
end

for pat = 1:size(patientlist,1)
    scid       = patientlist(pat);
    %if ismember(scid, [23, 24, 78, 133])
    if ismember(scid, expat)
        tic

        fprintf('Visualising measures for patient %d\n', scid);
        poffset    = patientoffsets.PatientOffset(patientoffsets.SmartCareID == scid);
        hospital   = cdPatient.Hospital{cdPatient.ID == scid};
        spstart    = cdPatient.StudyDate(cdPatient.ID == scid);
        spstartdn  = datenum(spstart) - offset - poffset + 1;
        spenddn    = spstartdn + 183;
        %hmstartdn  = min(physdata.ScaledDateNum(physdata.SmartCareID == scid));
        hmenddn    = max(physdata.ScaledDateNum(physdata.SmartCareID == scid));
        if size(cdNewMeds, 1) > 0
            orkstart   = cdNewMeds.StartDate(cdNewMeds.ID == scid & ismember(lower(cdNewMeds.Drugs), {'orkambi'}));
            orkstartdn = datenum(orkstart) - offset - poffset + 1;
            ivastart   = cdNewMeds.StartDate(cdNewMeds.ID == scid & ismember(lower(cdNewMeds.Drugs), {'ivacaftor'}));
            ivastartdn = datenum(ivastart) - offset - poffset + 1;
        else
            orkstartdn = -100;
            ivastartdn = -100;
        end
        
        % events
        ivabset   = cdAntibiotics(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, {'IV'}),:);
        ivabset.Startdn = datenum(ivabset.StartDate) - offset - poffset + 1;
        ivabset.Stopdn = datenum(ivabset.StopDate) - offset - poffset + 1;
        ivabgroupeddates = getGroupedIVTreatmentDates(ivabset);
        ivabgroupeddates.Startdn = datenum(ivabgroupeddates.StartDate) - offset - poffset + 1;
        ivabgroupeddates.Stopdn = datenum(ivabgroupeddates.StopDate) - offset - poffset + 1;

        %daysfrom = min(spstartdn, hmstartdn);
        daysfrom = 0;
        daysto   = max(spenddn, hmenddn);
        xl = [daysfrom daysto];

        imagefilename = sprintf('%s - Participant Measures - ID %d Hosp %s', study, scid, hospital);
        [f, p] = createFigureAndPanelForPaper(name, widthinch, heightinch);

        currhght = 1.0;
        currplot = 1;
        for i = 1:(ntitles + nclinicalmeasures + nmeasures + nlabels + nidentifiers)
            type = typearray(i);

            if type == 1
                % title
                currhght = currhght - typehght(type);
                sp(i) = uipanel('Parent', p, ...
                                'BorderType', 'none', ...
                                'BackgroundColor', 'white', ...
                                'OuterPosition', [0, currhght, 1.0, typehght(type)]);
                displaytext = sprintf('\\bf %s\\rm', labeltext{i});
                annotation(sp(i), 'textbox',  ...
                                'String', displaytext, ...
                                'Interpreter', 'tex', ...
                                'Units', 'normalized', ...
                                'Position', [0, 0, .2, 1], ...
                                'HorizontalAlignment', 'left', ...
                                'VerticalAlignment', 'middle', ...
                                'LineStyle', 'none', ...
                                'FontName', fontname, ...
                                'FontSize', titlefontsize);
            elseif type == 2 || type == 3
                % label
                currhght = currhght - typehght(type);
                displaytext = {formatTexDisplayMeasure(labeltext{i}); sprintf('\\fontsize{%d} (%s)', unitfontsize, getUnitsForMeasure(labeltext{i}))};
                sp(i) = uipanel('Parent', p, ...
                                'BorderType', 'none', ...
                                'BackgroundColor', 'white', ...
                                'OuterPosition', [0, currhght, labelwidth, typehght(type)]);
                annotation(sp(i), 'textbox',  ...
                                'String', displaytext, ...
                                'Interpreter', 'tex', ...
                                'Units', 'normalized', ...
                                'Position', [0, 0, 1, 1], ...
                                'HorizontalAlignment', 'center', ...
                                'VerticalAlignment', 'middle', ...
                                'LineStyle', 'none', ...
                                'FontName', fontname, ...
                                'FontSize', labelfontsize);
            elseif type == 4 || type == 5
                % plot
                sp(i) = uipanel('Parent', p, ...
                                'BorderType', 'none', ...
                                'BackgroundColor', 'white', ...
                                'OuterPosition', [labelwidth, currhght, plotwidth, typehght(type)]);

                if currplot == 1
                    % plot CRP levels
                    pcrp = cdCRP(cdCRP.ID == scid,:);
                    pcrp.ScaledDateNum = datenum(pcrp.CRPDate) - offset - poffset + 1;
                    rangelimit = setMinYDisplayRangeForMeasure('ClinicalCRP');
                    if size(pcrp,1) > 0
                        yl = setYDisplayRange(0, max(pcrp.NumericLevel), rangelimit);
                    else
                        yl = [0, rangelimit];
                    end
                    ax = subplot(1, 1, 1,'Parent', sp(i));
                    displaymeasure = 'Clinical CRP';
                    ax.FontSize = axisfontsize;
                    ax.FontName = fontname;
                    ax.XTickLabel = '';
                    ax.XColor = 'white';
                    yticks = setTicks(yl(1), yl(2), 3);
                    ax.YTick = yticks;
                    ax.YTickLabel = addCommaFormat(yticks);
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
                        plotFillAreaForPaper(ax, orkstartdn, orkstartdn + 1, yl(1), yl(2), orkcolour, '0.2', 'none');
                    end
                    if size(ivastartdn, 1) ~= 0
                        plotFillAreaForPaper(ax, ivastartdn, ivastartdn + 1, yl(1), yl(2), ivacolour, '0.2', 'none');
                    end
                    hold off;
                elseif currplot == 2
                    % plot clinical lung function
                    ppft = cdPFT(cdPFT.ID == scid,:);
                    ppft.ScaledDateNum = datenum(ppft.LungFunctionDate) - offset - poffset + 1;
                    tablemeasure = 'LungFunctionRecording';
                    m = measures.Index(ismember(measures.Name, tablemeasure));
                    column = getColumnForMeasure(tablemeasure);
                    %scdata = physdata(physdata.SmartCareID == scid & ismember(physdata.RecordingType, tablemeasure), :);
                    %scdata = scdata(:, {'SmartCareID','ScaledDateNum' 'Date_TimeRecorded', column});
                    %scdata.Properties.VariableNames{column} = 'Measurement';
                    rangelimit = setMinYDisplayRangeForMeasure(tablemeasure);
                    measrow = amDatacube(scid, :, m);
                    
                    %if size(scdata,1) > 0
                    if sum(~isnan(measrow)) > 0
                        %ylm = setYDisplayRange(min(scdata.Measurement), max(scdata.Measurement), rangelimit);
                        ylm = setYDisplayRange(min(measrow), max(measrow), rangelimit);
                    else
                        ylm = [0, rangelimit];
                    end
                    rangelimit = setMinYDisplayRangeForMeasure('ClinicalFEV1');
                    if size(ppft,1) > 0
                        ylc = setYDisplayRange(min(ppft.CalcFEV1_), max(ppft.CalcFEV1_), rangelimit);

                    else
                        ylc = [0, rangelimit];
                    end
                    yl(1) = min(ylm(1), ylc(1));
                    yl(2) = max(ylm(2), ylc(2));
                    ax = subplot(1, 1, 1, 'Parent', sp(i));
                    displaymeasure = 'Clinical FEV1';
                    ax.FontSize = axisfontsize;
                    ax.FontName = fontname;
                    yticks = setTicks(yl(1), yl(2), 3);
                    ax.YTick = yticks;
                    ax.YTickLabel = addCommaFormat(yticks);
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
                        plotFillAreaForPaper(ax, orkstartdn, orkstartdn + 1, yl(1), yl(2), orkcolour, '0.2', 'none');
                    end
                    if size(ivastartdn, 1) ~= 0
                        plotFillAreaForPaper(ax, ivastartdn, ivastartdn + 1, yl(1), yl(2), ivacolour, '0.2', 'none');
                    end
                    hold off;
                else
                    m = currplot - nclinicalmeasures;
                    tablemeasure = measures.Name{m};
                    %column = getColumnForMeasure(tablemeasure);
                    %scdata = physdata(physdata.SmartCareID == scid & ismember(physdata.RecordingType, tablemeasure), :);
                    %scdata = scdata(:, {'SmartCareID','ScaledDateNum' 'Date_TimeRecorded', column});
                    %scdata.Properties.VariableNames{column} = 'Measurement';
                    
                    measrow = amDatacube(scid, :, measures.Index(m));
                    days = 0:(ndays - 1);
                    
                    rangelimit = setMinYDisplayRangeForMeasure(tablemeasure);
                    %if size(scdata, 1) > 0
                    if sum(~isnan(measrow)) > 0
                        %yl = setYDisplayRange(min(scdata.Measurement), max(scdata.Measurement), rangelimit);
                        yl = setYDisplayRange(min(measrow), max(measrow), rangelimit);
                    else
                        yl = [0, rangelimit];
                    end

                    ax = subplot(1, 1, 1,'Parent', sp(i));
                    displaymeasure = measures.DisplayName{m};
                    [smcolour, rwcolour] = getColourForMeasure(displaymeasure);
                    ax.FontSize = axisfontsize;
                    ax.FontName = fontname;
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

                    %if size(scdata, 1) > 0
                    if sum(~isnan(measrow)) > 0
                        hold on;
                        
                        plot(ax, days, measrow, ...
                            'Color', rwcolour, ...
                            'LineStyle', '-', ...
                            'Marker', 'o', ...
                            'LineWidth',1, ...
                            'MarkerSize',2, ...
                            'MarkerEdgeColor', rwcolour, ...
                            'MarkerFaceColor', rwcolour);

                        %actx = find(~isnan(scdata.Measurement));
                        %acty = scdata.Measurement(~isnan(scdata.Measurement));
                        %fullx = (1:size(scdata.Measurement));
                        %fully = interp1(actx, acty, fullx, 'linear');
                        %fully = scdata.Measurement;
                        
                        actx = find(~isnan(measrow));
                        acty = measrow(~isnan(measrow));
                        fullx = (1:size(measrow));
                        fully = interp1(actx, acty, fullx, 'linear');
                        %fully = scdata.Measurement;

                        %plot(ax, scdata.ScaledDateNum, fully, ...
                        %    'Color', rwcolour, ...
                        %    'LineStyle', '-', ...
                        %    'Marker', 'o', ...
                        %    'LineWidth',1, ...
                        %    'MarkerSize',2, ...
                        %    'MarkerEdgeColor', rwcolour, ...
                        %    'MarkerFaceColor', rwcolour);

                        %plot(ax, scdata.ScaledDateNum, movmean(fully, 4, 'omitnan'), ...
                        %    'Color', smcolour, ...
                        %    'LineStyle', '-', ...
                        %    'Marker', 'none', ...
                        %    'LineWidth', 1.5);

                        %plot(ax, days, movmean(measrow, 4, 'omitnan'), ...
                        plot(ax, days, movmean(measrow, 4, 'omitnan'), ...
                            'Color', smcolour, ...
                            'LineStyle', '-', ...
                            'Marker', 'none', ...
                            'LineWidth', 1.5);

                        
                        for a = 1:size(ivabgroupeddates, 1)
                            plotFillAreaForPaper(ax, ivabgroupeddates.Startdn(a), ivabgroupeddates.Stopdn(a), ...
                                yl(1), yl(2), 'red', '0.1', 'none');
                        end
                        if size(orkstartdn, 1) ~= 0
                            plotFillAreaForPaper(ax, orkstartdn, orkstartdn + 1, yl(1), yl(2), orkcolour, '0.2', 'none');
                        end
                        if size(ivastartdn, 1) ~= 0
                            plotFillAreaForPaper(ax, ivastartdn, ivastartdn + 1, yl(1), yl(2), ivacolour, '0.2', 'none');
                        end

                        % use exclude upper quartile mean/std for pulse rate,
                        % otherwise use exclude bottom quartile mean/std
                        if ismember(displaymeasure, invmeasarray)
                            %mmean = xu25mean(scdata.Measurement(~isnan(scdata.Measurement)));
                            %mstd  = xu25std(scdata.Measurement(~isnan(scdata.Measurement)));
                            mmean = xu25mean(measrow(~isnan(measrow)));
                            mstd  = xu25std(measrow(~isnan(measrow)));
                        else
                            %mmean = xb25mean(scdata.Measurement(~isnan(scdata.Measurement)));
                            %mstd  = xb25std(scdata.Measurement(~isnan(scdata.Measurement)));
                            mmean = xb25mean(measrow(~isnan(measrow)));
                            mstd  = xb25std(measrow(~isnan(measrow)));
                        end
                        plotFillArea(ax, xl(1), xl(2), ...
                            mmean - (0.5 * mstd), mmean + (0.5 * mstd), meancolour, '0.2', 'none');
                        line(xl, [mmean mmean] , 'Color', meancolour, 'LineStyle', '-', 'LineWidth', .5)
                        hold off;
                    end
                end
                currplot = currplot + 1;
            elseif type == 6
                % iv and orkambi identifiers
                currhght = currhght - typehght(type);
                sp(i) = uipanel('Parent', p, ...
                                'BorderType', 'none', ...
                                'BackgroundColor', 'white', ...
                                'OuterPosition', [labelwidth, currhght, plotwidth, typehght(type)]);
                if size(ivabgroupeddates, 1) > 0
                    displaytext1 = sprintf('\\bf %s\\rm', labeltext{i});
                    displaytext2 = sprintf('\\bf %s\\rm', 'antibiotics');
                    displaytext = {displaytext1; displaytext2};  
                    xposition = (((ivabgroupeddates.Startdn(1) + ivabgroupeddates.Stopdn(1)) / 2) - 22) /183;
                    annotation(sp(i), 'textbox',  ...
                                    'String', displaytext, ...
                                    'Interpreter', 'tex', ...
                                    'Units', 'normalized', ...
                                    'Position', [xposition, 0, .2, 1], ...
                                    'HorizontalAlignment', 'center', ...
                                    'VerticalAlignment', 'bottom', ...
                                    'LineStyle', 'none', ...
                                    'FontName', fontname, ...
                                    'FontSize', smallfontsize);
                end
                if size(orkstartdn, 1) ~= 0
                    displaytext1 = sprintf('\\bf %s\\rm', 'Initiation of');
                    displaytext2 = sprintf('\\bf %s\\rm', 'Orkambi');
                    displaytext = {displaytext1; displaytext2};  
                    xposition = (orkstartdn - 34) /183;
                    annotation(sp(i), 'textbox',  ...
                                    'String', displaytext, ...
                                    'Interpreter', 'tex', ...
                                    'Units', 'normalized', ...
                                    'Position', [xposition, 0, .2, 1], ...
                                    'HorizontalAlignment', 'center', ...
                                    'VerticalAlignment', 'bottom', ...
                                    'LineStyle', 'none', ...
                                    'FontName', fontname, ...
                                    'FontSize', smallfontsize);
                end
            end
        end
        savePlotInDir(f, imagefilename, subfolder);
        savePlotInDirAsSVG(f, imagefilename, subfolder);
        close(f);
    end
end

end

    
    