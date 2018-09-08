function [meancurvesumsq, meancurvesum, meancurvecount] = am4RemoveFromMean(meancurvesumsq, meancurvesum, meancurvecount, ...
    amIntrCube, offset, currinter, min_offset, max_offset, align_wind, nmeasures)

% am4RemoveFromMean - remove an underlying curve from the meancurve (sumsq, sum and count) 

for m = 1:nmeasures
    for i = 1:(max_offset + align_wind - 1 - offset)
        if ~isnan(amIntrCube(currinter, max_offset + align_wind - i, m))
            meancurvesumsq(max_offset + align_wind - offset - i, m) = meancurvesumsq(max_offset + align_wind - offset - i, m) - (amIntrCube(currinter, max_offset + align_wind - i, m) ^ 2);
            meancurvesum(max_offset + align_wind - offset - i, m)   = meancurvesum(max_offset + align_wind - offset - i, m)   - amIntrCube(currinter, max_offset + align_wind - i, m);
            meancurvecount(max_offset + align_wind - offset - i, m) = meancurvecount(max_offset + align_wind - offset - i, m) - 1;
        end
    end
end

end
