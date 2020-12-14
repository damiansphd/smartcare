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
outputfilename = sprintf('%s-ClinicVisitsVsPFT.xlsx', study);
residualsheet = 'PFTWithNoClinicAdmissionAB';

tic
% get patients with enough data
patientoffsets = getPatientOffsets(physdata);
patientoffsets.Properties.VariableNames{'SmartCareID'} = 'ID';

% sort by Hospital, SmartCareID and Date
cdPFT = sortrows(cdPFT, {'Hospital','ID','LungFunctionDate'}, 'ascend');
cdClinicVisits = sortrows(cdClinicVisits, {'Hospital','ID','AttendanceDate'},'ascend');
cdOtherVisits = sortrows(cdOtherVisits, {'Hospital','ID','AttendanceDate'},'ascend');
cdAdmissions = sortrows(cdAdmissions, {'Hospital','ID','Admitted'}, 'ascend');
cdAntibiotics = sortrows(cdAntibiotics, {'Hospital','ID','StartDate'}, 'ascend');

cdPFT = innerjoin(cdPFT, patientoffsets);

residualtable = table('Size',[1 10], ...
    'VariableTypes', {'string(56)', 'string(8)', 'int32',       'string(20)',  'int32',          'datetime',         'double', 'int32', 'double', 'int32'}, ...
    'VariableNames', {'RowType',    'Hospital',  'SmartCareID', 'StudyNumber', 'LungFunctionID', 'LungFunctionDate', 'FEV1',   'FEV1_',  'FVC1',   'FVC1_', });
rowtoadd = residualtable;
residualtable(1,:) = [];
matchcount = 0;

for i = 1:size(cdPFT,1)
    scid = cdPFT.ID(i);
    pftdate = cdPFT.LungFunctionDate(i);
    
    rowtoadd.SmartCareID = scid;
    rowtoadd.Hospital = cdPFT.Hospital{i};
    rowtoadd.StudyNumber = cdPFT.StudyNumber{i};
    %rowtoadd.LungFunctionID = cdPFT.LungFunctionID(i);
    rowtoadd.LungFunctionDate = pftdate;
    rowtoadd.FEV1  = cdPFT.FEV1(i);
    rowtoadd.FEV1_ = cdPFT.FEV1_(i);
    %rowtoadd.FVC1  = cdPFT.FVC1(i);
    %rowtoadd.FVC1_ = cdPFT.FVC1_(i);
    
    idx =  find(cdAdmissions.ID == scid & (cdAdmissions.Admitted-days(7)) <= pftdate & cdAdmissions.Discharge >= pftdate);
    idx2 = find(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, {'IV'}) & cdAntibiotics.StartDate <= pftdate & cdAntibiotics.StopDate >= pftdate);
    idx3 = find(cdClinicVisits.ID == scid & cdClinicVisits.AttendanceDate == pftdate);
    idx4 = find(cdOtherVisits.ID == scid & cdOtherVisits.AttendanceDate == pftdate);
    
    if (size(idx,1) ==0 & size(idx2,1)==0 & size(idx3,1)==0 & size(idx4,1)==0)
        rowtoadd.RowType = '*** PFT with no Clinic Visit/Admission/IV Antibiotic ***';
        fprintf('%56s  :  Hospital %8s  Patient ID %3d  :  LungFunction ID %3d  LungFunction Date  %11s  FEV1 %1.2f  FEV1_ %3.0f  FVC1 %1.2f  FVC1_ %3.0f\n', ... 
            rowtoadd.RowType, rowtoadd.Hospital, rowtoadd.SmartCareID, rowtoadd.LungFunctionID, datestr(rowtoadd.LungFunctionDate,1), rowtoadd.FEV1, ...
            rowtoadd.FEV1_, rowtoadd.FVC1, rowtoadd.FVC1_);
        residualtable = [residualtable; rowtoadd];
    else
        rowtoadd.RowType = 'Ok - PFT with Clinic Visit/Admission/IV Antibiotic';
        matchcount = matchcount + 1;
        fprintf('%56s  :  Hospital %8s  Patient ID %3d  :  LungFunction ID %3d  LungFunction Date  %11s  FEV1 %1.2f  FEV1_ %3.0f  FVC1 %1.2f  FVC1_ %3.0f\n', ... 
            rowtoadd.RowType, rowtoadd.Hospital, rowtoadd.SmartCareID, rowtoadd.LungFunctionID, datestr(rowtoadd.LungFunctionDate,1), rowtoadd.FEV1, ...
            rowtoadd.FEV1_, rowtoadd.FVC1, rowtoadd.FVC1_);
    end
end

toc
fprintf('\n');

fprintf('Completeness check - %3d rows missing\n', size(cdPFT,1) - size(residualtable,1) - matchcount);
fprintf('\n');

tic
fprintf('Saving results\n');

writetable(residualtable,  fullfile(basedir, subfolder,outputfilename), 'Sheet', residualsheet);
toc
fprintf('\n');
