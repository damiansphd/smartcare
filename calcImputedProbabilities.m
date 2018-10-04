function [amImputedCube] = calcImputedProbabilities(amIntrCube, amHeldBackcube, ...
        meancurvemean, meancurvestd, normstd, overall_pdoffset, max_offset, align_wind, nmeasures, ...
        ninterventions,sigmamethod, smoothingmethod, imputationmode);

, 
% getImputedProbabilities - gets the probabilities for the set of held back
% points and also returns the cumulative normalised distance from the
% objective function for these points

tempmean = zeros(max_offset + align_wind - 1, nmeasures);
tempstd  = zeros(max_offset + align_wind - 1, nmeasures);
amImputedCube = zeros(ninterventions, max_offset + align_wind - 1, nmeasures);

for m = 1:nmeasures
    if smoothingmethod == 2
        tempmean(:,m) = smooth(meancurvemean(:,m),5);
        tempstd(:,m) = smooth(meancurvestd(:,m),5);
    else
        tempmean(:,m) = meancurvemean(:,m);
        tempstd(:,m) = meancurvestd(:,m);
    end
end

if imputationmode == 2
    for n = 1:ninterventions
        for i = 1:align_wind
            for m = 1:nmeasures
                for offset = 0:max_offset - 1
                    if (~isnan(amIntrCube(n, max_offset + align_wind - i, m)) && amHeldBackcube(n, max_offset + align_wind - i, m) == 1)
                        thisdist = calcRegDist(tempmean(max_offset + align_wind - i - offset, m), ...
                                               tempstd(max_offset + align_wind - i - offset, m), ...
                                               normstd(n, m), ...
                                               amIntrCube(n, max_offset + align_wind - i, m), ...
                                               sigmamethod);
                        amImputedCube(n, max_offset + align_wind - i, m) = ...
                            amImputedCube(n, max_offset + align_wind - i, m) + (exp(-thisdist) * overall_pdoffset(n, offset + 1));
                    end
                end 
                if amHeldBackcube(n, max_offset + align_wind - i, m) == 1
                    fprintf('Intervention %2d, day%2d, measure %d, imputed probability is %.2f%%\n', n, ...
                        max_offset + align_wind - i, m, 100 * amImputedCube(n, max_offset + align_wind - i, m)); 
                end
            end
        end
    end
end

end

