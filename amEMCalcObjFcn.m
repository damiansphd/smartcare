function [dist, count, hstg, isOutlier] = amEMCalcObjFcn(meancurvemean, meancurvestd, amIntrCube, ...
    amHeldBackcube, isOutlier, outprior, measuresmask, measuresrange, normstd, hstg, currinter, ...
    curroffset, max_offset, align_wind, nmeasures, update_histogram, sigmamethod, smoothingmethod)

% amEMCalcObjFcn - calculates residual sum of squares distance for points in
% curve vs meancurve incorporating offset

dist = 0;
count = 0;
tempmean = zeros(max_offset + align_wind - 1, nmeasures);
tempstd  = zeros(max_offset + align_wind - 1, nmeasures);

if (update_histogram == 1)
    for m = 1:nmeasures
        hstg(m, currinter, curroffset + 1) = 0;
    end
end

for m = 1:nmeasures
    if smoothingmethod == 2
        tempmean(:,m) = smooth(meancurvemean(:,m),5);
        tempstd(:,m) = smooth(meancurvestd(:,m),5);
    else
        tempmean(:,m) = meancurvemean(:,m);
        tempstd(:,m) = meancurvestd(:,m);
    end
end

for i = 1:align_wind
    for m = 1:nmeasures
        % distance calculation for an outlier point
        outdist = -log(outprior) + log(measuresrange(m));
        if (~isnan(amIntrCube(currinter, max_offset + align_wind - i, m)) && amHeldBackcube(currinter, max_offset + align_wind - i, m) == 0)
            % distance calculation for a regular point
            regdist = calcRegDist(tempmean(max_offset + align_wind - i - curroffset, m), ...
                                  tempstd(max_offset + align_wind - i - curroffset, m), ...
                                  normstd(currinter, m), ...
                                  amIntrCube(currinter, max_offset + align_wind - i, m), ...
                                  sigmamethod);
            regdist = regdist - log(1 - outprior);

            if regdist <= outdist
                thisdist = regdist;
                isOutlier(currinter, align_wind + 1 - i, m, curroffset + 1) = 0;
            else
                thisdist = outdist;
                isOutlier(currinter, align_wind + 1 - i, m, curroffset + 1) = 1;
            end
            
            % only include desired measures in overall alignment
            % optimisation
            if measuresmask(m) == 1
                dist = dist + thisdist;
                count = count + 1;
            end
            if (update_histogram == 1)
                hstg(m, currinter, curroffset + 1) = hstg(m, currinter, curroffset + 1) + thisdist;
            end
        end
    end
end

end
