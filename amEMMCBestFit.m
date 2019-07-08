function [better_offset, better_curve, hstg, pdoffset, overall_hist, overall_pdoffset, vshift, isOutlier] = amEMMCBestFit(meancurvemean, meancurvestd, ...
    amIntrCube, amHeldBackcube, measuresmask, measuresrange, normstd, hstg, pdoffset, overall_hist, overall_pdoffset, vshift, ...
    isOutlier, outprior, currinter, min_offset, max_offset, align_wind, nmeasures, sigmamethod, smoothingmethod, runmode, nlatentcurves, allowvshift, vshiftmax)

% amEMMCBestFit - calculates the offset and curve for an intervention by minimising the
% objective function (with multiple sets of latent curves)

% update the histogram during alignment process
update_histogram = 1;

% initialise variables
better_offset = 0;
better_curve  = 0;
minidist = 1000000;

for n = 1:nlatentcurves
    for i = min_offset:max_offset - 1
        [currdist, ~, hstg(n, :, :, :), vshift(n, :, :, :), isOutlier(n, :, :, :, :)] = amEMMCCalcObjFcn(meancurvemean(n, :, :), meancurvestd(n, :, :), amIntrCube, amHeldBackcube, vshift(n, :, :, :), ...
            isOutlier(n, :, :, :, :), outprior, measuresmask, measuresrange, normstd, hstg(n, :, :, :), currinter, i, max_offset, align_wind, nmeasures, ...
            update_histogram, sigmamethod, smoothingmethod, allowvshift, vshiftmax);
        if currdist < minidist
            better_offset = i;
            better_curve = n;
            minidist = currdist;
        end
    end
end

for n = 1:nlatentcurves
    overall_hist(n, currinter, :)     = reshape(sum(hstg(n, logical(measuresmask), currinter, :), 2), [1, max_offset]);
end

for m=1:nmeasures
    pdoffset(:, m, currinter, min_offset+1:max_offset) = amEMMCConvertFromLogSpaceAndNormalise(hstg(:, m, currinter, min_offset+1:max_offset));
end

if runmode == 5
    overall_pdoffset(:, currinter,min_offset+1:max_offset) = 0;
    overall_pdoffset(better_curve, currinter, better_offset + 1) = 1;
else
    overall_pdoffset(:, currinter, (min_offset + 1):max_offset) = amEMMCConvertFromLogSpaceAndNormalise(overall_hist(:, currinter, (min_offset + 1):max_offset));
end
    
end

