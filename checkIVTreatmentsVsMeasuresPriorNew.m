% creates list of oral & IV treatments
%
% 1. collapses down the multiple concurrent/sequential antibiotic treatments
% 2. creates the initial list of unique treatments for a given treatment gap 
% 3. creates stats on number of recorded measures in the 40 days prior to 
% the treatment start. This is used in the next script to filter out 
% examples with very sparse data
% 
% Input:
% ------
% clinical data
% measurements data
%
% Output:
% -------
% ivandmeasures_gap .mat                    stats on #recorded measures
% MeasuresPriorToIVTreatments_gap .xlsx     idem + full measures list

clc; clear; close all;


basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

[studynbr, study, studyfullname] = selectStudy();
[datamatfile, clinicalmatfile, ] = getRawDataFilenamesForStudy(study);
[physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);

tic
% remove Oral treatments & sort by SmartCareID and StopDate
% after further analysis, changed to include oral ab's as well as iv ab's
%idx = find(ismember(cdAntibiotics.Route, {'Oral'}));
%cdAntibiotics(idx,:) = [];
if studynbr == 3
    % extension for non empty reasons
    fprintf('Loading exacerbation reasons\n');
    exreasonsfile = 'climbexacerbationreasons.mat';
    load(fullfile(basedir, subfolder, exreasonsfile), 'exacerbationreasons');
    fprintf('\n');

    ivTreatments               = unique(cdAntibiotics(:,{'ID', 'StudyNumber', 'Hospital', 'StartDate', 'StopDate', 'Route', 'Reason'}));
else
    ivTreatments               = unique(cdAntibiotics(:,{'ID', 'StudyNumber', 'Hospital', 'StartDate', 'StopDate', 'Route'}));
    ivTreatments.Reason(:)     = {'PE'};
end
%ivTreatments.IVDateNum     = datenum(ivTreatments.StartDate) - offset*(ivTreatments.ID >= 16) - tmoffset*(ivTreatments.ID < 16) + 1;
%ivTreatments.IVStopDateNum = datenum(ivTreatments.StopDate)  - offset*(ivTreatments.ID >= 16) - tmoffset*(ivTreatments.ID < 16) + 1;

ivTreatments.IVDateNum     = datenum(ivTreatments.StartDate) - offset + 1;
ivTreatments.IVStopDateNum = datenum(ivTreatments.StopDate)  - offset + 1;
ivTreatments.Type          = zeros(height(ivTreatments),1);

% consider any treatment gaps (stop date to next start date) of less than
% 20 days to be part of the same treatment 
%treatgap = 20;
% now make treatgap a parameter
treatgap = selectTreatmentGap();

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

% first remove all interpolated measures as these aren't part of the raw
% data set
physdata(startsWith(physdata.RecordingType, 'Interp'), :) = [];

physdata = sortrows(physdata, {'SmartCareID', 'DateNum', 'RecordingType'}, 'ascend');
numdays = 40;
nkeycols = 13;
Day = zeros(1,numdays);
Day = array2table(Day);
ivandmeasurestable = table('Size',[1 nkeycols], ...
    'VariableTypes', {'double',      'cell',        'cell',     'datetime',    'double',    'datetime',   'double',        'double',           'double',        'double',            'cell',  'double', 'logical'     }, ...
    'VariableNames', {'SmartCareID', 'StudyNumber', 'Hospital', 'IVStartDate', 'IVDateNum', 'IVStopDate', 'IVStopDateNum', 'DaysWithMeasures', 'TotalMeasures', 'AvgMeasuresPerDay', 'Route', 'Type',   'ExRelated'});
% have to do it this way to get the column type to be a char
ivandmeasurestable.SequentialIntervention(:) = ' ';
ivandmeasurestable = [ivandmeasurestable Day];
for i = 1:40
    ivandmeasurestable.Properties.VariableNames{i + nkeycols + 1} = sprintf('IVminus%d',abs(i-41));
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
rowtoadd.StudyNumber       = ivTreatments.StudyNumber(i);
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
%rowtoadd.ExRelated         = checkTreatmentExRelated(ivTreatments.Reason(i), exacerbationreasons);
rowtoadd.ExRelated         = 1;

if rowtoadd.ExRelated
    exreltxt = '(*)';
else
    exreltxt = '( )';
end

for a = 1:numdays
    colname = sprintf('IVminus%d', a);
    dayidx = (pdcountmtable.SmartCareID == ivTreatments.ID(i)) & (pdcountmtable.DateNum == ivTreatments.IVDateNum(i) - numdays - 1 + a);
    if sum(dayidx,1) > 0
        daymeasures = pdcountmtable.GroupCount(dayidx);
        rowtoadd{1,colname} = daymeasures;
    else
        rowtoadd{1,colname} = 0;
    end
end
fprintf('ID %3d, StartDate %11s, StopDate %11s, Route %4s, Type %d %3s: First Treatment\n', ...
            ivTreatments.ID(i), datestr(ivTreatments.StartDate(i), 1), datestr(ivTreatments.StopDate(i), 1), ivTreatments.Route{i}, ivTreatments.Type(i), exreltxt);

for i = 2:size(ivTreatments,1)
    
    if ivTreatments.ID(i) == ivTreatments.ID(i - 1) && ivTreatments.IVDateNum(i) < rowtoadd.IVStopDateNum + treatgap
        if ivTreatments.IVStopDateNum(i) > rowtoadd.IVStopDateNum
            rowtoadd.IVStopDate        = ivTreatments.StopDate(i);
            rowtoadd.IVStopDateNum     = ivTreatments.IVStopDateNum(i);
            %rowtoadd.ExRelated         = rowtoadd.ExRelated || checkTreatmentExRelated(ivTreatments.Reason(i), exacerbationreasons);
            rowtoadd.ExRelated         = 1;
            if rowtoadd.ExRelated
                exreltxt = '(*)';
            else
                exreltxt = '( )';
            end
            fprintf('ID %3d, StartDate %11s, StopDate %11s, Route %4s, Type %d %3s: Skipping but updating stop date and exrelated\n', ...
                ivTreatments.ID(i), datestr(ivTreatments.StartDate(i), 1), datestr(ivTreatments.StopDate(i), 1), ivTreatments.Route{i}, ivTreatments.Type(i), exreltxt);
        end
    else
        % we've hit a new patient or treatment, so add pending rowtoadd
        % first if it is exacerbation related
        if rowtoadd.ExRelated
            ivandmeasurestable = [ivandmeasurestable ; rowtoadd];
            measuresdetailtable = [measuresdetailtable ; physdata(idx,:)];
            fprintf('ID %3d, StartDate %11s, StopDate %11s, Route %4s, Type %d %3s: ******************************** Adding New Intervention\n', ...
            rowtoadd.SmartCareID, datestr(rowtoadd.IVStartDate, 1), datestr(rowtoadd.IVStopDate, 1), rowtoadd.Route{1}, rowtoadd.Type, exreltxt);
        else
            fprintf('ID %3d, StartDate %11s, StopDate %11s, Route %4s, Type %d %3s: ******************************** Skipping - not exacerbation related\n', ...
            rowtoadd.SmartCareID, datestr(rowtoadd.IVStartDate, 1), datestr(rowtoadd.IVStopDate, 1), rowtoadd.Route{1}, rowtoadd.Type, exreltxt);
        end
        
        % now update rowtoadd with current row
        idx = find(physdata.SmartCareID == ivTreatments.ID(i) & physdata.DateNum < ivTreatments.IVDateNum(i) & physdata.DateNum >= (ivTreatments.IVDateNum(i) - numdays));
        pdcountmtable = varfun(@max, physdata(idx, {'SmartCareID','DateNum'}), 'GroupingVariables', {'SmartCareID', 'DateNum'});
        rowtoadd.SmartCareID       = ivTreatments.ID(i);
        rowtoadd.StudyNumber       = ivTreatments.StudyNumber(i);
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
        %rowtoadd.ExRelated         = checkTreatmentExRelated(ivTreatments.Reason(i), exacerbationreasons);
        rowtoadd.ExRelated         = 1;
        if rowtoadd.ExRelated
            exreltxt = '(*)';
        else
            exreltxt = '( )';
        end
        for a = 1:numdays
            colname = sprintf('IVminus%d', a);
            dayidx = (pdcountmtable.SmartCareID == ivTreatments.ID(i)) & (pdcountmtable.DateNum == ivTreatments.IVDateNum(i) - numdays - 1 + a);
            if sum(dayidx,1) > 0
                daymeasures = pdcountmtable.GroupCount(dayidx);
                rowtoadd{1,colname} = daymeasures;
            else
                rowtoadd{1,colname} = 0;
            end
        end
        fprintf('ID %3d, StartDate %11s, StopDate %11s, Route %4s, Type %d %3s: New Treatment\n', ...
            ivTreatments.ID(i), datestr(ivTreatments.StartDate(i), 1), datestr(ivTreatments.StopDate(i), 1), ivTreatments.Route{i}, ivTreatments.Type(i), exreltxt);
    end
end
if rowtoadd.ExRelated
    ivandmeasurestable = [ivandmeasurestable ; rowtoadd];
    measuresdetailtable = [measuresdetailtable ; physdata(idx,:)];
    fprintf('ID %3d, StartDate %11s, StopDate %11s, Route %4s, Type %d %3s: ******************************** Adding Final Intervention\n', ...
    rowtoadd.SmartCareID, datestr(rowtoadd.IVStartDate, 1), datestr(rowtoadd.IVStopDate, 1), rowtoadd.Route{1}, rowtoadd.Type, exreltxt);
else
    fprintf('ID %3d, StartDate %11s, StopDate %11s, Route %4s, Type %d %3s: ******************************** Skipping - not exacerbation related\n', ...
    rowtoadd.SmartCareID, datestr(rowtoadd.IVStartDate, 1), datestr(rowtoadd.IVStopDate, 1), rowtoadd.Route{1}, rowtoadd.Type, exreltxt);
end



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
outputfilename = sprintf('%sivandmeasures_gap%d.mat', study, treatgap);

fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder, outputfilename), 'ivandmeasurestable', 'treatgap');

%ivandmeasurestable.IVDateNum = [];
measuresdetailtable.ScaledDateNum = [];
measuresdetailtable.DateNum = [];

fprintf('Saving results to excel\n');

basedir = setBaseDir();
subfolder = 'ExcelFiles';
outputfilename = sprintf('%sMeasuresPriorToIVTreatments_gap%d.xlsx', study, treatgap);
summarysheet = 'SummaryByIVTreatment';
detailsheet = 'MeasuresDetail';

writetable(ivandmeasurestable,  fullfile(basedir, subfolder, outputfilename), 'Sheet', summarysheet);
writetable(measuresdetailtable, fullfile(basedir, subfolder, outputfilename), 'Sheet', detailsheet);

toc
fprintf('\n');
    
    
    