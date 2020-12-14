clc; clear; close all;

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

[studynbr, study, studyfullname] = selectStudy();
[datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
[physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);

alignmentmodelinputsfile = sprintf('%salignmentmodelinputs.mat', study);

tic
fprintf('Loading demographic data by patient\n');
load(fullfile(basedir, subfolder, demographicsmatfile), 'demographicstable', 'overalltable');
fprintf('Loading alignment model inputs\n');
load(fullfile(basedir, subfolder, alignmentmodelinputsfile), 'amInterventions','amDatacube', 'measures', 'npatients','ndays', 'nmeasures', 'ninterventions');
toc
fprintf('\n');

basedir = setBaseDir();
subfolder = sprintf('Plots/%s', study);
if ~exist(strcat(basedir, subfolder), 'dir')
    mkdir(strcat(basedir, subfolder));
end

patientoffsets = getPatientOffsets(physdata);

patientlist = unique(physdata.SmartCareID);
%for i = 1:size(patientlist,1)
for i = 59:59
%for i = 1:4
    tic
    scid       = patientlist(i);
    fprintf('Visualising measures for patient %d\n', scid);
    poffset    = patientoffsets.PatientOffset(patientoffsets.SmartCareID == scid);
    hospital   = cdPatient.Hospital{cdPatient.ID == scid};
    spstart    = cdPatient.StudyDate(cdPatient.ID == scid);
    spstartdn  = datenum(spstart) - offset - poffset + 1;
    spend      = cdPatient.StudyDate(cdPatient.ID == scid)+days(183);
    spenddn    = spstartdn + 183;
    hmstart    = min(physdata.Date_TimeRecorded(physdata.SmartCareID == scid));
    hmstartdn  = min(physdata.ScaledDateNum(physdata.SmartCareID == scid));
    hmend      = max(physdata.Date_TimeRecorded(physdata.SmartCareID == scid));
    hmenddn    = max(physdata.ScaledDateNum(physdata.SmartCareID == scid));
    
    imagefilename = sprintf('%s - Participant Clinical Measures - ID %d Hosp %s', studyfullname, scid, hospital);
    [f, p] = createFigureAndPanel(imagefilename, 'Portrait', 'a4');
    
    plotsacross = 1;
    plotsdown = 5;
    
    daysfrom = min(spstartdn, hmstartdn);
    daysto   = max(spenddn, hmenddn);
    xl = [daysfrom daysto];
    
    ax = subplot(plotsdown, plotsacross, 1,'Parent', p);
    hold on;
    fontsize = 7;
    ax.FontSize = fontsize;
    title(ax, 'Clinic Visits ({\color{green}g}), Admissions ({\color{magenta}m}), IV Antibiotics ({\color{red}r}) and Oral Antibiotics ({\color{cyan}c})', 'FontSize', 8);
    xlabel(ax, 'Days');
    ylabel(ax, 'Event');
    xlim(xl);
    yl = [0 4];
    ylim(yl);
    linewidth = 10;
    
    cvset     = cdClinicVisits(cdClinicVisits.ID == scid,:);
    cvset.AttendanceDatedn = datenum(cvset.AttendanceDate) - offset - poffset + 1;
    for m = 1:size(cvset,1)
        line(ax, [cvset.AttendanceDatedn(m) cvset.AttendanceDatedn(m) + 1], [3.5, 3.5], 'Color', 'green', 'LineStyle', '-', 'LineWidth', linewidth);
    end
    admset    = cdAdmissions(cdAdmissions.ID == scid,:);
    admset.Admitteddn = datenum(admset.Admitted) - offset - poffset + 1;
    admset.Dischargedn = datenum(admset.Discharge) - offset - poffset + 1;
    admdates = unique([admset.Admitteddn ; admset.Dischargedn]);
    for m = 1:size(admset,1)
        line(ax, [admset.Admitteddn(m) admset.Dischargedn(m)], [2.5, 2.5], 'Color', 'magenta', 'LineStyle', '-', 'LineWidth', linewidth);
    end
    ivabset   = cdAntibiotics(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, {'IV'}),:);
    ivabset.Startdn = datenum(ivabset.StartDate) - offset - poffset + 1;
    ivabset.Stopdn = datenum(ivabset.StopDate) - offset - poffset + 1;
    ivabgroupeddates = getGroupedIVTreatmentDates(ivabset);
    ivabgroupeddates.Startdn = datenum(ivabgroupeddates.StartDate) - offset - poffset + 1;
    ivabgroupeddates.Stopdn = datenum(ivabgroupeddates.StopDate) - offset - poffset + 1;
    ivabdates = unique([ivabgroupeddates.Startdn ; ivabgroupeddates.Stopdn]);
    for m = 1:size(ivabset,1)
        line(ax, [ivabset.Startdn(m) ivabset.Stopdn(m)], [1.5, 1.5], 'Color', 'red', 'LineStyle', '-', 'LineWidth', linewidth);
    end
    oralabset = cdAntibiotics(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, {'Oral'}),:);
    oralabset.Startdn = datenum(oralabset.StartDate) - offset - poffset + 1;
    oralabset.Stopdn = datenum(oralabset.StopDate) - offset - poffset + 1;
    for m = 1:size(oralabset,1)
        line(ax, [oralabset.Startdn(m) oralabset.Stopdn(m)], [0.5, 0.5], 'Color', 'cyan', 'LineStyle', '-', 'LineWidth', linewidth);
    end
    hold off;
    
    ax = subplot(plotsdown, plotsacross, 2,'Parent', p);
    pcrp = cdCRP(cdCRP.ID == scid,:);
    pcrp.ScaledDateNum = datenum(pcrp.CRPDate) - offset - poffset + 1;
    if size(pcrp,1) > 0
        hold on;
        plot(ax, pcrp.ScaledDateNum,pcrp.NumericLevel, ...
            'Color', [0, 0.65, 1], ...
            'LineStyle', ':', ...
            'Marker', 'o', ...
            'LineWidth',1,...
            'MarkerSize',2,...
            'MarkerEdgeColor','b',...
            'MarkerFaceColor','g');
        
        fontsize = 7;
        ax.FontSize = fontsize;
        title(ax, 'Clinical CRP Level', 'FontSize', 8);
        xlabel(ax, 'Days');
        ylabel(ax, 'CRP Level');
        xlim(xl);
        rangelimit = setMinYDisplayRangeForMeasure('ClinicalCRP');
        yl = setYDisplayRange(min(pcrp.NumericLevel), max(pcrp.NumericLevel), rangelimit);
        ylim(yl);
        for m = 1:size(ivabgroupeddates, 1)
            plotFillArea(ax, ivabgroupeddates.Startdn, ivabgroupeddates.Stopdn, ...
                yl(1), yl(2), 'red', '0.1', 'none');
        end 
        %for m = 1:size(ivabdates,1)
        %    line(ax, [ivabdates(m) ivabdates(m)], yl, 'Color', 'red', 'LineStyle', ':', 'LineWidth', 1)
        %end
        %for c = 1:size(admdates,1)
        %    line(ax, [admdates(c) admdates(c)], yl, 'Color', 'magenta', 'LineStyle', ':', 'LineWidth', 1)
        %end
        hold off;
    end
    
    ax = subplot(plotsdown, plotsacross, 3,'Parent', p);
    ppft = cdPFT(cdPFT.ID == scid,:);
    ppft.ScaledDateNum = datenum(ppft.LungFunctionDate) - offset - poffset + 1;
    if size(ppft,1) > 0
        hold on;
        plot(ax, ppft.ScaledDateNum, ppft.CalcFEV1_, ...
            'Color', [0, 0.65, 1], ...
            'LineStyle', ':', ...
            'Marker', 'o', ...
            'LineWidth',1,...
            'MarkerSize',2,...
            'MarkerEdgeColor','b',...
            'MarkerFaceColor','g');
        fontsize = 7;
        ax.FontSize = fontsize;
        title(ax, 'Clinical FEV1%', 'FontSize', 8);
        xlabel(ax, 'Days');
        ylabel(ax, 'FEV1%');
        xlim(xl);
        rangelimit = setMinYDisplayRangeForMeasure('ClinicalFEV1');
        yl = setYDisplayRange(min(ppft.CalcFEV1_), max(ppft.CalcFEV1_), rangelimit);
        ylim(yl);
        for m = 1:size(ivabgroupeddates, 1)
            plotFillArea(ax, ivabgroupeddates.Startdn, ivabgroupeddates.Stopdn, ...
                yl(1), yl(2), 'red', '0.1', 'none');
        end 
        %for m = 1:size(ivabdates,1)
        %    line(ax, [ivabdates(m) ivabdates(m)], yl, 'Color', 'red', 'LineStyle', ':', 'LineWidth', 1)
        %end
        %for c = 1:size(admdates,1)
        %    line(ax, [admdates(c) admdates(c)], yl, 'Color', 'magenta', 'LineStyle', ':', 'LineWidth', 1)
        %end
        hold off;
    end
    
    savePlotInDir(f, imagefilename, subfolder);
    savePlotInDirAsSVG(f, imagefilename, subfolder);
    close(f);
    fprintf('Next Page\n');
    
    plotsacross = 1;
    plotsdown = 5;
    plotsperpage = plotsacross * plotsdown;
    
    nmeasures = size(unique(physdata.RecordingType), 1);
    
    page = 1;
    npages = ceil(nmeasures / plotsperpage);
    
    filenameprefix = sprintf('%s - Participant Home Measures - ID %d Hosp %s', studyfullname, scid, hospital);
    imagefilename = sprintf('%s - Page %d of %d', filenameprefix, page, npages);
    [f, p] = createFigureAndPanel(imagefilename, 'Portrait', 'a4');
    
    % get all measures so the plots for each appear in a consistent place
    % across all patients
    measures = unique(physdata.RecordingType);
    for m = 1:size(measures,1)
        measure = measures{m};
        column = getColumnForMeasure(measure);
        scdata = physdata(physdata.SmartCareID == scid & ismember(physdata.RecordingType, measure), :);
        scdata = scdata(:, {'SmartCareID','ScaledDateNum' 'Date_TimeRecorded', column});
        scdata.Properties.VariableNames{column} = 'Measurement';
        
        if size(scdata,1) > 0
            ax = subplot(plotsdown, plotsacross, m - (page - 1) * plotsperpage,'Parent',p);
            hold on;
            xlim(xl);
            rangelimit = setMinYDisplayRangeForMeasure(measure);
            yl = setYDisplayRange(min(scdata.Measurement), max(scdata.Measurement), rangelimit);
            ylim(yl);
            fontsize = 7;
            ax.FontSize = fontsize;
            title(ax, replace(measure, 'Recording', ''), 'FontSize', 8);
            xlabel(ax, 'Days');
            ylabel(ax, 'Measure');
            
            plot(ax, scdata.ScaledDateNum, scdata.Measurement, ...
                'Color', [0, 0.65, 1], ...
                'LineStyle', ':', ...
                'Marker', 'o', ...
                'LineWidth',1,...
                'MarkerSize',2,...
                'MarkerEdgeColor','b',...
                'MarkerFaceColor','g');
            
            plot(ax, scdata.ScaledDateNum, movmean(scdata.Measurement, 4, 'omitnan'), ...
                'Color', [0, 0.65, 1], ...
                'LineStyle', '-', ...
                'Marker', 'none', ...
                'LineWidth', 1);
            
            plotFillArea(ax, ivabgroupeddates.Startdn, ivabgroupeddates.Stopdn, ...
                yl(1), yl(2), 'red', '0.1', 'none');
            
            
            
            ddcolumn = sprintf('Fun_%s',column);
            mmean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(1);
            mstd  = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(2);
            
            plotFillArea(ax, xl(1), xl(2), ...
                mmean - mstd, mmean + mstd, [0.4, 0.4, 0.4], '0.1', 'none');
            
            %line( xl, [mmean mmean] , 'Color', 'black', 'LineStyle', '-.', 'LineWidth', 1)
            
            %mid50mean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(5);
            %mid50std = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(6);
            %line( xl, [mid50mean mid50mean] , 'Color', 'black', 'LineStyle', '-.', 'LineWidth', 1)
            %line( xl, [mid50mean-mid50std mid50mean-mid50std] , 'Color', 'black', 'LineStyle', ':', 'LineWidth', 1)
            %line( xl, [mid50mean+mid50std mid50mean+mid50std] , 'Color', 'black', 'LineStyle', ':', 'LineWidth', 1)
            %for a = 1:size(ivabdates,1)
            %    line( [ivabdates(a) ivabdates(a)], yl, 'Color', 'm', 'LineStyle', ':', 'LineWidth', 1)
            %end
            %for c = 1:size(admdates,1)
            %    line( [admdates(c) admdates(c)], yl, 'Color', 'r', 'LineStyle', ':', 'LineWidth', 1)
            %end
            hold off;
        end
        
        if round(m/plotsperpage) == m/plotsperpage
            savePlotInDir(f, imagefilename, subfolder);
            savePlotInDirAsSVG(f, imagefilename, subfolder);
            close(f);
            page = page + 1;
            fprintf('Next Page\n');
            imagefilename = sprintf('%s - Page %d of %d', filenameprefix, page, npages);
            [f, p] = createFigureAndPanel(imagefilename, 'Portrait', 'a4');
        end
    end
    
    if exist('f', 'var')
        savePlotInDir(f, imagefilename, subfolder);
        savePlotInDirAsSVG(f, imagefilename, subfolder);
        close(f);
    end

    toc
    
end

    
    