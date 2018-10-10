function [amIntrNormcube] = createNormalisedIntrDatacube(amIntrDatacube, normmean, normstd, max_offset, align_wind, ninterventions, nmeasures, sigmamethod)

% createNormalisedIntrDatacube - creates the normalised data cube by
% intervention (for each measure)

% for sigma methods 1, 2, & 3 just normalise by mu (as the sigma is
% constant for a given intervention/measure and is incorporated in the
% model objective function
% for sigma methos 4, need to normalise by mu and sigma here as the model
% is using a by day/measure sigma.

amIntrNormcube = amIntrDatacube;

for i = 1:ninterventions
    for m = 1:nmeasures
        if sigmamethod == 4
            amIntrNormcube(i, 1:(max_offset + align_wind -1), m) = ...
                (amIntrDatacube(i, 1:(max_offset + align_wind -1), m) - normmean(i, m)) / normstd(i, m);
        else 
            amIntrNormcube(i, 1:(max_offset + align_wind -1), m) = ...
                (amIntrDatacube(i, 1:(max_offset + align_wind -1), m) - normmean(i, m));
        end
    end
end

end

