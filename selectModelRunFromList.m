function [modelrun, modelidx, models] = selectModelRunFromList(loadtype)

% selectModelRunFromList - allows you to load the saved variables from a
% historical model run (either all the variables or just the prob
% distributions/distance function arrays.

damianmodels = {  
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
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm2_mm3_mo25_dw25_ex-27_obj10768.2854';
            'placeholder';
            
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm1_ob1_mm2_mo25_dw25_ex-27_obj17477.2629';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm1_ob1_mm2_mo25_dw25_ex-27_obj17419.4511';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm2_ob1_mm2_mo25_dw25_ex-xx_objxxxx.xxxx';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm5_ob1_mm2_mo25_dw25_ex-27_obj17477.2629';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm4_ob1_mm2_mo25_dw25_ex-27_obj17384.2629';
            
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm1_ob1_mm3_mo25_dw25_ex-27_obj32115.4702';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm1_ob1_mm3_mo25_dw25_ex-27_obj32042.1136';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm2_ob1_mm3_mo25_dw25_ex-xx_objxxxxx.xxxx';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm5_ob1_mm3_mo25_dw25_ex-27_obj32115.4702';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-27_obj32077.8214';
            
            'SC_AMvEM_sig3_mu3_ca2_sm2_rm4_ob1_mm2_mo25_dw25_ex-27_obj17402.3337';
            'SC_AMvEM_sig3_mu3_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-27_obj32015.6861';
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm2_ob1_mm2_mo25_dw25_ex-27_obj17383.5845';
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm2_ob1_mm3_mo25_dw25_ex-27_obj32004.1787';
            'placeholder';
            
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            
            'SC_AMv4c_sig4_mu3_ca2_sm1_rm1_ob1_mm2_mo25_dw25_ex-28_obj17836.3116';
            'SC_AMv4c_sig4_mu3_ca2_sm2_rm1_ob1_mm2_mo25_dw25_ex-28_obj17850.8576';
            'SC_AMv4c_sig4_mu3_ca2_sm2_rm2_ob1_mm2_mo25_dw25_ex-28_obj17806.9471';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm5_ob1_mm2_mo25_dw25_ex-28_obj17836.3116';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm2_mo25_dw25_ex-28_obj17797.4510';
            
            'SC_AMv4c_sig4_mu3_ca2_sm1_rm1_ob1_mm3_mo25_dw25_ex-28_obj32500.5703';
            'SC_AMv4c_sig4_mu3_ca2_sm2_rm1_ob1_mm3_mo25_dw25_ex-28_obj32461.0147';
            'SC_AMv4c_sig4_mu3_ca2_sm2_rm2_ob1_mm3_mo25_dw25_ex-28_obj32449.6955';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm5_ob1_mm3_mo25_dw25_ex-28_obj32500.5703';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj32486.8715';
            
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm2_mo25_dw25_ex-28_obj17826.4088';
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj32464.4365';
            'SC_AMv4c_sig4_mu3_ca2_sm1_rm2_ob1_mm2_mo25_dw25_ex-28_obj17778.1399';
            'SC_AMv4c_sig4_mu3_ca2_sm1_rm2_ob1_mm3_mo25_dw25_ex-27_obj31672.5924';
            'placeholder';
            
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.8308';
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm2_mo25_dw25_ex-28_obj318.6805';
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm1_mo25_dw25_ex-28_obj291.2961';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm1_mo25_dw25_ex-28_obj291.1600';
            'TM_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj9531.1669';
            
         };
     
dragomodels = {  
            '<insert name of matlab saved variable file here>';
            '<leave off the .mat from the name';
            'etc';
            
         };

fprintf('Pick Model set\n');
fprintf('--------------\n');
fprintf('1: Damian\n');
fprintf('2: Drago\n');

modelset = input('Choose model set (1-2) ');

if modelset > 2
    fprintf('Invalid choice\n');
    return;
end
if isequal(modelset,'')
    fprintf('Invalid choice\n');
    return;
end

if modelset == 1
    models = damianmodels;
else
    models = dragomodels;
end


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

