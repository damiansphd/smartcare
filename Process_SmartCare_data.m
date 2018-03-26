% clear all user defined variables, close all figures/plots, clear the terminal screen
clear;close all;clc;

%----------------------------------------

load('patientid_data.mat');

sc_inputFilename = 'mydata.csv';
sc_outputFilename = 'SmartCareData.mat';

tic
fprintf('Pre-processing smartcare measurement data and saving in Octave/Matlab format\n')
processAndSaveSmartCareData(sc_inputFilename,sc_outputFilename, patientID, smarcareID);
toc

%----------------------------------------


