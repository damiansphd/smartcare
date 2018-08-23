function [probdist] = convertFromLogSpaceAndNormalise(distfcn)

% convertFromLogSpaceAndNormalise - takes the results from a 'distance'
% function in log space and normalises to a probability distribution.

probdist = exp(-1 * (distfcn - min(distfcn)));

probdist = probdist / sum(probdist);

end

