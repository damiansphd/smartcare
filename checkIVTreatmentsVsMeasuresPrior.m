clc; clear; close all;

tic

basedir = './';
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'clinicaldata.mat';
scmatfile = 'smartcaredata.mat';

fprintf('Loading Clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading SmartCare measurement data\n');
load(fullfile(basedir, subfolder, scmatfile));
toc

tic
% remove Oral treatments & sort by SmartCareID and StopDate
idx = find(ismember(cdAntibiotics.Route, {'Oral'}));
cdAntibiotics(idx,:) = [];
ivTreatments = unique(cdAntibiotics(:,{'ID', 'Hospital', 'StartDate'}));
ivTreatments.IVDateNum = datenum(ivTreatments.StartDate) - offset + 1;

% use the version of physdata before handling dateoutliers
%physdata = physdata_predateoutlierhandling;

physdata = sortrows(physdata, {'SmartCareID', 'DateNum', 'RecordingType'}, 'ascend');
numdays = 40;
Day = zeros(1,numdays);
Day = array2table(Day);
ivandmeasurestable = table('Size',[1 7], ...
    'VariableTypes', {'double',       'cell',     'datetime',    'double',     'double',            'double',         'double'}, ...
    'VariableNames', {'SmartCareID', 'Hospital', 'IVStartDate', 'IVDateNum', 'DaysWithMeasures', 'TotalMeasures', 'AvgMeasuresPerDay'});
ivandmeasurestable = [ivandmeasurestable Day];
for i = 1:40
    ivandmeasurestable.Properties.VariableNames{i+7} = sprintf('IVminus%d',abs(i-41));
end
rowtoadd = ivandmeasurestable;
ivandmeasurestable(1,:) = [];

measuresdetailtable = physdata(1:1,:);
measuresdetailtable = [];

oldid = 0;
oldstartdn = 0;
for i = 1:size(ivTreatments,1)
    scid = ivTreatments.ID(i);
    hospital = ivTreatments.Hospital(i);
    startdate = ivTreatments.StartDate(i);
    startdn = ivTreatments.IVDateNum(i);
    
    if (scid ~= oldid | startdn > oldstartdn + 25)
        idx = find(physdata.SmartCareID == scid & physdata.DateNum < startdn & physdata.DateNum >= (startdn - numdays));
        pdcountmtable = varfun(@max, physdata(idx, {'SmartCareID','DateNum'}), 'GroupingVariables', {'SmartCareID', 'DateNum'});
    
        rowtoadd.SmartCareID = scid;
        rowtoadd.Hospital = hospital;
        rowtoadd.IVStartDate = startdate;
        rowtoadd.IVDateNum = startdn;
        rowtoadd.DaysWithMeasures = size(find(pdcountmtable.GroupCount>0),1);
        rowtoadd.TotalMeasures = sum(pdcountmtable.GroupCount);
        rowtoadd.AvgMeasuresPerDay = rowtoadd.TotalMeasures/numdays;
    
        for a = 1:numdays
            colname = sprintf('IVminus%d', a);
            dayidx = find(pdcountmtable.SmartCareID == scid & pdcountmtable.DateNum == startdn-numdays-1+a);
            if size(dayidx,1) > 0
                daymeasures = pdcountmtable.GroupCount(find(pdcountmtable.SmartCareID == scid & pdcountmtable.DateNum == startdn-numdays-1+a));
                rowtoadd{1,colname} = daymeasures;
            else
                rowtoadd{1,colname} = 0;
            end
        end
    
        ivandmeasurestable = [ivandmeasurestable ; rowtoadd];
        measuresdetailtable = [measuresdetailtable ; physdata(idx,:)];
    end
    
    oldid = scid;
    oldstartdn = startdn;
end
toc
fprintf('\n');

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
outputfilename = 'ivandmeasures.mat';

fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder, outputfilename), 'ivandmeasurestable');

ivandmeasurestable.IVDateNum = [];
measuresdetailtable.ScaledDateNum = [];
measuresdetailtable.DateNum = [];

fprintf('Saving results to excel\n');

basedir = './';
subfolder = 'ExcelFiles';
outputfilename = 'MeasuresPriorToIVTreatments.xlsx';
summarysheet = 'SummaryByIVTreatment';
detailsheet = 'MeasuresDetail';

writetable(ivandmeasurestable,        fullfile(basedir, subfolder, outputfilename), 'Sheet', summarysheet);
writetable(measuresdetailtable, fullfile(basedir, subfolder, outputfilename), 'Sheet', detailsheet);

toc
fprintf('\n');
    
    
    