clc; clear; close all;

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

basedir = setBaseDir();
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

tic
temp = hsv;
colors(1,:)  = [0 0 0];     % black for no measures
colors(2,:)  = temp(4,:);
colors(3,:)  = temp(6,:);
colors(4,:)  = temp(8,:);
colors(5,:)  = temp(10,:);
colors(6,:)  = temp(12,:);
colors(7,:)  = temp(14,:);
colors(8,:)  = temp(16,:);
colors(9,:)  = temp(18,:);

%f1 = createMeasuresHeatmapWithStudyPeriod(physdata, offset, cdPatient);
f2 = createHeatmapOfPatientsAndMeasures(physdata(physdata.ScaledDateNum<184,{'SmartCareID','ScaledDateNum'}), colors, strcat(study, '-Heatmap of Patient Measures during Study Period'), 1, 1, 'a3');

basedir = setBaseDir();
subfolder = 'Plots';
filenameappend = 'ForStudyPeriod';
fullfilename = strcat(study, '-HeatmapAllPatients', filenameappend);
savePlotInDir(f2, fullfilename, subfolder);
close(f2);

toc
fprintf('\n');
