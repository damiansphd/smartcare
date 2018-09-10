function compareModelRunToTestData(amLabelledInterventions, amIntrDatacube, measures, pdoffset, overall_pdoffset, ...
    hstg, overall_hist, offsets, meancurvemean, normmean, ex_start, nmeasures, ninterventions, min_offset, max_offset, ...
    align_wind, study, version, modelrun, modelidx)

% compareModelRunToTestData - compares the output of a chosen model run to
% the labelled test data

amLabelledInterventions = [array2table([1:ninterventions]'), amLabelledInterventions];
amLabelledInterventions.Properties.VariableNames{'Var1'} = 'InterNbr';

testidx = amLabelledInterventions.IncludeInTestSet=='Y';

modeloffsets = offsets(testidx);
testset = amLabelledInterventions(testidx,:);
testsetsize = size(testset,1);
testset_ex_start = testset.ExStart(1);

diff_ex_start = testset_ex_start - ex_start;

matchidx = ((modeloffsets >= (testset.LowerBound + diff_ex_start)) & (modeloffsets <= (testset.UpperBound + diff_ex_start)));
if diff_ex_start < 0
    matchidx2 = (modeloffsets >= max_offset + diff_ex_start) & (testset.UpperBound == max_offset - 1);
elseif diff_ex_start > 0
    matchidx2 = (modeloffsets <= min_offset + diff_ex_start) & (testset.LowerBound == min_offset);
else
    matchidx2 = (modeloffsets == -10);
end
matchidx = matchidx | matchidx2;

fprintf('For model %d: %s:\n', modelidx, modelrun);
fprintf('%2d of %2d results match labelled test data\n', sum(matchidx), testsetsize);
fprintf('\n');

plotsdown = 9;
plotsacross = 5;
mpos = [ 1 2 6 7 ; 3 4 8 9 ; 11 12 16 17 ; 13 14 18 19 ; 21 22 26 27 ; 23 24 28 29 ; 31 32 36 37 ; 33 34 38 39];
hpos = [ 5 ; 10 ; 15 ; 20 ; 25 ; 30 ; 35 ; 40 ; 45 ; 44 ; 43 ; 42 ; 41 ];
days = [-1 * (max_offset + align_wind - 1): -1];
anchor = 0; % latent curve is to be shifted by offset on the plot

for i = 1:testsetsize
    scid = testset.SmartCareID(i);
    thisinter = testset.InterNbr(i);
    offset = modeloffsets(i);
    %if ((modeloffsets(i) >= (testset.LowerBound(i) + diff_ex_start)) && (modeloffsets(i) <= (testset.UpperBound(i) + diff_ex_start)))
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
    fprintf('Labelled Range: %2d - %2d, Model Pred: %2d\n', testset.LowerBound(i), testset.UpperBound(i), modeloffsets(i));
    
    name = sprintf('%s_AM%s m%d vs Labels - Ex %d (ID %d Date %s%s) Offset %2d vs %2d - %2d %s', study, version, modelidx, thisinter, scid, ...
                    datestr(testset.IVStartDate(i),29), seqstring, offset, testset.LowerBound(i), testset.UpperBound(i), result);
    
    [f, p] = createFigureAndPanel(name, 'portrait', 'a4');

    for m = 1:nmeasures
        if all(isnan(amIntrDatacube(thisinter, :, m)))
            continue;
        end
        % initialise plot areas
        xl = [0 0];
        yl = [min((meancurvemean(1:max_offset + align_wind - 1 - offset, m) + normmean(thisinter, m)) * .99) ...
              max((meancurvemean(1:max_offset + align_wind - 1 - offset, m) + normmean(thisinter, m)) * 1.01)];
    
        % create subplot and plot required data arrays
        ax = subplot(plotsdown, plotsacross, mpos(m,:), 'Parent',p);               
        [xl, yl] = plotMeasurementData(ax, days, amIntrDatacube(thisinter, :, m), xl, yl, measures(m,:), [0, 0.65, 1], '-', 1.0, 'o', 2.0, 'blue', 'green');
        [xl, yl] = plotHorizontalLine(ax, normmean(thisinter, m), xl, yl, 'blue', '--', 0.5); % plot mean
        [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, offset, (meancurvemean(:, m) + normmean(thisinter, m)), xl, yl, 'red', ':', 1.0, anchor);
        [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, offset, smooth(meancurvemean(:, m) + normmean(thisinter, m),5), xl, yl, 'red', '-', 1.0, anchor);
        [xl, yl] = plotExStart(ax, ex_start, offset, xl, yl,  'black', '-', 0.5);
        [xl, yl] = plotVerticalLine(ax, 0, xl, yl, 'cyan', '-', 0.5); % plot treatment start
        tempyl = yl;
        tempyl(2) = yl(1) + ((yl(2)-yl(1)) * 0.1);
        [xl] = plotVerticalLine(ax, testset_ex_start, xl, tempyl, 'red', '-', 0.5);
        hold on;
        fill(ax, [ (testset_ex_start + testset.LowerBound(i)) (testset_ex_start + testset.UpperBound(i))    ...
                      (testset_ex_start + testset.UpperBound(i)) (testset_ex_start + testset.LowerBound(i)) ], ...
                    [yl(1) yl(1) yl(2) yl(2)], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        hold off;
        
        % plot prob distributions
        xl2 = [0 max_offset-1];
        yl2 = [0 0.25];            
        ax2 = subplot(plotsdown, plotsacross, hpos(m,:),'Parent',p);           
        [xl2, yl2] = plotProbDistribution(ax2, max_offset, pdoffset(m, thisinter,:), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');
        [xl2, yl2] = plotVerticalLine(ax2, offset, xl2, yl2, 'black', '-', 0.5); % plot predicted offset
        hold on;
        fill(ax2, [ testset.LowerBound(i) testset.UpperBound(i)    ...
                       testset.UpperBound(i) testset.LowerBound(i) ], ...
                     [ yl2(1) yl2(1) yl2(2) yl2(2) ], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        hold off
                    
        set(gca,'fontsize',6);
        if measures.Mask(m) == 1
            title(sprintf('%s (%.1f)', measures.DisplayName{m}, hstg(m, thisinter, offset + 1)), 'BackgroundColor', 'g');
        else
            title(sprintf('%s (%.1f)', measures.DisplayName{m}, hstg(m, thisinter, offset + 1)));
        end
                    
    end

    % plot the overall posterior distribution
    xl2 = [0 max_offset-1];
    yl2 = [0 0.25];
    ax2 = subplot(plotsdown, plotsacross, hpos(nmeasures + 1,:),'Parent',p); 
    [xl2, yl2] = plotProbDistribution(ax2, max_offset, overall_pdoffset(thisinter,:), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');                
    [xl2, yl2] = plotVerticalLine(ax2, offset, xl2, yl2, 'black', '-', 0.5); % plot predicted offset
    hold on;
    fill(ax2, [ testset.LowerBound(i) testset.UpperBound(i)    ...
                testset.UpperBound(i) testset.LowerBound(i) ], ...
              [ yl2(1) yl2(1) yl2(2) yl2(2) ], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
    hold off
    
    set(gca,'fontsize',6);
    title(sprintf('Overall (%.1f)', overall_hist(thisinter, offset + 1)), 'BackgroundColor', 'g');

    % save plot
    savePlot(f, name);
    close(f);
end
    
end

