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
outputfilename = sprintf('%s-TreatmentsOutsideStudyPeriodNotionalEnd.xlsx', study);

tic
% get patients with enough data
patientoffsets = getPatientOffsets(physdata);
patientoffsets.Properties.VariableNames{'SmartCareID'} = 'ID';

% remove Oral treatments & sort by SmartCareID and StopDate
ivantibiotics = cdAntibiotics;
idx = find(ismember(ivantibiotics.Route, {'Oral'}));
ivantibiotics(idx,:) = [];
ivantibiotics = sortrows(ivantibiotics, {'ID','StopDate'},'ascend');
ivantibiotics = innerjoin(ivantibiotics, patientoffsets);

physdata = sortrows(physdata, {'SmartCareID', 'DateNum', 'RecordingType'}, 'ascend');

% get min and max measurement dates for each SmartCare ID
minDatesByPatient = varfun(@min, physdata(:,{'SmartCareID', 'Date_TimeRecorded'}), 'GroupingVariables', 'SmartCareID');
maxDatesByPatient = varfun(@max, physdata(:,{'SmartCareID', 'Date_TimeRecorded'}), 'GroupingVariables', 'SmartCareID');

outputtable = table('Size',[1 11], 'VariableTypes', {'string(12)','int32','int32','datetime','datetime','int32', 'string(14)','datetime','datetime','datetime','datetime'}, ...
    'VariableNames', {'RowType','SmartCareID','StudyPeriod','StudyStartDate','StudyEndDate','AntibioticID','AntibioticName','AntibioticStart','AntibioticEnd','FirstMeasurement','LastMeasurement'});
rowtoadd = outputtable;
outputtable(1,:) = [];


oldid = ivantibiotics.ID(1);
for i = 1:size(ivantibiotics,1)
    scid = ivantibiotics.ID(i);
    treatmentstart = ivantibiotics.StartDate(i);
    dntreatmentstart = datenum(ivantibiotics.StartDate(i));
    treatmentend = ivantibiotics.StopDate(i);
    dntreatmentend = datenum(ivantibiotics.StopDate(i));
    
    idx = find(cdPatient.ID == scid);
    studystart = cdPatient.StudyDate(idx);
    dnstudystart = ceil(datenum(studystart));
    studyend = dateshift(studystart,'start','day',183);
    dnstudyend = ceil(datenum(studyend));
    
    idx = find(minDatesByPatient.SmartCareID == scid);
    if size(idx,1)>0
        firstmeasurement = minDatesByPatient.min_Date_TimeRecorded(idx);
        dnfirstm = ceil(datenum(minDatesByPatient.min_Date_TimeRecorded(idx)));
        lastmeasurement = maxDatesByPatient.max_Date_TimeRecorded(idx);
        dnlastm = ceil(datenum(maxDatesByPatient.max_Date_TimeRecorded(idx)));
    else
        firstmeasurement = datetime(0,0,0);
        lastmeasurement = datetime(0,0,0);
    end
    
    if (dntreatmentend < dnstudystart-1) | (dntreatmentstart > dnstudyend)
        if oldid ~= scid
           fprintf('\n');
           oldid = scid;
        end
        
        rowtoadd.SmartCareID = scid;
        rowtoadd.StudyPeriod = dnstudyend - dnstudystart;
        rowtoadd.StudyStartDate = studystart;
        rowtoadd.StudyEndDate = studyend;
        rowtoadd.AntibioticID = ivantibiotics.AntibioticID(i);
        rowtoadd.AntibioticName = ivantibiotics.AntibioticName{i};
        rowtoadd.AntibioticStart = treatmentstart;
        rowtoadd.AntibioticEnd = treatmentend;
        rowtoadd.FirstMeasurement = firstmeasurement;
        rowtoadd.LastMeasurement = lastmeasurement;
        
        if (dntreatmentend < dnstudystart-1)
            fprintf('Treatment before study  :  Patient ID %3d Study Period %3d days Study Start Date %11s  :  Antibiotic ID %3d %14s End   %11s  :  First Measurement %11s\n', ... 
                scid, dnstudyend - dnstudystart, datestr(studystart,1), ivantibiotics.AntibioticID(i), ivantibiotics.AntibioticName{i}, datestr(treatmentend,1), datestr(firstmeasurement,1)); 
            rowtoadd.RowType = 'Treatment before study';
        end
        if (dntreatmentstart > dnstudyend) 
            fprintf('Treatment after  study  :  Patient ID %3d Study Period %3d days   Study End Date %11s  :  Antibiotic ID %3d %14s Start %11s  :   Last Measurement %11s\n', ...
                scid, dnstudyend - dnstudystart, datestr(studyend,1), ivantibiotics.AntibioticID(i), ivantibiotics.AntibioticName{i}, datestr(treatmentstart,1), datestr(lastmeasurement,1)); 
            rowtoadd.RowType = 'Treatment after study';
        end
        outputtable = [outputtable;rowtoadd];        
    end
end

writetable(outputtable, fullfile(basedir, subfolder,outputfilename));

toc

    