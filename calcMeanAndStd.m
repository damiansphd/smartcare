function [meancurvemean, meancurvestd] = calcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind)

% am4CalcMeanAndStd - recalc meancurvemean and meancurvestd arrays

% recalculate mean curve and std by day
meancurvemean = meancurvesum ./ meancurvecount;
meancurvestd  = (abs((meancurvesumsq ./ meancurvecount) - (meancurvemean .* meancurvemean))) .^ 0.5;

if min_offset > 0
    meancurvemean((max_offset + align_wind - min_offset): (max_offset + align_wind - 1),:) = 0;
    meancurvestd((max_offset + align_wind - min_offset): (max_offset + align_wind - 1),:)  = 0;
end

end
