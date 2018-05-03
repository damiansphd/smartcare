clc; clear; close all;

tic

basedir = './';
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'clinicaldata.mat';
scmatfile = 'smartcaredata.mat';
ivandmeasuresfile = 'ivandmeasures.mat';
datademographicsfile = 'datademographicsbypatient.mat';


fprintf('Loading Clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading SmartCare measurement data\n');
load(fullfile(basedir, subfolder, scmatfile));
fprintf('Loading iv treatment and measures prior data\n');
load(fullfile(basedir, subfolder, ivandmeasuresfile));
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, datademographicsfile));
toc

tic

basedir = './';
subfolder = 'Plots';

patientoffsets = getPatientOffsets(physdata);

patientlist = unique(physdata.SmartCareID);
for i = 1:size(patientlist,1)
%for i = 103:104
%for i = 1:4
    
    scid       = patientlist(i);
    poffset    = patientoffsets.PatientOffset(patientoffsets.SmartCareID == scid);
    hospital   = cdPatient.Hospital{cdPatient.ID == scid};
    sex        = cdPatient.Sex{cdPatient.ID == scid};
    spstart    = cdPatient.StudyDate(cdPatient.ID == scid);
    spstartdn  = datenum(spstart) - offset - poffset + 1;
    spend      = cdPatient.StudyDate(cdPatient.ID == scid)+days(183);
    spenddn    = spstartdn + 183;
    hmstart    = min(physdata.Date_TimeRecorded(physdata.SmartCareID == scid));
    hmstartdn  = min(physdata.ScaledDateNum(physdata.SmartCareID == scid));
    hmend      = max(physdata.Date_TimeRecorded(physdata.SmartCareID == scid));
    hmenddn    = max(physdata.ScaledDateNum(physdata.SmartCareID == scid));
    
    spclinicvisits  = size(cdClinicVisits.ID(cdClinicVisits.ID == scid & cdClinicVisits.AttendanceDate >= spstart & cdClinicVisits.AttendanceDate <= spend),1);
    sphospadm       = size(cdAdmissions.ID(cdAdmissions.ID == scid & cdAdmissions.Admitted >= spstart & cdAdmissions.Admitted <= spend),1);
    spivab          = size(cdAntibiotics.ID(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, 'IV') & cdAntibiotics.StartDate >= spstart & cdAntibiotics.StartDate <= spend),1);
    sporalab        = size(cdAntibiotics.ID(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, 'Oral') & cdAntibiotics.StartDate >= spstart & cdAntibiotics.StartDate <= spend),1);
    spcpftmeas      = size(cdPFT.ID(cdPFT.ID == scid & cdPFT.LungFunctionDate >= spstart & cdPFT.LungFunctionDate <= spend),1);
    spccrpmeas      = size(cdCRP.ID(cdCRP.ID == scid & cdCRP.CRPDate >= spstart & cdCRP.CRPDate <= spend),1);
    
    hmclinicvisits  = size(cdClinicVisits.ID(cdClinicVisits.ID == scid & cdClinicVisits.AttendanceDate >= hmstart & cdClinicVisits.AttendanceDate <= hmend),1);
    hmhospadm       = size(cdAdmissions.ID(cdAdmissions.ID == scid & cdAdmissions.Admitted >= hmstart & cdAdmissions.Admitted <= hmend),1);
    hmivab          = size(cdAntibiotics.ID(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, 'IV') & cdAntibiotics.StartDate >= hmstart & cdAntibiotics.StartDate <= hmend),1);
    hmoralab        = size(cdAntibiotics.ID(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, 'Oral') & cdAntibiotics.StartDate >= hmstart & cdAntibiotics.StartDate <= hmend),1);
    hmcpftmeas      = size(cdPFT.ID(cdPFT.ID == scid & cdPFT.LungFunctionDate >= hmstart & cdPFT.LungFunctionDate <= hmend),1);
    hmccrpmeas      = size(cdCRP.ID(cdCRP.ID == scid & cdCRP.CRPDate >= hmstart & cdCRP.CRPDate <= hmend),1);
    
    allclinicvisits = size(cdClinicVisits.ID(cdClinicVisits.ID == scid),1);
    allhospadm      = size(cdAdmissions.ID(cdAdmissions.ID == scid),1);
    allcpftmeas     = size(cdPFT.ID(cdPFT.ID == scid),1);
    allccrpmeas     = size(cdCRP.ID(cdCRP.ID == scid),1);
    allivab         = size(cdAntibiotics.ID(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, 'IV')),1);
    alloralab       = size(cdAntibiotics.ID(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, 'Oral')),1);
    
    allcavgfev1     = mean(cdPFT.FEV1(cdPFT.ID == scid));
    allcstdfev1     = std(cdPFT.FEV1(cdPFT.ID == scid));
    allcminfev1     = min(cdPFT.FEV1(cdPFT.ID == scid));
    allcmaxfev1     = max(cdPFT.FEV1(cdPFT.ID == scid));
    
    allcavgfev1_    = mean(cdPFT.CalcFEV1_(cdPFT.ID == scid));
    allcstdfev1_    = std (cdPFT.CalcFEV1_(cdPFT.ID == scid));
    allcminfev1_    = min(cdPFT.CalcFEV1_(cdPFT.ID == scid));
    allcmaxfev1_    = max(cdPFT.CalcFEV1_(cdPFT.ID == scid));
    
    allcavgcrp      = mean(cdCRP.NumericLevel(cdCRP.ID == scid));
    allcstdcrp      = std(cdCRP.NumericLevel(cdCRP.ID == scid));
    allcmincrp      = min(cdCRP.NumericLevel(cdCRP.ID == scid));
    allcmaxcrp      = max(cdCRP.NumericLevel(cdCRP.ID == scid));
    
    hmtotal         = size(physdata.SmartCareID(physdata.SmartCareID == scid),1);
    hmduration      = max(physdata.DateNum(physdata.SmartCareID == scid)) - min(physdata.DateNum(physdata.SmartCareID == scid));
    hmavgperday     = hmtotal/hmduration;
    
    leftstring = [  {sprintf('                Study Info')}                                                               ; ...
                    {sprintf('------------------------------------------')}                                               ; ...
                    {sprintf('Patient ID       :  %d', scid)}                                                             ; ...
                    {sprintf('Hospital         :  %s', hospital)}                                                         ; ...
                    {sprintf('Study Start Date :  %s', datestr(spstart,1))}                                               ; ...
                    {sprintf('Study End Date   :  %s', datestr((spend),1))}                                               ; ...
                    {sprintf('Study Status     :  %s', cdEndStudy.EndOfStudyReason{cdEndStudy.ID == scid})}               ; ...
                    {sprintf(' ')}                                                                                        ; ...
                    {sprintf('              Clinical Data')}                                                              ; ...
                    {sprintf('   StudyPeriod (HomeMeasurePeriod, All)')}                                                  ; ...
                    {sprintf('------------------------------------------')}                                               ; ...
                    {sprintf('Hospital Admissions   :  %2d (%2d,%2d)', sphospadm, hmhospadm, allhospadm)}                   ; ...
                    {sprintf('Antibiotics - IV      :  %2d (%2d,%2d)', spivab, hmivab, allivab)}                            ; ...
                    {sprintf('Antibiotics - Oral    :  %2d (%2d,%2d)', sporalab, hmoralab, alloralab)}                      ; ...
                    {sprintf('Clinic Visits         :  %2d (%2d,%2d)', spclinicvisits, hmclinicvisits, allclinicvisits )}   ; ...
                    {sprintf('Clinical PFT Measures :  %2d (%2d,%2d)', spcpftmeas, hmcpftmeas, allcpftmeas)}                ; ...
                    {sprintf('Clinical CRP Measures :  %2d (%2d,%2d)', spccrpmeas, hmccrpmeas, allccrpmeas)}                ; ...
                    {sprintf(' ')}                                                                                        ; ...
                    {sprintf('            Clinical Measures')}                                                            ; ...
                    {sprintf('          Avg +/- Std (Min, Max)')}                                                         ; ...
                    {sprintf('------------------------------------------')}                                                ; ...
                    {sprintf('FEV1      : %4.1f  +/- %4.1f  (%4.1f, %4.1f)', allcavgfev1, allcstdfev1, allcminfev1, allcmaxfev1)} ; ...
                    {sprintf('FEV1%%     : %4.1f%% +/- %4.1f%% (%3.0f%%, %3.0f%%)', allcavgfev1_, allcstdfev1_, allcminfev1_, allcmaxfev1_)} ; ...
                    {sprintf('CRP Level : %4.1f  +/- %4.1f  (%4.1f, %4.1f)', allcavgcrp, allcstdcrp, allcmincrp, allcmaxcrp)}     ; ...
                    {sprintf(' ')}                                                                                        ; ...
                    {sprintf('              Microbiology')}                                                               ; ...
                    {sprintf('------------------------------------------')}                                                ; ...
                  ];
                                                   
    microbiology = unique(cdMicrobiology.Microbiology(cdMicrobiology.ID==scid));
    for a = 1:size(microbiology,1)
        rowstring = sprintf('%s', microbiology{a});
        leftstring = [leftstring ; rowstring];
    end
    
    rightstring = [ {sprintf('                 Patient Data')}                                                            ; ...
                    {sprintf('----------------------------------------------')}                                           ; ...
                    {sprintf('Sex                    :  %s'       , cdPatient.Sex{cdPatient.ID == scid})}                 ; ...
                    {sprintf('D.O.B                  :  %s'       , datestr(cdPatient.DOB(cdPatient.ID == scid),1))}      ; ...
                    {sprintf('Age                    :  %d'       , cdPatient.CalcAge(cdPatient.ID == scid))}             ; ...
                    {sprintf('Height                 :  %1.1f cm' , cdPatient.Height(cdPatient.ID == scid))}              ; ...
                    {sprintf('Weight                 :  %1.1f kg' , cdPatient.Weight(cdPatient.ID == scid))}              ; ...
                    {sprintf('Predicted FEV1         :  %1.1f ltr', cdPatient.CalcFEV1SetAs(cdPatient.ID == scid))}       ; ...
                    {sprintf(' ')}                                                                                        ; ...
                    {sprintf('            Home Measurement Data')}                                                        ; ...
                    {sprintf('----------------------------------------------')}                                           ; ...
                    {sprintf('Measurement Start      :  %s'      , datestr(hmstart,1))}                                   ; ...
                    {sprintf('Measurement End        :  %s'      , datestr(hmend,1))}                                     ; ...
                    {sprintf('Duration               :  %d days' , hmduration)}                                           ; ...
                    {sprintf('Total Measures         :  %d'      , hmtotal)}                                              ; ...
                    {sprintf('Avg Measures Per Day   :  %1.1f'   , hmavgperday)}                                          ; ...
                    {sprintf(' ')}                                                                                        ; ...
                    {sprintf('              Home Measures')}                                                              ; ...
                    {sprintf('          Avg +/- Std (Min, Max)')}                                                         ; ...
                    {sprintf('----------------------------------------------')}                                           ; ...
                  ];
              
    measures = unique(physdata.RecordingType(physdata.SmartCareID == scid));
    for a = 1:size(measures,1)
        measure = measures{a};
        column = getColumnForMeasure(measure);
        ddcolumn = sprintf('Fun_%s',column);
        mmean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(1);
        mstd  = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(2);
        mmin  = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(3);
        mmax  = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(4);
        if ismember(measure, 'ActivityRecording')
            rowstring = sprintf('%-13s : %5.0f +/- %5.0f (%5.0f, %5.0f)', replace(measure, 'Recording', ''), mmean, mstd, mmin, mmax);
        else
            rowstring = sprintf('%-13s : %5.1f +/- %5.1f (%5.1f, %5.1f)', replace(measure, 'Recording', ''), mmean, mstd, mmin, mmax);
        end
        rightstring = [rightstring ; rowstring];
    end
    
    rightstring = [rightstring ;
                    {sprintf(' ')}                                           ; ...
                    {sprintf('       Mid 50%% Avg +/- Std (Min, Max)')}      ; ...
                    {sprintf('----------------------------------------------')} ];
                
    for a = 1:size(measures,1)
        measure = measures{a};
        column = getColumnForMeasure(measure);
        ddcolumn  = sprintf('Fun_%s',column);
        mid50mean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(5);
        mid50std  = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(6);
        mid50min  = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(7);
        mid50max  = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(8);
        if ismember(measure, 'ActivityRecording')
            rowstring = sprintf('%-13s : %5.0f +/- %5.0f (%5.0f, %5.0f)', replace(measure, 'Recording', ''), mid50mean, mid50std, mid50min, mid50max);
        else
            rowstring = sprintf('%-13s : %5.1f +/- %5.1f (%5.1f, %5.1f)', replace(measure, 'Recording', ''), mid50mean, mid50std, mid50min, mid50max);
        end
        rightstring = [rightstring ; rowstring];
    end
    
    page = 1;
    
    f = figure('Name',sprintf('Patient Summary - ID %d Hosp %s - Page %d', scid, hospital, page));
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0.45, 0, 0.35, 0.92], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
    p = uipanel('Parent', f, 'BorderType', 'none'); 
    p.Title = sprintf('Patient Summary - ID %d (%s) - Page %d', scid, hospital, page); 
    p.TitlePosition = 'centertop';
    p.FontSize = 20;
    p.FontWeight = 'bold';
    sp1 = uicontrol('Parent', p, ... 
                    'Units', 'normalized', ...
                    'OuterPosition', [0.02, 0.45, 0.48, 0.54], ...
                    'Style', 'text', ...
                    'FontName', 'FixedWidth', ...
                    'FontSize', 8, ...
                    'FontWeight', 'bold', ...
                    'HorizontalAlignment', 'left', ...
                    'String', leftstring);
    sp2 = uicontrol('Parent', p, ... 
                    'Units', 'normalized', ...
                    'OuterPosition', [0.5, 0.45, 0.5, 0.54], ...
                    'Style', 'text', ...
                    'FontName', 'FixedWidth', ...
                    'FontSize', 8, ...
                    'FontWeight', 'bold', ...
                    'HorizontalAlignment', 'left', ...
                    'String', rightstring);
    sp3 = uipanel('Parent', p, ...
                  'BorderType', 'none', ...
                  'OuterPosition', [0.0, 0.0, 1.0, 0.45]);
    
    plotsacross = 1;
    plotsdown = 3;
    plotsperpage = plotsacross * plotsdown;
    
    daysfrom = min(spstartdn, hmstartdn);
    daysto   = max(spenddn, hmenddn);
    xl = [daysfrom daysto];
    
    subplot(plotsdown, plotsacross, 1,'Parent',sp3);
    hold on;
    title('Clinic Visits ({\color{green}g}), Admissions ({\color{red}r}), IV Antibiotics ({\color{magenta}m}) and Oral Antibiotics ({\color{cyan}c})');
    xlabel('Days');
    ylabel('Event');
    xlim(xl);
    yl = [0 4];
    ylim(yl);
    linewidth = 10;
    
    cvset     = cdClinicVisits(cdClinicVisits.ID == scid,:);
    cvset.AttendanceDatedn = datenum(cvset.AttendanceDate) - offset - poffset + 1;
    for a = 1:size(cvset,1)
        line( [cvset.AttendanceDatedn(a) cvset.AttendanceDatedn(a) + 1], [3.5, 3.5], 'Color', 'g', 'LineStyle', '-', 'LineWidth', linewidth);
    end
    admset    = cdAdmissions(cdAdmissions.ID == scid,:);
    admset.Admitteddn = datenum(admset.Admitted) - offset - poffset + 1;
    admset.Dischargedn = datenum(admset.Discharge) - offset - poffset + 1;
    admdates = unique([admset.Admitteddn ; admset.Dischargedn]);
    for a = 1:size(admset,1)
        line( [admset.Admitteddn(a) admset.Dischargedn(a)], [2.5, 2.5], 'Color', 'r', 'LineStyle', '-', 'LineWidth', linewidth);
    end
    ivabset   = cdAntibiotics(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, {'IV'}),:);
    ivabset.Startdn = datenum(ivabset.StartDate) - offset - poffset + 1;
    ivabset.Stopdn = datenum(ivabset.StopDate) - offset - poffset + 1;
    ivabgroupeddates = getGroupedIVTreatmentDates(ivabset);
    ivabgroupeddates.Startdn = datenum(ivabgroupeddates.StartDate) - offset - poffset + 1;
    ivabgroupeddates.Stopdn = datenum(ivabgroupeddates.StopDate) - offset - poffset + 1;
    ivabdates = unique([ivabgroupeddates.Startdn ; ivabgroupeddates.Stopdn]);
    for a = 1:size(ivabset,1)
        line( [ivabset.Startdn(a) ivabset.Stopdn(a)], [1.5, 1.5], 'Color', 'm', 'LineStyle', '-', 'LineWidth', linewidth);
    end
    oralabset = cdAntibiotics(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, {'Oral'}),:);
    oralabset.Startdn = datenum(oralabset.StartDate) - offset - poffset + 1;
    oralabset.Stopdn = datenum(oralabset.StopDate) - offset - poffset + 1;
    for a = 1:size(oralabset,1)
        line( [oralabset.Startdn(a) oralabset.Stopdn(a)], [0.5, 0.5], 'Color', 'c', 'LineStyle', '-', 'LineWidth', linewidth);
    end
    hold off;
    
    subplot(plotsdown, plotsacross, 2,'Parent',sp3);
    pcrp = cdCRP(cdCRP.ID == scid,:);
    pcrp.ScaledDateNum = datenum(pcrp.CRPDate) - offset - poffset + 1;
    
    if size(pcrp,1) > 0
        hold on;
        plot(pcrp.ScaledDateNum,pcrp.NumericLevel,'c-o',...
            'LineWidth',1,...
            'MarkerSize',3,...
            'MarkerEdgeColor','m',...
            'MarkerFaceColor','w');
        title('Clinical CRP Level');
        xlabel('Days');
        ylabel('CRP Level');
        xlim(xl);
        rangelimit = setMinYDisplayRangeForMeasure('ClinicalCRP');
        yl = setYDisplayRange(min(pcrp.NumericLevel), max(pcrp.NumericLevel), rangelimit);
        ylim(yl);
        for a = 1:size(ivabdates,1)
            line( [ivabdates(a) ivabdates(a)], yl, 'Color', 'm', 'LineStyle', '--', 'LineWidth', 1)
        end
        for c = 1:size(admdates,1)
            line( [admdates(c) admdates(c)], yl, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1)
        end
        hold off;
    end
    
    

    subplot(plotsdown, plotsacross, 3,'Parent',sp3);
    ppft = cdPFT(cdPFT.ID == scid,:);
    ppft.ScaledDateNum = datenum(ppft.LungFunctionDate) - offset - poffset + 1;
    if size(ppft,1) > 0
        hold on;
        plot(ppft.ScaledDateNum,ppft.CalcFEV1_,'c-o',...
            'LineWidth',1,...
           'MarkerSize',3,...
           'MarkerEdgeColor','m',...
           'MarkerFaceColor','w');
        title('Clinical FEV1%');
        xlabel('Days');
        ylabel('FEV1%');
        xlim(xl);
        rangelimit = setMinYDisplayRangeForMeasure('ClinicalFEV1');
        yl = setYDisplayRange(min(ppft.CalcFEV1_), max(ppft.CalcFEV1_), rangelimit);
        ylim(yl);
        for a = 1:size(ivabdates,1)
            line( [ivabdates(a) ivabdates(a)], yl, 'Color', 'm', 'LineStyle', '--', 'LineWidth', 1)
        end
        for c = 1:size(admdates,1)
            line( [admdates(c) admdates(c)], yl, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1)
        end
        hold off;
    end
    
    imagefilename = sprintf('PatientSummary_ID%d_%s_page%d.png', scid, hospital, page);
    saveas(f,fullfile(basedir, subfolder, imagefilename));
    close(f);
    
    % add page with home measures here
    plotsacross = 2;
    plotsdown = 5;
    plotsperpage = plotsacross * plotsdown;
    page = 2;
    
    f = figure('Name',sprintf('Patient Summary - ID %d Hosp %s - Page %d', scid, hospital, page));
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0.45, 0, 0.35, 0.92], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
    p = uipanel('Parent', f, 'BorderType', 'none'); 
    p.Title = sprintf('Patient Summary - ID %d (%s) - Page %d', scid, hospital, page); 
    p.TitlePosition = 'centertop';
    p.FontSize = 20;
    p.FontWeight = 'bold';
    
    % get all measures so the plots for each appear in a consistent place
    % across all patients
    measures = unique(physdata.RecordingType);
    for a = 1:size(measures,1)
        measure = measures{a};
        column = getColumnForMeasure(measure);
        scdata = physdata(physdata.SmartCareID == scid & ismember(physdata.RecordingType, measure), :);
        scdata = scdata(:, {'SmartCareID','ScaledDateNum' 'Date_TimeRecorded', column});
        scdata.Properties.VariableNames{column} = 'Measurement';
        if size(scdata,1) > 0
            subplot(plotsdown,plotsacross,a,'Parent',p);
            hold on;
            xlim(xl);
            rangelimit = setMinYDisplayRangeForMeasure(measure);
            yl = setYDisplayRange(min(scdata.Measurement), max(scdata.Measurement), rangelimit);
            ylim(yl);
            title(measure);
            xlabel('Days');
            ylabel('Measure');
            plot(scdata.ScaledDateNum, scdata.Measurement, 'y-o',...
                'LineWidth',1,...
                'MarkerSize',3,...
                'MarkerEdgeColor','b',...
                'MarkerFaceColor','g');
            ddcolumn = sprintf('Fun_%s',column);
            mid50mean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(5);
            mid50std = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(6);
            line( xl, [mid50mean mid50mean] , 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1)
            line( xl, [mid50mean-mid50std mid50mean-mid50std] , 'Color', 'black', 'LineStyle', ':', 'LineWidth', 1)
            line( xl, [mid50mean+mid50std mid50mean+mid50std] , 'Color', 'black', 'LineStyle', ':', 'LineWidth', 1)
            for a = 1:size(ivabdates,1)
                line( [ivabdates(a) ivabdates(a)], yl, 'Color', 'm', 'LineStyle', '--', 'LineWidth', 1)
            end
            for c = 1:size(admdates,1)
                line( [admdates(c) admdates(c)], yl, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1)
            end
            hold off;
        end
    end
    imagefilename = sprintf('PatientSummary_ID%d_%s_page%d.png', scid, hospital, page);
    saveas(f,fullfile(basedir, subfolder, imagefilename));
    close(f);
    
end
toc

    
    