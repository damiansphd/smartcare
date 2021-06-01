clc; clear; close all;

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

[studynbr, study, ~] = selectStudy();
[datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
[physdata, offset, physdata_predateoutlierhandling] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);

% Tristan's function to harmonise drug therapy namings - temporary until 
% REDcap is active
cdDrugTherapy.DrugTherapyType = cleanDrugTherapyNamings(cdDrugTherapy.DrugTherapyType);

tic
fprintf('Loading demographic data by patient\n');
load(fullfile(basedir, subfolder, demographicsmatfile), 'demographicstable', 'overalltable');
toc
fprintf('\n');

subfolder = sprintf('Plots/%s', study);
if ~exist(strcat(basedir, subfolder), 'dir')
    mkdir(strcat(basedir, subfolder));
end

runmode = input('Which patients to run for 1) Those with enough data 2) Those without enough data ?');
if runmode ~= 1 & runmode ~= 2
    fprintf('Invalid entry')
    return;
end

if runmode == 1
    patientlist = unique(physdata.SmartCareID);
elseif runmode == 2
    goodpatients = unique(physdata.SmartCareID);
    patientlist = unique(physdata_predateoutlierhandling.SmartCareID(~ismember(physdata_predateoutlierhandling.SmartCareID, goodpatients)));
    physdata = physdata_predateoutlierhandling;
end

patientoffsets = getPatientOffsets(physdata);
cvcol   = [0.94  0.52  0.15];
admcol  = [0.694 0.627 0.78]; 
ivcol   = [1     0     0   ];
oralcol = [1     0.85  0   ];
trplcol = [0     1     0   ];
drugcol = [0     0.8   0.6 ];

for i = 1:size(patientlist,1)
%for i = 59:59
%for i = 1:4
    tic
    scid       = patientlist(i);
    fprintf('Creating patient summary for patient %d\n', scid);
    poffset    = patientoffsets.PatientOffset(patientoffsets.SmartCareID == scid);
    studyid   = cdPatient.StudyNumber{cdPatient.ID == scid};
    hospital   = cdPatient.Hospital{cdPatient.ID == scid};
    sex        = cdPatient.Sex{cdPatient.ID == scid};
    spstart    = cdPatient.StudyDate(cdPatient.ID == scid);
    spstartdn  = datenum(spstart) - offset - poffset + 1;
    spend      = cdPatient.StudyDate(cdPatient.ID == scid)+days(183);
    spenddn    = spstartdn + 183;
    if studynbr == 3 || studynbr == 4
        spendstatus = ' ';
    else
        spendstatus = cdEndStudy.EndOfStudyReason{cdEndStudy.ID == scid};
    end
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
                    {sprintf('Study ID         :  %s', studyid)}                                                         ; ...
                    {sprintf('Hospital         :  %s', hospital)}                                                         ; ...
                    {sprintf('Study Start Date :  %s', datestr(spstart,1))}                                               ; ...
                    {sprintf('Study End Date   :  %s', datestr((spend),1))}                                               ; ...
                    {sprintf('Study Status     :  %s', spendstatus)}                                                      ; ...
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
    for m = 1:size(microbiology,1)
        rowstring = sprintf('%s', microbiology{m});
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
    for m = 1:size(measures,1)
        measure = measures{m};
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
                
    for m = 1:size(measures,1)
        measure = measures{m};
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
    
    cplotsacross = 1;
    cplotsdown = 3;
    
    mplotsacross = 1;
    mplotsdown = 6;
    mplotsperpage = mplotsacross * mplotsdown;
    
    measures = unique(physdata.RecordingType);
    npages = ceil(size(measures, 1) / mplotsperpage) + 1;
    page = 1;
    filenameprefix = sprintf('%s-Patient Summary - ID %d (%s) Hosp %s', study, scid, studyid, hospital);
    imagefilename = sprintf('%s - Page %d of %d', filenameprefix, page, npages);
    [f, p] = createFigureAndPanel(imagefilename, 'Portrait', 'a4');
    
    sp1 = uicontrol('Parent', p, ... 
                    'Units', 'normalized', ...
                    'OuterPosition', [0.02, 0.45, 0.48, 0.54], ...
                    'Style', 'text', ...
                    'FontName', 'FixedWidth', ...
                    'FontSize', 8, ...
                    'FontWeight', 'bold', ...
                    'HorizontalAlignment', 'left', ...
                    'BackgroundColor', 'white', ...
                    'String', leftstring);
    sp2 = uicontrol('Parent', p, ... 
                    'Units', 'normalized', ...
                    'OuterPosition', [0.5, 0.45, 0.5, 0.54], ...
                    'Style', 'text', ...
                    'FontName', 'FixedWidth', ...
                    'FontSize', 8, ...
                    'FontWeight', 'bold', ...
                    'HorizontalAlignment', 'left', ...
                    'BackgroundColor', 'white', ...
                    'String', rightstring);
    sp3 = uipanel('Parent', p, ...
                  'BorderType', 'none', ...
                  'BackgroundColor', 'white', ...
                  'OuterPosition', [0.0, 0.0, 1.0, 0.45]);
    
    
    
    daysfrom = min(spstartdn, hmstartdn) - 14;
    daysto   = max(spenddn, hmenddn) + 14;
    xl = [daysfrom daysto];
    
    ax = subplot(cplotsdown, cplotsacross, 1,'Parent',sp3);
    hold on;
    title(ax, 'Clinic Visits ({\color[rgb]{0.5 0.33 0}br}), Admissions ({\color[rgb]{0.694 0.627 0.78}p}), IV ({\color[rgb]{1 0 0}r}) and Oral ({\color[rgb]{1 0.85 0}y}) Antibiotics, Triple Therapy ({\color[rgb]{0 1 0}g}) and Other Therapies ({\color[rgb]{0 0.8 0.6}g})');
    xlabel(ax, 'Days');
    ylabel(ax, 'Event');
    xlim(xl);
    yl = [0 5];
    ylim(yl);
    linewidth = 8;
    
    cvset     = cdClinicVisits(cdClinicVisits.ID == scid,:);
    cvset.AttendanceDatedn = datenum(cvset.AttendanceDate) - offset - poffset + 1;
    for a = 1:size(cvset,1)
        line(ax, [cvset.AttendanceDatedn(a) cvset.AttendanceDatedn(a) + 1], [4.5, 4.5], 'Color', cvcol, 'LineStyle', '-', 'LineWidth', linewidth);
    end
    admset    = cdAdmissions(cdAdmissions.ID == scid,:);
    admset.Admitteddn = datenum(admset.Admitted) - offset - poffset + 1;
    admset.Dischargedn = datenum(admset.Discharge) - offset - poffset + 1;
    admdates = unique([admset.Admitteddn ; admset.Dischargedn]);
    for a = 1:size(admset,1)
        line(ax, [admset.Admitteddn(a) admset.Dischargedn(a)], [3.5, 3.5], 'Color', admcol, 'LineStyle', '-', 'LineWidth', linewidth);
    end
    ivabset   = cdAntibiotics(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, {'IV'}),:);
    ivabset.Startdn = datenum(ivabset.StartDate) - offset - poffset + 1;
    ivabset.Stopdn = datenum(ivabset.StopDate) - offset - poffset + 1;
    for a = 1:size(ivabset,1)
        line(ax, [ivabset.Startdn(a) ivabset.Stopdn(a)], [2.5, 2.5], 'Color', ivcol, 'LineStyle', '-', 'LineWidth', linewidth);
    end
    oralabset = cdAntibiotics(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, {'Oral'}),:);
    oralabset.Startdn = datenum(oralabset.StartDate) - offset - poffset + 1;
    oralabset.Stopdn = datenum(oralabset.StopDate) - offset - poffset + 1;
    for a = 1:size(oralabset,1)
        line(ax, [oralabset.Startdn(a) oralabset.Stopdn(a)], [1.5, 1.5], 'Color', oralcol, 'LineStyle', '-', 'LineWidth', linewidth);
    end
    trplset = cdDrugTherapy(cdDrugTherapy.ID == scid & ismember(cdDrugTherapy.DrugTherapyType, {'Triple Therapy'}),:);
    trplset.Startdn = datenum(trplset.DrugTherapyStartDate) - offset - poffset + 1;
    for a = 1:size(trplset,1)
        line(ax, [trplset.Startdn(a) trplset.Startdn(a) + 1], [0.5, 0.5], 'Color', trplcol, 'LineStyle', '-', 'LineWidth', linewidth);
    end
    drugset = cdDrugTherapy(cdDrugTherapy.ID == scid & ~ismember(cdDrugTherapy.DrugTherapyType, {'Triple Therapy'}),:);
    drugset.Startdn = datenum(drugset.DrugTherapyStartDate) - offset - poffset + 1;
    for a = 1:size(drugset,1)
        line(ax, [drugset.Startdn(a) drugset.Startdn(a) + 1], [0.5, 0.5], 'Color', drugcol, 'LineStyle', '-', 'LineWidth', linewidth);
    end
    hold off;
    
    ax = subplot(cplotsdown, cplotsacross, 2,'Parent',sp3);
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
        
        title(ax, 'Clinical CRP Level');
        xlabel(ax, 'Days');
        ylabel(ax, 'CRP Level');
        xlim(xl);
        rangelimit = setMinYDisplayRangeForMeasure('ClinicalCRP');
        yl = setYDisplayRange(min(pcrp.NumericLevel), max(pcrp.NumericLevel), rangelimit);
        ylim(yl);
        for a = 1:size(ivabset,1)
            fill(ax, [ivabset.Startdn(a) ivabset.Stopdn(a) ivabset.Stopdn(a) ivabset.Startdn(a)], ...
                      [yl(1) yl(1) yl(2) yl(2)], ivcol, 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        end
        for a = 1:size(oralabset,1)
            fill(ax, [oralabset.Startdn(a) oralabset.Stopdn(a) oralabset.Stopdn(a) oralabset.Startdn(a)], ...
                      [yl(1) yl(1) yl(2) yl(2)], oralcol, 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        end
        for a = 1:size(trplset,1)
            fill(ax, [trplset.Startdn(a), trplset.Startdn(a) + 1, trplset.Startdn(a) + 1, trplset.Startdn(a)] , ...
                      [yl(1) yl(1) yl(2) yl(2)], trplcol, 'EdgeColor', 'none');
        end
        for a = 1:size(drugset,1)
            fill(ax, [drugset.Startdn(a), drugset.Startdn(a) + 1, drugset.Startdn(a) + 1, drugset.Startdn(a)], ...
                      [yl(1) yl(1) yl(2) yl(2)], drugcol, 'EdgeColor', 'none');
        end
        hold off;
    end
    
    ax = subplot(cplotsdown, cplotsacross, 3,'Parent',sp3);
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
        title(ax, 'Clinical FEV1%');
        xlabel(ax, 'Days');
        ylabel(ax, 'FEV1%');
        xlim(xl);
        rangelimit = setMinYDisplayRangeForMeasure('ClinicalFEV1');
        yl = setYDisplayRange(min(ppft.CalcFEV1_), max(ppft.CalcFEV1_), rangelimit);
        ylim(yl);
        for a = 1:size(ivabset,1)
            fill(ax, [ivabset.Startdn(a) ivabset.Stopdn(a) ivabset.Stopdn(a) ivabset.Startdn(a)], ...
                      [yl(1) yl(1) yl(2) yl(2)], ivcol, 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        end
        for a = 1:size(oralabset,1)
            fill(ax, [oralabset.Startdn(a) oralabset.Stopdn(a) oralabset.Stopdn(a) oralabset.Startdn(a)], ...
                      [yl(1) yl(1) yl(2) yl(2)], oralcol, 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        end
        for a = 1:size(trplset,1)
            fill(ax, [trplset.Startdn(a), trplset.Startdn(a) + 1, trplset.Startdn(a) + 1, trplset.Startdn(a)] , ...
                      [yl(1) yl(1) yl(2) yl(2)], trplcol, 'EdgeColor', 'none');
        end
        for a = 1:size(drugset,1)
            fill(ax, [drugset.Startdn(a), drugset.Startdn(a) + 1, drugset.Startdn(a) + 1, drugset.Startdn(a)], ...
                      [yl(1) yl(1) yl(2) yl(2)], drugcol, 'EdgeColor', 'none');
        end
        hold off;
    end
    
    savePlotInDir(f, imagefilename, subfolder);
    close(f);
    page = page + 1;
    fprintf('Next Page\n');
    
    imagefilename = sprintf('%s - Page %d of %d', filenameprefix, page, npages);
    [f, p] = createFigureAndPanel(imagefilename, 'Portrait', 'a4');
    
    % plots for home measures on remaining pages
    
    
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
            ax = subplot(mplotsdown, mplotsacross, m - (page-2) * mplotsperpage,'Parent',p);
            hold on;
            xlim(xl);
            rangelimit = setMinYDisplayRangeForMeasure(measure);
            yl = setYDisplayRange(min(scdata.Measurement), max(scdata.Measurement), rangelimit);
            ylim(yl);
            title(ax, replace(measure, 'Recording', ''));
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
            
            ddcolumn = sprintf('Fun_%s',column);
            mid50mean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(5);
            mid50std = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(6);
            line( xl, [mid50mean mid50mean] , 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1)
            line( xl, [mid50mean-mid50std mid50mean-mid50std] , 'Color', 'black', 'LineStyle', ':', 'LineWidth', 1)
            line( xl, [mid50mean+mid50std mid50mean+mid50std] , 'Color', 'black', 'LineStyle', ':', 'LineWidth', 1)
            
            for a = 1:size(ivabset,1)
                fill(ax, [ivabset.Startdn(a) ivabset.Stopdn(a) ivabset.Stopdn(a) ivabset.Startdn(a)], ...
                          [yl(1) yl(1) yl(2) yl(2)], ivcol, 'FaceAlpha', '0.1', 'EdgeColor', 'none');
            end
            for a = 1:size(oralabset,1)
                fill(ax, [oralabset.Startdn(a) oralabset.Stopdn(a) oralabset.Stopdn(a) oralabset.Startdn(a)], ...
                          [yl(1) yl(1) yl(2) yl(2)], oralcol, 'FaceAlpha', '0.1', 'EdgeColor', 'none');
            end
            for a = 1:size(trplset,1)
            fill(ax, [trplset.Startdn(a), trplset.Startdn(a) + 1, trplset.Startdn(a) + 1, trplset.Startdn(a)] , ...
                         [yl(1) yl(1) yl(2) yl(2)], trplcol, 'EdgeColor', 'none');
            end
            for a = 1:size(drugset,1)
                fill(ax, [drugset.Startdn(a), drugset.Startdn(a) + 1, drugset.Startdn(a) + 1, drugset.Startdn(a)], ...
                         [yl(1) yl(1) yl(2) yl(2)], drugcol, 'EdgeColor', 'none');
            end
            hold off;
        end
        
        if round(m/mplotsperpage) == m/mplotsperpage
            savePlotInDir(f, imagefilename, subfolder);
            close(f);
            page = page + 1;
            fprintf('Next Page\n');
            imagefilename = sprintf('%s - Page %d of %d', filenameprefix, page, npages);
            [f, p] = createFigureAndPanel(imagefilename, 'Portrait', 'a4');
        end
    end
    
    if exist('f', 'var')
        savePlotInDir(f, imagefilename, subfolder);
        close(f);
    end

    toc
    
end

    
    