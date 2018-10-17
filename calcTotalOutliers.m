function [totaloutliers, totalpoints] = calcTotalOutliers(amIntrDatacube, isOutlier, amHeldBackcube, offsets, max_offset, align_wind, ninterventions)

% calcTotalOutliers - sums up the total outliers after alignment
% optimisation has run (as well as the total number of data points

totaloutliers = 0;
totalpoints   = 0;

for i = 1:ninterventions
       totaloutliers = totaloutliers + sum(sum(isOutlier(i, :, :, offsets(i) + 1)));
       totalpoints   = totalpoints + sum(sum(~isnan(amIntrDatacube(i, max_offset:max_offset + align_wind -1, :))));
end

totalpoints = totalpoints - sum(sum(sum(amHeldBackcube)));

end

