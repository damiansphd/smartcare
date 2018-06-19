clear; clc; close all;

tic
fprintf('Creating TeleMed data structures\n');
fprintf('---------------------------------\n');
basedir = './';
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'clinicaldata.mat';
fprintf('Loading equivalent smartcare data structures as baseline\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
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
tmPatient           = cdPatient;
tmPatient(:,:)      = [];
tmPFT               = cdPFT;
pftrowtoadd         = tmPFT(1,:);
tmPFT(:,:)          = [];
toc
fprintf('\n');

tic
basedir = './';
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
for i = 1:size(tmPatient,1)
    tmPatient.Hospital{i} = 'PAP';
end
tmPatient.Age = tmPatientInfo.Age;
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

fprintf('\n');
tic
for i = 1:ntmpatients
    tmdatafile = sprintf('K%d.xlsx', i);
    fprintf('Loading data for Patient K%d\n', i);
    tmData = readtable(fullfile(basedir, subfolder, tmdatafile));
    tmData(:,{'PEANg_ml', 'IVAminophylline', 'POTheophylline', 'Steroids', 'WCC', 'Fat', 'Bone', 'Muscle', 'Visceral', 'peakFlow', 'Calories', 'Distance', 'Duration'}) = []; 
    if i ~= 11 & i ~= 15
        tmData.Date = datetime(tmData.Date, 'InputFormat', 'dd.MM.yy');
    end
    [tmClinicVisits, tmAdmissions, tmAntibiotics, tmCRP, tmPFT] = convertTeleMedData(tmData, tmPatient, tmClinicVisits, tmAdmissions, tmAntibiotics, tmCRP, tmPFT, ...
            cvrowtoadd, admrowtoadd, poabrowtoadd, ivabrowtoadd, crprowtoadd, pftrowtoadd, i);
    fprintf('\n');
        
end

toc




