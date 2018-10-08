function [modelrun, modelidx, models] = selectModelRunFromList(loadtype)

% selectModelRunFromList - allows you to load the saved variables from a
% historical model run (either all the variables or just the prob
% distributions/distance function arrays.

SCmodelsold = {  
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
            'placeholder';
            %'TM_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj9531.1669';
            
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.7499';
            'SC_AMvEM_sig4_mu4_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.5482';
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.8308';
            'SC_AMvEM_sig4_mu4_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.6818';
         };
     
SCmodelsnew = {  
            'placeholder';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm2_mo25_dw25_ex-28_obj317.8905';
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm2_mo25_dw25_ex-28_obj318.6805';
            'SC_AMvEM_sig4_mu4_ca2_sm1_rm4_ob1_mm2_mo25_dw25_ex-28_obj317.8905';
            'SC_AMvEM_sig4_mu4_ca2_sm2_rm4_ob1_mm2_mo25_dw25_ex-28_obj318.6805';
            
            'placeholder';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.7499';
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.8308';
            'SC_AMvEM_sig4_mu4_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.5482';
            'SC_AMvEM_sig4_mu4_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj293.6818';
            
            'placeholder';
            'SC_AMvEM_sig4_mu3_ca2_sm1_rm4_ob1_mm1_mo25_dw25_ex-28_obj291.1600';
            'SC_AMvEM_sig4_mu3_ca2_sm2_rm4_ob1_mm1_mo25_dw25_ex-28_obj291.2961';
            'SC_AMvEM_sig4_mu4_ca2_sm1_rm4_ob1_mm1_mo25_dw25_ex-28_obj290.9940';
            'SC_AMvEM_sig4_mu4_ca2_sm2_rm4_ob1_mm1_mo25_dw25_ex-28_obj291.1567';
            
            'placeholder';
            'SC_AMvEM2_sig4_mu3_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj295.4349';
            'SC_AMvEM2_sig4_mu3_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj296.0669';
            'SC_AMvEM2_sig4_mu4_ca2_sm1_rm4_ob1_mm3_mo25_dw25_ex-28_obj295.6658';
            'SC_AMvEM2_sig4_mu4_ca2_sm2_rm4_ob1_mm3_mo25_dw25_ex-28_obj295.9340';
            
            'placeholder';
            'SC_AMvEM2_sig4_mu3_ca2_sm1_rm4_ob1_mm1_mo25_dw25_ex-28_obj292.6813';
            'SC_AMvEM2_sig4_mu3_ca2_sm2_rm4_ob1_mm1_mo25_dw25_ex-28_obj293.2933';
            'SC_AMvEM2_sig4_mu4_ca2_sm1_rm4_ob1_mm1_mo25_dw25_ex-28_obj292.6343';
            'SC_AMvEM2_sig4_mu4_ca2_sm2_rm4_ob1_mm1_mo25_dw25_ex-28_obj292.9482';
            
            'placeholder';
            'SC_AMvEM2_sig4_mu3_ca2_sm1_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj135.6674';
            'SC_AMvEM2_sig4_mu3_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj135.5826';
            'SC_AMvEM2_sig4_mu4_ca2_sm1_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj135.3840';
            'placeholder';
            
            'placeholder';
            'SC_AMvEM2_sig4_mu3_ca2_sm2_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj135.4247';
            'placeholder';
            'placeholder';
            'SC_AMvEM2_sig4_mu4_ca2_sm2_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj135.3157';
            
            
         };

TMmodelsnew = {  
            'TM_AMvEM2_sig4_mu3_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj38.1535';
            'TM_AMvEM2_sig4_mu4_ca2_sm2_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj38.4991';
            'TM_AMvEM2_sig4_mu4_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj38.1535';
            'TM_AMvEM2_sig4_mu5_ca2_sm1_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj38.2212';
            'TM_AMvEM2_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj37.7257';
            'TM_AMvEM2_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj37.4667';
            'TM_AMvEM2_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj37.0931';
            'TM_AMvEM2_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj38.2047'; % 28 interventions
            'TM_AMvEM2_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj38.4291'; % 28 interventions
            'TM_AMvEM2_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm3_mo25_dw25_ex-28_obj37.1701'; % 28 interventions and outlier prior = 1%
            'TM_AMvEM2_sig4_mu5_ca2_sm2_rm4_ob1_im1_mm1_mo25_dw25_ex-28_obj37.3985'; % 28 interventions and outlier prior = 1%
            
            };
            
     
     
fprintf('Pick Model set\n');
fprintf('--------------\n');
fprintf('1: Damian SC - Old\n');
fprintf('2: Damian SC - New\n');
fprintf('3: Damian TM - New\n');

modelset = input('Choose model set (1-3) ');

if modelset > 3
    fprintf('Invalid choice\n');
    return;
end
if isequal(modelset,'')
    fprintf('Invalid choice\n');
    return;
end

if modelset == 1
    models = SCmodelsold;
elseif modelset == 2
    models = SCmodelsnew;
else
    models = TMmodelsnew;
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

