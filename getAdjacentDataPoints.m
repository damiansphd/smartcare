function [adjsumsqpt, adjsumpt, adjcountpt] = getAdjacentDataPoints(meancurvesumsqrow, meancurvesumrow, meancurvecountrow, thispoint, thismeasure, countthreshold, max_offset, align_wind)

% getAdjacentDataPoints - get and store adjacent data points to a point in the latent
% curve - to be used when there are too few underlying curves contributing

range = 0;
adjsumsqpt = 0;
adjsumpt = 0;
adjcountpt = 0;

while (meancurvecountrow(thispoint) + adjcountpt) < countthreshold
    range = range + 1;
    if (thispoint + range) <= max_offset + align_wind - 1
        adjsumsqpt = adjsumsqpt + meancurvesumsqrow(thispoint + range);
        adjsumpt   = adjsumpt   + meancurvesumrow(thispoint   + range);
        adjcountpt = adjcountpt + meancurvecountrow(thispoint + range);
    end
    if (thispoint - range) >= 1
        adjsumsqpt = adjsumsqpt + meancurvesumsqrow(thispoint - range);
        adjsumpt   = adjsumpt   + meancurvesumrow(thispoint   - range);
        adjcountpt = adjcountpt + meancurvecountrow(thispoint - range);
    end
end

%fprintf('Retrieved %d adjacent points to point %d for measure %d: %d addtional points\n', range, thispoint, thismeasure, adjcountpt);

end
