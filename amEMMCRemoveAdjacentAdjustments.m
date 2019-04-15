function [meancurvesumsq, meancurvesum, meancurvecount] = amEMMCRemoveAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, pptsstruct, nlatentcurves)

% amEMMCRemoveAdjacentAdjustments - removes the adjustments from adjacent points from the
% problem points in the curves (handles multiple latent curves)

for n = 1:nlatentcurves
    for a = 1:size(pptsstruct.Curve(n).ppts,1)
        meancurvesumsq(n, pptsstruct.Curve(n).ppts(a,1), pptsstruct.Curve(n).ppts(a,2)) = meancurvesumsq(n, pptsstruct.Curve(n).ppts(a,1), pptsstruct.Curve(n).ppts(a,2)) - pptsstruct.Curve(n).ppts(a,3);
        meancurvesum(n,   pptsstruct.Curve(n).ppts(a,1), pptsstruct.Curve(n).ppts(a,2)) = meancurvesum(n, pptsstruct.Curve(n).ppts(a,1),   pptsstruct.Curve(n).ppts(a,2)) - pptsstruct.Curve(n).ppts(a,4);
        meancurvecount(n, pptsstruct.Curve(n).ppts(a,1), pptsstruct.Curve(n).ppts(a,2)) = meancurvecount(n, pptsstruct.Curve(n).ppts(a,1), pptsstruct.Curve(n).ppts(a,2)) - pptsstruct.Curve(n).ppts(a,5);
    end
end

end

