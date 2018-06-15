function [dist, hstg, hstgc] = amCalcObjFcn(meancurvesum, meancurvecount, amNormcube, amInterventions, hstg, hstgc, currinter, curroffset, max_offset, align_wind, nmeasures, updatehistogram)

% amCalcObjFcn - calculates residual sum of squares distance for points in
% curve vs meancurve incorporating offset

dist = 0;
distcount = 0;
scid   = amInterventions.SmartCareID(currinter);
start = amInterventions.IVScaledDateNum(currinter);

if (updatehistogram == 1)
    for m = 1:nmeasures
        hstg(m, currinter, curroffset + 1) = 0;
        hstgc(m, currinter, curroffset + 1) = 0;
    end
end

for i = 1:align_wind
    for m = 1:nmeasures
        if start - i <= 0
            continue;
        end
        if ~isnan(amNormcube(scid, start - i, m))
            thisdist = (meancurvesum((max_offset + align_wind + 1) - i - curroffset, m)/meancurvecount((max_offset + align_wind + 1) - i - curroffset, m) ...
                - amNormcube(scid, start - i, m))^2;
            dist = dist + thisdist;
            distcount = distcount + 1;
            if (updatehistogram == 1)
                hstg(m, currinter, curroffset + 1) = hstg(m, currinter, curroffset + 1) + thisdist;
                hstgc(m, currinter, curroffset + 1) = hstgc(m, currinter, curroffset + 1) + 1;
            end
        end
    end
end

if distcount > 0
    dist = dist/distcount;
%    fprintf('%d intervention, distcount is %d\n', currinter, distcount);
%    if (updatehistogram == 1)
%        hstg(:, currinter, curroffset + 1) = hstg(:, currinter, curroffset + 1) ./ hstgc(:, currinter, curroffset + 1) + 1;
%    end
end

end
