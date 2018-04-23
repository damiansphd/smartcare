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

fprintf('\n');

basedir = './';
subfolder = 'ExcelFiles';
outputfilename = 'ClinicVisitsVsPFT.xlsx';
exceptionsheet = '1)ClinicVisitNoPFT';
matchsheet = '3)ClinicVisitAndPFT';
residualsheet = '2)PFTWithNoClinicOrAdmission';

tic
% sort by SmartCareID and StartDate
cdClinicVisits = sortrows(cdClinicVisits, {'Hospital','ID','AttendanceDate'},'ascend');
cdPFT = sortrows(cdPFT, {'Hospital','ID','LungFunctionDate'}, 'ascend');
cdAdmissions = sortrows(cdAdmissions, {'Hospital','ID','Admitted'}, 'ascend');
cdAntibiotics = sortrows(cdAntibiotics, {'Hospital','ID','StartDate'}, 'ascend');

matchtable = table('Size',[1 10], ...
    'VariableTypes', {'string(35)', 'string(8)', 'int32',       'int32',    'datetime',       'int32',         'double', 'int32', 'double', 'int32'}, ...
    'VariableNames', {'RowType',    'Hospital',  'SmartCareID', 'ClinicID', 'AttendanceDate', 'LungFunctionID','FEV1',   'FEV1_',  'FVC1',   'FVC1_'});
rowtoadd = matchtable;
matchtable(1,:) = [];

exceptiontable = table('Size',[1 5], ...
    'VariableTypes', {'string(35)', 'string(8)', 'int32',       'int32',    'datetime',}, ...
    'VariableNames', {'RowType',    'Hospital',  'SmartCareID', 'ClinicID', 'AttendanceDate'});
exceptiontable(1,:) = [];

matchedidx = [];

for i = 1:size(cdClinicVisits,1)
    scid = cdClinicVisits.ID(i);
    attenddate = cdClinicVisits.AttendanceDate(i);
    
    idx = find(cdPFT.ID == scid & cdPFT.LungFunctionDate == attenddate);
    matchedidx = [matchedidx; idx];
    
    rowtoadd.SmartCareID = scid;
    rowtoadd.Hospital = cdClinicVisits.Hospital(i);
    rowtoadd.ClinicID = cdClinicVisits.ClinicID(i);
    rowtoadd.AttendanceDate = attenddate;
    
    if size(idx,1) == 0
        rowtoadd.RowType = '*** ClinicVisit with no PFT ***';
        fprintf('%35s  :  Hospital %8s  Patient ID %3d  Attend Date  %11s\n', ... 
            rowtoadd.RowType, string(rowtoadd.Hospital), scid, datestr(attenddate,1)); 
        exceptiontable = [exceptiontable;rowtoadd(1,{'RowType', 'Hospital', 'SmartCareID', 'ClinicID', 'AttendanceDate'})];  
    else
        for t = 1:size(idx,1)
            rowtoadd.RowType = 'OK - ClinicVisit and PFT';
            rowtoadd.LungFunctionID = cdPFT.LungFunctionID(idx(t));
            rowtoadd.FEV1  = cdPFT.FEV1(idx(t));
            rowtoadd.FEV1_ = cdPFT.FEV1_(idx(t));
            rowtoadd.FVC1  = cdPFT.FVC1(idx(t));
            rowtoadd.FVC1_ = cdPFT.FVC1_(idx(t));
        
            fprintf('%35s  :  Hospital %8s  Patient ID %3d  Clinic ID %3d Attended  %11s  :  Lung Function ID %3d  FEV1 %1.2f  FEV1_ %3d  FVC1 %1.2f  FVC1_ %3d\n', ... 
                rowtoadd.RowType, string(rowtoadd.Hospital), scid, rowtoadd.ClinicID, datestr(attenddate,1), rowtoadd.LungFunctionID, rowtoadd.FEV1, ...
                rowtoadd.FEV1_, rowtoadd.FVC1, rowtoadd.FVC1_); 
        
            matchtable = [matchtable;rowtoadd];  
        end
    end
end

toc
fprintf('\n');

tic
umatchedidx = unique(matchedidx);
pftidx = find(cdPFT.ID);
residualidx = setdiff(pftidx, umatchedidx);

residualtable = table('Size',[1 9], ...
    'VariableTypes', {'string(56)', 'string(8)', 'int32',       'int32',          'datetime',         'double', 'int32', 'double', 'int32'}, ...
    'VariableNames', {'RowType',    'Hospital',  'SmartCareID', 'LungFunctionID', 'LungFunctionDate', 'FEV1',   'FEV1_',  'FVC1',   'FVC1_', });
rowtoadd = residualtable;
residualtable(1,:) = [];
hapftcount = 0;

for i = 1:size(residualidx,1)
    scid = cdPFT.ID(residualidx(i));
    pftdate = cdPFT.LungFunctionDate(residualidx(i));
    
    rowtoadd.SmartCareID = scid;
    rowtoadd.Hospital = cdPFT.Hospital{residualidx(i)};
    rowtoadd.LungFunctionID = cdPFT.LungFunctionID(residualidx(i));
    rowtoadd.LungFunctionDate = pftdate;
    rowtoadd.FEV1  = cdPFT.FEV1(residualidx(i));
    rowtoadd.FEV1_ = cdPFT.FEV1_(residualidx(i));
    rowtoadd.FVC1  = cdPFT.FVC1(residualidx(i));
    rowtoadd.FVC1_ = cdPFT.FVC1_(residualidx(i));
    
    idx = find(cdAdmissions.ID == scid & (cdAdmissions.Admitted-days(7)) <= pftdate & cdAdmissions.Discharge >= pftdate);
    idx2 = find(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, {'IV'}) & cdAntibiotics.StartDate <= pftdate & cdAntibiotics.StopDate >= pftdate);
    
    if (size(idx,1) ==0 & size(idx2,1)==0)
        rowtoadd.RowType = '*** PFT with no Clinic Visit/Admission/IV Antibiotic ***';
        fprintf('%56s  :  Hospital %8s  Patient ID %3d  :  LungFunction ID %3d  LungFunction Date  %11s  FEV1 %1.2f  FEV1_ %3.0f  FVC1 %1.2f  FVC1_ %3.0f\n', ... 
            rowtoadd.RowType, rowtoadd.Hospital, rowtoadd.SmartCareID, rowtoadd.LungFunctionID, datestr(rowtoadd.LungFunctionDate,1), rowtoadd.FEV1, ...
            rowtoadd.FEV1_, rowtoadd.FVC1, rowtoadd.FVC1_);
        residualtable = [residualtable; rowtoadd];
    else
        rowtoadd.RowType = 'Ok - PFT during Hospital Admission';
        hapftcount = hapftcount + 1;
        fprintf('%56s  :  Hospital %8s  Patient ID %3d  :  LungFunction ID %3d  LungFunction Date  %11s  FEV1 %1.2f  FEV1_ %3.0f  FVC1 %1.2f  FVC1_ %3.0f\n', ... 
            rowtoadd.RowType, rowtoadd.Hospital, rowtoadd.SmartCareID, rowtoadd.LungFunctionID, datestr(rowtoadd.LungFunctionDate,1), rowtoadd.FEV1, ...
            rowtoadd.FEV1_, rowtoadd.FVC1, rowtoadd.FVC1_);
    end
end

toc
fprintf('\n');

fprintf('Completeness check - %3d rows missing\n', size(cdPFT,1) - size(umatchedidx,1) - size(residualtable,1) - hapftcount);
fprintf('\n');

tic
fprintf('Saving results\n');

writetable(residualtable,  fullfile(basedir, subfolder,outputfilename), 'Sheet', residualsheet);
toc
fprintf('\n');
