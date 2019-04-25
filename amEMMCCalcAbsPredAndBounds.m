function [amInterventions] = amEMMCCalcAbsPredAndBounds(amInterventions, ex_start, nlatentcurves)

% amEMMCCalcAbsPredAndBounds - calculates the prediction and lower/upper
% bounds in absolute days and stores as additional columns in
% amInterventions table

amInterventions.Ex_Start(:) = 0;
amInterventions.Pred(:) = 0;
amInterventions.RelLB1(:) = 0;
amInterventions.RelUB1(:) = 0;
amInterventions.RelLB2(:) = -1;
amInterventions.RelUB2(:) = -1;

for l = 1:nlatentcurves
    amInterventions.Ex_Start(amInterventions.LatentCurve == l) = ex_start(l);
end

amInterventions.Pred   = amInterventions.IVScaledDateNum + amInterventions.Ex_Start + amInterventions.Offset;
amInterventions.RelLB1 = amInterventions.IVScaledDateNum + amInterventions.Ex_Start + amInterventions.LowerBound1;
amInterventions.RelUB1 = amInterventions.IVScaledDateNum + amInterventions.Ex_Start + amInterventions.UpperBound1;

twoconfidx = amInterventions.LowerBound2 ~= -1;
amInterventions.RelLB2(twoconfidx) = amInterventions.IVScaledDateNum(twoconfidx) ...
        + amInterventions.Ex_Start(twoconfidx) + amInterventions.LowerBound2(twoconfidx);
    
amInterventions.RelUB2(twoconfidx) = amInterventions.IVScaledDateNum(twoconfidx) ...
        + amInterventions.Ex_Start(twoconfidx) + amInterventions.UpperBound2(twoconfidx);

end