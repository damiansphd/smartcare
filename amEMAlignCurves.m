function [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd, profile_pre, offsets, hstg, pdoffset, overall_hstg, overall_pdoffset, qual] = amEMAlignCurves(amIntrCube, amInterventions, measures, normstd, max_offset, align_wind, nmeasures, ninterventions, detaillog, sigmamethod, runmode)

% amEMAlignCurves = function to align measurement curves prior to intervention

meancurvedata     = zeros(max_offset + align_wind - 1, nmeasures, ninterventions);
meancurvesum      = zeros(max_offset + align_wind - 1, nmeasures);
meancurvecount    = zeros(max_offset + align_wind - 1, nmeasures);
meancurvemean     = zeros(max_offset + align_wind - 1, nmeasures);
meancurvestd      = zeros(max_offset + align_wind - 1, nmeasures);
offsets           = zeros(ninterventions, 1);
hstg              = zeros(nmeasures, ninterventions, max_offset);
pdoffset          = zeros(nmeasures, ninterventions, max_offset);
overall_hstg      = zeros(ninterventions, max_offset);
overall_pdoffset  = zeros(ninterventions, max_offset);

% populate pdoffset & overall_pdoffset with uniform prior distribution
for i = 1:ninterventions
    for m = 1:nmeasures
        pdoffset(m, i, :) = exp(-1 * (hstg(m, i, :) - min(hstg(m, i, :))));
        pdoffset(m, i, :) = pdoffset(m, i, :) / sum(pdoffset(m, i, :));
    end
    if runmode == 4
        overall_pdoffset(i,:)     = exp(-1 * (overall_hstg(i,:) - min(overall_hstg(i, :)))); 
        overall_pdoffset(i,:)     = overall_pdoffset(i,:) / sum(overall_pdoffset(i,:));
    else
        overall_pdoffset(i,:) = 0;
        overall_pdoffset(i, 1) = 1;
    end
end

% calculate initial mean curve over all interventions & prior prob
% distribution for offsets
for i = 1:ninterventions
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvedata, meancurvesum, ...
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

while (pddiff > 0.001)
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMRemoveFromMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, pnt, ...
        max_offset, align_wind, nmeasures);
    % check safety
    ok = 1;
    for i=1:max_offset + align_wind - 1
        for m=1:nmeasures
            if meancurvecount(i,m) < 2
                %if detaillog
                %    fprintf('Intervention %d, Measure %s, dayprior %d <3 datapoints\n', pnt, measures.Name{m}, i);
                %end
                ok = 0;
            end
        end
    end
    
    if ok == 1
        [better_offset, better_dist, hstg, pdoffset, overall_hstg, overall_pdoffset] = amEMBestFit(meancurvemean, meancurvestd, amIntrCube, ...
            measures.Mask, normstd, hstg, pdoffset, overall_hstg, overall_pdoffset, ...
            pnt, max_offset, align_wind, nmeasures, sigmamethod, runmode);
    else
        better_offset = amInterventions.Offset(pnt);
    end
    
    if better_offset ~= amInterventions.Offset(pnt)
        if detaillog
            fprintf('amIntervention.Offset(%d) updated from %d to %d\n', pnt, amInterventions.Offset(pnt), better_offset);
        end
        amInterventions.Offset(pnt) = better_offset;
        cnt = cnt+1;
    end
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, pnt, ...
        max_offset, align_wind, nmeasures);
        
    pnt = pnt+1;
    if pnt > ninterventions
        iter = iter + 1;
        pnt = pnt - ninterventions;
        pddiff = calcDiffOverallPD(overall_pdoffset, prior_overall_pdoffset);
        % compute the overall objective function each time we've iterated
        % through the full set of interventions
        % ** don't update the histogram here to avoid double counting on the best
        % offset day **
        update_histogram = 0;
        qual = 0;
        for i=1:ninterventions
            [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMRemoveFromMean(meancurvedata, meancurvesum, ...
                meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, i, ...
                max_offset, align_wind, nmeasures);
    
            qual = qual + amEMCalcObjFcn(meancurvemean, meancurvestd, amIntrCube, measures.Mask, normstd, ...
                hstg, i, amInterventions.Offset(i), max_offset, align_wind, nmeasures, update_histogram, sigmamethod);
    
            [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvedata, meancurvesum, ...
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
    end
end

for i=1:ninterventions 
    offsets(i) = amInterventions.Offset(i);
end

end

