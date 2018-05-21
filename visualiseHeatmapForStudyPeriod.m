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
f2 = createHeatmapOfPatientsAndMeasures(physdata(physdata.ScaledDateNum<184,{'SmartCareID','ScaledDateNum'}), colors, 'Heatmap of Patient Measures during Study Period', 1, 1, 'a3');

basedir = './';
subfolder = 'Plots';
filenameappend = 'ForStudyPeriod';
fullfilename = strcat('HeatmapAllPatients', filenameappend, '.png');
saveas(f2,fullfile(basedir, subfolder, fullfilename));
fullfilename = strcat('HeatmapAllPatients', filenameappend, '.svg');
saveas(f2,fullfile(basedir, subfolder, fullfilename));

toc
fprintf('\n');
