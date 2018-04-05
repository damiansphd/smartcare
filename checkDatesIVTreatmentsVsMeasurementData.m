clc; clear; close;

tic
fprintf('Loading Clinical data\n');
load('clinicaldata.mat');
fprintf('Loading SmartCare measurement data\n');
load('smartcaredata.mat');
toc

% uncomment one or other pair here depending on whether you want actual or
% notional end date for measurement period
%createnotionalmeasurementend = false;
%outputfilename = 'TreatmentsOutsideStudyPeriod.xlsx';
createnotionalmeasurementend = true;
outputfilename = 'TreatmentsOutsideStudyPeriodNotionalEnd.xlsx';

tic
% remove Oral treatments & sort by SmartCareID and StopDate
idx = find(ismember(cdAntibiotics.Route, {'Oral'}));
cdAntibiotics(idx,:) = [];
cdAntibiotics = sortrows(cdAntibiotics, {'ID','StopDate'},'ascend');

physdata = sortrows(physdata, {'SmartCareID', 'DateNum', 'RecordingType'}, 'ascend');

% get min and max measurement dates for each SmartCare ID
minDatesByPatient = varfun(@min, physdata(:,{'SmartCareID', 'Date_TimeRecorded'}), 'GroupingVariables', 'SmartCareID');
maxDatesByPatient = varfun(@max, physdata(:,{'SmartCareID', 'Date_TimeRecorded'}), 'GroupingVariables', 'SmartCareID');

outputtable = table('Size',[1 9], 'VariableTypes', {'string(12)','int32','int32','datetime','datetime','int32', 'string(14)','datetime','datetime'}, ...
    'VariableNames', {'RowType','SmartCareID','StudyPeriod','FirstMeasurement','LastMeasurement','AntibioticID','AntibioticName','AntibioticStart','AntibioticEnd'});
rowtoadd = outputtable;
outputtable(1,:) = [];


oldid = cdAntibiotics.ID(1);
for i = 1:size(cdAntibiotics,1)
    scid = cdAntibiotics.ID(i);
    treatmentstart = cdAntibiotics.StartDate(i);
    dntreatmentstart = datenum(cdAntibiotics.StartDate(i));
    treatmentend = cdAntibiotics.StopDate(i);
    dntreatmentend = datenum(cdAntibiotics.StopDate(i));
    
    idx = find(minDatesByPatient.SmartCareID == scid);
    firstmeasurement = minDatesByPatient.min_Date_TimeRecorded(idx);
    dnfirstm = ceil(datenum(minDatesByPatient.min_Date_TimeRecorded(idx)));
    lastmeasurement = maxDatesByPatient.max_Date_TimeRecorded(idx);
    dnlastm = ceil(datenum(maxDatesByPatient.max_Date_TimeRecorded(idx)));
    if (((dnlastm - dnfirstm) < 183) & createnotionalmeasurementend)
        lastmeasurement = dateshift(firstmeasurement,'start','day',183);
        dnlastm = dnfirstm + 183;
    end
    if (dntreatmentend < dnfirstm-1) | (dntreatmentstart > dnlastm)
        if oldid ~= scid
           fprintf('\n');
           oldid = scid;
        end
        
        rowtoadd.SmartCareID = scid;
        rowtoadd.StudyPeriod = dnlastm - dnfirstm;
        rowtoadd.FirstMeasurement = firstmeasurement;
        rowtoadd.LastMeasurement = lastmeasurement;
        rowtoadd.AntibioticID = cdAntibiotics.AntibioticID(i);
        rowtoadd.AntibioticName = cdAntibiotics.AntibioticName{i};
        rowtoadd.AntibioticStart = treatmentstart;
        rowtoadd.AntibioticEnd = treatmentend;
        
        if (dntreatmentend < dnfirstm-1)
            fprintf('Treatment before study  :  Patient ID %3d Study Period %3d days First Measurement %11s  :  Antibiotic ID %3d %14s End   %11s\n', scid, dnlastm - dnfirstm, datestr(firstmeasurement,1), ...
                cdAntibiotics.AntibioticID(i), cdAntibiotics.AntibioticName{i}, datestr(treatmentend,1)); 
            rowtoadd.RowType = 'Treatment before study';
        end
        if (dntreatmentstart > dnlastm) 
            fprintf('Treatment after  study  :  Patient ID %3d Study Period %3d days  Last Measurement %11s  :  Antibiotic ID %3d %14s Start %11s\n', scid, dnlastm - dnfirstm, datestr(lastmeasurement,1), ...
                cdAntibiotics.AntibioticID(i), cdAntibiotics.AntibioticName{i}, datestr(treatmentstart,1)); 
            rowtoadd.RowType = 'Treatment after study';
        end
        outputtable = [outputtable;rowtoadd];        
    end
end

writetable(outputtable, outputfilename);

toc

    