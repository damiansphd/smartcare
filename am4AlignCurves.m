function [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd, animatedmeancurvemean, profile_pre, offsets, animatedoffsets, hstg, qual] = am4AlignCurves(amIntrCube, amInterventions, measures, normstd, max_offset, align_wind, nmeasures, ninterventions, detaillog, sigmamethod, smoothingmethod)

% am4AlignCurves = function to align measurement curves prior to intervention

aniterations      = 2000;

meancurvedata     = zeros(max_offset + align_wind - 1, nmeasures, ninterventions);
meancurvesum      = zeros(max_offset + align_wind - 1, nmeasures);
meancurvecount    = zeros(max_offset + align_wind - 1, nmeasures);
meancurvemean     = zeros(max_offset + align_wind - 1, nmeasures);
meancurvestd      = zeros(max_offset + align_wind - 1, nmeasures);
animatedmeancurvemean = zeros(max_offset + align_wind - 1, nmeasures, aniterations);
offsets           = zeros(ninterventions, 1);
animatedoffsets   = zeros(ninterventions, aniterations);
hstg              = zeros(nmeasures, ninterventions, max_offset);

qual = 0;

% calculate mean curve over all interventions
for i = 1:ninterventions
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = am4AddToMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, amIntrCube, amInterventions.Offset(i), i, max_offset, ...
       align_wind, nmeasures);
end

% store the mean curves pre-alignment for each measure for plotting
profile_pre = meancurvemean;

% iterate to convergence
pnt = 1;
cnt = 0;
iter = 0;
ok  = 0;
miniiter = 0;

while 1
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = am4RemoveFromMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, amIntrCube, amInterventions.Offset(pnt), pnt, ...
        max_offset, align_wind, nmeasures);
    % check safety
    ok = 1;
    for i=1:max_offset + align_wind - 1
        for m=1:nmeasures
            if (measures.Mask(m) == 1) && (meancurvecount(i,m) < 2)
            %if meancurvecount(i,m) < 2
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
        [better_offset, hstg] = am4BestFit(meancurvemean, meancurvestd, amIntrCube, ...
            measures.Mask, normstd, hstg, pnt, max_offset, align_wind, nmeasures, sigmamethod, smoothingmethod);
    else
        better_offset = amInterventions.Offset(pnt);
    end
    
    if better_offset ~= amInterventions.Offset(pnt)
        if detaillog & iter > 20
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
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = am4AddToMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, amIntrCube, amInterventions.Offset(pnt), pnt, ...
        max_offset, align_wind, nmeasures);
        
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
        meancurvecount, meancurvemean, meancurvestd, amIntrCube, amInterventions.Offset(i), i, ...
        max_offset, align_wind, nmeasures);
    
    qual = qual + am4CalcObjFcn(meancurvemean, meancurvestd, amIntrCube, measures.Mask, normstd, ...
        hstg, i, amInterventions.Offset(i), max_offset, align_wind, nmeasures, update_histogram, sigmamethod, smoothingmethod);
    
    fprintf('Iteration %d, qual = %.4f\n', i, qual);
    
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = am4AddToMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, amIntrCube, amInterventions.Offset(i), i, ...
        max_offset, align_wind, nmeasures);
end

for i=1:ninterventions 
    offsets(i) = amInterventions.Offset(i);
end

end

