clear; close all; clc;

fprintf('Select first model to compare\n');
fprintf('\n');

[modelrun1, modelidx1] = selectModelRunFromList('');

fprintf('Select second model to compare\n');
fprintf('\n');

[modelrun2, modelidx2] = selectModelRunFromList('');

fprintf('\n');
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
fprintf('Loading output from first model run\n');
load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun1)));

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
load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun2)));

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
fprintf('%s\n', modelrun1);
fprintf('%s\n', modelrun2);
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
                actualpoints1 = 0;
                maxpoints1 = 0;
                actualpoints2 = 0;
                maxpoints2 = 0;
                for m = 1:nmeasures
                    if (measures1.Mask(m) == 1)
                        actualpoints1 = actualpoints1 + sum(~isnan(amIntrDatacube1(idx(a), max_offset1:max_offset1+align_wind1-1, m)));
                        maxpoints1 = maxpoints1 + align_wind1;
                    end
                    if (measures2.Mask(m) == 1)
                        actualpoints2 = actualpoints2 + sum(~isnan(amIntrDatacube2(idx(a), max_offset2:max_offset2+align_wind2-1, m)));
                        maxpoints2 = maxpoints2 + align_wind2;
                    end  
                end
                datacompleteness1 = 100 * actualpoints1/maxpoints1;
                datacompleteness2 = 100 * actualpoints2/maxpoints2;
                
                fprintf('%2d: Offset %2d vs %2d, Data Completeness = %.2f%% %.2f%%\n', idx(a), offset_array(idx(a),1), offset_array(idx(a),2), datacompleteness1, datacompleteness2);
                scid = amInterventions1.SmartCareID(idx(a));
                name = sprintf('%s_AM Prediction Comparison m%d vs m%d - Ex %d (ID %d Date %s) Offset %2d vs %2d', study1, modelidx1, modelidx2, idx(a), scid, ...
                    datestr(amInterventions1.IVStartDate(idx(a)),29), offset_array(idx(a),1), offset_array(idx(a),2));
                
                [f, p] = createFigureAndPanel(name, 'portrait', 'a4');
                
                for m = 1:nmeasures
                    if all(isnan(amIntrDatacube(idx(a), :, m)))
                        continue;
                    end
                    % initialise plot areas
                    xl = [0 0];
                    yl = [min((meancurvemean2(1:max_offset2 + align_wind2 - 1 - offsets2(idx(a)), m) + normmean1(idx(a), m)) * .99) ...
                        max((meancurvemean2(1:max_offset2 + align_wind2 - 1 - offsets2(idx(a)), m) + normmean1(idx(a), m)) * 1.01)];
                    
                    % create subplot and plot required data arrays
                    ax = subplot(plotsdown, plotsacross, mpos(m,:), 'Parent',p);
                    
                    [xl, yl] = plotMeasurementData(ax, days, amIntrDatacube1(idx(a), :, m), xl, yl, measures1(m,:), [0, 0.65, 1], '-', 1.0, 'o', 2.0, 'blue', 'green');
                    if measures1.Mask(m) == 1 && measures2.Mask(m) == 1
                        title(measures1.DisplayName(m), 'FontSize', 6, 'BackgroundColor', 'yellow');
                    elseif measures1.Mask(m) == 1
                        title(measures1.DisplayName(m), 'FontSize', 6, 'BackgroundColor', 'cyan');
                    elseif measures2.Mask(m) == 1
                        title(measures1.DisplayName(m), 'FontSize', 6, 'BackgroundColor', 'green');
                    else
                        title(measures1.DisplayName(m),'FontSize', 6);
                    end
                    
                    [xl, yl] = plotHorizontalLine(ax, normmean1(idx(a), m), xl, yl, 'blue', '--', 0.5); % plot mean
                    
                    [xl, yl] = plotLatentCurve(ax, max_offset1, align_wind1, offsets1(idx(a)), (meancurvemean1(:, m) + normmean1(idx(a), m)), xl, yl, 'red', ':', 1.0);
                    [xl, yl] = plotLatentCurve(ax, max_offset1, align_wind1, offsets1(idx(a)), smooth(meancurvemean1(:, m) + normmean1(idx(a), m),5), xl, yl, 'red', '-', 1.0);
                    
                    [xl, yl] = plotLatentCurve(ax, max_offset2, align_wind2, offsets2(idx(a)), (meancurvemean2(:, m) + normmean2(idx(a), m)), xl, yl, 'magenta', ':', 1.0);
                    [xl, yl] = plotLatentCurve(ax, max_offset2, align_wind2, offsets2(idx(a)), smooth(meancurvemean2(:, m) + normmean2(idx(a), m),5), xl, yl, 'magenta', '-', 1.0);
                    
                    [xl, yl] = plotExStart(ax, ex_start1, offsets1(idx(a)), xl, yl,  'red', '-', 0.5);
                    [xl, yl] = plotExStart(ax, ex_start2, offsets2(idx(a)), xl, yl, 'magenta', '-', 0.5);
                    
                    [xl, yl] = plotVerticalLine(ax, 0, xl, yl, 'cyan', '-', 0.5); % plot treatment start
                    
                    xl2 = [0 max_offset-1];
                    yl2 = [0 0.25];
                    
                    ax2 = subplot(plotsdown, plotsacross, hpos(m,:),'Parent',p); 
                    
                    [xl2, yl2] = plotProbDistribution(ax2, max_offset1, pdoffset1(m, idx(a),:), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');
                    [xl2, yl2] = plotProbDistribution(ax2, max_offset2, pdoffset2(m, idx(a),:), xl2, yl2, 'o', 0.5, 2.0, 'green', 'green'); 
                    
                    [xl2, yl2] = plotVerticalLine(ax2, offsets1(idx(a)), xl2, yl2, 'blue', '-', 0.5); % plot predicted offset
                    [xl2, yl2] = plotVerticalLine(ax2, offsets2(idx(a)), xl2, yl2, 'green', '-', 0.5); % plot predicted offset
                    
                    set(gca,'fontsize',6);
                    if measures1.Mask(m) == 1 && measures2.Mask(m) == 1
                        title(sprintf('%s %.1f %.1f', measures1.DisplayName{m}, hstg1(m, idx(a), offsets1(idx(a)) + 1), hstg2(m, idx(a), offsets2(idx(a)) + 1)), 'BackgroundColor', 'yellow');
                    elseif measures1.Mask(m) == 1
                        title(sprintf('%s %.1f %.1f', measures1.DisplayName{m}, hstg1(m, idx(a), offsets1(idx(a)) + 1), hstg2(m, idx(a), offsets2(idx(a)) + 1)), 'BackgroundColor', 'cyan');
                    elseif measures2.Mask(m) == 1
                        title(sprintf('%s %.1f %.1f', measures1.DisplayName{m}, hstg1(m, idx(a), offsets1(idx(a)) + 1), hstg2(m, idx(a), offsets2(idx(a)) + 1)), 'BackgroundColor', 'green');
                    else
                        title(sprintf('%s %.1f %.1f', measures1.DisplayName{m}, hstg1(m, idx(a), offsets1(idx(a)) + 1), hstg2(m, idx(a), offsets2(idx(a)) + 1)));
                    end
                    
                end
                
                xl2 = [0 max_offset-1];
                yl2 = [0 0.25];
                
                ax2 = subplot(plotsdown, plotsacross, hpos(nmeasures + 1,:),'Parent',p); 
                
                [xl2, yl2] = plotProbDistribution(ax2, max_offset1, overall_pdoffset1(idx(a),:), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');
                [xl2, yl2] = plotProbDistribution(ax2, max_offset2, overall_pdoffset2(idx(a),:), xl2, yl2, 'o', 0.5, 2.0, 'green', 'green'); 
                    
                [xl2, yl2] = plotVerticalLine(ax2, offsets1(idx(a)), xl2, yl2, 'blue', '-', 0.5); % plot predicted offset
                [xl2, yl2] = plotVerticalLine(ax2, offsets2(idx(a)), xl2, yl2, 'green', '-', 0.5); % plot predicted offset
                
                set(gca,'fontsize',6);
                %title('Overall', 'BackgroundColor', 'g');
                title(sprintf('Overall %.1f %.1f', overall_hist1(idx(a), offsets1(idx(a)) + 1), overall_hist2(idx(a), offsets2(idx(a)) + 1)), 'BackgroundColor', 'yellow');
                
                xl2 = [0 max_offset-1];
                yl2 = [0 0.25];
                
                ax2 = subplot(plotsdown, plotsacross, hpos(nmeasures + 2,:),'Parent',p); 
                
                [xl2, yl2] = plotProbDistribution(ax2, max_offset1, overall_pdoffset_all1(idx(a),:), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');
                [xl2, yl2] = plotProbDistribution(ax2, max_offset2, overall_pdoffset_all2(idx(a),:), xl2, yl2, 'o', 0.5, 2.0, 'green', 'green'); 
                    
                [xl2, yl2] = plotVerticalLine(ax2, offsets1(idx(a)), xl2, yl2, 'blue', '-', 0.5); % plot predicted offset
                [xl2, yl2] = plotVerticalLine(ax2, offsets2(idx(a)), xl2, yl2, 'green', '-', 0.5); % plot predicted offset
                
                set(gca,'fontsize',6);
                %title('Overall - All');
                title(sprintf('Overall - All %.1f %.1f', overall_hist_all1(idx(a), offsets1(idx(a)) + 1), overall_hist_all2(idx(a), offsets2(idx(a)) + 1)));
                
                xl2 = [0 max_offset-1];
                yl2 = [0 0.25];
                
                ax2 = subplot(plotsdown, plotsacross, hpos(nmeasures + 3,:),'Parent',p); 
                
                [xl2, yl2] = plotProbDistribution(ax2, max_offset1, overall_pdoffset_xAL1(idx(a),:), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');
                [xl2, yl2] = plotProbDistribution(ax2, max_offset2, overall_pdoffset_xAL2(idx(a),:), xl2, yl2, 'o', 0.5, 2.0, 'green', 'green'); 
                    
                [xl2, yl2] = plotVerticalLine(ax2, offsets1(idx(a)), xl2, yl2, 'blue', '-', 0.5); % plot predicted offset
                [xl2, yl2] = plotVerticalLine(ax2, offsets2(idx(a)), xl2, yl2, 'green', '-', 0.5); % plot predicted offset
                
                set(gca,'fontsize',6);
                %title('Overall - xAL');
                title(sprintf('Overall - xAL %.1f %.1f', overall_hist_xAL1(idx(a), offsets1(idx(a)) + 1), overall_hist_xAL2(idx(a), offsets2(idx(a)) + 1)));
                
                plotsubfolder = 'Plots';
                savePlotInDir(f, name, plotsubfolder);
                close(f);
            end
            fprintf('\n');
        end
    end
end









