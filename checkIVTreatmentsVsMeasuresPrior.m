clc; clear; close all;

studynbr = input('Enter Study to run for (1 = SmartCare, 2 = TeleMed, 3 = joint): ');

if studynbr == 1
    study = 'SC';
    clinicalmatfile = 'clinicaldata.mat';
    datamatfile = 'smartcaredata.mat';
elseif studynbr == 2
    study = 'TM';
    clinicalmatfile = 'telemedclinicaldata.mat';
    datamatfile = 'telemeddata.mat';
elseif studynbr == 3
    study = 'SC+TM';
    clinicalmatfile = 'clinicaldata.mat';
    datamatfile = 'smartcaredata.mat';
else
    fprintf('Invalid study\n');
    return;
end

tmoffset = 0;

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
fprintf('Loading clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading measurement data\n');
load(fullfile(basedir, subfolder, datamatfile));
if studynbr == 3
    clinicalmatfile = 'telemedclinicaldata.mat';
    datamatfile = 'telemeddata.mat';
    load(fullfile(basedir, subfolder, clinicalmatfile));
    load(fullfile(basedir, subfolder, datamatfile));
end
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

if studynbr == 3
    physdata = [ physdata ; tmphysdata ];
    cdPatient = [ cdPatient ; tmPatient];
    cdMicrobiology = [ cdMicrobiology ; tmMicrobiology];
    cdAntibiotics = [ cdAntibiotics ; tmAntibiotics];
    cdAdmissions = [ cdAdmissions ; tmAdmissions];
    cdPFT = [cdPFT ; tmPFT ];
    cdCRP = [cdCRP ; tmCRP];
    cdClinicVisits = [cdClinicVisits ; tmClinicVisits];
    cdEndStudy = [cdEndStudy ; tmEndStudy];
end

tic
% remove Oral treatments & sort by SmartCareID and StopDate
% after further analysis, changed to include oral ab's as well as iv ab's
%idx = find(ismember(cdAntibiotics.Route, {'Oral'}));
%cdAntibiotics(idx,:) = [];
ivTreatments = unique(cdAntibiotics(:,{'ID', 'Hospital', 'StartDate','Route'}));
ivTreatments.IVDateNum = datenum(ivTreatments.StartDate) - offset*(ivTreatments.ID >= 16) - tmoffset*(ivTreatments.ID < 16) + 1;
ivTreatments.Type = zeros(height(ivTreatments),1);

% counting and labelling - IVO = 1 , OO = 2, IVPBO = 3
oldid = 0;
oldstartdn = 0;
oldtype = '';
ooandivpbo = 0;
ivo = 0;
ivpbo = 0;
for i = 1:size(ivTreatments,1)-1
    scid = ivTreatments.ID(i);
    hospital = ivTreatments.Hospital(i);
    startdate = ivTreatments.StartDate(i);
    startdn = ivTreatments.IVDateNum(i);
    type = ivTreatments.Route(i);
    
    if ( (scid ~= oldid | startdn > oldstartdn + 25)  )
        if isequal(type,cellstr('Oral'))
            ooandivpbo = ooandivpbo + 1;
            ivTreatments.Type(i) = 2;
        else
            ivo = ivo+1;
            ivTreatments.Type(i) = 1;
        end
    else
        if ivTreatments.Type(i-1)==2 & (startdn - oldstartdn < 25) & oldid == scid
            ivpbo = ivpbo + 1;
            ivTreatments.Type(i-1) = 3;
            ivTreatments.Type(i) = 4;
        end
    end
    
    oldid = scid;
    oldstartdn = startdn;
    oldtype = type;
end
oo = ooandivpbo - ivpbo/2 ;

%end of counting & labelling

% idx = find(ismember(ivTreatments.Type,[0 1 2 4]));
% ivTreatments(idx,:) = [];
% ivTreatments = sortrows(ivTreatments,{'Type'});

% use the version of physdata before handling dateoutliers
%physdata = physdata_predateoutlierhandling;

physdata = sortrows(physdata, {'SmartCareID', 'DateNum', 'RecordingType'}, 'ascend');
numdays = 40;
Day = zeros(1,numdays);
Day = array2table(Day);
ivandmeasurestable = table('Size',[1 8], ...
    'VariableTypes', {'double',       'cell',     'datetime',    'double',     'double',            'double',         'double',        'double'}, ...
    'VariableNames', {'SmartCareID', 'Hospital', 'IVStartDate', 'IVDateNum', 'DaysWithMeasures', 'TotalMeasures', 'AvgMeasuresPerDay', 'Type' });
ivandmeasurestable = [ivandmeasurestable Day];
for i = 1:40
    ivandmeasurestable.Properties.VariableNames{i+8} = sprintf('IVminus%d',abs(i-41));
end
rowtoadd = ivandmeasurestable;
ivandmeasurestable(1,:) = [];

measuresdetailtable = physdata(1:1,:);
measuresdetailtable = [];

oldid = 0;
oldstartdn = 0;
for i = 1:size(ivTreatments,1)
    scid = ivTreatments.ID(i);
    hospital = ivTreatments.Hospital(i);
    startdate = ivTreatments.StartDate(i);
    startdn = ivTreatments.IVDateNum(i);
    
    if (scid ~= oldid | startdn > oldstartdn + 25)
        idx = find(physdata.SmartCareID == scid & physdata.DateNum < startdn & physdata.DateNum >= (startdn - numdays));
        pdcountmtable = varfun(@max, physdata(idx, {'SmartCareID','DateNum'}), 'GroupingVariables', {'SmartCareID', 'DateNum'});
    
        rowtoadd.SmartCareID = scid;
        rowtoadd.Hospital = hospital;
        rowtoadd.IVStartDate = startdate;
        rowtoadd.IVDateNum = startdn;
        rowtoadd.DaysWithMeasures = size(find(pdcountmtable.GroupCount>0),1);
        rowtoadd.TotalMeasures = sum(pdcountmtable.GroupCount);
        rowtoadd.AvgMeasuresPerDay = rowtoadd.TotalMeasures/numdays;
        rowtoadd.Type = ivTreatments.Type(i);
    
        for a = 1:numdays
            colname = sprintf('IVminus%d', a);
            dayidx = find(pdcountmtable.SmartCareID == scid & pdcountmtable.DateNum == startdn-numdays-1+a);
            if size(dayidx,1) > 0
                daymeasures = pdcountmtable.GroupCount(find(pdcountmtable.SmartCareID == scid & pdcountmtable.DateNum == startdn-numdays-1+a));
                rowtoadd{1,colname} = daymeasures;
            else
                rowtoadd{1,colname} = 0;
            end
        end
    
        ivandmeasurestable = [ivandmeasurestable ; rowtoadd];
        measuresdetailtable = [measuresdetailtable ; physdata(idx,:)];
    end
    
    oldid = scid;
    oldstartdn = startdn;
end

toc
fprintf('\n');

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%sivandmeasuresOLD.mat', study);

fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder, outputfilename), 'ivandmeasurestable');

ivandmeasurestable.IVDateNum = [];
measuresdetailtable.ScaledDateNum = [];
measuresdetailtable.DateNum = [];

fprintf('Saving results to excel\n');

basedir = setBaseDir();
subfolder = 'ExcelFiles';
outputfilename = sprintf('%sMeasuresPriorToIVTreatmentsOLD.xlsx', study);
summarysheet = 'SummaryByIVTreatment';
detailsheet = 'MeasuresDetail';

writetable(ivandmeasurestable,        fullfile(basedir, subfolder, outputfilename), 'Sheet', summarysheet);
writetable(measuresdetailtable, fullfile(basedir, subfolder, outputfilename), 'Sheet', detailsheet);

toc
fprintf('\n');
    
    
    