function [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = am4RemoveFromMean(meancurvesumsq, meancurvesum, ...
    meancurvecount, meancurvemean, meancurvestd, amIntrCube, offset, currinter, max_offset, align_wind, nmeasures)

% am4RemoveFromMean - remove a curve from the mean curve (sum and count)

for m = 1:nmeasures
    for i = 1:(max_offset + align_wind - 1 - offset)
        if ~isnan(amIntrCube(currinter, max_offset + align_wind - i, m))
            meancurvesumsq(max_offset + align_wind - offset - i, m) = meancurvesumsq(max_offset + align_wind - offset - i, m) - (amIntrCube(currinter, max_offset + align_wind - i, m) ^ 2);
            meancurvesum(max_offset + align_wind - offset - i, m)   = meancurvesum(max_offset + align_wind - offset - i, m)   - amIntrCube(currinter, max_offset + align_wind - i, m);
            meancurvecount(max_offset + align_wind - offset - i, m) = meancurvecount(max_offset + align_wind - offset - i, m) - 1;
        end
        meancurvemean(max_offset + align_wind - offset - i, m) = meancurvesum(max_offset + align_wind - offset - i, m) / meancurvecount(max_offset + align_wind - offset - i, m);
        meancurvestd(max_offset + align_wind - offset - i, m)  = ( (meancurvesumsq(max_offset + align_wind - offset - i, m) / meancurvecount(max_offset + align_wind - offset - i, m)) ...
                                                                 - (meancurvemean(max_offset + align_wind - offset - i, m)  * meancurvemean(max_offset + align_wind - offset - i, m)) ) ^ 0.5 ;
    end
end

end
