clear; close all; clc;

studynbr = input('Enter Study to run for (1 = SmartCare, 2 = TeleMed): ');

if studynbr == 1
    study = 'SC';
    clinicalmatfile = 'clinicaldata.mat';
    datamatfile = 'smartcaredata.mat';
elseif studynbr == 2
    study = 'TM';
    clinicalmatfile = 'telemedclinicaldata.mat';
    datamatfile = 'telemeddata.mat';
else
    fprintf('Invalid study\n');
    return;
end

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
fprintf('Loading clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading measurement data\n');
load(fullfile(basedir, subfolder, datamatfile));
toc

if studynbr == 2
    physdata = tmphysdata;
    cdPatient = tmPatient;
    cdMicrobiology = tmMicrobiology;
    cdAntibiotics = tmAntibiotics;
    cdAdmissions = tmAdmissions;
    cdPFT = tmPFT;
    cdCRP = tmCRP;
    cdClinicVisits = tmClinicVisits;
    cdEndStudy = tmEndStudy;
    offset = tmoffset;
end

[modelrun, modelidx, models] = selectModelRunFromList('');

fprintf('Loading model run results data\n');
load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun)));


    
outputdata = table('Size',[1 8], ...
    'VariableTypes', {'double', 'double',        'datetime',   'double', 'double', 'double' ,           'double',   'double'     }, ...
    'VariableNames', {'ID',     'ScaledDateNum', 'Date', 'OralAB', 'IVAB',   'InterventionStart', 'CRPLevel', 'ExStartProb'});

tempmeasures = measures(measures.Mask==1,:);
mnum = size(tempmeasures,1);
mcols = nan(1,mnum);
mcols = array2table(mcols);
outputdata = [outputdata mcols];
for i = 1:mnum
    outputdata.Properties.VariableNames{i+8} = sprintf('%s_Raw',tempmeasures.DisplayName{i});
end
outputdata = [outputdata mcols];
for i = 1:mnum
    outputdata.Properties.VariableNames{i+8+mnum} = sprintf('%s_Smooth',tempmeasures.DisplayName{i});
end

rowtoadd = outputdata;

patientoffsets = getPatientOffsets(physdata);

%for i = 1:size(cdPatient,1)
for i = 1:1   
    outputdata(1:size(outputdata,1),:) = [];
    scid = cdPatient.ID(i);
    
    minscdn = min(physdata.ScaledDateNum(physdata.SmartCareID == scid));
    minscdt = min(physdata.Date_TimeRecorded(physdata.SmartCareID == scid));
    maxscdn = max(physdata.ScaledDateNum(physdata.SmartCareID == scid));
    maxscdt = max(physdata.Date_TimeRecorded(physdata.SmartCareID == scid));
    
    for a = minscdn:maxscdn
        rowtoadd.ID            = scid;
        rowtoadd.ScaledDateNum = a;
        rowtoadd.CRPLevel = nan;
        outputdata = [outputdata; rowtoadd];
    end
    outputdata.Date = [datetime(minscdt-seconds(1)):datetime(maxscdt-seconds(1))]';
     
    tmpInterventions = amInterventions(amInterventions.SmartCareID == scid,:);
    for a = 1:size(tmpInterventions,1)
        outputdata.InterventionStart(tmpInterventions.IVScaledDateNum(a)) = 1;
    end
    
    tmpCRP = cdCRP(cdCRP.ID == scid,:);
    for a = 1:size(tmpCRP,1)
        scdatenum = datenum(tmpCRP.CRPDate(a)) + 1 - offset - patientoffsets.PatientOffset(patientoffsets.SmartCareID==scid);
        outputdata.CRPLevel(outputdata.ScaledDateNum==scdatenum) = tmpCRP.NumericLevel(a);
       fprintf('ScaledDataNum = %d, Date = %s, Level = %d\n', scdatenum, ...
           datestr(tmpCRP.CRPDate(a),1), tmpCRP.NumericLevel(a));
    end
    
    tmpOralAB = cdAntibiotics(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, 'Oral'),:);
    for a = 1:size(tmpOralAB,1)
        startdn = datenum(tmpOralAB.StartDate(a)) + 1 - offset - patientoffsets.PatientOffset(patientoffsets.SmartCareID==scid);
        stopdn  = datenum(tmpOralAB.StopDate(a))  + 1 - offset - patientoffsets.PatientOffset(patientoffsets.SmartCareID==scid);
        outputdata.OralAB(outputdata.ScaledDateNum >= startdn & outputdata.ScaledDateNum <= stopdn) = 1;
        fprintf('Oral AB ScaledDateNum %d:%d, Date = %s:%s\n', startdn, stopdn, ...
           datestr(tmpOralAB.StartDate(a),1), datestr(tmpOralAB.StopDate(a),1)) ;
    end
    
    tmpIVAB   = cdAntibiotics(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, 'IV'),:);
    for a = 1:size(tmpIVAB,1)
        startdn = datenum(tmpIVAB.StartDate(a)) + 1 - offset - patientoffsets.PatientOffset(patientoffsets.SmartCareID==scid);
        stopdn  = datenum(tmpIVAB.StopDate(a))  + 1 - offset - patientoffsets.PatientOffset(patientoffsets.SmartCareID==scid);
        outputdata.IVAB(outputdata.ScaledDateNum >= startdn & outputdata.ScaledDateNum <= stopdn) = 1;
        fprintf('IV AB ScaledDateNum %d:%d, Date = %s:%s\n', startdn, stopdn, ...
           datestr(tmpIVAB.StartDate(a),1), datestr(tmpIVAB.StopDate(a),1)) ;
    end
    
        
end



