function [dist, hstg] = am2CalcObjFcn(meancurvesum, meancurvecount, amDatacube, amInterventions, measures, normstd, hstg, currinter, curroffset, max_offset, align_wind, nmeasures, updatehistogram)

% am2CalcObjFcn - calculates residual sum of squares distance for points in
% curve vs meancurve incorporating offset

dist = 0;
scid   = amInterventions.SmartCareID(currinter);
start = amInterventions.IVScaledDateNum(currinter);

if (updatehistogram == 1)
    for m = 1:nmeasures
        hstg(m, currinter, curroffset + 1) = 0;
    end
end

for i = 1:align_wind
    for m = 1:nmeasures
        if start - i <= 0
            continue;
        end
        if ~isnan(amDatacube(scid, start - i, m))
            %thisdist = ( (meancurvesum((max_offset + align_wind + 1) - i - curroffset, m)/meancurvecount((max_offset + align_wind + 1) - i - curroffset, m) ...
            %    - amDatacube(scid, start - i, m)) ^ 2 ) / (2 * (measures.AlignWindStd(m)) ^ 2 ) ;
            thisdist = ( (meancurvesum((max_offset + align_wind + 1) - i - curroffset, m)/meancurvecount((max_offset + align_wind + 1) - i - curroffset, m) ...
                - amDatacube(scid, start - i, m)) ^ 2 ) / (2 * (normstd(scid, m)) ^ 2 ) ;
            dist = dist + thisdist;
            if (updatehistogram == 1)
                hstg(m, currinter, curroffset + 1) = hstg(m, currinter, curroffset + 1) + thisdist;
            end
        end
    end
end

end
