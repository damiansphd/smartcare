function amEMMCCompareModelRunToTestData(amLabelledInterventions, amInterventions, amIntrDatacube, measures, pdoffset, overall_pdoffset, ...
    hstg, overall_hist, meancurvemean, normmean, normstd, ex_start, nmeasures, nlatentcurves, max_offset, ...
    align_wind, sigmamethod, study, mversion, modelrun, modelidx, testsetmode, plotsubfolder)

% amEMMCCompareModelRunToTestData - compares the output of a chosen model run to
% the labelled test data (able to handle multiple sets of latent curves

if testsetmode == 1
    testidx = amLabelledInterventions.IncludeInTestSet=='Y';
elseif testsetmode == 2
    testidx = true(size(amLabelledInterventions, 1), 1);
else
    fprintf('**** Unknown test set mode ****\n');
    return
end

% need to join between labelled interventions and interventions and vice-versa to
% get the list of the subset of interventions in common between each.
% and inner join both ways ensures the same sort order in both tables

testset   = innerjoin(amLabelledInterventions(testidx, :), amInterventions, 'LeftKeys', {'SmartCareID', 'IVDateNum'}, 'RightKeys', {'SmartCareID', 'IVDateNum'}, 'RightVariables', {});
amintrtst = innerjoin(amInterventions, amLabelledInterventions(testidx, :), 'LeftKeys', {'SmartCareID', 'IVDateNum'}, 'RightKeys', {'SmartCareID', 'IVDateNum'}, 'RightVariables', {});
testsetsize = size(testset,1);    
modelpreds = amintrtst.Pred;

matchidx   = (modelpreds >= (testset.IVScaledDateNum + testset.LowerBound1) & modelpreds <= (testset.IVScaledDateNum + testset.UpperBound1)) | ...
             (modelpreds >= (testset.IVScaledDateNum + testset.LowerBound2) & modelpreds <= (testset.IVScaledDateNum + testset.UpperBound2));
        
dist = 0;
distArr = zeros(1,4);

for i = 1:size(testset,1)
    if ~matchidx(i)
        distArr(1) = abs(testset.IVScaledDateNum(i) + testset.LowerBound1(i) - modelpreds(i));
        distArr(2) = abs(testset.IVScaledDateNum(i) + testset.UpperBound1(i) - modelpreds(i));
        if testset.LowerBound2(i) ~= 0
            distArr(3) = abs(testset.IVScaledDateNum(i) + testset.LowerBound2(i) - modelpreds(i));
            distArr(4) = abs(testset.IVScaledDateNum(i) + testset.UpperBound2(i) - modelpreds(i));
        else
            distArr(3) = 100;
            distArr(4) = 100;
        end
        dist = dist + min(distArr);
    end
end

fprintf('For model %d: %s:\n', modelidx, modelrun);
fprintf('%2d of %2d results match labelled test data\n', sum(matchidx), testsetsize);
fprintf('Quality Score is %d\n', dist);
fprintf('\n');

basedir = setBaseDir();
mkdir(strcat(basedir, plotsubfolder));

plotsdown = 9;
if nlatentcurves == 1
    if nmeasures <= 8
        plotsdown = 9;
        plotsacross = 5;
        mpos = [ 1  2  6  7 ;  3  4  8  9 ; 
                11 12 16 17 ; 13 14 18 19 ; 
                21 22 26 27 ; 23 24 28 29 ; 
                31 32 36 37 ; 33 34 38 39 ];
        hpos(1,:) = [ 5 ; 10 ; 
                     15 ; 20 ; 
                     25 ; 30 ; 
                     35 ; 40 ; 
                     45      ];
    elseif nmeasures > 8 && nmeasures <= 18
        plotsdown = 14;
        plotsacross = 8;
        mpos = [ 1  2  9 10 ;  3  4 11 12 ;  5  6 13 14 ; 
                17 18 25 26 ; 19 20 27 28 ; 21 22 29 30 ; 
                33 34 41 42 ; 35 36 43 44 ; 37 38 45 46 ; 
                49 50 57 58 ; 51 52 59 60 ; 53 54 61 62 ;
                65 66 73 74 ; 67 68 75 76 ; 69 70 77 78 ; 
                81 82 89 90 ; 83 84 91 92 ; 85 86 93 94 ];
        hpos(1,:) = [  7 ;  8 ; 15 ; 
                      23 ; 24 ; 31 ;  
                      39 ; 40 ; 47 ; 
                      55 ; 56 ; 63 ; 
                      71 ; 72 ; 79 ;
                      87 ; 88 ; 95 ;
                      103          ];
    end
elseif nlatentcurves == 2
    plotsacross = 6;
    mpos       = [ 1 2 7 8 ; 3 4 9 10 ; 13 14 19 20 ; 15 16 21 22 ; 25 26 31 32 ; 27 28 33 34 ; 37 38 43 44 ; 39 40 45 46 ];
    hpos(1, :) = [ 5       ; 11       ; 17          ; 23          ; 29          ; 35          ; 41          ; 47          ; 53 ];
    hpos(2, :) = [ 6       ; 12       ; 18          ; 24          ; 30          ; 36          ; 42          ; 48          ; 54 ];
elseif nlatentcurves == 3
    plotsacross = 7;
    mpos       = [ 1 2 8 9 ; 3 4 10 11 ; 15 16 22 23 ; 17 18 24 25 ; 29 30 36 37 ; 31 32 38 39 ; 43 44 50 51 ; 45 46 52 53 ];
    hpos(1, :) = [ 5       ; 12        ; 19          ; 26          ; 33          ; 40          ; 47          ; 54          ; 61 ];
    hpos(2, :) = [ 6       ; 13        ; 20          ; 27          ; 34          ; 41          ; 48          ; 55          ; 62 ];
    hpos(3, :) = [ 7       ; 14        ; 21          ; 28          ; 35          ; 42          ; 49          ; 56          ; 63 ];    
else
    fprintf('Only supports up to 3 sets of latent curves\n');
end

days = -1 * (max_offset + align_wind - 1): -1;
anchor = 0; % latent curve is to be shifted by offset on the plot

for i = 1:testsetsize
    scid      = testset.SmartCareID(i);
    thisinter = testset.IntrNbr(i);
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
    fprintf('Intervention %2d (ID %d Date %s%s):', testset.IntrNbr(i), scid, datestr(testset.IVStartDate(i),29), seqstring);
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
        
        if sigmamethod == 4
            adjmeancurvemean = (meancurvemean(lc, :, m) * normstd(thisinter, m)) + normmean(thisinter, m);
        else
            adjmeancurvemean =  meancurvemean(lc, :, m) + normmean1(thisinter, m);
        end
        
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
        [~, yl] = plotVerticalLine(ax, 0, xl, yl, 'cyan', '-', 0.5); % plot treatment start
        %tempyl = yl;
        %tempyl(2) = yl(1) + ((yl(2)-yl(1)) * 0.1);
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
        for lc = 1:nlatentcurves
            xl2 = [0 max_offset-1];
            yl2 = [0 0.25];
            ax2 = subplot(plotsdown, plotsacross, hpos(lc, m),'Parent',p);
            [xl2, yl2] = plotProbDistribution(ax2, max_offset, reshape(pdoffset(lc, m, thisinter,:), [1 max_offset]), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');
            [~, yl2] = plotVerticalLine(ax2, offset, xl2, yl2, 'black', '-', 0.5); % plot predicted offset
            hold on;
            fill(ax2, [ (testset.LowerBound1(i) - ex_start(lc)) (testset.UpperBound1(i) - ex_start(lc))    ...
                        (testset.UpperBound1(i) - ex_start(lc)) (testset.LowerBound1(i) - ex_start(lc)) ], ...
                        [ yl2(1) yl2(1) yl2(2) yl2(2) ], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
            if testset.LowerBound2(i) ~= 0
                fill(ax2, [ (testset.LowerBound2(i) - ex_start(lc)) (testset.UpperBound2(i) - ex_start(lc))    ...
                            (testset.UpperBound2(i) - ex_start(lc)) (testset.LowerBound2(i) - ex_start(lc)) ], ...
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
    for lc = 1:nlatentcurves
        xl2 = [0 max_offset-1];
        yl2 = [0 0.25];
        ax2 = subplot(plotsdown, plotsacross, hpos(lc, nmeasures + 1),'Parent',p);
        
        [xl2, yl2] = plotProbDistribution(ax2, max_offset, reshape(overall_pdoffset(lc, thisinter, :), [1 max_offset]), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');                
        [~, yl2] = plotVerticalLine(ax2, offset, xl2, yl2, 'black', '-', 0.5); % plot predicted offset
        hold on;
        fill(ax2, [ (testset.LowerBound1(i) - ex_start(lc)) (testset.UpperBound1(i) - ex_start(lc))    ...
                    (testset.UpperBound1(i) - ex_start(lc)) (testset.LowerBound1(i) - ex_start(lc)) ], ...
                    [ yl2(1) yl2(1) yl2(2) yl2(2) ], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        if testset.LowerBound2(i) ~= 0
            fill(ax2, [ (testset.LowerBound2(i) - ex_start(lc)) (testset.UpperBound2(i) - ex_start(lc))    ...
                        (testset.UpperBound2(i) - ex_start(lc)) (testset.LowerBound2(i) - ex_start(lc)) ], ...
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

