function [amImputedCube, imputedscore] = amEMMCCalcImputedProbabilities(amIntrCube, amHeldBackcube, ...
        meancurvemean, meancurvestd, normstd, overall_pdoffset, max_offset, align_wind, nmeasures, ...
        ninterventions,sigmamethod, smoothingmethod, imputationmode, latentcurve, nlatentcurves)


% getImputedProbabilities - gets the probabilities for the set of held back
% points and also returns the cumulative normalised distance from the
% objective function for these points

tempmean = zeros(nlatentcurves, max_offset + align_wind - 1, nmeasures);
tempstd  = zeros(nlatentcurves, max_offset + align_wind - 1, nmeasures);
amImputedCube = zeros(ninterventions, max_offset + align_wind - 1, nmeasures);

for n = 1:nlatentcurves
    for m = 1:nmeasures
        if smoothingmethod == 2
            tempmean(n, :, m) = smooth(meancurvemean(n, :, m), 5);
            tempstd(n, :, m)  = smooth(meancurvestd(n, :, m), 5);
        else
            tempmean(n, :, m) = meancurvemean(n, :, m);
            tempstd(n, :, m)  = meancurvestd(n, :, m);
        end
    end
end

imputedscore = 0;

if imputationmode == 2
    for n = 1:ninterventions
        lc = latentcurve(n);
        for i = 1:align_wind
            for m = 1:nmeasures
                for offset = 0:max_offset - 1
                    if (~isnan(amIntrCube(n, max_offset + align_wind - i, m)) && amHeldBackcube(n, max_offset + align_wind - i, m) == 1)
                        thisdist = calcRegDist(tempmean(lc, max_offset + align_wind - i - offset, m), ...
                                               tempstd(lc, max_offset + align_wind - i - offset, m), ...
                                               normstd(n, m), ...
                                               amIntrCube(n, max_offset + align_wind - i, m), ...
                                               sigmamethod);
                        amImputedCube(n, max_offset + align_wind - i, m) = ...
                            amImputedCube(n, max_offset + align_wind - i, m) + (exp(-thisdist) * overall_pdoffset(lc, n, offset + 1));
                    end
                end
                if amHeldBackcube(n, max_offset + align_wind - i, m) == 1
                    imputedscore = imputedscore + log(amImputedCube(n, max_offset + align_wind - i, m));
                    fprintf('Intervention %2d, Latent Curve %d, day %2d, measure %d, score is %.2f\n', n, lc, ...
                        max_offset + align_wind - i, m, log(amImputedCube(n, max_offset + align_wind - i, m))); 
                end
            end
        end
    end
end

fprintf('\n');
fprintf('Total held back points: %.6f\n', sum(sum(sum(amHeldBackcube))));
fprintf('Total imputed score   : %.6f\n', imputedscore);
fprintf('Scaled imputed score  : %.6f\n', imputedscore/sum(sum(sum(amHeldBackcube))));
fprintf('\n');

end

