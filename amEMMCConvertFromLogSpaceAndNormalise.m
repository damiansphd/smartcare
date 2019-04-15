function [probdist] = amEMMCConvertFromLogSpaceAndNormalise(distfcn)

% amEMMCConvertFromLogSpaceAndNormalise - takes the results from a 'distance'
% function in log space and normalises to a probability distribution.


probdist = exp(-1 * (distfcn - min(min(distfcn))));

probdist = probdist / sum(sum(probdist));

end

