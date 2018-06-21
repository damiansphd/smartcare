function [offsets, profile_pre, profile_post, hstg, qual] = am2AlignCurves(amDatacube, amInterventions, measures, normstd, max_offset, align_wind, nmeasures, ninterventions, run_type, detaillog)

% am2AlignCurves = function to align measurement curves prior to intervention

meancurvesum      = zeros(max_offset + align_wind, nmeasures);
meancurvecount    = zeros(max_offset + align_wind, nmeasures);
offsets           = zeros(ninterventions, 1);
profile_pre       = zeros(nmeasures, max_offset+align_wind);
profile_post      = zeros(nmeasures, max_offset+align_wind);
hstg              = zeros(nmeasures, ninterventions, max_offset);

qual = 0;

% calculate mean curve over all interventions
for i = 1:ninterventions
    [meancurvesum, meancurvecount] = am2AddToMean(meancurvesum, meancurvecount, amDatacube, amInterventions, i, max_offset, align_wind, nmeasures);
end

% store the mean curves pre-alignment for each measure for plotting
for m = 1:nmeasures
    for day = 1:max_offset + align_wind
        profile_pre(m, day) = meancurvesum(day, m)/meancurvecount(day, m);
    end
end

% iterate to convergence
pnt = 1;
cnt = 0;
iter = 0;
ok  = 0;
while 1
    [meancurvesum, meancurvecount] = am2RemoveFromMean(meancurvesum, meancurvecount, amDatacube, amInterventions, pnt, max_offset, align_wind, nmeasures);
    %check safety
    ok = 1;
    for i=1:max_offset + align_wind
        for m=1:nmeasures
            if meancurvecount(i,m) < 3
                %if detaillog
                %    fprintf('Intervention %d, Measure %s, dayprior %d <3 datapoints\n', pnt, measures.Name{m}, i);
                %end
                ok = 0;
            end
        end
    end
    
    if ok == 1
        [better_offset, hstg] = am2BestFit(meancurvesum, meancurvecount, amDatacube, amInterventions, measures, normstd, hstg, pnt, max_offset, align_wind, nmeasures);
    else
        better_offset = amInterventions.Offset(pnt);
    end
    
    if better_offset ~= amInterventions.Offset(pnt)
        amInterventions.Offset(pnt) = better_offset;
        %if detaillog
        %    fprintf('amIntervention.Offset(%d) set to %d\n', pnt, better_offset);
        %end
        cnt = cnt+1;
    end
    [meancurvesum, meancurvecount] = am2AddToMean(meancurvesum, meancurvecount, amDatacube, amInterventions, pnt, max_offset, align_wind, nmeasures);
        
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
for i=1:ninterventions
    [meancurvesum, meancurvecount] = am2RemoveFromMean(meancurvesum, meancurvecount, amDatacube, amInterventions, i, max_offset, align_wind, nmeasures);
    qual = qual + am2CalcObjFcn(meancurvesum, meancurvecount, amDatacube, amInterventions, measures, normstd, hstg, i, amInterventions.Offset(i), max_offset, align_wind, nmeasures, 0);
    [meancurvesum, meancurvecount] = am2AddToMean(meancurvesum, meancurvecount, amDatacube, amInterventions, i, max_offset, align_wind, nmeasures);
end

for i=1:ninterventions 
    offsets(i) = amInterventions.Offset(i);
end

% store the mean curves post-alignment for each measure for plotting
for m = 1:nmeasures
    for day = 1:max_offset + align_wind
        profile_post(m, day) = meancurvesum(day, m)/meancurvecount(day, m);
    end
end

end

