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
outputfilename = 'ClinicVisitsVsCRP.xlsx';
exceptionsheet = '1)ClinicVisitNoCRP';
matchsheet = '3)ClinicVisitAndCRP';
residualsheet = '2)CRPWithNoClinicOrAdmission';

tic
% sort by SmartCareID and StartDate
cdClinicVisits = sortrows(cdClinicVisits, {'Hospital','ID','AttendanceDate'},'ascend');
cdCRP = sortrows(cdCRP, {'Hospital','ID','CRPDate'}, 'ascend');
cdAdmissions = sortrows(cdAdmissions, {'Hospital','ID','Admitted'}, 'ascend');
cdAntibiotics = sortrows(cdAntibiotics, {'Hospital','ID','StartDate'}, 'ascend');

matchtable = table('Size',[1 7], ...
    'VariableTypes', {'string(35)', 'string(8)', 'int32',       'int32',    'datetime',       'int32', 'int32'}, ...
    'VariableNames', {'RowType',    'Hospital',  'SmartCareID', 'ClinicID', 'AttendanceDate', 'CRPID', 'CRPLevel'});
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
    
    idx = find(cdCRP.ID == scid & cdCRP.CRPDate == attenddate);
    matchedidx = [matchedidx; idx];
    
    rowtoadd.SmartCareID = scid;
    rowtoadd.Hospital = cdClinicVisits.Hospital(i);
    rowtoadd.ClinicID = cdClinicVisits.ClinicID(i);
    rowtoadd.AttendanceDate = attenddate;
    
    if size(idx,1) == 0
        rowtoadd.RowType = '*** ClinicVisit with no CRP ***';
        fprintf('%35s  :  Hospital %8s  Patient ID %3d  Attend Date  %11s\n', ... 
            rowtoadd.RowType, string(rowtoadd.Hospital), scid, datestr(attenddate,1)); 
        exceptiontable = [exceptiontable;rowtoadd(1,{'RowType', 'Hospital', 'SmartCareID', 'ClinicID', 'AttendanceDate'})];  
    else
        for t = 1:size(idx,1)
            rowtoadd.RowType = 'OK - ClinicVisit and CRP';
            rowtoadd.CRPID = cdCRP.CRPID(idx(t));
            rowtoadd.CRPLevel = cdCRP.NumericLevel(idx(t));
        
            fprintf('%35s  :  Hospital %8s  Patient ID %3d  Clinic ID %3d Attended  %11s  :  CRP ID %3d  CRP Level  %3d\n', ... 
                rowtoadd.RowType, string(rowtoadd.Hospital), scid, rowtoadd.ClinicID, datestr(attenddate,1), rowtoadd.CRPID, rowtoadd.CRPLevel); 
        
            matchtable = [matchtable;rowtoadd];  
        end
    end
end

toc
fprintf('\n');

tic
umatchedidx = unique(matchedidx);
crpidx = find(cdCRP.ID);
residualidx = setdiff(crpidx, umatchedidx);

residualtable = table('Size',[1 6], ...
    'VariableTypes', {'string(56)', 'string(8)', 'int32',       'int32', 'datetime', 'int32'}, ...
    'VariableNames', {'RowType',    'Hospital',  'SmartCareID', 'CRPID', 'CRPDate',  'CRPLevel'});
rowtoadd = residualtable;
residualtable(1,:) = [];
hacrpcount = 0;

for i = 1:size(residualidx,1)
    scid = cdCRP.ID(residualidx(i));
    crpdate = cdCRP.CRPDate(residualidx(i));
    
    rowtoadd.SmartCareID = scid;
    rowtoadd.Hospital = cdCRP.Hospital{residualidx(i)};
    rowtoadd.CRPID = cdCRP.CRPID(residualidx(i));
    rowtoadd.CRPDate = crpdate;
    rowtoadd.CRPLevel = cdCRP.NumericLevel(residualidx(i));
    
    idx = find(cdAdmissions.ID == scid & (cdAdmissions.Admitted-days(7)) <= crpdate & cdAdmissions.Discharge >= crpdate);
    idx2 = find(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, {'IV'}) & cdAntibiotics.StartDate <= crpdate & cdAntibiotics.StopDate >= crpdate);
    
    if (size(idx,1) ==0 & size(idx2,1)==0)
        rowtoadd.RowType = '*** CRP with no Clinic Visit/Admission/IV Antibiotic ***';
        fprintf('%56s  :  Hospital %8s  Patient ID %3d  :  CRP ID %3d  CRP Date  %11s  CRP Level  %3d\n', ... 
            rowtoadd.RowType, rowtoadd.Hospital, rowtoadd.SmartCareID, rowtoadd.CRPID, datestr(rowtoadd.CRPDate,1), rowtoadd.CRPLevel);
        residualtable = [residualtable; rowtoadd];
    else
        rowtoadd.RowType = 'Ok - CRP during Admission/IV Antibiotic';
        hacrpcount = hacrpcount + 1;
        fprintf('%56s  :  Hospital %8s  Patient ID %3d  :  CRP ID %3d  CRP Date  %11s  CRP Level  %3d\n', ... 
            rowtoadd.RowType, rowtoadd.Hospital, rowtoadd.SmartCareID, rowtoadd.CRPID, datestr(rowtoadd.CRPDate,1), rowtoadd.CRPLevel);
    end
end

toc
fprintf('\n');

fprintf('Completeness check - %3d rows missing\n', size(cdCRP,1) - size(umatchedidx,1) - size(residualtable,1) - hacrpcount);
fprintf('\n');

tic
fprintf('Saving results\n');

writetable(residualtable,  fullfile(basedir, subfolder,outputfilename), 'Sheet', residualsheet);
toc
fprintf('\n');