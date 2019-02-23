clear; clc; close all;

tic
fprintf('Creating TeleMed data structures\n');
fprintf('---------------------------------\n');
basedir =setBaseDir();
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'clinicaldata.mat';
scmatfile = 'smartcaredata.mat';
fprintf('Loading equivalent smartcare data structures as baseline\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
load(fullfile(basedir, subfolder, scmatfile));
fprintf('Done\n');

tmAdmissions        = cdAdmissions;
admrowtoadd         = tmAdmissions(1,:);
tmAdmissions(:,:)   = [];

tmAntibiotics       = cdAntibiotics;
ivabrowtoadd        = tmAntibiotics(1,:);
poabrowtoadd        = tmAntibiotics(1,:);
tmAntibiotics(:,:)  = [];

tmClinicVisits      = cdClinicVisits;
cvrowtoadd         = tmClinicVisits(1,:); 
tmClinicVisits(:,:) = [];

tmCRP               = cdCRP;
crprowtoadd         = tmCRP(1,:);
tmCRP(:,:)          = [];

tmMicrobiology      = cdMicrobiology;
tmMicrobiology(:,:) = [];

tmEndStudy          = cdEndStudy;
tmEndStudy(:,:)     = [];

tmPatient           = cdPatient;
tmPatient(:,:)      = [];

tmPFT               = cdPFT;
pftrowtoadd         = tmPFT(1,:);
tmPFT(:,:)          = [];

tmphysdata          = physdata;
phrowtoadd          = tmphysdata(1,:);
tmphysdata(:,:)     = [];
tmoffset            = datenum('2013/01/31');

toc
fprintf('\n');

tic
basedir = setBaseDir();
subfolder = 'DataFiles/TeleMed';
clinicalfile = 'FEVdata-complete.xlsx';

fprintf('Loading Telemed clinical patient data\n');
tmPatientInfo = readtable(fullfile(basedir, subfolder, clinicalfile));
tmPatientInfo(:,{'AZM','inhPx','PNL','Diabetes'}) = [];
tmPatientInfo.ID = str2double(strrep(tmPatientInfo.Patient, 'K', ''));
tmPatientInfo = sortrows(tmPatientInfo,{'ID'});
tmPatientInfo.PredFEV1 = tmPatientInfo.FEV1_L_Av ./ (tmPatientInfo.FEV1___Av/100);
tmPatientInfo.FEV1SetAs = round(tmPatientInfo.PredFEV1,1);

ntmpatients = size(tmPatientInfo,1);
tmPatient.ID(1:ntmpatients) = tmPatientInfo.ID;
tmPatient.Hospital(1:ntmpatients) = {'PAP'};
%for i = 1:size(tmPatient,1)
%    tmPatient.Hospital{i} = 'PAP';
%end
tmPatient.StudyNumber = cellstr(num2str(tmPatient.ID));
tmPatient.Age = tmPatientInfo.Age;
tmPatient.DOB = datetime(2013-tmPatient.Age, 1, 1);
tmPatient.Sex = tmPatientInfo.Gender;
tmPatient.Height = tmPatientInfo.Height;
tmPatient.PredictedFEV1 = tmPatientInfo.PredFEV1;
tmPatient.FEV1SetAs = tmPatientInfo.FEV1SetAs;

fprintf('Populate calculated PredictedFEV1 and FEV1SetAs\n');
tmMalePatient = tmPatient(ismember(tmPatient.Sex,'M'),:);
tmFemalePatient = tmPatient(~ismember(tmPatient.Sex,'M'),:);
tmMalePatient.CalcPredictedFEV1 = (tmMalePatient.Height * 0.01 * 4.3) - (tmMalePatient.Age * 0.029) - 2.49;
tmFemalePatient.CalcPredictedFEV1 = (tmFemalePatient.Height * 0.01 * 3.95) - (tmFemalePatient.Age * 0.025) - 2.6;
tmMalePatient.CalcFEV1SetAs = round(tmMalePatient.CalcPredictedFEV1,1);
tmFemalePatient.CalcFEV1SetAs = round(tmFemalePatient.CalcPredictedFEV1,1);
tmPatient = sortrows([tmMalePatient ; tmFemalePatient], {'ID'}, 'ascend');

tmEndStudy.ID(1:ntmpatients) = tmPatient.ID;
tmEndStudy.Hospital = tmPatient.Hospital;
tm.StudyNumber = tmPatient.StudyNumber;
for i = 1:size(tmEndStudy,1)
    tmEndStudy.EndOfStudyReason{i} = 'Completed Study';
end

toc
fprintf('\n');

tic
for i = 1:ntmpatients
    tmdatafile = sprintf('K%d.xlsx', i);
    fprintf('Loading data for Patient K%d\n', i);
    tmData = readtable(fullfile(basedir, subfolder, tmdatafile));
    tmData(:,{'PEANg_ml', 'IVAminophylline', 'POTheophylline', 'Steroids', 'WCC', 'Fat', 'Bone', 'Muscle', 'Visceral', 'peakFlow', 'Calories', 'Distance', 'Duration'}) = []; 
    if i ~= 11 && i ~= 15
        tmData.Date = datetime(tmData.Date, 'InputFormat', 'dd.MM.yy');
    end
    [tmPatient, tmClinicVisits, tmAdmissions, tmAntibiotics, tmCRP, tmPFT, tmphysdata] = ...,
        convertTeleMedData(tmData, tmPatient, tmClinicVisits, tmAdmissions, tmAntibiotics, tmCRP, tmPFT, tmphysdata, ...
        cvrowtoadd, admrowtoadd, poabrowtoadd, ivabrowtoadd, crprowtoadd, pftrowtoadd, phrowtoadd, i, tmoffset);
    fprintf('\n');    
end

% populate id's in clinical tables
fprintf('Populating ids in clinical tables\n');
tmClinicVisits.ClinicID = [1:size(tmClinicVisits,1)]';
tmAdmissions.HospitalAdmissionID = [1:size(tmAdmissions,1)]';
tmAntibiotics.AntibioticID = [1:size(tmAntibiotics,1)]';
tmCRP.CRPID = [1:size(tmCRP,1)]';
tmPFT.LungFunctionID = [1:size(tmPFT,1)]';
tmEndStudy.EndOfStudyID = [1:size(tmEndStudy,1)]';

% populate Study Date in clinical patient table
fprintf('Populating study date in clinical patient table\n');
minDatesByPatient = varfun(@min, tmphysdata(:,{'SmartCareID', 'Date_TimeRecorded'}), 'GroupingVariables', 'SmartCareID');
minDatesByPatient.GroupCount = [];
minDatesByPatient.Properties.VariableNames({'SmartCareID'}) = {'ID'};
minDatesByPatient.Properties.VariableNames({'min_Date_TimeRecorded'}) = {'MinPatientDate'};
tmPatient = innerjoin(tmPatient, minDatesByPatient);
tmPatient.StudyDate = tmPatient.MinPatientDate;
tmPatient.MinPatientDate = [];

% populate ScaledDateNum in measurement data table
fprintf('Populating ScaledDateNum in measurement data\n');
minDatesByPatient = varfun(@min, tmphysdata(:,{'SmartCareID', 'DateNum'}), 'GroupingVariables', 'SmartCareID');
minDatesByPatient.GroupCount = [];
minDatesByPatient.Properties.VariableNames({'min_DateNum'}) = {'MinPatientDateNum'};
tmphysdata = innerjoin(tmphysdata,minDatesByPatient);
tmphysdata.ScaledDateNum = tmphysdata.DateNum - tmphysdata.MinPatientDateNum + 1;
tmphysdata.MinPatientDateNum = [];

% remove invalid HR and O2 measures from patient K14
tmphysdata(isnan(tmphysdata.DateNum),:) = [];

%remove 0 measurements for LungFunction, O2 Saturation, Pulse
counter = 1;
idloc = zeros(1,2);
for i=1:size(tmphysdata,1)
    if isequal(tmphysdata.RecordingType(i),cellstr('LungFunctionRecording'))
        if tmphysdata.FEV1_(i) == 0
            idloc(counter) = i;
            counter = counter+1;
        end
    elseif isequal(tmphysdata.RecordingType(i),cellstr('O2SaturationRecording'))
        if tmphysdata.O2Saturation(i) == 0
            idloc(counter) = i;
            counter = counter+1;
        end
    elseif isequal(tmphysdata.RecordingType(i),cellstr('PulseRateRecording'))
        if tmphysdata.Pulse_BPM_(i) == 0
            idloc(counter) = i;
            counter = counter+1;
        end
    else
    end
end

tmphysdata(idloc,:) = [];
fprintf('Removed %d measurement rows with zero values\n', counter - 1);

toc
fprintf('\n');    

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
tmclinicalmatfile = 'telemedclinicaldata.mat';
tmmatfile = 'telemeddata.mat';
fprintf('Saving telemed clinical data variables to file %s\n', tmclinicalmatfile);
save(fullfile(basedir, subfolder,tmclinicalmatfile), 'tmPatient', 'tmClinicVisits', 'tmPFT', 'tmAdmissions', 'tmAntibiotics', 'tmCRP', 'tmMicrobiology', 'tmEndStudy');
fprintf('Saving telemed measurement data variables to file %s\n', tmclinicalmatfile);
save(fullfile(basedir, subfolder, tmmatfile), 'tmphysdata', 'tmoffset');

toc




