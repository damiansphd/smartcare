clc; clear; close all;

tic

basedir = './';
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'clinicaldata.mat';
scmatfile = 'smartcaredata.mat';
ivandmeasuresfile = 'ivandmeasures.mat';


fprintf('Loading Clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading SmartCare measurement data\n');
load(fullfile(basedir, subfolder, scmatfile));
fprintf('Loading iv treatment and measures prior data\n');
load(fullfile(basedir, subfolder, ivandmeasuresfile));
toc

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
abTreatments = ivandmeasurestable(ivandmeasurestable.DaysWithMeasures >= 20 & ivandmeasurestable.AvgMeasuresPerDay >= 3, {'SmartCareID', 'Hospital', 'IVStartDate', 'IVDateNum'});

% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(physdata);

% do inner join to reduce to only patients with enough data
abTreatments = innerjoin(patientoffsets, abTreatments);

% set variables to format uipane
plotsacross = 2;
plotsdown = 5;
plotsperpage = plotsacross * plotsdown;
basedir = './';
subfolder = 'Plots';

%oldid = 0;
%oldstartdn = 0;
% treat all antibiotic treatments within a 25 day window as being part of
% the same event
abpriorwindow = days(-7);
abpostwindow = days(25);
measuresstartdn = -40;
for i = 1:size(abTreatments,1)
%for i = 1:4       
    scid = abTreatments.SmartCareID(i);
    hospital = abTreatments.Hospital{i};
    eventstartdate = abTreatments.IVStartDate(i);
    %eventstartdn = abTreatments.IVDateNum(i);
    eventstartdn = datenum(abTreatments.IVStartDate(i)) - offset + 1;
    patientoffset = abTreatments.PatientOffset(i);
    
    % only create a plot if the row is a new patient, or the start date is
    % more than 25 days from prior treatment
    %if (scid ~= oldid | eventstartdn >= oldstartdn + abpostwindow)
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
        
        % set the x range for the plots (always start at -20, and finish at
        % max stop date of all rows for this event (with a minimum of 20)
        xplotstartdn = measuresstartdn;
        xplotstopdn = max(eventtable.StopDateNum);
        xplotstopdn = max(20, xplotstopdn);
        
        f = figure('Name',sprintf('Patient: %d  Hospital: %s  EventDate: %s', scid, hospital, datestr(eventstartdate, 29)));
        set(gcf, 'Units', 'normalized', 'OuterPosition', [0.2, 0.2, 0.8, 0.8], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
        p = uipanel('Parent', f, 'BorderType', 'none'); 
        p.Title = sprintf('Patient: %d  Hospital: %s  EventDate: %s', scid, hospital, datestr(eventstartdate, 29)); 
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
        % plot a horizontal row for each row in the event table, coloured
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
            line( [eventtable.StartDateNum(a) eventtable.StopDateNum(a)], [yval, yval], 'Color', colour, 'LineStyle', '-', 'LineWidth', 6);
        end
        % add vertical line to mark event date
        line( [0 0], yl, 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1)
        hold off    
        
        % add plots of measures here
        measures = unique(physdata.RecordingType);
        for b = 1:size(measures,1)
            measure = measures{b};
            switch measure
                case 'ActivityRecording'
                    column = 'Activity_Steps';
                case {'CoughRecording','SleepActivityRecording','WellnessRecording'}
                    column = 'Rating';
                case 'LungFunctionRecording'
                    column = 'CalcFEV1_';
                case 'O2SaturationRecording'
                    column = 'O2Saturation';
                case 'PulseRateRecording'
                    column = 'Pulse_BPM_';
                case 'TemperatureRecording'
                    column = 'Temp_degC_';
                case 'WeightRecording'
                    column = 'WeightInKg';
                otherwise
                    column = '';
            end
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
                plot(scdata.DateNum, scdata.Measurement, 'y-o',...
                'LineWidth',1,...
                'MarkerSize',3,...
                'MarkerEdgeColor','b',...
                'MarkerFaceColor','g');
                % add vertical line to mark event date
                line( [0 0], yl, 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1)
                hold off;
            end
        end
        % save plot
        imagefilename = sprintf('ExacerbationTimeline_ID%d_%s_%11s.png', scid, hospital, datestr(eventstartdate, 29));
        saveas(f,fullfile(basedir, subfolder, imagefilename));
        close(f);
    %end
    %fprintf('Patient: %3d  Hospital: %8s  EventDate: %10s - skipping - same timeline\n', scid, hospital, datestr(eventstartdate, 29));
    %oldid = scid;
    %oldstartdn = eventstartdn;
end
    
        
        
        