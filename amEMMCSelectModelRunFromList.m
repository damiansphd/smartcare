function [modelrun, modelidx, models] = amEMMCSelectModelRunFromList(loadtype)

% amEMMCSelectModelRunFromList - allows you to load the saved variables from a
% historical model run (either all the variables or just the prob
% distributions/distance function arrays. For the version handling multiple
% sets of latent curves
     
SCmodelsVEMMC_C1 = {
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

 SCmodelsVEMMC_C2 = {
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

fprintf('Pick Model set\n');
fprintf('--------------\n');
fprintf(' 1: Damian SC - vEMMC - 1 Set  of Latent Curves\n');
fprintf(' 2: Damian SC - vEMMC - 2 Sets of Latent Curves\n');

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
    models = SCmodelsVEMMC_C1;
elseif modelset == 2
    models = SCmodelsVEMMC_C2;
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

