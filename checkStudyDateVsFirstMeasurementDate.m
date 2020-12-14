clc; clear; close all;

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

[studynbr, study, studyfullname] = selectStudy();
[datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
[physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);

basedir = setBaseDir();
subfolder = 'ExcelFiles';
outputfilename = sprintf('%s-StudyStartvsFirstMeasurement.xlsx', study);

tic
% get patients with enough data
patientoffsets = getPatientOffsets(physdata);
patientoffsets.Properties.VariableNames{'SmartCareID'} = 'ID';

cdPatient = sortrows(cdPatient, {'ID'}, 'ascend');
patients = innerjoin(cdPatient, patientoffsets);

physdata = sortrows(physdata, {'SmartCareID', 'DateNum', 'RecordingType'}, 'ascend');

% get min and max measurement dates for each SmartCare ID
minDatesByPatient = varfun(@min, physdata(:,{'SmartCareID', 'Date_TimeRecorded'}), 'GroupingVariables', 'SmartCareID');
maxDatesByPatient = varfun(@max, physdata(:,{'SmartCareID', 'Date_TimeRecorded'}), 'GroupingVariables', 'SmartCareID');

outputtable = table('Size',[1 6], 'VariableTypes', {'string(39)','int32','datetime','datetime', 'int32', 'int32'}, ...
    'VariableNames', {'RowType','SmartCareID','StudyStartDate','FirstMeasurement', 'DaysFMBeforeSS', 'NumberOfMeasuresBeforeSS'});
rowtoadd = outputtable;
outputtable(1,:) = [];

measurestable = physdata(1,:);
measurestable(1,:) = [];


oldid = patients.ID(1);
for i = 1:size(patients,1)
    scid = patients.ID(i);
    studystart = patients.StudyDate(i);
    dnstudystart = ceil(datenum(studystart));
    
    idx = find(minDatesByPatient.SmartCareID == scid);
    firstmeasurement = minDatesByPatient.min_Date_TimeRecorded(idx);
    dnfirstm = ceil(datenum(minDatesByPatient.min_Date_TimeRecorded(idx)));
    
    if (dnfirstm < dnstudystart) | ((dnfirstm - dnstudystart) > 14)
        if oldid ~= scid
           fprintf('\n');
           oldid = scid;
        end
        
        rowtoadd.SmartCareID = scid;
        rowtoadd.StudyStartDate = studystart;
        rowtoadd.FirstMeasurement = firstmeasurement;
        rowtoadd.DaysFMBeforeSS = dnfirstm - dnstudystart;
        
        nmeasurements = 0;
        range = dnstudystart - dnfirstm;
        if range > 0
            fprintf('SCID %3d   FMDate %11s   FMDateNum %6d   DateRange %3d\n', scid, datestr(firstmeasurement,1), dnfirstm, range);
            measurements = getMeasuresForPatientAndDateRange(physdata, scid, dnfirstm - offset, range, 'All',true);
            measurestable = [measurestable;measurements];
            nmeasurements = size(measurements,1);
        end
        rowtoadd.NumberOfMeasuresBeforeSS = nmeasurements;
        
        if (dnfirstm < dnstudystart)
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

measurestable.DateNum = [];
measurestable = sortrows(measurestable, {'SmartCareID', 'Date_TimeRecorded', 'RecordingType'}, 'ascend');

writetable(outputtable, fullfile(basedir, subfolder,outputfilename), 'Sheet', 'MeasurementsBeforeStudyStart');
writetable(measurestable, fullfile(basedir, subfolder,outputfilename), 'Sheet', 'MeasurementDetails');

toc

    