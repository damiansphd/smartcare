function [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd, profile_pre, offsets, hstg, pdoffset, qual] = amEMAlignCurves(amDatacube, amInterventions, measures, normstd, max_offset, align_wind, nmeasures, ninterventions, detaillog, sigmamethod)

% amEMAlignCurves = function to align measurement curves prior to intervention

meancurvedata     = zeros(max_offset + align_wind - 1, nmeasures, ninterventions);
meancurvesum      = zeros(max_offset + align_wind - 1, nmeasures);
meancurvecount    = zeros(max_offset + align_wind - 1, nmeasures);
meancurvemean     = zeros(max_offset + align_wind - 1, nmeasures);
meancurvestd      = zeros(max_offset + align_wind - 1, nmeasures);
offsets           = zeros(ninterventions, 1);
hstg              = zeros(nmeasures, ninterventions, max_offset);
pdoffset          = zeros(nmeasures, ninterventions, max_offset);
qual = 0;

% populate pdoffset with uniform prior distribution (and hstg)
for i = 1:ninterventions
    for m = 1:nmeasures
        pdoffset(m, i, :) = exp(-1 * (hstg(m, i, :) - max(hstg(m, i, :))));
        pdoffset(m, i, :) = pdoffset(m, i, :) / sum(pdoffset(m, i, :));
    end
end

% calculate initial mean curve over all interventions & prior prob
% distribution for offsets
for i = 1:ninterventions
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, pdoffset, amDatacube, amInterventions, i, ...
        max_offset, align_wind, nmeasures);
end

%meancurvemean
%temp = input('Continue ? ');

% store the mean curves pre-alignment for each measure for plotting
profile_pre = meancurvemean;

% iterate to convergence
pnt = 1;
cnt = 0;
iter = 0;
ok  = 0;
while iter < 100
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMRemoveFromMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, pdoffset, amDatacube, amInterventions, pnt, ...
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
        %fprintf('Got here ! Actually doing some shifting....\n');
        %dummy = input('Continue ?');
        [better_offset, hstg, pdoffset] = amEMBestFit(meancurvemean, meancurvestd, amDatacube, ...
            amInterventions, measures.Mask, normstd, hstg, pdoffset, pnt, max_offset, align_wind, nmeasures, sigmamethod);
        %better_offset
        %reshape(hstg(:,pnt,:), [nmeasures, max_offset])
        %reshape(pdoffset(:,pnt,:), [nmeasures, max_offset])
        %dummy = input('Continue ?');
    else
        better_offset = amInterventions.Offset(pnt);
    end
    
    if better_offset ~= amInterventions.Offset(pnt)
        if detaillog %& iter > 20
            fprintf('amIntervention.Offset(%d) updated from %d to %d\n', pnt, amInterventions.Offset(pnt), better_offset);
        end
        amInterventions.Offset(pnt) = better_offset;
        cnt = cnt+1;
    end
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, pdoffset, amDatacube, amInterventions, pnt, ...
        max_offset, align_wind, nmeasures);
        
    pnt = pnt+1;
    if pnt > ninterventions
        iter = iter + 1;
        pnt = pnt - ninterventions;
        if cnt == 0
            if detaillog
                fprintf('No changes on iteration %2d\n', iter);
                %break;
            end
        else 
            if detaillog
                fprintf('Changed %2d offsets on iteration %2d\n', cnt, iter);
            end
            if iter > 100
                if detaillog
                    fprintf('Iteration count limit exceeded - breaking\n');
                end
                break;
            end
            cnt = 0;
        end
    end
end

% computing the objective function result for converged offset array
% don't update the histogram here to avoid double counting on the best
% offset day
update_histogram = 0;

for i=1:ninterventions
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMRemoveFromMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, pdoffset, amDatacube, amInterventions, i, ...
        max_offset, align_wind, nmeasures);
    
    qual = qual + amEMCalcObjFcn(meancurvemean, meancurvestd, amDatacube, amInterventions, measures.Mask, normstd, ...
        hstg, i, amInterventions.Offset(i), max_offset, align_wind, nmeasures, update_histogram, sigmamethod);
    
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, pdoffset, amDatacube, amInterventions, i, ...
        max_offset, align_wind, nmeasures);
end

for i=1:ninterventions 
    offsets(i) = amInterventions.Offset(i);
end

end

