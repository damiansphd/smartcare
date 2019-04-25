function amEMMCCompareModelRunToTestData(amLabelledInterventions, amInterventions, amIntrDatacube, measures, pdoffset, overall_pdoffset, ...
    hstg, overall_hist, meancurvemean, normmean, normstd, ex_start, nmeasures, ninterventions, nlatentcurves, max_offset, ...
    align_wind, study, mversion, modelrun, modelidx)

% amEMMCCompareModelRunToTestData - compares the output of a chosen model run to
% the labelled test data (able to handle multiple sets of latent curves

amLabelledInterventions = amLabelledInterventions(ismember(amLabelledInterventions.SmartCareID,amInterventions.SmartCareID),:);
amLabelledInterventions = [array2table([1:ninterventions]'), amLabelledInterventions];
amLabelledInterventions.Properties.VariableNames{'Var1'} = 'InterNbr';

testidx = amLabelledInterventions.IncludeInTestSet=='Y';
testset = amLabelledInterventions(testidx,:);
testsetsize = size(testset,1);

modelpreds = amInterventions.Pred(testidx);
amintrtst  = amInterventions(testidx, :);
        
matchidx   = (modelpreds >= (testset.IVScaledDateNum + testset.LowerBound1) & modelpreds <= (testset.IVScaledDateNum + testset.UpperBound1)) | ...
                     (modelpreds >= (testset.IVScaledDateNum + testset.LowerBound2) & modelpreds <= (testset.IVScaledDateNum + testset.UpperBound2));
        
dist = 0;
for i = 1:size(testset,1)
    if ~matchidx(i)
        dist1 = min(abs(testset.IVScaledDateNum(i) + testset.LowerBound1(i) - modelpreds(i)), abs(testset.IVScaledDateNum(i) + testset.LowerBound2(i) - modelpreds(i)));
        dist2 = min(abs(testset.IVScaledDateNum(i) + testset.UpperBound1(i) - modelpreds(i)), abs(testset.IVScaledDateNum(i) + testset.UpperBound2(i) - modelpreds(i)));
        dist = dist + min(dist1, dist2);
    end
end

fprintf('For model %d: %s:\n', modelidx, modelrun);
fprintf('%2d of %2d results match labelled test data\n', sum(matchidx), testsetsize);
fprintf('Quality Score is %d\n', dist);
fprintf('\n');

basedir = setBaseDir();
plotsubfolder = strcat('Plots/', sprintf('%s%sm%d vs Labels', study, mversion, modelidx));
mkdir(strcat(basedir, plotsubfolder));

plotsdown = 9;
%plotsacross = 5;
%mpos = [ 1 2 6 7 ; 3 4 8 9 ; 11 12 16 17 ; 13 14 18 19 ; 21 22 26 27 ; 23 24 28 29 ; 31 32 36 37 ; 33 34 38 39];
%hpos = [ 5 ; 10 ; 15 ; 20 ; 25 ; 30 ; 35 ; 40 ; 45 ; 44 ; 43 ; 42 ; 41 ];
plotsacross = 6;
mpos  = [ 1 2 7 8 ; 3 4 9 10 ; 13 14 19 20 ; 15 16 21 22 ; 25 26 31 32 ; 27 28 33 34 ; 37 38 43 44 ; 39 40 45 46 ];
hpos  = [ 5       ; 11       ; 17          ; 23          ; 29          ; 35          ; 41          ; 47          ; 53 ];
hpos2 = [ 6       ; 12       ; 18          ; 24          ; 30          ; 36          ; 42          ; 48          ; 54 ];
   
days = -1 * (max_offset + align_wind - 1): -1;
anchor = 0; % latent curve is to be shifted by offset on the plot

for i = 1:testsetsize
    scid      = testset.SmartCareID(i);
    thisinter = testset.InterNbr(i);
    lc        = amintrtst.LatentCurve(i);
    exstrt    = amintrtst.Ex_Start(i);
    pred      = amintrtst.Ex_Start(i) + amintrtst.Offset(i);
    offset    = amintrtst.Offset(i);
    if matchidx(i)
        result = 'MATCH';
    else
        result = 'MISMATCH';
    end
    if testset.SequentialIntervention(i) == 'Y'
        seqstring = ' Seq';
    else
        seqstring = '';
    end
    fprintf('Intervention %2d (ID %d Date %s%s):', testset.InterNbr(i), scid, datestr(testset.IVStartDate(i),29), seqstring);
    fprintf(' %8s :', result);
    fprintf('Labelled Range: %2d:%2d ', testset.LowerBound1(i), testset.UpperBound1(i));
    if testset.LowerBound2(i) ~= 0
        fprintf('and %2d:%2d ', testset.LowerBound2(i), testset.UpperBound2(i));
    end
    fprintf('Model Pred: %2d\n', pred);
    
    name = sprintf('%s%sm%d vs Labels - Ex %d (ID %d Date %s%s) Pred %2d %s', study, mversion, modelidx, thisinter, scid, ...
                    datestr(testset.IVStartDate(i),29), seqstring, pred, result);
    
    [f, p] = createFigureAndPanel(name, 'portrait', 'a4');

    for m = 1:nmeasures
        if all(isnan(amIntrDatacube(thisinter, :, m)))
            continue;
        end
        
        adjmeancurvemean = (meancurvemean(lc, :,m) * normstd(thisinter, m)) + normmean(thisinter, m);
        
        % initialise plot areas
        xl = [0 0];
        yl = [min(adjmeancurvemean(1:max_offset + align_wind - 1 - offset) * .99) ...
              max(adjmeancurvemean(1:max_offset + align_wind - 1 - offset) * 1.01)];
      
        % create subplot and plot required data arrays
        ax = subplot(plotsdown, plotsacross, mpos(m,:), 'Parent',p);               
        [xl, yl] = plotMeasurementData(ax, days, amIntrDatacube(thisinter, :, m), xl, yl, measures(m,:), [0, 0.65, 1], '-', 1.0, 'o', 2.0, 'blue', 'green');
        [xl, yl] = plotHorizontalLine(ax, normmean(thisinter, m), xl, yl, 'blue', '--', 0.5); % plot mean
        [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, offset, adjmeancurvemean, xl, yl, 'red', ':', 1.0, anchor);
        [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, offset, smooth(adjmeancurvemean,5), xl, yl, 'red', '-', 1.0, anchor);
    
        [xl, yl] = plotExStart(ax, exstrt, offset, xl, yl,  'black', '-', 0.5);
        [xl, yl] = plotVerticalLine(ax, 0, xl, yl, 'cyan', '-', 0.5); % plot treatment start
        tempyl = yl;
        tempyl(2) = yl(1) + ((yl(2)-yl(1)) * 0.1);
        hold on;
        fill(ax, [ testset.LowerBound1(i) testset.UpperBound1(i)    ...
                   testset.UpperBound1(i) testset.LowerBound1(i) ], ...
                   [yl(1) yl(1) yl(2) yl(2)], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        if testset.LowerBound2(i) ~= 0
            fill(ax, [ testset.LowerBound2(i) testset.UpperBound2(i)    ...
                       testset.UpperBound2(i) testset.LowerBound2(i) ], ...
                       [yl(1) yl(1) yl(2) yl(2)], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        end    
        hold off;
        
        % plot prob distributions
        for l = 1:nlatentcurves
            xl2 = [0 max_offset-1];
            yl2 = [0 0.25];
            if l == 1
                ax2 = subplot(plotsdown, plotsacross, hpos(m,:),'Parent',p);
            else
                ax2 = subplot(plotsdown, plotsacross, hpos2(m,:),'Parent',p);
            end
            [xl2, yl2] = plotProbDistribution(ax2, max_offset, reshape(pdoffset(l, m, thisinter,:), [1 max_offset]), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');
            [xl2, yl2] = plotVerticalLine(ax2, offset, xl2, yl2, 'black', '-', 0.5); % plot predicted offset
            hold on;
            fill(ax2, [ (testset.LowerBound1(i) - ex_start(l)) (testset.UpperBound1(i) - ex_start(l))    ...
                        (testset.UpperBound1(i) - ex_start(l)) (testset.LowerBound1(i) - ex_start(l)) ], ...
                        [ yl2(1) yl2(1) yl2(2) yl2(2) ], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
            if testset.LowerBound2(i) ~= 0
                fill(ax2, [ (testset.LowerBound2(i) - ex_start(l)) (testset.UpperBound2(i) - ex_start(l))    ...
                            (testset.UpperBound2(i) - ex_start(l)) (testset.LowerBound2(i) - ex_start(l)) ], ...
                            [ yl2(1) yl2(1) yl2(2) yl2(2) ], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
            end    
            hold off

            set(gca,'fontsize',6);
            if measures.Mask(m) == 1
                title(sprintf('%s (%.1f)', measures.DisplayName{m}, hstg(lc, m, thisinter, offset + 1)), 'BackgroundColor', 'g');
            else
                title(sprintf('%s (%.1f)', measures.DisplayName{m}, hstg(lc, m, thisinter, offset + 1)));
            end
        end
                    
    end

    % plot the overall posterior distribution
    for l = 1:nlatentcurves
        xl2 = [0 max_offset-1];
        yl2 = [0 0.25];
        if l == 1
            ax2 = subplot(plotsdown, plotsacross, hpos(nmeasures + 1, :),'Parent',p);
        else
            ax2 = subplot(plotsdown, plotsacross, hpos2(nmeasures + 1, :),'Parent',p);
        end
        [xl2, yl2] = plotProbDistribution(ax2, max_offset, reshape(overall_pdoffset(l, thisinter, :), [1 max_offset]), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');                
        [xl2, yl2] = plotVerticalLine(ax2, offset, xl2, yl2, 'black', '-', 0.5); % plot predicted offset
        hold on;
        fill(ax2, [ (testset.LowerBound1(i) - ex_start(l)) (testset.UpperBound1(i) - ex_start(l))    ...
                    (testset.UpperBound1(i) - ex_start(l)) (testset.LowerBound1(i) - ex_start(l)) ], ...
                    [ yl2(1) yl2(1) yl2(2) yl2(2) ], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        if testset.LowerBound2(i) ~= 0
            fill(ax2, [ (testset.LowerBound2(i) - ex_start(l)) (testset.UpperBound2(i) - ex_start(l))    ...
                        (testset.UpperBound2(i) - ex_start(l)) (testset.LowerBound2(i) - ex_start(l)) ], ...
                        [ yl2(1) yl2(1) yl2(2) yl2(2) ], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        end    
        hold off

        set(gca,'fontsize',6);
        title(sprintf('Overall (%.1f)', overall_hist(lc, thisinter, offset + 1)), 'BackgroundColor', 'g');
    end

    % save plot
    savePlotInDir(f, name, plotsubfolder);
    close(f);
end
    
end

