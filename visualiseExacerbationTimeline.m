clc; clear; close all;

studynbr = input('Enter Study to run for (1 = SmartCare, 2 = TeleMed): ');

if studynbr == 1
    study = 'SC';
    clinicalmatfile = 'clinicaldata.mat';
    datamatfile = 'smartcaredata.mat';
    ivandmeasuresfile = 'SCivandmeasures.mat';
    datademographicsfile = 'SCdatademographicsbypatient.mat';
elseif studynbr == 2
    study = 'TM';
    clinicalmatfile = 'telemedclinicaldata.mat';
    datamatfile = 'telemeddata.mat';
    ivandmeasuresfile = 'TMivandmeasures.mat';
    datademographicsfile = 'TMdatademographicsbypatient.mat';
else
    fprintf('Invalid study\n');
    return;
end

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
fprintf('Loading clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading measurement data\n');
load(fullfile(basedir, subfolder, datamatfile));
fprintf('Loading iv treatment and measures prior data\n');
load(fullfile(basedir, subfolder, ivandmeasuresfile));
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, datademographicsfile));
toc

if studynbr == 2
    physdata = tmphysdata;
    cdPatient = tmPatient;
    cdMicrobiology = tmMicrobiology;
    cdAntibiotics = tmAntibiotics;
    cdAdmissions = tmAdmissions;
    cdPFT = tmPFT;
    cdCRP = tmCRP;
    cdClinicVisits = tmClinicVisits;
    cdEndStudy = tmEndStudy;
    offset = tmoffset;
end

tic
% sort antibiotic and admission clinical data consistently
cdAntibiotics = sortrows(cdAntibiotics, {'ID', 'StartDate', 'Route'}, 'ascend');
cdAdmissions = sortrows(cdAdmissions, {'ID', 'Admitted'}, 'ascend');
% add column to admissions to capture event type (for antibiotics, use
% Route as event type
cdAdmissions.EventType = cdAdmissions.Hospital;
cdAdmissions.EventType(:) = {'Admission'};

% create set of antibiotic treatments
%abTreatments = unique(cdAntibiotics(:,{'ID', 'Hospital', 'StartDate'}));
%abTreatments.Properties.VariableNames{'ID'} = 'SmartCareID';
%abTreatments.IVDateNum = datenum(abTreatments.StartDate) - offset + 1;
abTreatments = ivandmeasurestable(ivandmeasurestable.DaysWithMeasures >= 15 & ivandmeasurestable.AvgMeasuresPerDay >= 2, {'SmartCareID', 'Hospital', 'IVStartDate', 'IVDateNum'});

% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(physdata);

% do inner join to reduce to only patients with enough data
abTreatments = innerjoin(patientoffsets, abTreatments);

% set variables to format uipane
plotsacross = 2;
plotsdown = 5;
plotsperpage = plotsacross * plotsdown;
basedir = setBaseDir();
subfolder = 'Plots';

% treat all antibiotic treatments within a -7/+25 day window as being part of
% the same event
abpriorwindow = days(-7);
abpostwindow = days(25);
measuresstartdn = -40;
for i = 1:size(abTreatments,1)
%for i = 41:43       
    scid = abTreatments.SmartCareID(i);
    hospital = abTreatments.Hospital{i};
    eventstartdate = abTreatments.IVStartDate(i);
    eventstartdn = datenum(abTreatments.IVStartDate(i)) - offset + 1;
    patientoffset = abTreatments.PatientOffset(i);
    
    fprintf('Patient: %3d  Hospital: %8s  EventDate: %10s - plotting timeline\n', scid, hospital, datestr(eventstartdate, 29));
    % get antibiotics treatments for this event
    antibset = cdAntibiotics(cdAntibiotics.ID == scid & cdAntibiotics.StartDate >= (eventstartdate + abpriorwindow) ...
        & cdAntibiotics.StartDate < (eventstartdate + abpostwindow), ...
        {'ID', 'Hospital', 'StartDate', 'StopDate', 'Route'});
    antibset.Properties.VariableNames{'ID'} = 'SmartCareID';
    antibset.Properties.VariableNames{'Route'} = 'EventType';
    % get hospital admission for this event
    admset = cdAdmissions(cdAdmissions.ID == scid & cdAdmissions.Admitted >= (eventstartdate + abpriorwindow) ...
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
    xplotstopdn = max(20, xplotstopdn);
        
    f = figure('Name',sprintf('%s-Patient: %d  Hospital: %s  EventDate: %s', study, scid, hospital, datestr(eventstartdate, 29)));
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0.45, 0, 0.35, 0.92], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
    %set(gcf, 'Units', 'normalized', 'OuterPosition', [0.2, 0.2, 0.8, 0.8], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
    p = uipanel('Parent', f, 'BorderType', 'none'); 
    p.Title = sprintf('%s-Patient: %d  Hospital: %s  EventDate: %s', study, scid, hospital, datestr(eventstartdate, 29)); 
    p.TitlePosition = 'centertop';
    p.FontSize = 20;
    p.FontWeight = 'bold';
    subplot(plotsdown, plotsacross, 1,'Parent',p);
    hold on;
    xl = [xplotstartdn xplotstopdn];
    xlim(xl);
    % set y range to be the number of rows in the event table, with a
    % minimum of 8 if less than this
    yl = [0 max(8,size(eventtable,1))];
    ylim(yl);
    title('Admissions and Treatments');
    xlabel('Days');
    % plot a horizontal bar for each row in the event table, coloured
    % according to the type of event.
    for a = 1:size(eventtable,1)
        yval = size(eventtable,1) - a + 1;
        switch eventtable.EventType{a}
            case 'Oral'
                colour = 'c';
            case 'IV'
                colour = 'm';
            case 'Admission'
                colour = 'r';
            otherwise
                colour = 'b';
        end
        l(a) = line( [eventtable.StartDateNum(a) eventtable.StopDateNum(a)], [yval, yval], 'Color', colour, 'LineStyle', '-', 'LineWidth', 6);
    end  
    % add vertical line to mark event date
    line( [0 0], yl, 'Color', 'black', 'LineStyle', ':', 'LineWidth', 1)
    % add legend for plot with one of each type of event listed
    [dummy, legendidx] = unique(eventtable.EventType, 'stable');
    legend(l(legendidx), eventtable.EventType(legendidx), 'Location', 'west', 'FontSize', 8);
    hold off    
        
    % add plots of measures here
    measures = unique(physdata.RecordingType);
    for b = 1:size(measures,1)
        measure = measures{b};
        column = getColumnForMeasure(measure);
        scdata = physdata(physdata.SmartCareID == scid & ismember(physdata.RecordingType, measure) & ...
            physdata.DateNum >= eventstartdn + xplotstartdn & physdata.DateNum <= eventstartdn + xplotstopdn, :);
        scdata = scdata(:, {'SmartCareID','DateNum' 'Date_TimeRecorded', column});
        scdata.Properties.VariableNames{column} = 'Measurement';
        scdata.DateNum = scdata.DateNum - eventstartdn;
        if size(scdata,1) > 0
            subplot(plotsdown,plotsacross,b+1,'Parent',p);
            hold on;
            xl = [xplotstartdn xplotstopdn];
            xlim(xl);
            % set y range to be the number of rows in the event table, with a
            % minimum of 8 if less than this
            ydisplaymin = min(scdata.Measurement) * .9;
            ydisplaymax = max(scdata.Measurement) * 1.1;
            yl = [ydisplaymin ydisplaymax];
            ylim(yl);
            title(measure);
            xlabel('Days');
            ylabel('Measure');
            plot(scdata.DateNum, scdata.Measurement, ...
                'Color', [0, 0.65, 1], ...
                'LineStyle', '-', ...
                'Marker', 'o', ...
                'LineWidth',1,...
                'MarkerSize',3,...
                'MarkerEdgeColor','b',...
                'MarkerFaceColor','g');
            % add vertical line to mark event date & IV antibiotics,
            % & admissions, 
            admdates = unique([eventtable.StartDateNum(ismember(eventtable.EventType, 'Admission')) ; eventtable.StopDateNum(ismember(eventtable.EventType, 'Admission'))]);
            ivdates = unique([eventtable.StartDateNum(ismember(eventtable.EventType, 'IV')) ; eventtable.StopDateNum(ismember(eventtable.EventType, 'IV'))]);
            ivdates = setdiff(ivdates, admdates);
            line( [0 0], yl, 'Color', 'black', 'LineStyle', ':', 'LineWidth', 1)
            for c = 1:size(admdates,1)
                line( [admdates(c) admdates(c)], yl, 'Color', 'r', 'LineStyle', ':', 'LineWidth', 1)
            end
            for c = 1:size(ivdates,1)
                line( [ivdates(c) ivdates(c)], yl, 'Color', 'm', 'LineStyle', ':', 'LineWidth', 1)
            end
            % add horizontal lines for mid50mean and mid50 min/max
            ddcolumn = sprintf('Fun_%s',column);
            mid50mean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(5);
            mid50std = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(6);
            line( xl, [mid50mean mid50mean] , 'Color', 'bl', 'LineStyle', '--', 'LineWidth', 1)
            line( xl, [mid50mean-mid50std mid50mean-mid50std] , 'Color', 'bl', 'LineStyle', ':', 'LineWidth', 1)
            line( xl, [mid50mean+mid50std mid50mean+mid50std] , 'Color', 'bl', 'LineStyle', ':', 'LineWidth', 1)
            
            hold off;
        end
    end
    % save plot
    imagefilename = sprintf('%s-ExacerbationTimeline_ID%d_%s_%11s', study, scid, hospital, datestr(eventstartdate, 29));
    savePlotInDir(f, imagefilename, subfolder);
    close(f);
end
    
        
        
        