clc; clear; close all;

tic
fprintf('Loading Clinical data\n');
load('clinicaldata.mat');
fprintf('Loading SmartCare measurement data\n');
load('smartcaredata.mat');
toc

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

outputtable = table('Size',[1 11], 'VariableTypes', {'string(12)','int32','int32','datetime','datetime','int32', 'string(14)','datetime','datetime','datetime','datetime'}, ...
    'VariableNames', {'RowType','SmartCareID','StudyPeriod','StudyStartDate','StudyEndDate','AntibioticID','AntibioticName','AntibioticStart','AntibioticEnd','FirstMeasurement','LastMeasurement'});
rowtoadd = outputtable;
outputtable(1,:) = [];


oldid = cdAntibiotics.ID(1);
for i = 1:size(cdAntibiotics,1)
    scid = cdAntibiotics.ID(i);
    treatmentstart = cdAntibiotics.StartDate(i);
    dntreatmentstart = datenum(cdAntibiotics.StartDate(i));
    treatmentend = cdAntibiotics.StopDate(i);
    dntreatmentend = datenum(cdAntibiotics.StopDate(i));
    
    idx = find(cdPatient.ID == scid);
    studystart = cdPatient.StudyDate(idx);
    dnstudystart = ceil(datenum(studystart));
    studyend = dateshift(studystart,'start','day',183);
    dnstudyend = ceil(datenum(studyend));
    
    idx = find(minDatesByPatient.SmartCareID == scid);
    firstmeasurement = minDatesByPatient.min_Date_TimeRecorded(idx);
    dnfirstm = ceil(datenum(minDatesByPatient.min_Date_TimeRecorded(idx)));
    lastmeasurement = maxDatesByPatient.max_Date_TimeRecorded(idx);
    dnlastm = ceil(datenum(maxDatesByPatient.max_Date_TimeRecorded(idx)));
    
    if (dntreatmentend < dnstudystart-1) | (dntreatmentstart > dnstudyend)
        if oldid ~= scid
           fprintf('\n');
           oldid = scid;
        end
        
        rowtoadd.SmartCareID = scid;
        rowtoadd.StudyPeriod = dnstudyend - dnstudystart;
        rowtoadd.StudyStartDate = studystart;
        rowtoadd.StudyEndDate = studyend;
        rowtoadd.AntibioticID = cdAntibiotics.AntibioticID(i);
        rowtoadd.AntibioticName = cdAntibiotics.AntibioticName{i};
        rowtoadd.AntibioticStart = treatmentstart;
        rowtoadd.AntibioticEnd = treatmentend;
        rowtoadd.FirstMeasurement = firstmeasurement;
        rowtoadd.LastMeasurement = lastmeasurement;
        
        if (dntreatmentend < dnstudystart-1)
            fprintf('Treatment before study  :  Patient ID %3d Study Period %3d days Study Start Date %11s  :  Antibiotic ID %3d %14s End   %11s  :  First Measurement %11s\n', ... 
                scid, dnstudyend - dnstudystart, datestr(studystart,1), cdAntibiotics.AntibioticID(i), cdAntibiotics.AntibioticName{i}, datestr(treatmentend,1), datestr(firstmeasurement,1)); 
            rowtoadd.RowType = 'Treatment before study';
        end
        if (dntreatmentstart > dnstudyend) 
            fprintf('Treatment after  study  :  Patient ID %3d Study Period %3d days   Study End Date %11s  :  Antibiotic ID %3d %14s Start %11s  :   Last Measurement %11s\n', ...
                scid, dnstudyend - dnstudystart, datestr(studyend,1), cdAntibiotics.AntibioticID(i), cdAntibiotics.AntibioticName{i}, datestr(treatmentstart,1), datestr(lastmeasurement,1)); 
            rowtoadd.RowType = 'Treatment after study';
        end
        outputtable = [outputtable;rowtoadd];        
    end
end

writetable(outputtable, outputfilename);

toc

    