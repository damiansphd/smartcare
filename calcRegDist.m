function [dist] = calcRegDist(lcpointmean, lcpointstd, pmstd, datapoint, sigmamethod)

% calcRegDist - convenience function to calculate the sum of squares
% difference for the objective function

if sigmamethod == 4
    dist = ( (lcpointmean - datapoint) ^ 2 ) / ( 2 * (lcpointstd ^ 2) ) ...
           + log(lcpointstd) ...
           + log((2 * pi) ^ 0.5);      
else
    dist = ( (lcpointmean - datapoint) ^ 2 ) / ( 2 * pmstd ) ...
           + log(pmstd) ...
           + log((2 * pi) ^ 0.5);
end

end

