function [amHeldBackcube] = createHeldBackcube(amIntrDatacube, max_offset, align_wind, ninterventions, nmeasures, heldbackpct, imputationmode)

% createHeldBackcube - creates an index array indicating points to be held
% back for imputation (chosen at random)

% set seed random number generator to a consistent point for
% reproduceability
rng(2);

amHeldBackcube = zeros(ninterventions, max_offset + align_wind - 1, nmeasures);

if imputationmode ==2
    for i = 1:ninterventions
        for d = max_offset:max_offset + align_wind -1
            for m = 1:nmeasures
                if ~isnan(amIntrDatacube(i, d, m))
                    holdback = rand;
                    if holdback <= heldbackpct
                        amHeldBackcube(i, d, m) = 1;
                    end
                end
            end
        end
    end
end
end

