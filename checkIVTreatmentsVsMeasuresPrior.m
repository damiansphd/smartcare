clc; clear; close all;

tic
fprintf('Loading Clinical data\n');
load('clinicaldata.mat');
fprintf('Loading SmartCare measurement data\n');
load('smartcaredata.mat');
toc

outputfilename = 'MeasuresPriorToIVTreatments.xlsx';
summarysheet = 'SummaryByIVTreatment';
detailsheet = 'MeasuresDetail';

tic
% remove Oral treatments & sort by SmartCareID and StopDate
idx = find(ismember(cdAntibiotics.Route, {'Oral'}));
cdAntibiotics(idx,:) = [];
ivTreatments = unique(cdAntibiotics(:,{'ID','StartDate'}));
ivTreatments.IVDateNum = datenum(ivTreatments.StartDate) - offset + 1;

% use the version of physdata before handling dateoutliers
%physdata = physdata_predateoutlierhandling;

physdata = sortrows(physdata, {'SmartCareID', 'DateNum', 'RecordingType'}, 'ascend');
numdays = 40;
Day = zeros(1,numdays);
Day = array2table(Day);
summarytable = table('Size',[1 6], ...
    'VariableTypes', {'int32',       'datetime',    'int32',     'int32',            'int32',         'double'}, ...
    'VariableNames', {'SmartCareID', 'IVStartDate', 'IVDateNum', 'DaysWithMeasures', 'TotalMeasures', 'AvgMeasuresPerDay'});
summarytable = [summarytable Day];
for i = 1:40
    summarytable.Properties.VariableNames{i+6} = sprintf('IVminus%d',abs(i-41));
end
rowtoadd = summarytable;
summarytable(1,:) = [];

measuresdetailtable = physdata(1:1,:);
measuresdetailtable = [];

oldid = 0;
oldstartdn = 0;
for i = 1:size(ivTreatments,1)
    scid = ivTreatments.ID(i);
    startdate = ivTreatments.StartDate(i);
    startdn = ivTreatments.IVDateNum(i);
    
    if (scid ~= oldid | startdn > oldstartdn + 25)
        idx = find(physdata.SmartCareID == scid & physdata.DateNum < startdn & physdata.DateNum >= (startdn - numdays));
        pdcountmtable = varfun(@max, physdata(idx, {'SmartCareID','DateNum'}), 'GroupingVariables', {'SmartCareID', 'DateNum'});
    
        rowtoadd.SmartCareID = scid;
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
    
        summarytable = [summarytable ; rowtoadd];
        measuresdetailtable = [measuresdetailtable ; physdata(idx,:)];
    end
    
    oldid = scid;
    oldstartdn = startdn;
end
toc
fprintf('\n');

summarytable.IVDateNum = [];
measuresdetailtable.ScaledDateNum = [];
measuresdetailtable.DateNum = [];

tic
fprintf('Saving results\n');
%writetable(summarytable,        outputfilename, 'Sheet', summarysheet);
%writetable(measuresdetailtable, outputfilename, 'Sheet', detailsheet);

toc
fprintf('\n');
    
    
    