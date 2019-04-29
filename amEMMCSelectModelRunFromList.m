function [modelrun, modelidx, models] = amEMMCSelectModelRunFromList(loadtype)

% amEMMCSelectModelRunFromList - allows you to load the saved variables from a
% historical model run (either all the variables or just the prob
% distributions/distance function arrays. For the version handling multiple
% sets of latent curves
     
SCmodelsVEMMC_C1_rm4 = {
            'SCvEMMC_sig4_mu3_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'SCvEMMC_sig4_mu3_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'SCvEMMC_sig4_mu4_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj1.39416912';
            'SCvEMMC_sig4_mu5_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'SCvEMMC_sig4_mu5_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'SCvEMMC_sig4_mu3_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'SCvEMMC_sig4_mu3_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'SCvEMMC_sig4_mu4_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'SCvEMMC_sig4_mu5_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'SCvEMMC_sig4_mu5_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'SCvEMMC_sig4_mu3_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'SCvEMMC_sig4_mu3_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'SCvEMMC_sig4_mu4_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'SCvEMMC_sig4_mu5_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'SCvEMMC_sig4_mu5_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl1_ex-28_obj';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
         };     

 SCmodelsVEMMC_C2_rm4 = {
            'placeholder';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj1.34756307'; % did not fully converge
            'SCvEMMC_sig4_mu4_ca2_sm2_rm4_im1_cm2_mm4_mo25_dw25_nl2_ex-29-28_obj1.36167748'; % did not fully converge
            'placeholder';
            'placeholder';
            'SCvEMMC_sig4_mu5_ca2_sm1_rm4_im1_cm2_mm4_mo20_dw25_nl2_ex-28_obj'; % did not fully converge
            'placeholder';
            'placeholder';
            'SCvEMMC_sig4_mu5_ca2_sm2_rm4_im1_cm2_mm4_mo15_dw25_nl2_ex-28_obj'; % did not fully converge
         };     

SCmodelsVEMMC_C2_rm7 = {
            'SCvEMMC_sig4_mu4_ca2_sm2_rm7_im1_cm2_mm1_mo25_dw25_nl2_ex-27-32_obj1.36490643'; % did not fully converge
            'SCvEMMC_sig4_mu4_ca2_sm2_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-27-31_obj1.36242133';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm7_im1_cm2_mm4_mo25_dw25_nl2_ex-27-30_obj1.36677220';
            'placeholder';
            'placeholder';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm7_im1_cm2_mm4_mo20_dw25_nl2_ex-15-28_obj1.37414073';
            'placeholder';
            'placeholder';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm7_im1_cm2_mm4_mo15_dw25_nl2_ex-17-32_obj1.37941825'; % did not fully converge
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm8_im1_cm2_mm4_mo20_dw25_nl3_ex-23-25-12_obj1.35214044';
         };
     
 SCmodelsVEMMC_C3_rm8 = {
            'SCvEMMC_sig4_mu4_ca2_sm2_rm8_im1_cm2_mm1_mo25_dw25_nl3_ex-xxx_objxxx'; 
            'SCvEMMC_sig4_mu4_ca2_sm2_rm8_im1_cm2_mm3_mo25_dw25_nl3_ex-xxx_objxxx';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm8_im1_cm2_mm4_mo25_dw25_nl3_ex-xxx_objxxx';
            'placeholder';
            'placeholder';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm8_im1_cm2_mm4_mo20_dw25_nl3_ex-23-25-12_obj1.35214044';
            'placeholder';
            'placeholder';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm8_im1_cm2_mm4_mo15_dw25_nl3_ex-xxx_objxxx'; 
         };  

fprintf('Pick Model set\n');
fprintf('--------------\n');
fprintf(' 1: Damian SC - vEMMC - 1 Set  of Latent Curves, Uniform Offset start\n');
fprintf(' 2: Damian SC - vEMMC - 2 Sets of Latent Curves, Random Curve, Uniform Offset start\n');
fprintf(' 3: Damian SC - vEMMC - 2 Sets of Latent Curves, FEV1Split Curve, Uniform Offset start\n');
fprintf(' 4: Damian SC - vEMMC - 3 Sets of Latent Curves, Elective + FEV1Split Curve, Uniform Offset start\n');

modelset = input('Choose model set (1-4) ');

if modelset > 4
    fprintf('Invalid choice\n');
    return;
end
if isequal(modelset,'')
    fprintf('Invalid choice\n');
    return;
end

if modelset == 1
    models = SCmodelsVEMMC_C1_rm4;
elseif modelset == 2
    models = SCmodelsVEMMC_C2_rm4;
elseif modelset == 3
    models = SCmodelsVEMMC_C2_rm7;
elseif modelset == 4
    models = SCmodelsVEMMC_C3_rm8;
else
    fprintf('Should not get here\n');
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

