function [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMAddToMean(meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, currinter, max_offset, align_wind, nmeasures)

% amEMAddToMean - add a curve to the mean curve (sum and count) - to all
% possible offsets, weighted by the overall probability of each offset


for offset = 0:max_offset-1
    % place the current intervention curve into every possible offset
    % position, weighted by the probability each offset position is the
    % right one
    for m = 1:nmeasures
        for i = 1:(max_offset + align_wind - 1 - offset)
            if ~isnan(amIntrCube(currinter, max_offset + align_wind - i, m))
                meancurvesumsq(max_offset + align_wind - offset - i, m) = meancurvesumsq(max_offset + align_wind - offset - i, m) + ((amIntrCube(currinter, max_offset + align_wind - i, m) ^ 2) * overall_pdoffset(currinter, offset + 1));
                meancurvesum(max_offset + align_wind - offset - i, m)   = meancurvesum(max_offset + align_wind - offset - i, m)   + (amIntrCube(currinter, max_offset + align_wind - i, m) * overall_pdoffset(currinter, offset + 1));
                meancurvecount(max_offset + align_wind - offset - i, m) = meancurvecount(max_offset + align_wind - offset - i, m) + overall_pdoffset(currinter, offset + 1);
            end
        end
    end
end

meancurvemean = meancurvesum ./ meancurvecount;
meancurvestd  = ((meancurvesumsq ./ meancurvecount) - (meancurvemean .* meancurvemean)) .^ 0.5;

end
