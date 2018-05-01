clc; clear; close all;

tic

basedir = './';
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'clinicaldata.mat';
scmatfile = 'smartcaredata.mat';
ivandmeasuresfile = 'ivandmeasures.mat';
datademographicsfile = 'datademographicsbypatient.mat';


fprintf('Loading Clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
fprintf('Loading SmartCare measurement data\n');
load(fullfile(basedir, subfolder, scmatfile));
fprintf('Loading iv treatment and measures prior data\n');
load(fullfile(basedir, subfolder, ivandmeasuresfile));
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, datademographicsfile));
toc

plotsacross = 1;
plotsdown = 3;
plotsperpage = plotsacross * plotsdown;
basedir = './';
subfolder = 'Plots';

patientlist = unique(physdata.SmartCareID);

for i = 1:size(patientlist,1)
    scid = patientlist(i);
    
    f = figure('Name',sprintf('Patient Summary: %d', scid));
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0.45, 0, 0.35, 0.92], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
    p = uipanel('Parent', f, 'BorderType', 'none'); 
    p.Title = sprintf('Patient Summary: %d', scid); 
    p.TitlePosition = 'centertop';
    p.FontSize = 20;
    p.FontWeight = 'bold';
    sp = uipanel('Parent', p, 'OuterPosition', [0, 0.6, 1.0, 1.0]);
    spt = textarea(
    hold on;