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

pdcountmtable = varfun(@max, physdata_predateoutlierhandling(:, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});
pcountdmtable = varfun(@sum, pdcountmtable, 'GroupingVariables', {'SmartCareID'});

h = histogram(pcountdmtable.GroupCount,5);
h.BinEdges = [0 40 80 120 500];

h.Values






