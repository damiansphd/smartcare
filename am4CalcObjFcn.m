function [dist, hstg] = am4CalcObjFcn(meancurvemean, meancurvestd, amIntrCube, measuresmask, normstd, hstg, ...
    currinter, curroffset, max_offset, align_wind, nmeasures, update_histogram, sigmamethod, smoothingmethod)

% am4CalcObjFcn - calculates residual sum of squares distance for points in
% curve vs meancurve incorporating offset

dist = 0;
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
        if ~isnan(amIntrCube(currinter, max_offset + align_wind - i, m))
            if sigmamethod == 4
                thisdist = (( (tempmean(max_offset + align_wind - i - curroffset, m) - amIntrCube(currinter, max_offset + align_wind - i, m)) ^ 2 ) ...
                                / (2 * ( tempstd(max_offset + align_wind - i - curroffset, m) ^ 2 ))) ...
                            + log(tempstd(max_offset + align_wind - i - curroffset, m)) ...
                            + log((2 * pi) ^ 0.5);
            else
                thisdist = (( (tempmean(max_offset + align_wind - i - curroffset, m) - amIntrCube(currinter, max_offset + align_wind - i, m)) ^ 2 ) ...
                                / (2 * ( normstd(currinter, m) ^ 2 ))) ...
                            + log(normstd(currinter, m)) ...
                            + log((2 * pi) ^ 0.5);
            end
            % only include desired measures in overall alignment
            % optimisation
            if measuresmask(m) == 1
                dist = dist + thisdist;
            end
            
            if (update_histogram == 1)
                hstg(m, currinter, curroffset + 1) = hstg(m, currinter, curroffset + 1) + thisdist;
            end
        end
    end
end

end
