clear; close all; clc;

models = {  'SC_AMv4c_sig3_mu3_ca2_sm1_rm1_mm2_mo25_dw25_ex-26_obj4609.9914.mat';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm1_mm2_mo25_dw25_ex-26_obj4593.9558.mat';
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm2_mm2_mo25_dw25_ex-27_obj4559.8753.mat';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm2_mm2_mo25_dw25_ex-27_obj4557.8883.mat';
            'SC_AMvEM_sig3_mu3_ca2_ea2_mm2_mo25_dw25_ex-26_obj4609.9914.mat';
            'SC_AMvEM_sig3_mu3_ca2_ea1_mm2_mo25_dw25_ex-27_obj4587.4418.mat';
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

modelidx1 = input('Choose first model ? ');
if modelidx1 > nmodels 
    fprintf('Invalid choice\n');
    return;
end
if isequal(modelidx1,'')
    fprintf('Invalid choice\n');
    return;
end

modelidx2 = input('Choose second model ? ');
if modelidx2 > nmodels 
    fprintf('Invalid choice\n');
    return;
end
if isequal(modelidx2,'')
    fprintf('Invalid choice\n');
    return;
end

if modelidx1 == modelidx2
    fprintf('Invalid choice\n');
    return;
end

basedir = './';
subfolder = 'MatlabSavedVariables';
fprintf('Loading output from first model run\n');
load(fullfile(basedir, subfolder, models{modelidx1}));


