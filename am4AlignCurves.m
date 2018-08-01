function [offsets, profile_pre, profile_post, count_post, std_post, hstg, qual, meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = am4AlignCurves(amDatacube, amInterventions, measures, normstd, max_offset, align_wind, nmeasures, ninterventions, run_type, detaillog, curveaveragingmethod, sigmamethod, smoothingmethod)

% am4AlignCurves = function to align measurement curves prior to intervention

meancurvedata     = nan(max_offset + align_wind, nmeasures, ninterventions);
meancurvesum      = zeros(max_offset + align_wind, nmeasures);
meancurvecount    = zeros(max_offset + align_wind, nmeasures);
meancurvemean     = zeros(max_offset + align_wind, nmeasures);
meancurvestd      = zeros(max_offset + align_wind, nmeasures);
offsets           = zeros(ninterventions, 1);
profile_pre       = zeros(nmeasures, max_offset+align_wind);
profile_post      = zeros(nmeasures, max_offset+align_wind);
count_post        = zeros(nmeasures, max_offset+align_wind);
std_post          = zeros(nmeasures, max_offset+align_wind);
hstg              = zeros(nmeasures, ninterventions, max_offset);
qual = 0;

% calculate mean curve over all interventions
for i = 1:ninterventions
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = am4AddToMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, amDatacube, amInterventions, i, max_offset, ...
       align_wind, nmeasures, curveaveragingmethod, smoothingmethod);
end

% store the mean curves pre-alignment for each measure for plotting
for m = 1:nmeasures
    for day = 1:max_offset + align_wind
        %profile_pre(m, day) = meancurvesum(day, m) / meancurvecount(day, m);
        profile_pre(m, day) = meancurvemean(day, m);
    end
end

% iterate to convergence
pnt = 1;
cnt = 0;
iter = 0;
ok  = 0;
while 1
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = am4RemoveFromMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, amDatacube, amInterventions, pnt, ...
        max_offset, align_wind, nmeasures, curveaveragingmethod, smoothingmethod);
    % check safety
    ok = 1;
    for i=2:max_offset + align_wind
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
        [better_offset, hstg] = am4BestFit(meancurvemean, meancurvestd, amDatacube, ...
            amInterventions, measures.Mask, normstd, hstg, pnt, max_offset, align_wind, nmeasures, sigmamethod, smoothingmethod);
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
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = am4AddToMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, amDatacube, amInterventions, pnt, ...
        max_offset, align_wind, nmeasures, curveaveragingmethod, smoothingmethod);
        
    pnt = pnt+1;
    if pnt > ninterventions
        iter = iter + 1;
        pnt = pnt - ninterventions;
        if cnt == 0
            if detaillog
                fprintf('Converged after %2d iterations\n', iter);
            end
            break;
        else 
            if detaillog
                fprintf('Changed %2d offsets on iteration %2d\n', cnt, iter);
            end
            if iter > 35
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
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = am4RemoveFromMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, amDatacube, amInterventions, i, ...
        max_offset, align_wind, nmeasures, curveaveragingmethod, smoothingmethod);
    qual = qual + am4CalcObjFcn(meancurvemean, meancurvestd, amDatacube, amInterventions, measures.Mask, normstd, ...
        hstg, i, amInterventions.Offset(i), max_offset, align_wind, nmeasures, update_histogram, sigmamethod, smoothingmethod);
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = am4AddToMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, amDatacube, amInterventions, i, ...
        max_offset, align_wind, nmeasures, curveaveragingmethod, smoothingmethod);
end

for i=1:ninterventions 
    offsets(i) = amInterventions.Offset(i);
end

% store the mean curves post-alignment for each measure for plotting
for m = 1:nmeasures
    for day = 1:max_offset + align_wind
        %profile_post(m, day) = meancurvesum(day, m)/meancurvecount(day, m);
        profile_post(m, day) = meancurvemean(day, m);
        count_post(m, day) = meancurvecount(day, m);
        std_post(m, day) = meancurvestd(day, m);
    end
end

end

