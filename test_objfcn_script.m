
meancurvedata     = nan(max_offset + align_wind, nmeasures, ninterventions);
meancurvesum      = zeros(max_offset + align_wind, nmeasures);
meancurvecount    = zeros(max_offset + align_wind, nmeasures);
meancurvemean     = zeros(max_offset + align_wind, nmeasures);
meancurvestd      = zeros(max_offset + align_wind, nmeasures);

for i = 1:ninterventions
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = am4AddToMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, amNormcube, amInterventions, i, max_offset, ...
       align_wind, nmeasures, curveaveragingmethod, smoothingmethod);
end

temp_meancurvedata = meancurvedata;
temp_meancurvesum = meancurvesum;
temp_meancurvecount = meancurvecount;
temp_meancurvemean = meancurvemean;
temp_meancurvestd = meancurvestd;

qual = 0;

for i=1:ninterventions
%for i=1:13
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = am4RemoveFromMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, amNormcube, amInterventions, i, ...
        max_offset, align_wind, nmeasures, curveaveragingmethod, smoothingmethod);
    qual = qual + am4CalcObjFcn(meancurvemean, meancurvestd, amNormcube, amInterventions, measures.Mask, normstd, ...
        histogram, i, amInterventions.Offset(i), max_offset, align_wind, nmeasures, 0, sigmamethod, smoothingmethod);
    fprintf('After intervention %d, obj fcn total = %.2f\n', i, qual);
    [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = am4AddToMean(meancurvedata, meancurvesum, ...
        meancurvecount, meancurvemean, meancurvestd, amNormcube, amInterventions, i, ...
        max_offset, align_wind, nmeasures, curveaveragingmethod, smoothingmethod);
end

temp_meancurvedata - meancurvedata
temp_meancurvesum - meancurvesum
temp_meancurvecount - meancurvecount
temp_meancurvemean - meancurvemean
temp_meancurvestd - meancurvestd

i = 14;
currinter = i;
curroffset = amInterventions.Offset(i);
measuresmask = measures.Mask;


dist = 0;
scid   = amInterventions.SmartCareID(currinter);
start = amInterventions.IVScaledDateNum(currinter);



for i = 1:align_wind
    for m = 1:nmeasures
        if start - i <= 0
            continue;
        end
        if ~isnan(amNormcube(scid, start - i, m))
            if sigmamethod == 4
                thisdist = ( (meancurvemean((max_offset + align_wind + 1) - i - curroffset, m) ...
                    - amNormcube(scid, start - i, m)) ^ 2 ) / ((meancurvestd((max_offset + align_wind + 1) - i - curroffset, m) ^ 2) ) ;
            else
                thisdist = ( (meancurvemean((max_offset + align_wind + 1) - i - curroffset, m) ...
                    - amNormcube(scid, start - i, m)) ^ 2 ) / ((normstd(scid, m) ^ 2 ) ) ;
            end
            % add measures mask here to only include in the total for
            % subset of measures.
            if measuresmask(m) == 1
                dist = dist + thisdist;
            end
        end
        fprintf('Day %d, measure %d, thisdist = %.2f\n', i, m, thisdist);
        %temp = input('Continue?');
    end
end