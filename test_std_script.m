

meancurvedata     = nan(max_offset + align_wind, nmeasures, ninterventions);
meancurvesum      = zeros(max_offset + align_wind, nmeasures);
meancurvecount    = zeros(max_offset + align_wind, nmeasures);
meancurvestd      = zeros(max_offset + align_wind, nmeasures);

for i = 1:ninterventions
    [meancurvedata, meancurvesum, meancurvecount, meancurvestd] = am3AddToMean(meancurvedata, meancurvesum, meancurvecount, amDatacube, amInterventions, i, max_offset, ...
       align_wind, nmeasures, curveaveragingmethod);
end