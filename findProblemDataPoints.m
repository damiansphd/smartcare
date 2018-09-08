function [ppts] = findProblemDataPoints(meancurvesumsq, meancurvesum, meancurvecount, measuresmask, min_offset, max_offset, align_wind, nmeasures, countthreshold)

% findProblemDataPoints - finds datapoints in the average curve that have fewer underlying
% curves contributing to them

% create array to hold problem points in the curve (with too few underlying
% data points contributing to them
ppts = [0, 0, 0, 0, 0];
    
% find and keep track of points that have too few data points contributing 
% to them - only check count for now, but should also check std is not less 
% than certain threshold in case enough data but all the same value
for a=max_offset + align_wind - 1 - min_offset:-1:1
    for m=1:nmeasures
        if (measuresmask(m) == 1) && (meancurvecount(a,m) < countthreshold)
            [adjsumsqpt, adjsumpt, adjcountpt] = getAdjacentDataPoints(meancurvesumsq(:, m), meancurvesum(:, m), meancurvecount(:,m), a, m, countthreshold, max_offset, align_wind);
            ppts = [ppts ; [a, m, adjsumsqpt, adjsumpt, adjcountpt]];
        end
    end
end

%remove dummy row
ppts(1,:) = [];

end

