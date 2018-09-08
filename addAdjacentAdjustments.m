function [meancurvesumsq, meancurvesum, meancurvecount] = addAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, ppts)

% addAdjacentAdjustments - adds the adjustments from adjacent points to the
% problem points in the curve

for a = 1:size(ppts,1)
    meancurvesumsq(ppts(a,1), ppts(a,2)) = meancurvesumsq(ppts(a,1), ppts(a,2)) + ppts(a,3);
    meancurvesum(ppts(a,1), ppts(a,2))   = meancurvesum(ppts(a,1), ppts(a,2))   + ppts(a,4);
    meancurvecount(ppts(a,1), ppts(a,2)) = meancurvecount(ppts(a,1), ppts(a,2)) + ppts(a,5);
end

end

