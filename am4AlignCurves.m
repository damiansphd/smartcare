function [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd, animatedmeancurvemean, profile_pre, ...
    offsets, animatedoffsets, hstg, ppts, qual, min_offset] = am4AlignCurves(amIntrCube, amInterventions, measures, normstd, max_offset, ...
    align_wind, nmeasures, ninterventions, detaillog, sigmamethod, smoothingmethod, offsetblockingmethod)

% am4AlignCurves = function to align measurement curves prior to intervention

aniterations      = 2000;

meancurvesum      = zeros(max_offset + align_wind - 1, nmeasures);
meancurvesumsq    = zeros(max_offset + align_wind - 1, nmeasures);
meancurvecount    = zeros(max_offset + align_wind - 1, nmeasures);
meancurvemean     = zeros(max_offset + align_wind - 1, nmeasures);
meancurvestd      = zeros(max_offset + align_wind - 1, nmeasures);
animatedmeancurvemean = zeros(max_offset + align_wind - 1, nmeasures, aniterations);
offsets           = zeros(ninterventions, 1);
animatedoffsets   = zeros(ninterventions, aniterations);
hstg              = zeros(nmeasures, ninterventions, max_offset);

min_offset        = 0; % start at zero, and only adjust if we encounter too few data points at right hand end of latent curve
countthreshold    = 5; % minimum number of undelying curves that must contribute to a point in the average curve

% calculate mean curve over all interventions
for i = 1:ninterventions
    [meancurvesumsq, meancurvesum, meancurvecount] = am4AddToMean(meancurvesumsq, meancurvesum, meancurvecount, ...
        amIntrCube, amInterventions.Offset(i), i, min_offset, max_offset, align_wind, nmeasures);
    [meancurvemean, meancurvestd] = calcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);
end

% store the mean curves pre-alignment for each measure for plotting
profile_pre = meancurvemean;

% iterate to convergence
pnt = 1;
cnt = 0;
iter = 0;
miniiter = 0;

while 1
    ok = 1;
    block_offset = 0;
    
    % remove current curve from the sum, sumsq, count average curve arrays 
    % before doing bestfit alignment
    [meancurvesumsq, meancurvesum, meancurvecount] = am4RemoveFromMean(meancurvesumsq, meancurvesum, meancurvecount, ...
        amIntrCube, amInterventions.Offset(pnt), pnt, min_offset, max_offset, align_wind, nmeasures);
    
    % find and keep track of points that have too few data points contributing 
    % to them 
    [ppts] = findProblemDataPoints(meancurvesumsq, meancurvesum, meancurvecount, measures.Mask, min_offset, max_offset, align_wind, nmeasures, countthreshold);
    
    % uncomment this if we need to enable offset blocking in the future
    %if size(ppts,1) >= 1
    %    block_offset = 1;
    %end
    
    % add the adjustments to the various meancurve arrays 
    % and recalc mean and std arrays
    [meancurvesumsq, meancurvesum, meancurvecount] = addAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, ppts);
    [meancurvemean, meancurvestd] = calcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);
        
    % ******** Offset blocking should not be used - leaving the code here
    % in case it's useful in the future but it should not be executed
    if offsetblockingmethod == 2 && block_offset == 1 && min_offset < 3
        if detaillog
            fprintf('Blocking offset %d: ', min_offset);
        end
        % put current intervention back in mean curve temporarily
        [meancurvesumsq, meancurvesum, meancurvecount] = removeAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, ppts);
        [meancurvesumsq, meancurvesum, meancurvecount] = am4AddToMean(meancurvesumsq, meancurvesum, meancurvecount, ...
            amIntrCube, amInterventions.Offset(pnt), pnt, min_offset, max_offset, align_wind, nmeasures);
        %[meancurvemean, meancurvestd] = calcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);
        
        idx = find(amInterventions.Offset == min_offset);
        if size(idx,1) >= 1
            % for each intervention with offset giving too few data
            % points at right hand end of curve, remove from mean,
            % increment offset by one, and then add back to mean.
            % Also zero out that offset day in hstg across all
            % measures.
            fprintf('Updating offset for interventions ');
            for i = 1:size(idx, 1)
                fprintf('%d, ', idx(i));
                
                [meancurvesumsq, meancurvesum, meancurvecount] = am4RemoveFromMean(meancurvesumsq, meancurvesum, meancurvecount, ...
                    amIntrCube, amInterventions.Offset(idx(i)), idx(i), min_offset, max_offset, align_wind, nmeasures);
                
                amInterventions.Offset(idx(i)) = min_offset + 1;
                
                [meancurvesumsq, meancurvesum, meancurvecount] = am4AddToMean(meancurvesumsq, meancurvesum, meancurvecount, ...
                    amIntrCube, amInterventions.Offset(idx(i)), idx(i), min_offset, max_offset, align_wind, nmeasures);
            end
            fprintf('\n');
            hstg(:, :, min_offset + 1) = 0;
            min_offset = min_offset + 1;
            %ok = 1;
            % remove current intervention from mean curve before
            % proceeding
            [meancurvesumsq, meancurvesum, meancurvecount] = am4RemoveFromMean(meancurvesumsq, meancurvesum, meancurvecount, ...
                amIntrCube, amInterventions.Offset(pnt), pnt, min_offset, max_offset, align_wind, nmeasures);
            [meancurvesumsq, meancurvesum, meancurvecount] = addAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, ppts);
            [meancurvemean, meancurvestd] = calcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);
        end
    end
    
    if ok == 1
        %fprintf('Got here ! Actually doing some shifting....\n');
        %dummy = input('Continue ?');
        [better_offset, hstg] = am4BestFit(meancurvemean, meancurvestd, amIntrCube, ...
            measures.Mask, normstd, hstg, pnt, min_offset, max_offset, align_wind, nmeasures, sigmamethod, smoothingmethod);
    else
        better_offset = amInterventions.Offset(pnt);
    end
    
    if better_offset ~= amInterventions.Offset(pnt)
        if detaillog %& iter >= 10
            fprintf('amIntervention.Offset(%d) updated from %d to %d\n', pnt, amInterventions.Offset(pnt), better_offset);
        end
        amInterventions.Offset(pnt) = better_offset;
        cnt = cnt+1;
        miniiter = miniiter+1;
        if miniiter < aniterations
            animatedmeancurvemean(:, :, miniiter) = meancurvemean;
            animatedoffsets(:,miniiter) = amInterventions.Offset;
        else
            fprintf('Exceeded storage for animated iterations\n');
        end
    end
    
    % remove the adjustments from the verious meancurve arrays and recalc mean
    % and std arrays and add current curve back to mean curve after doing alignment
    [meancurvesumsq, meancurvesum, meancurvecount] = removeAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, ppts);
    [meancurvesumsq, meancurvesum, meancurvecount] = am4AddToMean(meancurvesumsq, meancurvesum, meancurvecount, ...
        amIntrCube, amInterventions.Offset(pnt), pnt, min_offset, max_offset, align_wind, nmeasures);
    [meancurvemean, meancurvestd] = calcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);
        
    pnt = pnt+1;
    if pnt > ninterventions
        iter = iter + 1;
        pnt = pnt - ninterventions;
        % compute the overall objective function each time we've iterated
        % through the full set of interventions
        % ** don't update the histogram here to avoid double counting on the best
        % offset day **
        update_histogram = 0;
        qual = 0;
        for i=1:ninterventions
            [meancurvesumsq, meancurvesum, meancurvecount] = am4RemoveFromMean(meancurvesumsq, meancurvesum, meancurvecount, ...
                amIntrCube, amInterventions.Offset(i), i, min_offset, max_offset, align_wind, nmeasures);
            [meancurvesumsq, meancurvesum, meancurvecount] = addAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, ppts);
            [meancurvemean, meancurvestd] = calcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);
    
            qual = qual + am4CalcObjFcn(meancurvemean, meancurvestd, amIntrCube, measures.Mask, normstd, ...
                hstg, i, amInterventions.Offset(i), max_offset, align_wind, nmeasures, update_histogram, sigmamethod, smoothingmethod);
    
            %fprintf('Intervention %d, qual = %.4f\n', i, qual);
            
            [meancurvesumsq, meancurvesum, meancurvecount] = removeAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, ppts);
            [meancurvesumsq, meancurvesum, meancurvecount] = am4AddToMean(meancurvesumsq, meancurvesum, meancurvecount, ...
                amIntrCube, amInterventions.Offset(i), i, min_offset, max_offset, align_wind, nmeasures);
            [meancurvemean, meancurvestd] = calcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);
        end
        fprintf('On iteration %2d: Handled %d points with insufficient data\n', iter, size(unique(ppts(:,1)),1));
        if cnt == 0
            fprintf('On iteration %2d: No changes, obj fcn = %.4f\n', iter, qual);
            break;
        else
            fprintf('On iteration %2d: Changed %2d offsets, obj fcn = %.4f\n', iter, cnt, qual);
            if iter > 50
                fprintf('Iteration count limit exceeded - breaking\n');
                break;
            end  
        end
        cnt = 0;
    end
end

[meancurvesumsq, meancurvesum, meancurvecount] = addAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, ppts);
[meancurvemean, meancurvestd] = calcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);

for i=1:ninterventions 
    offsets(i) = amInterventions.Offset(i);
end

end

