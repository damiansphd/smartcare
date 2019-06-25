function [meancurvesumsq, meancurvesum, meancurvecount] = amEMMCRemoveFromMean(meancurvesumsq, meancurvesum, meancurvecount, ...
    overall_pdoffset, amIntrCube, amHeldBackcube, vshift, currinter, min_offset, max_offset, align_wind, nmeasures, nlatentcurves)

% amEMMCRemoveFromMean - remove an underlying curve from each of the sets of meancurve (sumsq, sum and count) 
% from possible offsets, weighted by the overall probability of each
% offset/meancurve

for n = 1:nlatentcurves
    for offset = min_offset:max_offset-1
        % place the current intervention curve into every possible offset
        % position, weighted by the probability each offset position is the
        % right one
        for m = 1:nmeasures
            for i = 1:(max_offset + align_wind - 1 - offset)
                if (~isnan(amIntrCube(currinter, max_offset + align_wind - i, m)) && amHeldBackcube(currinter, max_offset + align_wind - i, m)==0)
                    meancurvesumsq(n, max_offset + align_wind - offset - i, m) = meancurvesumsq(n, max_offset + align_wind - offset - i, m) - (((amIntrCube(currinter, max_offset + align_wind - i, m) + vshift(n, currinter, m, offset + 1)) ^ 2) * overall_pdoffset(n, currinter, offset + 1));
                    meancurvesum(n, max_offset + align_wind - offset - i, m)   = meancurvesum(n, max_offset + align_wind   - offset - i, m) -  ((amIntrCube(currinter, max_offset + align_wind - i, m) + vshift(n, currinter, m, offset + 1))      * overall_pdoffset(n, currinter, offset + 1));
                    meancurvecount(n, max_offset + align_wind - offset - i, m) = meancurvecount(n, max_offset + align_wind - offset - i, m) - overall_pdoffset(n, currinter, offset + 1);
                end
            end
        end
    end
end

end
