function [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd, animatedmeancurvemean, profile_pre, ...
    offsets, animatedoffsets, hstg, pdoffset, overall_hstg, overall_pdoffset, animated_overall_pdoffset, qual, min_offset] = ...
    amEMAlignCurves(amIntrCube, amInterventions, measures, normstd, max_offset, align_wind, nmeasures, ninterventions, ...
    detaillog, sigmamethod, smoothingmethod, offsetblockingmethod, runmode, fnmodelrun)

% amEMAlignCurves - function to align measurement curves prior to intervention

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
pdoffset          = zeros(nmeasures, ninterventions, max_offset);
overall_hstg      = zeros(ninterventions, max_offset);
overall_pdoffset  = zeros(ninterventions, max_offset);
animated_overall_pdoffset  = zeros(ninterventions, max_offset, aniterations);

if runmode == 6
    load(fnmodelrun);
    overall_hstg = overall_hist;
    for i = 1:ninterventions
        overall_pdoffset(i,:) = convertFromLogSpaceAndNormalise(overall_hstg(i,:));
    end
    amInterventions.Offset = offsets;
else    
    % populate pdoffset & overall_pdoffset with uniform prior distribution
    for i = 1:ninterventions
        for m = 1:nmeasures
            pdoffset(m, i, :) = convertFromLogSpaceAndNormalise(hstg(m, i, :));
        end
        if runmode == 4
            overall_pdoffset(i,:) = convertFromLogSpaceAndNormalise(overall_hstg(i,:));
        else
            overall_pdoffset(i,:) = 0;
            overall_pdoffset(i, 1) = 1;
        end
    end
end

animated_overall_pdoffset(:, :, 1) = overall_pdoffset;

min_offset = 0; % start at zero, and only adjust if we encounter too few data points at right hand end of latent curve

% calculate initial mean curve over all interventions & prior prob
% distribution for offsets
for i = 1:ninterventions
    [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvesumsq, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, i, ...
        min_offset, max_offset, align_wind, nmeasures);
end

% store the mean curves pre-alignment for each measure for plotting
profile_pre = meancurvemean;

% iterate to convergence
pnt = 1;
cnt = 0;
iter = 0;
pddiff = 100;
prior_overall_pdoffset = overall_pdoffset;
miniiter = 0;

while (pddiff > 0.00001)
    [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMRemoveFromMean(meancurvesumsq, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, pnt, ...
        min_offset, max_offset, align_wind, nmeasures);
    
    % check safety
    ok = 1;
    block_offset = 0;
    
    for a=1:max_offset + align_wind - 1 - min_offset
        for m=1:nmeasures
            if (measures.Mask(m) == 1) && (meancurvecount(a, m) < 2)
                if detaillog
                    fprintf('After removing intervention %d, %s on day %d has <3 datapoints, Count: %.6f StdDev: %.6f\n', pnt, measures.Name{m}, a, meancurvecount(a, m), meancurvestd(a, m));
                end
                ok = 0;
                if pddiff < 0.1 && a == max_offset + align_wind - 1 - min_offset
                    block_offset = 1;
                end
            end
        end
    end
        
    if offsetblockingmethod == 2 && block_offset == 1 && min_offset < 3
        
        fprintf('Blocking offset %d\n', min_offset);

        % put current intervention back in mean curve temporarily
        [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvesumsq, meancurvesum, ...
            meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, pnt, ...
            min_offset, max_offset, align_wind, nmeasures);

        % for all interventions remove from mean
        % **** avoids small number inaccuracies - just zero out all the
        % meancurve arrays
        %
        % zero out min_offset day from pdoffset, overall_pdoffset, hstg,
        % overall hstg
        % renormalise pdoffset and overall_pdoffset
        % 
        % for all interventions, add to mean with min_offset incremented
        
        %for i = 1:ninterventions
        %    [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMRemoveFromMean(meancurvesumsq, meancurvesum, ...
        %        meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, i, ...
        %        min_offset, max_offset, align_wind, nmeasures);
        %end
        
        meancurvesum(:,:)   = 0;
        meancurvesumsq(:,:) = 0;
        meancurvecount(:,:) = 0;
        meancurvemean(:,:)  = 0;
        meancurvestd(:,:)   = 0;
        
        hstg(:, :, min_offset + 1) = 0;
        overall_hstg(:, min_offset + 1) = 0;
        pdoffset(:, :, min_offset + 1) = 0;
        overall_pdoffset(:, min_offset + 1) = 0;
        
        min_offset = min_offset + 1;
        
        for i = 1:ninterventions
            for m = 1:nmeasures
                pdoffset(m, i, (min_offset + 1):max_offset) = pdoffset(m, i, (min_offset + 1):max_offset) ./ sum(pdoffset(m, i, (min_offset + 1):max_offset));
            end
            overall_pdoffset(i, (min_offset + 1):max_offset) = overall_pdoffset(i, (min_offset + 1):max_offset) ./ sum(overall_pdoffset(i, (min_offset + 1):max_offset));
        
            [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvesumsq, meancurvesum, ...
                meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, i, ...
                min_offset, max_offset, align_wind, nmeasures);
        end
        
        % remove current intervention from mean curve before
        % proceeding
        [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMRemoveFromMean(meancurvesumsq, meancurvesum, ...
            meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, pnt, ...
            min_offset, max_offset, align_wind, nmeasures);
    end
     
    if ok == 1
        [better_offset, better_dist, hstg, pdoffset, overall_hstg, overall_pdoffset] = amEMBestFit(meancurvemean, meancurvestd, amIntrCube, ...
            measures.Mask, normstd, hstg, pdoffset, overall_hstg, overall_pdoffset, ...
            pnt, min_offset, max_offset, align_wind, nmeasures, sigmamethod, smoothingmethod, runmode);
    else
        better_offset = amInterventions.Offset(pnt);
    end
    
    if better_offset ~= amInterventions.Offset(pnt)
        if detaillog
            fprintf('amIntervention.Offset(%d) updated from %d to %d\n', pnt, amInterventions.Offset(pnt), better_offset);
        end
        amInterventions.Offset(pnt) = better_offset;
        cnt = cnt+1;
        miniiter = miniiter+1;
        if miniiter < aniterations
            animatedmeancurvemean(:, :, miniiter) = meancurvemean;
            animatedoffsets(:,miniiter) = amInterventions.Offset;
            animated_overall_pdoffset(:, :, miniiter+1) = overall_pdoffset;
        else
            fprintf('Exceeded storage for animated iterations\n');
        end
    end
    [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvesumsq, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, pnt, ...
        min_offset, max_offset, align_wind, nmeasures);
        
    pnt = pnt+1;
    if pnt > ninterventions
        iter = iter + 1;
        pnt = pnt - ninterventions;
        %animatedmeancurvemean(:, :, iter) = meancurvemean;
        pddiff = calcDiffOverallPD(overall_pdoffset, prior_overall_pdoffset);
        % compute the overall objective function each time we've iterated
        % through the full set of interventions
        % ** don't update the histogram here to avoid double counting on the best
        % offset day **
        update_histogram = 0;
        qual = 0;
        for i=1:ninterventions
            [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMRemoveFromMean(meancurvesumsq, meancurvesum, ...
                meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, i, ...
                min_offset, max_offset, align_wind, nmeasures);
    
            qual = qual + amEMCalcObjFcn(meancurvemean, meancurvestd, amIntrCube, measures.Mask, normstd, ...
                hstg, i, amInterventions.Offset(i), max_offset, align_wind, nmeasures, update_histogram, sigmamethod, smoothingmethod);
            
            fprintf('Intervention %d, qual = %.4f\n', i, qual);
    
            [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvesumsq, meancurvesum, ...
                meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, i, ...
                min_offset, max_offset, align_wind, nmeasures);
        end
        if cnt == 0
            fprintf('No changes on iteration %2d, obj fcn = %.4f, prob distrib diff = %.4f\n', iter, qual, pddiff);
        else
            fprintf('Changed %2d offsets on iteration %2d, obj fcn = %.4f, prob distrib diff = %.4f\n', cnt, iter, qual, pddiff);
        end
        cnt = 0;
        prior_overall_pdoffset = overall_pdoffset;
        
        %temp = input('Continue ? ');
    end
end

for i=1:ninterventions 
    offsets(i) = amInterventions.Offset(i);
end

end

