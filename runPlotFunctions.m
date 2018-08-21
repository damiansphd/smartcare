clear; close all; clc;

models = {  'SC_AMv4c_sig3_mu3_ca2_sm1_rm1_mm2_mo25_dw25_ex-26_obj4609.9914.mat';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm1_mm2_mo25_dw25_ex-26_obj4593.9558.mat';
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm2_mm2_mo25_dw25_ex-26_obj4565.2372.mat';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm2_mm2_mo25_dw25_ex-27_obj4557.8883.mat';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm5_mm2_mo25_dw25_ex-26_obj4609.9914.mat';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm4_mm2_mo25_dw25_ex-27_obj4587.4418.mat';
            
            'TM_AMv4c_sig3_mu3_ca2_sm1_rm1_mm2_mo25_dw25_ex-25_obj1824.1270.mat';
            'TM_AMv4c_sig3_mu3_ca2_sm2_rm2_mm2_mo25_dw25_ex-26_obj1767.7903.mat';
            'TM_AMvEM_sig3_mu3_ca2_sm1_rm5_mm2_mo25_dw25_ex-25_obj1824.1270.mat';
            'TM_AMvEM_sig3_mu3_ca2_sm1_rm4_mm2_mo25_dw25_ex-26_obj1800.7496.mat';
            'TM_AMvEM_sig3_mu3_ca2_sm1_rm5_mm1_mo25_dw25_ex-25_obj4936.7227.mat';
            'TM_AMvEM_sig3_mu3_ca2_sm1_rm5_mm3_mo25_dw25_ex-26_obj3100.1715.mat';
            
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm1_mm2_mo25_dw25_ex-26_obj4595.2626.mat';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm5_mm2_mo25_dw25_ex-26_obj4595.2626.mat';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm4_mm2_mo25_dw25_ex-27_obj4536.9297.mat';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm1_mm2_mo25_dw25_ex-27_obj4602.0068.mat';
         };
     
% other models to potentially add
% sig4 version (although zero offset start is infinity
% vEM with bet random start from 3 or 4

nmodels = size(models,1);

fprintf('Models available for comparison\n');
fprintf('-------------------------------\n');
for i = 1:nmodels
    fprintf('%d: %s\n', i, models{i});
end
fprintf('\n');

modelidx1 = input('Choose model to plot predictions for ? ');
if modelidx1 > nmodels 
    fprintf('Invalid choice\n');
    return;
end
if isequal(modelidx1,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('Choose function to run\n');
fprintf('----------------------\n');
fprintf('1: Run prediction plots\n');
fprintf('2: Run alignment animation (concurrent)\n');
fprintf('3: Run alignment animation (sequential)\n');
fprintf('4: Run prod dist animation (concurrent)\n');
runfunction = input('Choose function (1-4) ');
fprintf('\n');
if runfunction > 4
    fprintf('Invalid choice\n');
    return;
end
if isequal(runfunction,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('\n');
basedir = './';
subfolder = 'MatlabSavedVariables';
fprintf('Loading output from model run\n');
load(fullfile(basedir, subfolder, models{modelidx1}));

if runfunction == 1
    tic
    fprintf('Plotting prediction results\n');
    for i=1:ninterventions
        amEMPlotsAndSavePredictions(amInterventions, amIntrDatacube, measures, pdoffset, overall_pdoffset, overall_pdoffset_all, overall_pdoffset_xAL, ...
            hstg, overall_hist, overall_hist_all, overall_hist_xAL, offsets, meancurvemean, normmean, ex_start, i, nmeasures, max_offset, align_wind, study, version);
    end
    toc
    fprintf('\n');
elseif runfunction == 2
    tic
    fprintf('Running concurrent alignment animation\n');
    [f, p, niterations] = animatedAlignmentConcurrent(animatedmeancurvemean, animatedoffsets, unaligned_profile, measures, max_offset, align_wind, nmeasures, ninterventions);
    toc
    fprintf('\n');
elseif runfunction == 3
    tic
    fprintf('Running sequential alignment animation\n');
    [f, p, niterations] = animatedAlignmentSequential(animatedmeancurvemean, unaligned_profile, measures, max_offset, align_wind, nmeasures);
    toc
    fprintf('\n');
else
    tic
    fprintf('Running concurrent prod distribution animation\n');
    [f, p, niterations] = animatedProbDistConcurrent(animated_overall_pdoffset, max_offset, ninterventions);
    toc
    fprintf('\n');
    
end
    

