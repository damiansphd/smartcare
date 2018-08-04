function [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd, pdoffset, amDatacube, amInterventions, currinter, max_offset, align_wind, nmeasures)

% amEMAddToMean - add a curve to the mean curve (sum and count)

scid   = amInterventions.SmartCareID(currinter);
start = amInterventions.IVScaledDateNum(currinter);

for offset = 0:max_offset-1
    % place the current intervention curve into every possible offset
    % position, weighted by the probability each offset position is the
    % right one
    for m = 1:nmeasures
        for i = 1:align_wind  
            if start - i <= 0
                continue;
            end
            if ~isnan(amDatacube(scid, start - i, m))
                meancurvedata(max_offset + align_wind - offset - i, m, currinter) = meancurvedata(max_offset + align_wind - offset - i, m) + (amDatacube(scid, start - i, m) * pdoffset(m, currinter, offset + 1));
                meancurvesum(max_offset + align_wind - offset - i, m)   = meancurvesum(max_offset + align_wind - offset - i, m)  + (amDatacube(scid, start - i, m) * pdoffset(m, currinter, offset + 1));
                meancurvecount(max_offset + align_wind - offset - i, m) = meancurvecount(max_offset + align_wind - offset - i, m) + pdoffset(m, currinter, offset + 1);
                meancurvestd(max_offset + align_wind - offset - i, m) = std(meancurvedata(max_offset + align_wind - offset - i, m, ~isnan(meancurvedata(max_offset + align_wind - offset - i, m,:))));
            end
            meancurvemean(max_offset + align_wind - offset - i, m) = meancurvesum(max_offset + align_wind - offset - i, m) / meancurvecount(max_offset + align_wind - offset - i, m);
        end
    end
end

end
