function amEMMCCompareModelRuns(modelrun1, modelidx1, modelrun2, modelidx2)

fprintf('\n');
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
fprintf('Loading output from first model run\n');
load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun1)));

%amDatacube1           = amDatacube;
amIntrDatacube1       = amIntrDatacube;
%amIntrNormcube1       = amIntrNormcube;
%amHeldBackcube1       = amHeldBackcube;
%amImputedCube1        = amImputedCube;
%isOutlier1            = isOutlier;
%outprior1             = outprior;
%totaloutliers1        = totaloutliers;
%totalpoints1          = totalpoints;
amInterventions1      = amInterventions;
%meancurvesumsq1       = meancurvesumsq;
%meancurvesum1         = meancurvesum;
%meancurvecount1       = meancurvecount;
meancurvemean1        = meancurvemean;
%meancurvestd1         = meancurvestd;
%initial_offsets1      = initial_offsets;
%initial_latentcurve1  = initial_latentcurve;
%qual1                 = qual;
%unaligned_profile1    = unaligned_profile;
hstg1                 = hstg;
pdoffset1             = pdoffset;
overall_hist1         = overall_hist;
overall_pdoffset1     = overall_pdoffset;
%sorted_interventions1 = sorted_interventions;
normmean1             = normmean;
normstd1              = normstd;
measures1             = measures;
study1                = study;
mversion1             = mversion;
sigmamethod1          = sigmamethod;
mumethod1             = mumethod;
curveaveragingmethod1 = curveaveragingmethod;
smoothingmethod1      = smoothingmethod;
measuresmask1         = measuresmask;
runmode1              = runmode;
imputationmode1       = imputationmode;
printpredictions1     = printpredictions;
max_offset1           = max_offset;
align_wind1           = align_wind;
ex_start1             = ex_start;
nmeasures1            = nmeasures;
ninterventions1       = ninterventions;

fprintf('Loading output from second model run\n');
load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun2)));

%amDatacube2           = amDatacube;
amIntrDatacube2       = amIntrDatacube;
%amIntrNormcube2       = amIntrNormcube;
%amHeldBackcube2       = amHeldBackcube;
%amImputedCube2        = amImputedCube;
%isOutlier2            = isOutlier;
%outprior2             = outprior;
%totaloutliers2        = totaloutliers;
%totalpoints2          = totalpoints;
amInterventions2      = amInterventions;
%meancurvesumsq2       = meancurvesumsq;
%meancurvesum2         = meancurvesum;
%meancurvecount2       = meancurvecount;
meancurvemean2        = meancurvemean;
%meancurvestd2         = meancurvestd;
%initial_offsets2      = initial_offsets;
%initial_latentcurve2  = initial_latentcurve;
%qual2                 = qual;
%unaligned_profile2    = unaligned_profile;
hstg2                 = hstg;
pdoffset2             = pdoffset;
overall_hist2         = overall_hist;
overall_pdoffset2     = overall_pdoffset;
%sorted_interventions2 = sorted_interventions;
normmean2             = normmean;
normstd2              = normstd;
measures2             = measures;
study2                = study;
mversion2             = mversion;
sigmamethod2          = sigmamethod;
mumethod2             = mumethod;
curveaveragingmethod2 = curveaveragingmethod;
smoothingmethod2      = smoothingmethod;
measuresmask2         = measuresmask;
runmode2              = runmode;
imputationmode2       = imputationmode;
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

if nmeasures1 <= 8
    plotsdown = 9;
    plotsacross = 5;
    mpos = [ 1  2  6  7 ;  3  4  8  9 ; 
            11 12 16 17 ; 13 14 18 19 ; 
            21 22 26 27 ; 23 24 28 29 ; 
            31 32 36 37 ; 33 34 38 39 ];
    hpos = [ 5 ; 10 ; 
            15 ; 20 ; 
            25 ; 30 ; 
            35 ; 40 ; 
            45      ];
elseif nmeasures1 > 8 && nmeasures1 <= 18
    plotsdown = 14;
    plotsacross = 8;
    mpos = [ 1  2  9 10 ;  3  4 11 12 ;  5  6 13 14 ; 
            17 18 25 26 ; 19 20 27 28 ; 21 22 29 30 ; 
            33 34 41 42 ; 35 36 43 44 ; 37 38 45 46 ; 
            49 50 57 58 ; 51 52 59 60 ; 53 54 61 62 ;
            65 66 73 74 ; 67 68 75 76 ; 69 70 77 78 ; 
            81 82 89 90 ; 83 84 91 92 ; 85 86 93 94 ];
    hpos = [  7 ;  8 ; 15 ; 
             23 ; 24 ; 31 ;  
             39 ; 40 ; 47 ; 
             55 ; 56 ; 63 ; 
             71 ; 72 ; 79 ;
             87 ; 88 ; 95 ;
             103          ];
end

days = [-1 * (max_offset1 + align_wind1 - 1): -1];
anchor = 0; % latent curve is to be shifted by offset on the plot

% comparing offsets
fprintf('Comparing predictions:\n\n');
%offset_array = [amInterventions1.Offset, amInterventions2.Offset, amInterventions1.Offset - amInterventions2.Offset];
pred_array = [(amInterventions1.Pred - amInterventions1.IVScaledDateNum), (amInterventions2.Pred - amInterventions2.IVScaledDateNum), amInterventions1.Pred - amInterventions2.Pred];

mismatch_threshold = 3;
%mismatchidx = find(abs(amInterventions1.Offset - amInterventions2.Offset) >= mismatch_threshold);
mismatchidx = find(abs(amInterventions1.Pred - amInterventions2.Pred) >= mismatch_threshold);

%mkdir(plotsubfolder);

plotsubfolder = strcat('Plots/', sprintf('%s Prediction Comparison %sm%d vs %sm%d', study1, mversion1, modelidx1, mversion2, modelidx2));
mkdir(strcat(basedir, plotsubfolder));

for i = 0:max_offset-1
    idx = find(abs(amInterventions1.Pred - amInterventions2.Pred) == i);
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
                
                fprintf('%2d: Pred %2d vs %2d, Data Completeness = %.2f%% %.2f%%\n', idx(a), pred_array(idx(a),1), ...
                    pred_array(idx(a),2), datacompleteness1, datacompleteness2);
                scid = amInterventions1.SmartCareID(idx(a));
                name = sprintf('%s Prediction Comparison %sm%d vs %sm%d - Ex %d (ID %d Date %s) Pred %2d vs %2d', ...
                    study1, mversion1, modelidx1, mversion2, modelidx2, idx(a), scid, ...
                    datestr(amInterventions1.IVStartDate(idx(a)),29), pred_array(idx(a),1), pred_array(idx(a),2));
                
                [f, p] = createFigureAndPanel(name, 'portrait', 'a4');
                lc1 = amInterventions1.LatentCurve(idx(a));
                lc2 = amInterventions2.LatentCurve(idx(a));
                for m = 1:nmeasures
                    if all(isnan(amIntrDatacube(idx(a), :, m)))
                        continue;
                    end
                    
                    if sigmamethod1 == 4
                        adjmeancurvemean1 = (meancurvemean1(lc1, :, m) * normstd1(idx(a), m)) + normmean1(idx(a), m);
                    else
                        adjmeancurvemean1 =  meancurvemean1(lc1, :, m) + normmean1(idx(a), m);
                    end
                    if sigmamethod2 == 4
                        adjmeancurvemean2 = (meancurvemean2(lc2, :, m) * normstd2(idx(a), m)) + normmean2(idx(a), m);
                    else
                        adjmeancurvemean2 =  meancurvemean2(lc2, :, m) + normmean2(idx(a), m);
                    end
                    
                    % initialise plot areas
                    xl = [0 0];
                    yl = [min(adjmeancurvemean2(1:max_offset2 + align_wind2 - 1 - amInterventions2.Offset(idx(a))) * .99) ...
                          max(adjmeancurvemean2(1:max_offset2 + align_wind2 - 1 - amInterventions2.Offset(idx(a))) * 1.01)];
                    if yl(1) == yl(2)
                        rangelimit = setMinYDisplayRangeForMeasure(measures1.Name{m});
                        yl(1) = yl(1) - rangelimit * 0.5;
                        yl(2) = yl(1) + rangelimit * 0.5;
                    end
                    
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
                    
                    [xl, yl] = plotLatentCurve(ax, max_offset1, align_wind1, amInterventions1.Offset(idx(a)), adjmeancurvemean1, xl, yl, 'red', ':', 1.0, anchor);
                    [xl, yl] = plotLatentCurve(ax, max_offset1, align_wind1, amInterventions1.Offset(idx(a)), smooth(adjmeancurvemean1,5), xl, yl, 'red', '-', 1.0, anchor);
                   
                    [xl, yl] = plotLatentCurve(ax, max_offset2, align_wind2, amInterventions2.Offset(idx(a)), adjmeancurvemean2, xl, yl, 'magenta', ':', 1.0, anchor);
                    [xl, yl] = plotLatentCurve(ax, max_offset2, align_wind2, amInterventions2.Offset(idx(a)), smooth(adjmeancurvemean2,5), xl, yl, 'magenta', '-', 1.0, anchor);
                    
                    [xl, yl] = plotExStart(ax, ex_start1(lc1), amInterventions1.Offset(idx(a)), xl, yl,  'red', '-', 0.5);
                    [xl, yl] = plotExStart(ax, ex_start2(lc2), amInterventions2.Offset(idx(a)), xl, yl, 'magenta', '-', 0.5);
                    
                    [xl, yl] = plotVerticalLine(ax, 0, xl, yl, 'cyan', '-', 0.5); % plot treatment start
                    
                    xl2 = [0 max_offset-1];
                    yl2 = [0 0.25];
                    
                    ax2 = subplot(plotsdown, plotsacross, hpos(m,:),'Parent',p); 
                    
                    [xl2, yl2] = plotProbDistribution(ax2, max_offset1, reshape(pdoffset1(lc1, m, idx(a),:), [1 max_offset]), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');
                    [xl2, yl2] = plotProbDistribution(ax2, max_offset2, reshape(pdoffset2(lc2, m, idx(a),:), [1 max_offset]), xl2, yl2, 'o', 0.5, 2.0, 'green', 'green'); 
                    
                    [xl2, yl2] = plotVerticalLine(ax2, amInterventions1.Offset(idx(a)), xl2, yl2, 'blue', '-', 0.5); % plot predicted offset
                    [xl2, yl2] = plotVerticalLine(ax2, amInterventions2.Offset(idx(a)), xl2, yl2, 'green', '-', 0.5); % plot predicted offset
                    
                    set(gca,'fontsize',6);
                    if measures1.Mask(m) == 1 && measures2.Mask(m) == 1
                        title(sprintf('%s %.1f %.1f', measures1.DisplayName{m}, hstg1(lc1, m, idx(a), amInterventions1.Offset(idx(a)) + 1), ...
                            hstg2(lc2, m, idx(a), amInterventions2.Offset(idx(a)) + 1)), 'BackgroundColor', 'yellow');
                    elseif measures1.Mask(m) == 1
                        title(sprintf('%s %.1f %.1f', measures1.DisplayName{m}, hstg1(lc1, m, idx(a), amInterventions1.Offset(idx(a)) + 1), ...
                            hstg2(lc2, m, idx(a), amInterventions2.Offset(idx(a)) + 1)), 'BackgroundColor', 'cyan');
                    elseif measures2.Mask(m) == 1
                        title(sprintf('%s %.1f %.1f', measures1.DisplayName{m}, hstg1(lc1, m, idx(a), amInterventions1.Offset(idx(a)) + 1), ...
                            hstg2(lc2, m, idx(a), amInterventions2.Offset(idx(a)) + 1)), 'BackgroundColor', 'green');
                    else
                        title(sprintf('%s %.1f %.1f', measures1.DisplayName{m}, hstg1(lc1, m, idx(a), amInterventions1.Offset(idx(a)) + 1), ...
                            hstg2(lc2, m, idx(a), amInterventions2.Offset(idx(a)) + 1)));
                    end
                    
                end
                
                xl2 = [0 max_offset-1];
                yl2 = [0 0.25];
                
                ax2 = subplot(plotsdown, plotsacross, hpos(nmeasures + 1,:),'Parent',p); 
                
                [xl2, yl2] = plotProbDistribution(ax2, max_offset1, reshape(overall_pdoffset1(lc1, idx(a), :), [1 max_offset]), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');
                [xl2, yl2] = plotProbDistribution(ax2, max_offset2, reshape(overall_pdoffset2(lc2, idx(a), :), [1 max_offset]), xl2, yl2, 'o', 0.5, 2.0, 'green', 'green'); 
                    
                [xl2, yl2] = plotVerticalLine(ax2, amInterventions1.Offset(idx(a)), xl2, yl2, 'blue', '-', 0.5); % plot predicted offset
                [xl2, yl2] = plotVerticalLine(ax2, amInterventions2.Offset(idx(a)), xl2, yl2, 'green', '-', 0.5); % plot predicted offset
                
                set(gca,'fontsize',6);
                title(sprintf('Overall %.1f %.1f', overall_hist1(lc1, idx(a), amInterventions1.Offset(idx(a)) + 1), ...
                    overall_hist2(lc2, idx(a), amInterventions2.Offset(idx(a)) + 1)), 'BackgroundColor', 'yellow');
                
                savePlotInDir(f, name, plotsubfolder);
                close(f);
            end
            fprintf('\n');
        end
    end
end

end









