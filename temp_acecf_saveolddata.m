clear; close all; clc;

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
modelinputsmatfile = 'ACvEMMC_gp10_lm1_sig4_mu4_ca2_sm2_rm4_in1_im1_cm2_mm26_mo25_dw25_nl1_rs4_ds1_ct3_sc2024-rr_vs0_vm0.0_ni50_ex-32_obj5.45632170.mat';

fprintf('Loading alignment model results from 20240202 %s\n', modelinputsmatfile);
fprintf('\n');

tic
load(fullfile(basedir, subfolder, modelinputsmatfile));

amInterventions_20240202    = amInterventions;
amDatacube_20240202         = amDatacube;
amIntrDatacube_20240202     = amIntrDatacube;
amIntrNormcube_20240202     = amIntrNormcube;
normmean_20240202           = normmean;
normstd_20240202            = normstd;
meancurvesum_20240202       = meancurvesum;
meancurvesumsq_20240202     = meancurvesumsq;
meancurvecount_20240202     = meancurvecount;
meancurvemean_20240202      = meancurvemean;
meancurvestd_20240202       = meancurvestd;
unaligned_profile_20240202  = unaligned_profile;

outputfilename = 'amdata_20240202.mat';
fprintf('Saving alignment model results to file %s\n', outputfilename);
fprintf('\n');
save(fullfile(basedir, subfolder, outputfilename), 'amDatacube_20240202', 'amIntrDatacube_20240202', ...
    'amIntrNormcube_20240202', 'amInterventions_20240202', 'normmean_20240202', 'normstd_20240202', ...
    'meancurvesum_20240202', 'meancurvesumsq_20240202', 'meancurvecount_20240202', 'meancurvemean_20240202', ...
    'meancurvestd_20240202', 'unaligned_profile_20240202');
toc

