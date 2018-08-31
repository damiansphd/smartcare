function [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd, animatedmeancurvemean, profile_pre, ...
    offsets, animatedoffsets, hstg, pdoffset, overall_hstg, overall_pdoffset, animated_overall_pdoffset, qual] = ...
    amEMAlignCurves(amIntrCube, amInterventions, measures, normstd, max_offset, align_wind, nmeasures, ninterventions, ...
    detaillog, sigmamethod, smoothingmethod, runmode, fnmodelrun)

% amEMAlignCurves - function to align measurement curves prior to intervention

aniterations      = 2000;

%meancurvedata     = nan(max_offset + align_wind - 1, nmeasures, ninterventions);
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
            %pdoffset(m, i, :) = exp(-1 * (hstg(m, i, :) - min(hstg(m, i, :))));
            %pdoffset(m, i, :) = pdoffset(m, i, :) / sum(pdoffset(m, i, :));
        end
        if runmode == 4
            overall_pdoffset(i,:) = convertFromLogSpaceAndNormalise(overall_hstg(i,:));
            %overall_pdoffset(i,:)     = exp(-1 * (overall_hstg(i,:) - min(overall_hstg(i, :)))); 
            %overall_pdoffset(i,:)     = overall_pdoffset(i,:) / sum(overall_pdoffset(i,:));
        else
            overall_pdoffset(i,:) = 0;
            overall_pdoffset(i, 1) = 1;
        end
    end
end

animated_overall_pdoffset(:, :, 1) = overall_pdoffset;

% calculate initial mean curve over all interventions & prior prob
% distribution for offsets
for i = 1:ninterventions
    [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvesumsq, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, i, ...
        max_offset, align_wind, nmeasures);
end

% store the mean curves pre-alignment for each measure for plotting
profile_pre = meancurvemean;

% iterate to convergence
pnt = 1;
cnt = 0;
iter = 0;
ok  = 0;
pddiff = 100;
prior_overall_pdoffset = overall_pdoffset;
miniiter = 0;

while (pddiff > 0.00001)
    [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMRemoveFromMean(meancurvesumsq, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, pnt, ...
        max_offset, align_wind, nmeasures);
    % check safety
    ok = 1;
    for i=1:max_offset + align_wind - 1
        for m=1:nmeasures
            if (measures.Mask(m) == 1) && (meancurvecount(i, m) < 2)
                if detaillog
                    fprintf('Intervention %d, Measure %s, dayprior %d <3 datapoints, Count: %.6f StdDev: %.6f\n', pnt, measures.Name{m}, i, meancurvecount(i,m), meancurvestd(i,m));
                end
                ok = 0;
            end
        end
    end
        
    if ok == 1
        [better_offset, better_dist, hstg, pdoffset, overall_hstg, overall_pdoffset] = amEMBestFit(meancurvemean, meancurvestd, amIntrCube, ...
            measures.Mask, normstd, hstg, pdoffset, overall_hstg, overall_pdoffset, ...
            pnt, max_offset, align_wind, nmeasures, sigmamethod, smoothingmethod, runmode);
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
        if miniiter < 2000
            animatedmeancurvemean(:, :, miniiter) = meancurvemean;
            animatedoffsets(:,miniiter) = amInterventions.Offset;
            animated_overall_pdoffset(:, :, miniiter+1) = overall_pdoffset;
        else
            fprintf('Exceeded storage for animated iterations\n');
        end
    end
    [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvesumsq, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, pnt, ...
        max_offset, align_wind, nmeasures);
        
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
                max_offset, align_wind, nmeasures);
    
            qual = qual + amEMCalcObjFcn(meancurvemean, meancurvestd, amIntrCube, measures.Mask, normstd, ...
                hstg, i, amInterventions.Offset(i), max_offset, align_wind, nmeasures, update_histogram, sigmamethod, smoothingmethod);
            
            %fprintf('Intervention %d, qual = %.4f\n', i, qual);
    
            [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvesumsq, meancurvesum, ...
                meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, i, ...
                max_offset, align_wind, nmeasures);
        end
        if cnt == 0
            if detaillog
                fprintf('No changes on iteration %2d, obj fcn = %.4f, prob distrib diff = %.4f\n', iter, qual, pddiff);
            end
        else 
            if detaillog
                fprintf('Changed %2d offsets on iteration %2d, obj fcn = %.4f, prob distrib diff = %.4f\n', cnt, iter, qual, pddiff);
            end
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

