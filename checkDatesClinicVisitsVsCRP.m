clc; clear; close;

tic
fprintf('Loading Clinical data\n');
load('clinicaldata.mat');
fprintf('Loading SmartCare measurement data\n');
load('smartcaredata.mat');
toc

fprintf('\n');

outputfilename = 'ClinicVisitsVsCRP.xlsx';
exceptionsheet = '1)ClinicVisitNoCRP';
matchsheet = '3)ClinicVisitAndCRP';
residualsheet = '2)CRPWithNoClinicVisit';

tic
% sort by SmartCareID and StartDate
cdClinicVisits = sortrows(cdClinicVisits, {'Hospital','ID','AttendanceDate'},'ascend');
cdCRP = sortrows(cdCRP, {'Hospital','ID','CRPDate'}, 'ascend');
cdAdmissions = sortrows(cdAdmissions, {'Hospital','ID','Admitted'}, 'ascend');

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

residualtable = table('Size',[1 6], 'VariableTypes', {'string(38)', 'string(8)', 'int32', 'int32', 'datetime', 'int32'}, ...
    'VariableNames', {'RowType', 'Hospital', 'SmartCareID', 'CRPID', 'CRPDate', 'CRPLevel'});
rowtoadd = residualtable;
residualtable(1,:) = [];

for i = 1:size(residualidx,1)
    rowtoadd.RowType = '*** CRP Level with no Clinic Visit ***';
    rowtoadd.SmartCareID = cdCRP.ID(residualidx(i));
    rowtoadd.Hospital = cdCRP.Hospital{residualidx(i)};
    rowtoadd.CRPID = cdCRP.CRPID(residualidx(i));
    rowtoadd.CRPDate = cdCRP.CRPDate(residualidx(i));
    rowtoadd.CRPLevel = cdCRP.NumericLevel(residualidx(i));
        
    fprintf('%38s  :  Hospital %8s  Patient ID %3d  :  CRP ID %3d  CRP Date  %11s  CRP Level  %3d\n', ... 
        rowtoadd.RowType, rowtoadd.Hospital, rowtoadd.SmartCareID, rowtoadd.CRPID, datestr(rowtoadd.CRPDate,1), rowtoadd.CRPLevel);
    residualtable = [residualtable; rowtoadd];
end

toc
fprintf('\n');

fprintf('Completeness check - %3d rows missing\n', size(cdCRP,1) - size(umatchedidx,1) - size(residualtable,1));
fprintf('\n');

tic
fprintf('Saving results\n');

writetable(exceptiontable, outputfilename, 'Sheet', exceptionsheet);
writetable(residualtable,  outputfilename, 'Sheet', residualsheet);
writetable(matchtable,     outputfilename, 'Sheet', matchsheet);
toc
fprintf('\n');