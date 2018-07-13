function [meancurvesum,meancurvecount] = am3RemoveFromMean(meancurvesum, meancurvecount, amDatacube, amInterventions, currinter, max_offset, align_wind, nmeasures, curveaveragingmethod)

% am3RemoveFromMean - remove a curve from the mean curve (sum and count)

scid   = amInterventions.SmartCareID(currinter);
start = amInterventions.IVScaledDateNum(currinter);
offset = amInterventions.Offset(currinter);

if curveaveragingmethod == 1
    averagewindow = align_wind;
else
    averagewindow = max_offset + align_wind - offset;
end

for m = 1:nmeasures
    for i = 1:averagewindow
        if start - i <= 0
            continue;
        end
        if ~isnan(amDatacube(scid, start - i, m))
            meancurvesum((max_offset + align_wind + 1) - offset - i, m)   = meancurvesum((max_offset + align_wind + 1) - offset - i, m)   - amDatacube(scid, start - i, m);
            meancurvecount((max_offset + align_wind + 1) - offset - i, m) = meancurvecount((max_offset + align_wind + 1) - offset - i, m) - 1;
        end
    end
end

end
