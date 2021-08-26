clc; clear; close all;

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

[studynbr, study, studyfullname] = selectStudy();
[datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
[physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);

basedir = setBaseDir();
subfolder = 'ExcelFiles';
outputfilename = sprintf('%s-AdmissionsVsAntibiotics-%s.xlsx', study, datestr(today, 'yyyymmdd'));
exceptionsheet = '1)AdmissionWithNoTreatment';
matchsheet = '3)AdmissionsWithTreatments';
ipsheet = '2)HospitalIVWithNoAdmission';
residualsheet = '4)HomeTreatments';

tic
% get patients with enough data
patientoffsets = getPatientOffsets(physdata);
patientoffsets.Properties.VariableNames{'SmartCareID'} = 'ID';

% sort by SmartCareID and StartDate
cdAntibiotics = sortrows(cdAntibiotics, {'ID','StartDate'},'ascend');
cdAntibiotics = innerjoin(cdAntibiotics, patientoffsets);

cdAdmissions = sortrows(cdAdmissions, {'ID','Admitted'}, 'ascend');
cdAdmissions = innerjoin(cdAdmissions, patientoffsets);

matchtable = table('Size',[1 13], 'VariableTypes', {'string(35)', 'string(8)', 'int32', 'string(20)', 'int32', 'datetime', 'datetime','int32', 'string(15)', 'string(5)', ...
    'string(10)', 'datetime','datetime'}, 'VariableNames', {'RowType', 'Hospital', 'SmartCareID', 'StudyNumber', 'AdmissionID', 'Admitted', 'Discharge', ...
    'AntibioticID', 'AntibioticName','Route', 'HomeIV','Start','Stop'});
rowtoadd = matchtable;
matchtable(1,:) = [];

exceptiontable = table('Size',[1 7], 'VariableTypes', {'string(35)','string(8)', 'int32', 'string(20)', 'int32', 'datetime', 'datetime'}, ...
    'VariableNames', {'RowType','Hospital', 'SmartCareID', 'StudyNumber', 'AdmissionID', 'Admitted', 'Discharge'});
exceptiontable(1,:) = [];

matchedidx = [];

for i = 1:size(cdAdmissions,1)
    scid = cdAdmissions.ID(i);
    admitted = cdAdmissions.Admitted(i);
    discharge = cdAdmissions.Discharge(i);
    
    idx = find(cdAntibiotics.ID == scid & (cdAntibiotics.StartDate >= (admitted-days(7))) & (cdAntibiotics.StartDate <= (discharge+days(7))));
    matchedidx = [matchedidx; idx];
    
    rowtoadd.SmartCareID = scid;
    rowtoadd.StudyNumber = cdAdmissions.StudyNumber(i);
    rowtoadd.Hospital = cdAdmissions.Hospital(i);
    %rowtoadd.AdmissionID = cdAdmissions.HospitalAdmissionID(i);
    rowtoadd.Admitted = admitted;
    rowtoadd.Discharge = discharge;
    
    if (size(idx,1) == 0)
        rowtoadd.RowType = '*** Admission with no treatment ***';
        fprintf('%3d: %35s  :  Hospital %8s  Patient ID %3d Admitted  %11s  Discharge  %11s (Study Nbr %s)\n', ... 
            i, rowtoadd.RowType, string(rowtoadd.Hospital), scid, datestr(admitted,1), datestr(discharge,1), string(rowtoadd.StudyNumber)); 
        exceptiontable = [exceptiontable;rowtoadd(1,{'RowType','Hospital', 'SmartCareID', 'StudyNumber', 'AdmissionID', 'Admitted', 'Discharge'})];  
    else
        for t = 1:size(idx,1)
            rowtoadd.RowType = 'OK - Treatment during admission';
            %rowtoadd.AntibioticID = cdAntibiotics.AntibioticID(idx(t));
            rowtoadd.AntibioticName = cdAntibiotics.AntibioticName{idx(t)};
            rowtoadd.Route = cdAntibiotics.Route{idx(t)};
            %rowtoadd.HomeIV = cdAntibiotics.HomeIV_s_{idx(t)};
            rowtoadd.Start = cdAntibiotics.StartDate(idx(t));
            rowtoadd.Stop = cdAntibiotics.StopDate(idx(t));
        
            fprintf('%3d: %35s  :  Hospital %8s  Patient ID %3d  Admitted  %11s  Discharge  %11s  : %15s %5s Start  %11s  End  %11s (Study Nbr %s)\n', ... 
                i, rowtoadd.RowType, string(rowtoadd.Hospital), scid, datestr(admitted,1), datestr(discharge,1), ...
                string(rowtoadd.AntibioticName), string(rowtoadd.Route), datestr(rowtoadd.Start,1), datestr(rowtoadd.Stop,1), string(rowtoadd.StudyNumber)); 
        
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

residualtable = table('Size',[1 10], 'VariableTypes', {'string(38)', 'string(8)', 'int32', 'string(20)', 'int32', 'string(15)', 'string(5)', 'string(10)', 'datetime', 'datetime'}, ...
    'VariableNames', {'RowType', 'Hospital', 'SmartCareID', 'StudyNumber', 'AntibioticID', 'AntibioticName', 'Route', 'HomeIV', 'Start', 'Stop'});
iptable = residualtable;
rowtoadd = residualtable;
residualtable(1,:) = [];
iptable(1,:) = [];

for i = 1:size(residualidx,1)
    scid = cdAntibiotics.ID(residualidx(i));
    route = cdAntibiotics.Route{residualidx(i)};
    if studynbr == 3 | studynbr == 4
        homeiv = cdAntibiotics.HomeIV_s{residualidx(i)};
    else
        homeiv = cdAntibiotics.HomeIV_s_{residualidx(i)};
    end
    
    rowtoadd.SmartCareID = scid;
    rowtoadd.StudyNumber = cdAntibiotics.StudyNumber(residualidx(i));
    rowtoadd.Hospital = cdAntibiotics.Hospital{residualidx(i)};
    rowtoadd.Route = route;
    rowtoadd.HomeIV = homeiv;

    if (isequal(route,'IV') & ismember(homeiv, {'No', 'part','IP+OP'}))
    %if (isequal(route,'IV'))
        rowtoadd.RowType = '*** Hospital IV with no Admission ***';
        %rowtoadd.AntibioticID = cdAntibiotics.AntibioticID(residualidx(i));
        rowtoadd.AntibioticName = cdAntibiotics.AntibioticName{residualidx(i)};
        rowtoadd.Start = cdAntibiotics.StartDate(residualidx(i));
        rowtoadd.Stop = cdAntibiotics.StopDate(residualidx(i));
        
        fprintf('%38s  :  Hospital %8s  Patient ID %3d  : %15s %5s Start  %11s  End  %11s (Study Nbr %s)\n', ... 
                rowtoadd.RowType, rowtoadd.Hospital, scid, rowtoadd.AntibioticName, route, ...
                datestr(rowtoadd.Start,1), datestr(rowtoadd.Stop,1), string(rowtoadd.StudyNumber)); 
        
        iptable = [iptable; rowtoadd];
    else
        rowtoadd.RowType = 'Ok - Oral or Home IV treatment';
        %rowtoadd.AntibioticID = cdAntibiotics.AntibioticID(residualidx(i));
        rowtoadd.AntibioticName = cdAntibiotics.AntibioticName{residualidx(i)};
        rowtoadd.Start = cdAntibiotics.StartDate(residualidx(i));
        rowtoadd.Stop = cdAntibiotics.StopDate(residualidx(i));
        
        fprintf('%38s  :  Hospital %8s  Patient ID %3d  : %15s %5s Start  %11s  End  %11s (Study Nbr %s)\n', ... 
                rowtoadd.RowType, rowtoadd.Hospital, scid, rowtoadd.AntibioticName, route, ...
                datestr(rowtoadd.Start,1), datestr(rowtoadd.Stop,1), string(rowtoadd.StudyNumber)); 
        
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
    