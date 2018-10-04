function [meancurvesumsq, meancurvesum, meancurvecount] = amEMRemoveFromMean(meancurvesumsq, meancurvesum, meancurvecount, ...
    overall_pdoffset, amIntrCube, amHeldBackcube, currinter, min_offset, max_offset, align_wind, nmeasures)

% amEMRemoveFromMean - remove an underlying curve from the meancurve (sumsq, sum and count) 
% from possible offsets, weighted by the overall probability of each offset

for offset = min_offset:max_offset-1
    % place the current intervention curve into every possible offset
    % position, weighted by the probability each offset position is the
    % right one
    for m = 1:nmeasures
        for i = 1:(max_offset + align_wind - 1 - offset)
            if (~isnan(amIntrCube(currinter, max_offset + align_wind - i, m)) && amHeldBackcube(currinter, max_offset + align_wind - i, m)==0)
                meancurvesumsq(max_offset + align_wind - offset - i, m) = meancurvesumsq(max_offset + align_wind - offset - i, m) - ((amIntrCube(currinter, max_offset + align_wind - i, m) ^ 2) * overall_pdoffset(currinter, offset + 1));
                meancurvesum(max_offset + align_wind - offset - i, m)   = meancurvesum(max_offset + align_wind - offset - i, m)   -  (amIntrCube(currinter, max_offset + align_wind - i, m)      * overall_pdoffset(currinter, offset + 1));
                meancurvecount(max_offset + align_wind - offset - i, m) = meancurvecount(max_offset + align_wind - offset - i, m) - overall_pdoffset(currinter, offset + 1);
            end
        end
    end
end

end
