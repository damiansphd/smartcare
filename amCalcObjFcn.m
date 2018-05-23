function [dist, hstg] = amCalcObjFcn(meancurvesum, meancurvecount, amNormcube, amInterventions, hstg, currinter, curroffset, max_offset, align_wind, nmeasures, updatehistogram)

% amCalcObjFcn - calculates residual sum of squares distance for points in
% curve vs meancurve incorporating offset

dist = 0;
scid   = amInterventions.SmartCareID(currinter);
start = amInterventions.IVScaledDateNum(currinter);

for i = 1:align_wind
    for m = 1:nmeasures
        if start - i <= 0
            continue;
        end
        if ~isnan(amNormcube(scid, start - i, m))
            thisdist = (meancurvesum((max_offset + align_wind + 1) - i - curroffset, m)/meancurvecount((max_offset + align_wind + 1) - i - curroffset, m) ...
                - amNormcube(scid, start - i, m))^2;
            dist = dist + thisdist;
            if (updatehistogram == 1)
                hstg(m, currinter, curroffset + 1) = hstg(m, currinter, curroffset + 1) + thisdist;
            end
        end
    end
end

end
