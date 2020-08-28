function [avgdelayreduction, trigintrtpr, avgtrigdelay, intrtrig] = calcAvgDelayReductionForThresh(pmAMPred, featureindex, labels, pred, thresh)

% calcAvgDelayReductionForThres - calculates the average reduction in time to
% treatment (over all interventions) for a given threshold level

reduction       = zeros(size(pmAMPred, 1), 1);
trigdelayarray  = zeros(size(pmAMPred, 1), 1);
intrtrig        = zeros(size(pmAMPred, 1), 1);
count           = 0;
trigcount       = 0;

for i = 1:size(pmAMPred, 1)
    pnbr       = pmAMPred.PatientNbr(i);
    exstart    = pmAMPred.Pred(i);
    treatstart = pmAMPred.IVScaledDateNum(i);
    
    intrlabl = labels(featureindex.PatientNbr == pnbr & featureindex.ScenType == 0 & featureindex.CalcDatedn >= exstart & featureindex.CalcDatedn < treatstart);
    if ~all(intrlabl)
        fprintf('**** Not all labels are 1 for intervention %3d:%3d:%3d ****\n', pnbr, exstart, treatstart);
    end
    
    intrpred = pred(featureindex.PatientNbr == pnbr & featureindex.ScenType == 0 & featureindex.CalcDatedn >= exstart & featureindex.CalcDatedn < treatstart);
    
    if size(intrpred, 1) ~= 0
        triggeridx = find(intrpred >= thresh, 1, 'first');
        if size(triggeridx, 1) ~= 0
            reduction(i) = size(intrpred, 1) + 1 - triggeridx;
            trigcount = trigcount + 1;
            intrtrig(i) = 1;
            trigdelayarray(i) = triggeridx - 1;
        else
            intrtrig(i) = -1;
            trigdelayarray(i) = size(intrpred, 1) - 1;
        end
        count = count + 1;
    end
end

fprintf('Total Interventions = %d, Predicted %d, Triggered %d\n', size(pmAMPred, 1), count, trigcount);

avgdelayreduction = sum(reduction) / count;
trigintrtpr = trigcount / count;
avgtrigdelay = sum(trigdelayarray) / count;

end
