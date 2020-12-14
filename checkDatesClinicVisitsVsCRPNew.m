clc; clear; close all;


tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

[studynbr, study, studyfullname] = selectStudy();
[datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
[physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);

fprintf('\n');

basedir = setBaseDir();
subfolder = 'ExcelFiles';
outputfilename = sprintf('%s-ClinicVisitsVsCRP.xlsx', study);
residualsheet = 'CRPWithNoClinicAdmissionAB';

tic
% get patients with enough data
patientoffsets = getPatientOffsets(physdata);
patientoffsets.Properties.VariableNames{'SmartCareID'} = 'ID';

% sort by SmartCareID and StartDate
cdCRP = sortrows(cdCRP, {'Hospital','ID','CRPDate'}, 'ascend');
cdAdmissions = sortrows(cdAdmissions, {'Hospital','ID','Admitted'}, 'ascend');
cdAntibiotics = sortrows(cdAntibiotics, {'Hospital','ID','StartDate'}, 'ascend');
cdClinicVisits = sortrows(cdClinicVisits, {'Hospital','ID','AttendanceDate'},'ascend');
cdOtherVisits = sortrows(cdOtherVisits, {'Hospital','ID','AttendanceDate'},'ascend');

cdCRP = innerjoin(cdCRP, patientoffsets);

residualtable = table('Size',[1 7], ...
    'VariableTypes', {'string(56)', 'string(8)', 'int32',       'string(20)',  'int32', 'datetime', 'int32'}, ...
    'VariableNames', {'RowType',    'Hospital',  'SmartCareID', 'StudyNumber', 'CRPID', 'CRPDate',  'CRPLevel'});
rowtoadd = residualtable;
residualtable(1,:) = [];
matchcount = 0;

for i = 1:size(cdCRP,1)
    scid = cdCRP.ID(i);
    crpdate = cdCRP.CRPDate(i);
    
    rowtoadd.SmartCareID = scid;
    rowtoadd.Hospital = cdCRP.Hospital{i};
    rowtoadd.StudyNumber = cdCRP.StudyNumber{i};
    %rowtoadd.CRPID = cdCRP.CRPID(i);
    rowtoadd.CRPDate = crpdate;
    rowtoadd.CRPLevel = cdCRP.NumericLevel(i);
    
    idx = find(cdAdmissions.ID == scid & (cdAdmissions.Admitted-days(7)) <= crpdate & cdAdmissions.Discharge >= crpdate);
    idx2 = find(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, {'IV'}) & cdAntibiotics.StartDate <= crpdate & cdAntibiotics.StopDate >= crpdate);
    idx3 = find(cdClinicVisits.ID == scid & cdClinicVisits.AttendanceDate == crpdate);
    idx4 = find(cdOtherVisits.ID == scid & cdOtherVisits.AttendanceDate == crpdate);
    
    if (size(idx,1) ==0 & size(idx2,1)==0 & size(idx3,1)==0 & size(idx4,1)==0)
        rowtoadd.RowType = '*** CRP with no Clinic Visit/Admission/IV Antibiotic ***';
        fprintf('%56s  :  Hospital %8s  Patient ID %3d  :  CRP ID %3d  CRP Date  %11s  CRP Level  %3d\n', ... 
            rowtoadd.RowType, rowtoadd.Hospital, rowtoadd.SmartCareID, rowtoadd.CRPID, datestr(rowtoadd.CRPDate,1), rowtoadd.CRPLevel);
        residualtable = [residualtable; rowtoadd];
    else
        rowtoadd.RowType = 'Ok - CRP during Clinic Visit/Admission/IV Antibiotic';
        matchcount = matchcount + 1;
        fprintf('%56s  :  Hospital %8s  Patient ID %3d  :  CRP ID %3d  CRP Date  %11s  CRP Level  %3d\n', ... 
            rowtoadd.RowType, rowtoadd.Hospital, rowtoadd.SmartCareID, rowtoadd.CRPID, datestr(rowtoadd.CRPDate,1), rowtoadd.CRPLevel);
    end
end

toc
fprintf('\n');

fprintf('Completeness check - %3d rows missing\n', size(cdCRP,1) - size(residualtable,1) - matchcount);
fprintf('\n');

tic
fprintf('Saving results\n');

writetable(residualtable,  fullfile(basedir, subfolder,outputfilename), 'Sheet', residualsheet);
toc
fprintf('\n');