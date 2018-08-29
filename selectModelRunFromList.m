function [modelrun, modelidx] = selectModelRunFromList(loadtype)

% selectModelRunFromList - allows you to load the saved variables from a
% historical model run (either all the variables or just the prob
% distributions/distance function arrays.

models = {  
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm1_mm2_mo25_dw25_ex-26_obj4595.2626';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm1_mm2_mo25_dw25_ex-27_obj4602.0068';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm2_mm2_mo25_dw25_ex-27_obj4557.8883';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm5_mm2_mo25_dw25_ex-26_obj4595.2626';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm4_mm2_mo25_dw25_ex-27_obj4536.9297';
            
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm1_mm3_mo25_dw25_ex-27_obj10964.9323';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm1_mm3_mo25_dw25_ex-27_obj10815.2946';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm2_mm3_mo25_dw25_ex-27_obj10753.8213';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm5_mm3_mo25_dw25_ex-27_obj10964.9323';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm4_mm3_mo25_dw25_ex-27_obj10775.2724';
            
            'SC_AMvEM_sig3_mu3_ca2_sm2_rm4_mm2_mo25_dw25_ex-27_obj4559.9901';
            'SC_AMvEM_sig3_mu3_ca2_sm2_rm4_mm3_mo25_dw25_ex-27_obj10779.2176';
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm2_mm2_mo25_dw25_ex-27_obj4551.0881';
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm2_mm3_mo25_dw25_ex-27_obj10768.2854'
         };

% other models to potentially add
% sig4 version (although zero offset start is infinity
% vEM with bet random start from 3 or 4

nmodels = size(models,1);

fprintf('Model runs available\n');
fprintf('--------------------\n');
for i = 1:nmodels
    fprintf('%d: %s\n', i, models{i});
end
fprintf('\n');

modelidx = input('Choose model run to use ? ');
if modelidx > nmodels 
    fprintf('Invalid choice\n');
    return;
end
if isequal(modelidx,'')
    fprintf('Invalid choice\n');
    return;
end
fprintf('\n');

if isequal(loadtype,'pd')
    modelrun = sprintf('%s-PDs',models{modelidx});
else
    modelrun = models{modelidx};
end

end

