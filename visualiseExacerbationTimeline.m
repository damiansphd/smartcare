clc; clear; close all;

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

[studynbr, study, ~] = selectStudy();
chosentreatgap = selectTreatmentGap();
[datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
[physdata, offset, physdata_predateoutlierhandling] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);
ivandmeasuresfile = sprintf('%sivandmeasures_gap%d.mat', study, chosentreatgap);

tic
fprintf('Loading clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading measurement data\n');
load(fullfile(basedir, subfolder, datamatfile));
fprintf('Loading iv treatment and measures prior data\n');
load(fullfile(basedir, subfolder, ivandmeasuresfile));
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, demographicsmatfile));
toc

tic
% sort antibiotic and admission clinical data consistently
cdAntibiotics = sortrows(cdAntibiotics, {'ID', 'StartDate', 'Route'}, 'ascend');
cdAdmissions = sortrows(cdAdmissions, {'ID', 'Admitted'}, 'ascend');
% add column to admissions to capture event type (for antibiotics, use
% Route as event type
%cdAdmissions.EventType = cdAdmissions.Hospital;
cdAdmissions.EventType(:) = {'Admission'};

% create set of antibiotic treatments
%abTreatments = unique(cdAntibiotics(:,{'ID', 'Hospital', 'StartDate'}));
%abTreatments.Properties.VariableNames{'ID'} = 'SmartCareID';
%abTreatments.IVDateNum = datenum(abTreatments.StartDate) - offset + 1;
abTreatments = ivandmeasurestable(ivandmeasurestable.DaysWithMeasures >= 15 & ivandmeasurestable.AvgMeasuresPerDay >= 2, {'SmartCareID', 'StudyNumber', 'Hospital', 'IVStartDate', 'IVDateNum'});

% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(physdata);

% do inner join to reduce to only patients with enough data
abTreatments = innerjoin(patientoffsets, abTreatments);

% set variables to format uipane
measures = unique(physdata.RecordingType);
plotsacross = 3;
plotsdown = ceil((1 + size(measures, 1)) / plotsacross);
plotsperpage = plotsacross * plotsdown;
subfolder = sprintf('Plots/%s', study);

% colours
admcol  = [0.694 0.627 0.78];
ivcol   = [1     0     0   ];
oralcol = [1     0.85  0   ];

% treat all antibiotic treatments within a -7/+25 day window as being part of
% the same event
abpriorwindow = days(-7);
abpostwindow = days(25);
measuresstartdn = -40;
for i = 1:size(abTreatments,1)
%for i = 41:43       
    scid = abTreatments.SmartCareID(i);
    studyid = abTreatments.StudyNumber{i};
    hospital = abTreatments.Hospital{i};
    eventstartdate = abTreatments.IVStartDate(i);
    eventstartdn = datenum(abTreatments.IVStartDate(i)) - offset + 1;
    patientoffset = abTreatments.PatientOffset(i);
    
    fprintf('Patient: %3d  Hospital: %8s  EventDate: %10s - plotting timeline\n', scid, hospital, datestr(eventstartdate, 29));
    % get antibiotics treatments for this event
    %antibset = cdAntibiotics(cdAntibiotics.ID == scid & cdAntibiotics.StartDate >= (eventstartdate + abpriorwindow) ...
    %    & cdAntibiotics.StartDate < (eventstartdate + abpostwindow), ...
    antibset = cdAntibiotics(cdAntibiotics.ID == scid & cdAntibiotics.StopDate >= (eventstartdate + measuresstartdn) ...
        & cdAntibiotics.StartDate < (eventstartdate + abpostwindow), ...
        {'ID', 'Hospital', 'StartDate', 'StopDate', 'Route'});
    antibset.Properties.VariableNames{'ID'} = 'SmartCareID';
    antibset.Properties.VariableNames{'Route'} = 'EventType';
    % get hospital admission for this event
    %admset = cdAdmissions(cdAdmissions.ID == scid & cdAdmissions.Admitted >= (eventstartdate + abpriorwindow) ...
    %    & cdAdmissions.Admitted < (eventstartdate + abpostwindow), ...
    admset = cdAdmissions(cdAdmissions.ID == scid & cdAdmissions.Discharge >= (eventstartdate + measuresstartdn) ...
        & cdAdmissions.Admitted < (eventstartdate + abpostwindow), ...
        {'ID', 'Hospital', 'Admitted', 'Discharge', 'EventType'});
    admset.Properties.VariableNames{'ID'} = 'SmartCareID';
    admset.Properties.VariableNames{'Admitted'} = 'StartDate';
    admset.Properties.VariableNames{'Discharge'} = 'StopDate';
        
    % concatenate and set relative start/stop dates with zero being the
    % start date of the current event
    eventtable = [admset ; antibset];
    eventtable.StartDateNum = datenum(eventtable.StartDate) - offset + 1 - eventstartdn;
    eventtable.StopDateNum = datenum(eventtable.StopDate) - offset + 1 - eventstartdn;
        
    eventtable = sortrows(eventtable, {'SmartCareID','StartDate','EventType'}, 'ascend');
        
    % set the x range for the plots (always start at -40, and finish at
    % max stop date of all rows for this event (with a minimum of 20)
    xplotstartdn = measuresstartdn;
    xplotstopdn = max(eventtable.StopDateNum);
    %xplotstopdn = max(20, xplotstopdn);
    if xplotstopdn > 20
        xplotstopdn = 20;
    end
    
    f = figure('Name',sprintf('%s-Patient: %s (%d) Hospital: %s  EventDate: %s', study, studyid, scid, hospital, datestr(eventstartdate, 29)));
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0.45, 0, 0.35, 0.92], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
    %set(gcf, 'Units', 'normalized', 'OuterPosition', [0.2, 0.2, 0.8, 0.8], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
    p = uipanel('Parent', f, 'BorderType', 'none'); 
    p.Title = sprintf('%s-Patient: %s (%d)  Hospital: %s  EventDate: %s', study, studyid, scid, hospital, datestr(eventstartdate, 29)); 
    p.TitlePosition = 'centertop';
    p.FontSize = 14;
    p.FontWeight = 'bold';
    ax = subplot(plotsdown, plotsacross, 1,'Parent',p);
    ax.FontSize = 8;
    hold on;
    xl = [xplotstartdn xplotstopdn];
    xlim(xl);
    % set y range to be the number of rows in the event table, with a
    % minimum of 8 if less than this
    yl = [0 max(8,size(eventtable,1))];
    ylim(yl);
    title(ax, 'Admissions and Treatments', 'FontSize', 10);
    xlabel(ax, 'Days', 'FontSize', 8);
    % plot a horizontal bar for each row in the event table, coloured
    % according to the type of event.
    for a = 1:size(eventtable,1)
        yval = size(eventtable,1) - a + 1;
        switch eventtable.EventType{a}
            case 'Oral'
                colour = oralcol;
            case 'IV'
                colour = ivcol;
            case 'Admission'
                colour = admcol;
            otherwise
                colour = 'b';
        end
        l(a) = line(ax, [eventtable.StartDateNum(a) eventtable.StopDateNum(a)], [yval, yval], 'Color', colour, 'LineStyle', '-', 'LineWidth', 6);
    end  
    % add vertical line to mark event date
    line(ax, [0 0], yl, 'Color', 'black', 'LineStyle', ':', 'LineWidth', 1)
    % add legend for plot with one of each type of event listed
    [dummy, legendidx] = unique(eventtable.EventType, 'stable');
    legend(ax, l(legendidx), eventtable.EventType(legendidx), 'Location', 'west', 'FontSize', 8);
    hold off    
        
    % add plots of measures here
    
    for b = 1:size(measures,1)
        measure = measures{b};
        column = getColumnForMeasure(measure);
        scdata = physdata(physdata.SmartCareID == scid & ismember(physdata.RecordingType, measure) & ...
            physdata.DateNum >= eventstartdn + xplotstartdn & physdata.DateNum <= eventstartdn + xplotstopdn, :);
        scdata = scdata(:, {'SmartCareID','DateNum' 'Date_TimeRecorded', column});
        scdata.Properties.VariableNames{column} = 'Measurement';
        scdata.DateNum = scdata.DateNum - eventstartdn;
        if size(scdata,1) > 0
            ax = subplot(plotsdown,plotsacross,b+1,'Parent',p);
            ax.FontSize = 8;
            hold on;
            xl = [xplotstartdn xplotstopdn];
            xlim(xl);
            % set y range to be the number of rows in the event table, with a
            % minimum of 8 if less than this
            rangelimit = setMinYDisplayRangeForMeasure(measure);
            yl = setYDisplayRange(min(scdata.Measurement), max(scdata.Measurement), rangelimit);
            %ydisplaymin = min(scdata.Measurement) * .9;
            %ydisplaymax = max(scdata.Measurement) * 1.1;
            %if ydisplaymin == 0 && ydisplaymax == 0
            %    ydisplaymax = 1;
            %end
            %yl = [ydisplaymin ydisplaymax];
            ylim(yl);
            title(ax, strrep(measure, 'Recording', ''), 'FontSize', 10);
            xlabel(ax, 'Days', 'FontSize', 8);
            ylabel(ax, 'Measure', 'FontSize', 8);
            plot(ax, scdata.DateNum, scdata.Measurement, ...
                'Color', [0, 0.65, 1], ...
                'LineStyle', ':', ...
                'Marker', 'o', ...
                'LineWidth',1,...
                'MarkerSize',2,...
                'MarkerEdgeColor','b',...
                'MarkerFaceColor','g');
            
            plot(ax, scdata.DateNum, movmean(scdata.Measurement, 4, 'omitnan'), ...
                'Color', [0, 0.65, 1], ...
                'LineStyle', '-', ...
                'Marker', 'none', ...
                'LineWidth', 1);
            
            % add vertical line to mark event date & IV antibiotics,
            % & admissions, 
            %admdates = unique([eventtable.StartDateNum(ismember(eventtable.EventType, 'Admission')) ; eventtable.StopDateNum(ismember(eventtable.EventType, 'Admission'))]);
            %ivdates = unique([eventtable.StartDateNum(ismember(eventtable.EventType, 'IV')) ; eventtable.StopDateNum(ismember(eventtable.EventType, 'IV'))]);
            %ivdates = setdiff(ivdates, admdates);
            %line( [0 0], yl, 'Color', 'black', 'LineStyle', ':', 'LineWidth', 1)
            %for c = 1:size(admdates,1)
            %    line(ax, [admdates(c) admdates(c)], yl, 'Color', 'r', 'LineStyle', ':', 'LineWidth', 1)
            %end
            %for c = 1:size(ivdates,1)
            %    line(ax, [ivdates(c) ivdates(c)], yl, 'Color', 'm', 'LineStyle', ':', 'LineWidth', 1)
            %end
            for a = 1:size(eventtable,1)
                switch eventtable.EventType{a}
                case 'Oral'
                    colour = oralcol;
                case 'IV'
                    colour = ivcol;
                case 'Admission'
                    colour = admcol;
                otherwise
                    colour = 'b';
                end
                fill(ax, [eventtable.StartDateNum(a) eventtable.StopDateNum(a) eventtable.StopDateNum(a) eventtable.StartDateNum(a)], ...
                          [yl(1) yl(1) yl(2) yl(2)], colour, 'FaceAlpha', '0.1', 'EdgeColor', 'none');
            end
            % add horizontal lines for mid50mean and mid50 min/max
            ddcolumn = sprintf('Fun_%s',column);
            mid50mean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(5);
            mid50std = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(6);
            line(ax, xl, [mid50mean mid50mean] , 'Color', 'bl', 'LineStyle', '--', 'LineWidth', 1)
            line(ax, xl, [mid50mean-mid50std mid50mean-mid50std] , 'Color', 'bl', 'LineStyle', ':', 'LineWidth', 1)
            line(ax, xl, [mid50mean+mid50std mid50mean+mid50std] , 'Color', 'bl', 'LineStyle', ':', 'LineWidth', 1)
            
            hold off;
        end
    end
    % save plot
    imagefilename = sprintf('%s-ExacerbationTimeline_ID_%d_%s_%s_%11s', study, scid, studyid, hospital, datestr(eventstartdate, 29));
    savePlotInDir(f, imagefilename, subfolder);
    close(f);
end
    
        
        
        