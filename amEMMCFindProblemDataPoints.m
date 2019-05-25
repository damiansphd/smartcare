function [pptsstruct] = amEMMCFindProblemDataPoints(meancurvesumsq, meancurvesum, meancurvecount, measuresmask, ...
    min_offset, max_offset, align_wind, nmeasures, countthreshold, nlatentcurves)

% amEMMCFindProblemDataPoints - finds datapoints in the average curve that have fewer underlying
% curves contributing to them

% structure to hold problem points by curve
pptsstruct = struct('Curve', []);

% find and keep track of points that have too few data points contributing 
% to them - only check count for now, but should also check std is not less 
% than certain threshold in case enough data but all the same value
for n = 1:nlatentcurves
    % create array to hold problem points in the curve (with too few underlying
    % data points contributing to them
    % create space for a max of 1000 problem points which should be plenty -
    % delete those unused prior to returning from function
    ppts = zeros(1000, 6);
    currppt = 1;
    for a=max_offset + align_wind - 1 - min_offset:-1:1
        for m=1:nmeasures
            if (measuresmask(m) == 1) && (meancurvecount(n, a,m) < countthreshold)
                [adjsumsqpt, adjsumpt, adjcountpt, range] = getAdjacentDataPoints(meancurvesumsq(n, :, m), meancurvesum(n, :, m), meancurvecount(n, :, m), a, m, countthreshold, max_offset, align_wind);
                ppts(currppt, :) = [a, m, adjsumsqpt, adjsumpt, adjcountpt, range];
                currppt = currppt + 1;
                if currppt > 1000
                    fprintf('***** WARNING - Number of problem points exceeded size of storage array *****\n');
                end
            end
        end
    end
    ppts(currppt:end,:) = [];
    pptsstruct.Curve(n).ppts = ppts;
end

end

