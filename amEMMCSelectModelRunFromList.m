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
            'SCvEMMC_sig4_mu3_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'SCvEMMC_sig4_mu3_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'SCvEMMC_sig4_mu4_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj1.34756307';
            'SCvEMMC_sig4_mu5_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'SCvEMMC_sig4_mu5_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'SCvEMMC_sig4_mu3_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'SCvEMMC_sig4_mu3_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'SCvEMMC_sig4_mu4_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'SCvEMMC_sig4_mu5_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'SCvEMMC_sig4_mu5_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'SCvEMMC_sig4_mu3_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'SCvEMMC_sig4_mu3_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'SCvEMMC_sig4_mu4_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'SCvEMMC_sig4_mu5_ca2_sm1_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'SCvEMMC_sig4_mu5_ca2_sm2_rm4_im1_cm2_mm3_mo25_dw25_nl2_ex-28_obj';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
         };     

SCmodelsVEMMC_C2_rm7 = {
            'SCvEMMC_sig4_mu3_ca2_sm1_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'SCvEMMC_sig4_mu3_ca2_sm2_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'SCvEMMC_sig4_mu4_ca2_sm1_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-27-31_obj1.36242133';
            'SCvEMMC_sig4_mu5_ca2_sm1_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'SCvEMMC_sig4_mu5_ca2_sm2_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'SCvEMMC_sig4_mu3_ca2_sm1_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'SCvEMMC_sig4_mu3_ca2_sm2_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'SCvEMMC_sig4_mu4_ca2_sm1_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'SCvEMMC_sig4_mu5_ca2_sm1_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'SCvEMMC_sig4_mu5_ca2_sm2_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
            'SCvEMMC_sig4_mu3_ca2_sm1_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'SCvEMMC_sig4_mu3_ca2_sm2_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'SCvEMMC_sig4_mu4_ca2_sm1_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'SCvEMMC_sig4_mu4_ca2_sm2_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'SCvEMMC_sig4_mu5_ca2_sm1_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'SCvEMMC_sig4_mu5_ca2_sm2_rm7_im1_cm2_mm3_mo25_dw25_nl2_ex-28_objxxx';
            'placeholder';
            'placeholder';
            'placeholder';
            'placeholder';
         };     

fprintf('Pick Model set\n');
fprintf('--------------\n');
fprintf(' 1: Damian SC - vEMMC - 1 Set  of Latent Curves, Uniform Offset start\n');
fprintf(' 2: Damian SC - vEMMC - 2 Sets of Latent Curves, Random Curve, Uniform Offset start\n');
fprintf(' 3: Damian SC - vEMMC - 2 Sets of Latent Curves, FEV1Split Curve, Uniform Offset start\n');

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
    models = SCmodelsVEMMC_C1_rm4;
elseif modelset == 2
    models = SCmodelsVEMMC_C2_rm4;
elseif modelset == 3
    models = SCmodelsVEMMC_C2_rm7;
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

