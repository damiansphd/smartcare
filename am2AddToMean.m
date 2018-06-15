function [meancurvesum,meancurvecount] = am2AddToMean(meancurvesum, meancurvecount, amDatacube, amInterventions, currinter, max_offset, align_wind, nmeasures)

% am2AddToMean - add a curve to the mean curve (sum and count)

scid   = amInterventions.SmartCareID(currinter);
start = amInterventions.IVScaledDateNum(currinter);
offset = amInterventions.Offset(currinter);

for m = 1:nmeasures
    for i = 1:max_offset + align_wind - offset
        if start - i <= 0
            continue;
        end
        if ~isnan(amDatacube(scid, start - i, m))
            meancurvesum((max_offset + align_wind + 1) - offset - i, m)   = meancurvesum((max_offset + align_wind + 1) - offset - i, m)   + amDatacube(scid, start - i, m);
            meancurvecount((max_offset + align_wind + 1) - offset - i, m) = meancurvecount((max_offset + align_wind + 1) - offset - i, m) + 1;
        end
    end
end

end
