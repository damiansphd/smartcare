clc; clear; close all;

studynbr = input('Enter Study to run for (1 = SmartCare, 2 = TeleMed, 3 = joint): ');

if studynbr == 1
    study = 'SC';
    clinicalmatfile = 'clinicaldata.mat';
    datamatfile = 'smartcaredata.mat';
elseif studynbr == 2
    study = 'TM';
    clinicalmatfile = 'telemedclinicaldata.mat';
    datamatfile = 'telemeddata.mat';
elseif studynbr == 3
    study = 'SC+TM';
    clinicalmatfile = 'clinicaldata.mat';
    datamatfile = 'smartcaredata.mat';
else
    fprintf('Invalid study\n');
    return;
end

tmoffset = 0;

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
fprintf('Loading clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading measurement data\n');
load(fullfile(basedir, subfolder, datamatfile));
if studynbr == 3
    clinicalmatfile = 'telemedclinicaldata.mat';
    datamatfile = 'telemeddata.mat';
    load(fullfile(basedir, subfolder, clinicalmatfile));
    load(fullfile(basedir, subfolder, datamatfile));
end
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

if studynbr == 3
    physdata = [ physdata ; tmphysdata ];
    cdPatient = [ cdPatient ; tmPatient];
    cdMicrobiology = [ cdMicrobiology ; tmMicrobiology];
    cdAntibiotics = [ cdAntibiotics ; tmAntibiotics];
    cdAdmissions = [ cdAdmissions ; tmAdmissions];
    cdPFT = [cdPFT ; tmPFT ];
    cdCRP = [cdCRP ; tmCRP];
    cdClinicVisits = [cdClinicVisits ; tmClinicVisits];
    cdEndStudy = [cdEndStudy ; tmEndStudy];
end

tic
% remove Oral treatments & sort by SmartCareID and StopDate
% after further analysis, changed to include oral ab's as well as iv ab's
%idx = find(ismember(cdAntibiotics.Route, {'Oral'}));
%cdAntibiotics(idx,:) = [];
ivTreatments               = unique(cdAntibiotics(:,{'ID', 'Hospital', 'StartDate', 'StopDate', 'Route'}));
ivTreatments.IVDateNum     = datenum(ivTreatments.StartDate) - offset*(ivTreatments.ID >= 16) - tmoffset*(ivTreatments.ID < 16) + 1;
ivTreatments.IVStopDateNum = datenum(ivTreatments.StopDate)  - offset*(ivTreatments.ID >= 16) - tmoffset*(ivTreatments.ID < 16) + 1;
ivTreatments.Type          = zeros(height(ivTreatments),1);

% consider any treatment gaps (stop date to next start date) of less than
% 20 days to be part of the same treatment
treatgap = 20;

% counting and labelling - IVO = 1 , OO = 2, IVPBO = 3
oldid = 0;
oldstopdn = 0;
ooandivpbo = 0;
ivo = 0;
ivpbo = 0;
for i = 1:size(ivTreatments,1)
    scid = ivTreatments.ID(i);
    hospital = ivTreatments.Hospital(i);
    startdate = ivTreatments.StartDate(i);
    startdn = ivTreatments.IVDateNum(i);
    stopdn  = ivTreatments.IVStopDateNum(i);
    type = ivTreatments.Route(i);
    
    if ( (scid ~= oldid || startdn > oldstopdn + treatgap)  )
        if isequal(type,cellstr('Oral'))
            ooandivpbo = ooandivpbo + 1;
            ivTreatments.Type(i) = 2;
        else
            ivo = ivo+1;
            ivTreatments.Type(i) = 1;
        end
    else
        if oldid == scid && ivTreatments.Type(i - 1) == 2 && (startdn < oldstopdn + treatgap)
            ivpbo = ivpbo + 1;
            ivTreatments.Type(i - 1) = 3;
            ivTreatments.Route(i - 1) = {'IVPBO'};
            ivTreatments.Type(i) = 4;
        end
    end
    
    oldid = scid;
    oldstopdn = stopdn;
end
oo = ooandivpbo - ivpbo/2 ;

%end of counting & labelling

% idx = find(ismember(ivTreatments.Type,[0 1 2 4]));
% ivTreatments(idx,:) = [];
% ivTreatments = sortrows(ivTreatments,{'Type'});

physdata = sortrows(physdata, {'SmartCareID', 'DateNum', 'RecordingType'}, 'ascend');
numdays = 40;
nkeycols = 12;
Day = zeros(1,numdays);
Day = array2table(Day);
ivandmeasurestable = table('Size',[1 nkeycols-1], ...
    'VariableTypes', {'double',      'cell',     'datetime',    'double',    'datetime',   'double',        'double',           'double',        'double',            'cell',  'double'}, ...
    'VariableNames', {'SmartCareID', 'Hospital', 'IVStartDate', 'IVDateNum', 'IVStopDate', 'IVStopDateNum', 'DaysWithMeasures', 'TotalMeasures', 'AvgMeasuresPerDay', 'Route', 'Type'});
% have to do it this way to get the column type to be a char
ivandmeasurestable.SequentialIntervention(:) = ' ';
ivandmeasurestable = [ivandmeasurestable Day];
for i = 1:40
    ivandmeasurestable.Properties.VariableNames{i+nkeycols} = sprintf('IVminus%d',abs(i-41));
end
rowtoadd = ivandmeasurestable;
ivandmeasurestable(1,:) = [];

measuresdetailtable = physdata(1,:);
measuresdetailtable = [];


i = 1;

% update rowtoadd with first treatment
idx = find(physdata.SmartCareID == ivTreatments.ID(i) & physdata.DateNum < ivTreatments.IVDateNum(i) & physdata.DateNum >= (ivTreatments.IVDateNum(i) - numdays));
pdcountmtable = varfun(@max, physdata(idx, {'SmartCareID','DateNum'}), 'GroupingVariables', {'SmartCareID', 'DateNum'});
rowtoadd.SmartCareID       = ivTreatments.ID(i);
rowtoadd.Hospital          = ivTreatments.Hospital(i);
rowtoadd.IVStartDate       = ivTreatments.StartDate(i);
rowtoadd.IVDateNum         = ivTreatments.IVDateNum(i);
rowtoadd.IVStopDate        = ivTreatments.StopDate(i);
rowtoadd.IVStopDateNum     = ivTreatments.IVStopDateNum(i);
rowtoadd.DaysWithMeasures  = size(find(pdcountmtable.GroupCount>0),1);
rowtoadd.TotalMeasures     = sum(pdcountmtable.GroupCount);
rowtoadd.AvgMeasuresPerDay = rowtoadd.TotalMeasures/numdays;
rowtoadd.Route             = ivTreatments.Route(i);
rowtoadd.Type              = ivTreatments.Type(i);
for a = 1:numdays
    colname = sprintf('IVminus%d', a);
    dayidx = (pdcountmtable.SmartCareID == ivTreatments.ID(i)) & (pdcountmtable.DateNum == ivTreatments.IVDateNum(i) - numdays - 1 + a);
    if size(dayidx,1) > 0
        daymeasures = pdcountmtable.GroupCount(dayidx);
        rowtoadd{1,colname} = daymeasures;
    else
        rowtoadd{1,colname} = 0;
    end
end
fprintf('ID %3d, StartDate %11s, StopDate %11s, Route %4s, Type %d: First Treatment\n', ...
                ivTreatments.ID(i), datestr(ivTreatments.StartDate(i), 1), datestr(ivTreatments.StopDate(i), 1), ivTreatments.Route{i}, ivTreatments.Type(i));

for i = 2:size(ivTreatments,1)
    
    if ivTreatments.ID(i) == ivTreatments.ID(i - 1) && ivTreatments.IVDateNum(i) < rowtoadd.IVStopDateNum + treatgap
        if ivTreatments.IVStopDateNum(i) > rowtoadd.IVStopDateNum
            rowtoadd.IVStopDate        = ivTreatments.StopDate(i);
            rowtoadd.IVStopDateNum     = ivTreatments.IVStopDateNum(i);
            fprintf('ID %3d, StartDate %11s, StopDate %11s, Route %4s, Type %d: Skipping but updating stop date\n', ...
                ivTreatments.ID(i), datestr(ivTreatments.StartDate(i), 1), datestr(ivTreatments.StopDate(i), 1), ivTreatments.Route{i}, ivTreatments.Type(i));
        else
            fprintf('ID %3d, StartDate %11s, StopDate %11s, Route %4s, Type %d: Skipping\n', ...
                ivTreatments.ID(i), datestr(ivTreatments.StartDate(i), 1), datestr(ivTreatments.StopDate(i), 1), ivTreatments.Route{i}, ivTreatments.Type(i));
        end
    else
        % we've hit a new patient or treatment, so add pending rowtoadd
        % first
        ivandmeasurestable = [ivandmeasurestable ; rowtoadd];
        measuresdetailtable = [measuresdetailtable ; physdata(idx,:)]; 
        fprintf('ID %3d, StartDate %11s, StopDate %11s, Route %4s, Type %d: ******************************** Adding New Intervention\n', ...
            rowtoadd.SmartCareID, datestr(rowtoadd.IVStartDate, 1), datestr(rowtoadd.IVStopDate, 1), rowtoadd.Route{1}, rowtoadd.Type);
        
        % now update rowtoadd with current row
        idx = find(physdata.SmartCareID == ivTreatments.ID(i) & physdata.DateNum < ivTreatments.IVDateNum(i) & physdata.DateNum >= (ivTreatments.IVDateNum(i) - numdays));
        pdcountmtable = varfun(@max, physdata(idx, {'SmartCareID','DateNum'}), 'GroupingVariables', {'SmartCareID', 'DateNum'});
        rowtoadd.SmartCareID       = ivTreatments.ID(i);
        rowtoadd.Hospital          = ivTreatments.Hospital(i);
        rowtoadd.IVStartDate       = ivTreatments.StartDate(i);
        rowtoadd.IVDateNum         = ivTreatments.IVDateNum(i);
        rowtoadd.IVStopDate        = ivTreatments.StopDate(i);
        rowtoadd.IVStopDateNum     = ivTreatments.IVStopDateNum(i);
        rowtoadd.DaysWithMeasures  = size(find(pdcountmtable.GroupCount>0),1);
        rowtoadd.TotalMeasures     = sum(pdcountmtable.GroupCount);
        rowtoadd.AvgMeasuresPerDay = rowtoadd.TotalMeasures/numdays;
        rowtoadd.Route             = ivTreatments.Route(i);
        rowtoadd.Type              = ivTreatments.Type(i);
        for a = 1:numdays
            colname = sprintf('IVminus%d', a);
            dayidx = (pdcountmtable.SmartCareID == ivTreatments.ID(i)) & (pdcountmtable.DateNum == ivTreatments.IVDateNum(i) - numdays - 1 + a);
            if size(dayidx,1) > 0
                daymeasures = pdcountmtable.GroupCount(dayidx);
                if size(daymeasures, 1) >= 1
                    rowtoadd{1,colname} = daymeasures;
                else
                    rowtoadd{1,colname} = 0;
                end
            else
                rowtoadd{1,colname} = 0;
            end
        end
        fprintf('ID %3d, StartDate %11s, StopDate %11s, Route %4s, Type %d: New Treatment\n', ...
            ivTreatments.ID(i), datestr(ivTreatments.StartDate(i), 1), datestr(ivTreatments.StopDate(i), 1), ivTreatments.Route{i}, ivTreatments.Type(i));
    end
end
ivandmeasurestable = [ivandmeasurestable ; rowtoadd];
measuresdetailtable = [measuresdetailtable ; physdata(idx,:)]; 
fprintf('ID %3d, StartDate %11s, StopDate %11s, Route %4s, Type %d: ******************************** Adding Final Intervention\n', ...
    rowtoadd.SmartCareID, datestr(rowtoadd.IVStartDate, 1), datestr(rowtoadd.IVStopDate, 1), rowtoadd.Route{1}, rowtoadd.Type);

% hardcode definitions for data window and mean window here - need to
% change if these model parameters are changed at any point
align_wind = 25;
meanwindow = 10;
fprintf('\n');
fprintf('Checking integrity of results and setting sequential intervention flag\n');
for i = 2:size(ivandmeasurestable, 1)
    if (ivandmeasurestable.SmartCareID(i) == ivandmeasurestable.SmartCareID(i-1) ...
                && ivandmeasurestable.IVDateNum(i) < ivandmeasurestable.IVStopDateNum(i-1))
            fprintf('*** For patient %d, Start date of current row (%d) is less than the stop date of the prior row (%d) - investigate further ***\n', ...
                ivandmeasurestable.SmartCareID(i), ivandmeasurestable.IVDateNum(i), ivandmeasurestable.IVStopDateNum(i-1));
    end
    if (ivandmeasurestable.SmartCareID(i) == ivandmeasurestable.SmartCareID(i-1) ...
                && ivandmeasurestable.IVDateNum(i) - ivandmeasurestable.IVStopDateNum(i-1) < (align_wind + meanwindow))
            ivandmeasurestable.SequentialIntervention(i) = 'Y';
    end
end

toc
fprintf('\n');

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%sivandmeasuresNEW.mat', study);

fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder, outputfilename), 'ivandmeasurestable');

%ivandmeasurestable.IVDateNum = [];
measuresdetailtable.ScaledDateNum = [];
measuresdetailtable.DateNum = [];

fprintf('Saving results to excel\n');

basedir = setBaseDir();
subfolder = 'ExcelFiles';
outputfilename = sprintf('%sMeasuresPriorToIVTreatmentsNEW.xlsx', study);
summarysheet = 'SummaryByIVTreatment';
detailsheet = 'MeasuresDetail';

writetable(ivandmeasurestable,        fullfile(basedir, subfolder, outputfilename), 'Sheet', summarysheet);
writetable(measuresdetailtable, fullfile(basedir, subfolder, outputfilename), 'Sheet', detailsheet);

toc
fprintf('\n');
    
    
    