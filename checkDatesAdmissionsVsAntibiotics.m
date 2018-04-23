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
outputfilename = 'AdmissionsVsAntibiotics.xlsx';
exceptionsheet = '1)AdmissionWithNoTreatment';
matchsheet = '3)AdmissionsWithTreatments';
ipsheet = '2)HospitalIVWithNoAdmission';
residualsheet = '4)HomeTreatments';

tic
% sort by SmartCareID and StartDate
cdAntibiotics = sortrows(cdAntibiotics, {'ID','StartDate'},'ascend');
cdAdmissions = sortrows(cdAdmissions, {'ID','Admitted'}, 'ascend');

matchtable = table('Size',[1 12], 'VariableTypes', {'string(35)', 'string(8)', 'int32', 'int32', 'datetime', 'datetime','int32', 'string(15)', 'string(5)', ...
    'string(10)', 'datetime','datetime'}, 'VariableNames', {'RowType', 'Hospital', 'SmartCareID', 'AdmissionID', 'Admitted', 'Discharge', ...
    'AntibioticID', 'AntibioticName','Route', 'HomeIV','Start','Stop'});
rowtoadd = matchtable;
matchtable(1,:) = [];

exceptiontable = table('Size',[1 6], 'VariableTypes', {'string(35)','string(8)', 'int32', 'int32', 'datetime', 'datetime'}, ...
    'VariableNames', {'RowType','Hospital', 'SmartCareID', 'AdmissionID', 'Admitted', 'Discharge'});
exceptiontable(1,:) = [];

matchedidx = [];

for i = 1:size(cdAdmissions,1)
    scid = cdAdmissions.ID(i);
    admitted = cdAdmissions.Admitted(i);
    discharge = cdAdmissions.Discharge(i);
    
    idx = find(cdAntibiotics.ID == scid & (cdAntibiotics.StartDate >= (admitted-days(7))) & (cdAntibiotics.StartDate <= (discharge+days(7))));
    matchedidx = [matchedidx; idx];
    
    rowtoadd.SmartCareID = scid;
    rowtoadd.Hospital = cdAdmissions.Hospital(i);
    rowtoadd.AdmissionID = cdAdmissions.HospitalAdmissionID(i);
    rowtoadd.Admitted = admitted;
    rowtoadd.Discharge = discharge;
    
    if (size(idx,1) == 0)
        rowtoadd.RowType = '*** Admission with no treatment ***';
        fprintf('%35s  :  Hospital %8s  Patient ID %3d  Admitted  %11s  Discharge  %11s\n', ... 
            rowtoadd.RowType, string(rowtoadd.Hospital), scid, datestr(admitted,1), datestr(discharge,1)); 
        exceptiontable = [exceptiontable;rowtoadd(1,{'RowType','Hospital', 'SmartCareID', 'AdmissionID', 'Admitted', 'Discharge'})];  
    else
        for t = 1:size(idx,1)
            rowtoadd.RowType = 'OK - Treatment during admission';
            rowtoadd.AntibioticID = cdAntibiotics.AntibioticID(idx(t));
            rowtoadd.AntibioticName = cdAntibiotics.AntibioticName{idx(t)};
            rowtoadd.Route = cdAntibiotics.Route{idx(t)};
            rowtoadd.HomeIV = cdAntibiotics.HomeIV_s_{idx(t)};
            rowtoadd.Start = cdAntibiotics.StartDate(idx(t));
            rowtoadd.Stop = cdAntibiotics.StopDate(idx(t));
        
            fprintf('%35s  :  Hospital %8s  Patient ID %3d  Admitted  %11s  Discharge  %11s  :  Antibiotic ID %3d %15s %5s %5s  Start  %11s  End  %11s\n', ... 
                rowtoadd.RowType, string(rowtoadd.Hospital), scid, datestr(admitted,1), datestr(discharge,1), rowtoadd.AntibioticID, ...
                string(rowtoadd.AntibioticName), string(rowtoadd.Route), string(rowtoadd.HomeIV), datestr(rowtoadd.Start,1), datestr(rowtoadd.Stop,1)); 
        
            matchtable = [matchtable;rowtoadd];  
        end
    end
end

toc
fprintf('\n');

tic
umatchedidx = unique(matchedidx);
abidx = find(cdAntibiotics.ID);
residualidx = setdiff(abidx, umatchedidx);

residualtable = table('Size',[1 9], 'VariableTypes', {'string(38)', 'string(8)', 'int32', 'int32', 'string(15)', 'string(5)', 'string(10)', 'datetime', 'datetime'}, ...
    'VariableNames', {'RowType', 'Hospital', 'SmartCareID', 'AntibioticID', 'AntibioticName', 'Route', 'HomeIV', 'Start', 'Stop'});
iptable = residualtable;
rowtoadd = residualtable;
residualtable(1,:) = [];
iptable(1,:) = [];

for i = 1:size(residualidx,1)
    scid = cdAntibiotics.ID(residualidx(i));
    route = cdAntibiotics.Route{residualidx(i)};
    homeiv = cdAntibiotics.HomeIV_s_{residualidx(i)};
    
    rowtoadd.SmartCareID = scid;
    rowtoadd.Hospital = cdAntibiotics.Hospital{residualidx(i)};
    rowtoadd.Route = route;
    rowtoadd.HomeIV = homeiv;

    if (isequal(route,'IV') & ismember(homeiv, {'No', 'part','IP+OP'}))
        rowtoadd.RowType = '*** Hospital IV with no Admission ***';
        rowtoadd.AntibioticID = cdAntibiotics.AntibioticID(residualidx(i));
        rowtoadd.AntibioticName = cdAntibiotics.AntibioticName{residualidx(i)};
        rowtoadd.Start = cdAntibiotics.StartDate(residualidx(i));
        rowtoadd.Stop = cdAntibiotics.StopDate(residualidx(i));
        
        fprintf('%38s  :  Hospital %8s  Patient ID %3d  :  Antibiotic ID %3d %15s %5s %5s  Start  %11s  End  %11s\n', ... 
                rowtoadd.RowType, rowtoadd.Hospital, scid, rowtoadd.AntibioticID, rowtoadd.AntibioticName, route, ...
                homeiv, datestr(rowtoadd.Start,1), datestr(rowtoadd.Stop,1)); 
        
        iptable = [iptable; rowtoadd];
    else
        rowtoadd.RowType = 'Ok - Oral or Home IV treatment';
        rowtoadd.AntibioticID = cdAntibiotics.AntibioticID(residualidx(i));
        rowtoadd.AntibioticName = cdAntibiotics.AntibioticName{residualidx(i)};
        rowtoadd.Start = cdAntibiotics.StartDate(residualidx(i));
        rowtoadd.Stop = cdAntibiotics.StopDate(residualidx(i));
        
        fprintf('%38s  :  Hospital %8s  Patient ID %3d  :  Antibiotic ID %3d %15s %5s %5s  Start  %11s  End  %11s\n', ... 
                rowtoadd.RowType, rowtoadd.Hospital, scid, rowtoadd.AntibioticID, rowtoadd.AntibioticName, route, ...
                homeiv, datestr(rowtoadd.Start,1), datestr(rowtoadd.Stop,1)); 
        
        residualtable = [residualtable; rowtoadd];
    end
end
toc
fprintf('\n');

fprintf('Completeness check - %3d rows missing\n', size(cdAntibiotics,1) - size(iptable,1) - size(umatchedidx,1) - size(residualtable,1));
fprintf('\n');

tic
fprintf('Saving results\n');
matchtable = sortrows(matchtable, {'Hospital','SmartCareID','Admitted'}, 'ascend');
exceptiontable = sortrows(exceptiontable, {'Hospital','SmartCareID','Admitted'}, 'ascend');
residualtable = sortrows(residualtable, {'Hospital','SmartCareID','Start'}, 'ascend');
iptable = sortrows(iptable, {'Hospital','SmartCareID','Start'}, 'ascend');

writetable(exceptiontable, fullfile(basedir, subfolder,outputfilename), 'Sheet', exceptionsheet);
writetable(iptable,        fullfile(basedir, subfolder,outputfilename), 'Sheet', ipsheet);
writetable(matchtable,     fullfile(basedir, subfolder,outputfilename), 'Sheet', matchsheet);
writetable(residualtable,  fullfile(basedir, subfolder,outputfilename), 'Sheet', residualsheet);


toc
fprintf('\n');
    