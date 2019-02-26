function compareModelRunToTestData(amLabelledInterventions, amInterventions, amIntrDatacube, measures, pdoffset, overall_pdoffset, ...
    hstg, overall_hist, meancurvemean, normmean, normstd, ex_start, nmeasures, ninterventions, min_offset, max_offset, ...
    align_wind, study, mversion, modelrun, modelidx)

% compareModelRunToTestData - compares the output of a chosen model run to
% the labelled test data

amLabelledInterventions = amLabelledInterventions(ismember(amLabelledInterventions.SmartCareID,amInterventions.SmartCareID),:);
amLabelledInterventions = [array2table([1:ninterventions]'), amLabelledInterventions];
amLabelledInterventions.Properties.VariableNames{'Var1'} = 'InterNbr';

testidx = amLabelledInterventions.IncludeInTestSet=='Y';

modeloffsets = amInterventions.Offset(testidx);
testset = amLabelledInterventions(testidx,:);
testsetsize = size(testset,1);
testset_ex_start = testset.ExStart(1);

diff_ex_start = testset_ex_start - ex_start;

matchidx = ((ex_start + modeloffsets >= (testset.LowerBound1)) & (ex_start + modeloffsets <= (testset.UpperBound1))) | ...
           ((ex_start + modeloffsets >= (testset.LowerBound2)) & (ex_start + modeloffsets <= (testset.UpperBound2)));
if diff_ex_start < 0
    matchidx2 = (modeloffsets >= max_offset + diff_ex_start) & ((testset.UpperBound1 - testset_ex_start == max_offset - 1) | (testset.UpperBound2 - testset_ex_start == max_offset - 1)) ;
elseif diff_ex_start > 0
    matchidx2 = (modeloffsets <= min_offset + diff_ex_start) & ((testset.LowerBound1 - testset_ex_start == min_offset)     | (testset.LowerBound2 - testset_ex_start == min_offset)) ;
else
    matchidx2 = (modeloffsets == -10);
end
matchidx = matchidx | matchidx2;

dist = 0;
for i = 1:size(testset,1)
    if ~matchidx(i)
        dist1 = min(abs(testset.LowerBound1(i) - (ex_start + modeloffsets(i))), abs(testset.LowerBound2(i) - (ex_start + modeloffsets(i))));
        dist2 = min(abs(testset.UpperBound1(i) - (ex_start + modeloffsets(i))), abs(testset.UpperBound2(i) - (ex_start + modeloffsets(i))));
        dist = dist + min(dist1, dist2);
    end
    %fprintf('For intervention %2d, Match = %d, Dist = %d\n', testset.InterNbr(i), matchidx(i), rowtoadd.Count);
end


fprintf('For model %d: %s:\n', modelidx, modelrun);
fprintf('%2d of %2d results match labelled test data\n', sum(matchidx), testsetsize);
fprintf('Quality Score is %d\n', dist);
fprintf('\n');

basedir = setBaseDir();
plotsubfolder = strcat('Plots/', sprintf('%s%sm%d vs Labels', study, mversion, modelidx));
mkdir(strcat(basedir, plotsubfolder));

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
    fprintf('Model Pred: %2d\n', ex_start + offset);
    
    name = sprintf('%s%sm%d vs Labels - Ex %d (ID %d Date %s%s) Pred %2d %s', study, mversion, modelidx, thisinter, scid, ...
                    datestr(testset.IVStartDate(i),29), seqstring, offset, result);
    
    [f, p] = createFigureAndPanel(name, 'portrait', 'a4');

    for m = 1:nmeasures
        if all(isnan(amIntrDatacube(thisinter, :, m)))
            continue;
        end
        
        adjmeancurvemean = (meancurvemean(:,m) * normstd(thisinter, m)) + normmean(thisinter, m);
        
        % initialise plot areas
        xl = [0 0];
        %yl = [min((meancurvemean(1:max_offset + align_wind - 1 - offset, m) + normmean(thisinter, m)) * .99) ...
        %      max((meancurvemean(1:max_offset + align_wind - 1 - offset, m) + normmean(thisinter, m)) * 1.01)];
        yl = [min(adjmeancurvemean(1:max_offset + align_wind - 1 - offset) * .99) ...
              max(adjmeancurvemean(1:max_offset + align_wind - 1 - offset) * 1.01)];
      
        % create subplot and plot required data arrays
        ax = subplot(plotsdown, plotsacross, mpos(m,:), 'Parent',p);               
        [xl, yl] = plotMeasurementData(ax, days, amIntrDatacube(thisinter, :, m), xl, yl, measures(m,:), [0, 0.65, 1], '-', 1.0, 'o', 2.0, 'blue', 'green');
        [xl, yl] = plotHorizontalLine(ax, normmean(thisinter, m), xl, yl, 'blue', '--', 0.5); % plot mean
        %[xl, yl] = plotLatentCurve(ax, max_offset, align_wind, offset, (meancurvemean(:, m) + normmean(thisinter, m)), xl, yl, 'red', ':', 1.0, anchor);
        %[xl, yl] = plotLatentCurve(ax, max_offset, align_wind, offset, smooth(meancurvemean(:, m) + normmean(thisinter, m),5), xl, yl, 'red', '-', 1.0, anchor);
        [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, offset, adjmeancurvemean, xl, yl, 'red', ':', 1.0, anchor);
        [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, offset, smooth(adjmeancurvemean,5), xl, yl, 'red', '-', 1.0, anchor);
    
        [xl, yl] = plotExStart(ax, ex_start, offset, xl, yl,  'black', '-', 0.5);
        [xl, yl] = plotVerticalLine(ax, 0, xl, yl, 'cyan', '-', 0.5); % plot treatment start
        tempyl = yl;
        tempyl(2) = yl(1) + ((yl(2)-yl(1)) * 0.1);
        [xl] = plotVerticalLine(ax, testset_ex_start, xl, tempyl, 'red', '-', 0.5);
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
        xl2 = [0 max_offset-1];
        yl2 = [0 0.25];            
        ax2 = subplot(plotsdown, plotsacross, hpos(m,:),'Parent',p);           
        [xl2, yl2] = plotProbDistribution(ax2, max_offset, pdoffset(m, thisinter,:), xl2, yl2, 'o', 0.5, 2.0, 'blue', 'blue');
        [xl2, yl2] = plotVerticalLine(ax2, offset, xl2, yl2, 'black', '-', 0.5); % plot predicted offset
        hold on;
        fill(ax2, [ (testset.LowerBound1(i) - ex_start) (testset.UpperBound1(i) - ex_start)    ...
                    (testset.UpperBound1(i) - ex_start) (testset.LowerBound1(i) - ex_start) ], ...
                    [ yl2(1) yl2(1) yl2(2) yl2(2) ], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        if testset.LowerBound2(i) ~= 0
            fill(ax2, [ (testset.LowerBound2(i) - ex_start) (testset.UpperBound2(i) - ex_start)    ...
                        (testset.UpperBound2(i) - ex_start) (testset.LowerBound2(i) - ex_start) ], ...
                        [ yl2(1) yl2(1) yl2(2) yl2(2) ], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        end    
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
    fill(ax2, [ (testset.LowerBound1(i) - ex_start) (testset.UpperBound1(i) - ex_start)    ...
                (testset.UpperBound1(i) - ex_start) (testset.LowerBound1(i) - ex_start) ], ...
                [ yl2(1) yl2(1) yl2(2) yl2(2) ], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
    if testset.LowerBound2(i) ~= 0
        fill(ax2, [ (testset.LowerBound2(i) - ex_start) (testset.UpperBound2(i) - ex_start)    ...
                    (testset.UpperBound2(i) - ex_start) (testset.LowerBound2(i) - ex_start) ], ...
                    [ yl2(1) yl2(1) yl2(2) yl2(2) ], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
    end    
    hold off
    
    set(gca,'fontsize',6);
    title(sprintf('Overall (%.1f)', overall_hist(thisinter, offset + 1)), 'BackgroundColor', 'g');

    % save plot
    savePlotInDir(f, name, plotsubfolder);
    close(f);
end
    
end

