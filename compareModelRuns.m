clear; close all; clc;

models = {  'SC_AMv4c_sig3_mu3_ca2_sm1_rm1_mm2_mo25_dw25_ex-26_obj4609.9914.mat';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm1_mm2_mo25_dw25_ex-26_obj4593.9558.mat';
            'SC_AMv4c_sig3_mu3_ca2_sm1_rm2_mm2_mo25_dw25_ex-26_obj4565.2372.mat';
            'SC_AMv4c_sig3_mu3_ca2_sm2_rm2_mm2_mo25_dw25_ex-27_obj4557.8883.mat';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm5_mm2_mo25_dw25_ex-26_obj4609.9914.mat';
            'SC_AMvEM_sig3_mu3_ca2_sm1_rm4_mm2_mo25_dw25_ex-27_obj4587.4418.mat';
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

fprintf('\n');
basedir = './';
subfolder = 'MatlabSavedVariables';
fprintf('Loading output from first model run\n');
load(fullfile(basedir, subfolder, models{modelidx1}));

amDatacube1           = amDatacube;
amIntrDatacube1       = amIntrDatacube;
amIntrNormcube1       = amIntrNormcube;
amInterventions1      = amInterventions;
meancurvedata1        = meancurvedata;
meancurvesum1         = meancurvesum;
meancurvecount1       = meancurvecount;
meancurvemean1        = meancurvemean;
meancurvestd1         = meancurvestd;
initial_offsets1      = initial_offsets;
offsets1              = offsets;
qual1                 = qual;
unaligned_profile1    = unaligned_profile;
hstg1                 = hstg;
pdoffset1             = pdoffset;
overall_hist1         = overall_hist;
overall_hist_all1     = overall_hist_all;
overall_hist_xAL1     = overall_hist_xAL;
overall_pdoffset1     = overall_pdoffset;
overall_pdoffset_all1 = overall_pdoffset_all;
overall_pdoffset_xAL1 = overall_pdoffset_xAL;
sorted_interventions1 = sorted_interventions;
normmean1             = normmean;
normstd1              = normstd;
measures1             = measures;
study1                = study;
version1              = version;
sigmamethod1          = sigmamethod;
mumethod1             = mumethod;
curveaveragingmethod1 = curveaveragingmethod;
smoothingmethod1      = smoothingmethod;
measuresmask1         = measuresmask;
runmode1              = runmode;
printpredictions1     = printpredictions;
max_offset1           = max_offset;
align_wind1           = align_wind;
ex_start1             = ex_start;
nmeasures1            = nmeasures;
ninterventions1       = ninterventions;

fprintf('Loading output from second model run\n');
load(fullfile(basedir, subfolder, models{modelidx2}));

amDatacube2           = amDatacube;
amIntrDatacube2       = amIntrDatacube;
amIntrNormcube2       = amIntrNormcube;
amInterventions2      = amInterventions;
meancurvedata2        = meancurvedata;
meancurvesum2         = meancurvesum;
meancurvecount2       = meancurvecount;
meancurvemean2        = meancurvemean;
meancurvestd2         = meancurvestd;
initial_offsets2      = initial_offsets;
offsets2              = offsets;
qual2                 = qual;
unaligned_profile2    = unaligned_profile;
hstg2                 = hstg;
pdoffset2             = pdoffset;
overall_hist2         = overall_hist;
overall_hist_all2     = overall_hist_all;
overall_hist_xAL2     = overall_hist_xAL;
overall_pdoffset2     = overall_pdoffset;
overall_pdoffset_all2 = overall_pdoffset_all;
overall_pdoffset_xAL2 = overall_pdoffset_xAL;
sorted_interventions2 = sorted_interventions;
normmean2             = normmean;
normstd2              = normstd;
measures2             = measures;
study2                = study;
version2              = version;
sigmamethod2          = sigmamethod;
mumethod2             = mumethod;
curveaveragingmethod2 = curveaveragingmethod;
smoothingmethod2      = smoothingmethod;
measuresmask2         = measuresmask;
runmode2              = runmode;
printpredictions2     = printpredictions;
max_offset2           = max_offset;
align_wind2           = align_wind;
ex_start2             = ex_start;
nmeasures2            = nmeasures;
ninterventions2       = ninterventions;

fprintf('\n');
fprintf('Comparing models:\n');
fprintf('%s\n', models{modelidx1});
fprintf('%s\n', models{modelidx2});
fprintf('\n');

plotsdown = 9;
plotsacross = 5;
mpos = [ 1 2 6 7 ; 3 4 8 9 ; 11 12 16 17 ; 13 14 18 19 ; 21 22 26 27 ; 23 24 28 29 ; 31 32 36 37 ; 33 34 38 39];
hpos = [ 5 ; 10 ; 15 ; 20 ; 25 ; 30 ; 35 ; 40 ; 45 ; 44 ; 43 ; 42 ; 41 ];
days = [-1 * (max_offset1 + align_wind1 - 1): -1];

% comparing offsets
fprintf('Comparing offsets:\n\n');
offset_array = [offsets1, offsets2, offsets1-offsets2];

mismatch_threshold = 3;
mismatchidx = find(abs(offsets1 - offsets2) >= mismatch_threshold);

for i = 0:max_offset-1
    idx = find(abs(offsets1 - offsets2) == i);
    if (size(idx,1) > 0)
        fprintf('+/-%d days: %2d of %2d interventions\n', i, size(idx,1), ninterventions1);
        if i < mismatch_threshold
            for a = 1:size(idx,1)
                fprintf('%2d ', idx(a));
                if (a/20 == round(a/20))
                    fprintf('\n');
                end
            end
            fprintf('\n\n');
        else
            for a = 1:size(idx,1)
                fprintf('%2d: Offset %2d vs %2d\n', idx(a), offset_array(idx(a),1), offset_array(idx(a),2));
                scid = amInterventions1.SmartCareID(idx(a));
                start = amInterventions1.IVScaledDateNum(idx(a));
                name = sprintf('%s_AM%s Exacerbation %d - ID %d Date %s Offsets %2d vs %2d', study1, version1, idx(a), scid, ...
                    datestr(amInterventions1.IVStartDate(idx(a)),29), offset_array(idx(a),1), offset_array(idx(a),2));
                [f, p] = createFigureAndPanel(name, 'portrait', 'a4');
                for m = 1:nmeasures
                    if all(isnan(amIntrDatacube(idx(a), :, m)))
                        continue;
                    end
                    xl = [0 0];
                    yl = [min((meancurvemean2(1:max_offset2 + align_wind2 - 1 - offsets2(idx(a)), m) + normmean1(idx(a), m)) * .99) ...
                        max((meancurvemean2(1:max_offset2 + align_wind2 - 1 - offsets2(idx(a)), m) + normmean1(idx(a), m)) * 1.01)];
                    ax = subplot(plotsdown, plotsacross, mpos(m,:), 'Parent',p);
                    [xl, yl] = plotMeasurementDataAndMean(ax, days, amIntrDatacube1(idx(a), :, m), xl, yl, normmean1(idx(a), m), measures1(m,:));
                    [xl, yl] = plotLatentCurveAndExStart(ax, [(-1 * (max_offset1 + align_wind1 - 1)) + offsets1(idx(a)): -1], ...
                        meancurvemean1(1:max_offset1 + align_wind1 - 1 - offsets1(idx(a)), m), xl, yl, normmean1(idx(a), m), ex_start1, offsets1(idx(a)), 'red');
                    [xl, yl] = plotLatentCurveAndExStart(ax, [(-1 * (max_offset2 + align_wind2 - 1)) + offsets2(idx(a)): -1], ...
                        meancurvemean2(1:max_offset2 + align_wind2 - 1 - offsets2(idx(a)), m), xl, yl, normmean2(idx(a), m), ex_start2, offsets2(idx(a)), 'magenta');
                    [xl, yl] = plotTreatmentStart(ax, 0, xl, yl);
                end
                savePlot(f, name);
                close(f);
            end
            fprintf('\n');
        end
    end
end









