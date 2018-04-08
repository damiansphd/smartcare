clc; clear; close;

tic
fprintf('Loading Clinical data\n');
load('clinicaldata.mat');
fprintf('Loading SmartCare measurement data\n');
load('smartcaredata.mat');
toc

outputfilename = 'StudyStartvsFirstMeasurement.xlsx';

tic
cdPatient = sortrows(cdPatient, {'ID'}, 'ascend');
physdata = sortrows(physdata, {'SmartCareID', 'DateNum', 'RecordingType'}, 'ascend');

% get min and max measurement dates for each SmartCare ID
minDatesByPatient = varfun(@min, physdata(:,{'SmartCareID', 'Date_TimeRecorded'}), 'GroupingVariables', 'SmartCareID');
maxDatesByPatient = varfun(@max, physdata(:,{'SmartCareID', 'Date_TimeRecorded'}), 'GroupingVariables', 'SmartCareID');

outputtable = table('Size',[1 4], 'VariableTypes', {'string(39)','int32','datetime','datetime'}, ...
    'VariableNames', {'RowType','SmartCareID','StudyStartDate','FirstMeasurement'});
rowtoadd = outputtable;
outputtable(1,:) = [];


oldid = cdPatient.ID(1);
for i = 1:size(cdPatient,1)
    scid = cdPatient.ID(i);
    studystart = cdPatient.StudyDate(i);
    dnstudystart = ceil(datenum(studystart));
    
    idx = find(minDatesByPatient.SmartCareID == scid);
    firstmeasurement = minDatesByPatient.min_Date_TimeRecorded(idx);
    dnfirstm = ceil(datenum(minDatesByPatient.min_Date_TimeRecorded(idx)));
    
    if (dnfirstm < dnstudystart-1) | ((dnfirstm - dnstudystart) > 14)
        if oldid ~= scid
           fprintf('\n');
           oldid = scid;
        end
        
        rowtoadd.SmartCareID = scid;
        rowtoadd.StudyStartDate = studystart;
        rowtoadd.FirstMeasurement = firstmeasurement;
        
        if (dnfirstm < dnstudystart-1)
            fprintf('First measurement before study start       :  Patient ID %3d Study Start Date %11s  :  First Measurement %11s\n', ... 
                scid, datestr(studystart,1), datestr(firstmeasurement,1)); 
            rowtoadd.RowType = 'First measurement before study start';
        end
        if (dnfirstm - dnstudystart) > 14
            fprintf('First measurement >2wk after study start   :  Patient ID %3d Study Start Date %11s  :  First Measurement %11s\n', ...
                scid, datestr(studystart,1), datestr(firstmeasurement,1)); 
            rowtoadd.RowType = 'First measurement >2Wk after study start';
        end
        outputtable = [outputtable;rowtoadd];        
    end
end

writetable(outputtable, outputfilename);

toc

    