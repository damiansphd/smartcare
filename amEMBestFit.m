function [better_offset, hstg, pdoffset, overall_hstg, overall_pdoffset, isOutlier] = amEMBestFit(meancurvemean, meancurvestd, ...
    amIntrCube, amHeldBackcube, measuresmask, measuresrange, normstd, hstg, pdoffset, overall_hstg, overall_pdoffset, isOutlier, outprior, currinter, min_offset, max_offset, align_wind, ...
    nmeasures, sigmamethod, smoothingmethod, runmode)

% amEMBestFit - calculates the offset for an intervention by minimising the
% objective function

% update the histogram during alignment process
update_histogram = 1;

% initialise variables
better_offset = 0;
minidist = 1000000;

for i = min_offset:max_offset - 1
    [currdist, dummy, hstg, isOutlier] = amEMCalcObjFcn(meancurvemean, meancurvestd, amIntrCube, amHeldBackcube, isOutlier, outprior, ...
        measuresmask, measuresrange, normstd, hstg, currinter, i, max_offset, align_wind, nmeasures, update_histogram, sigmamethod, smoothingmethod);
    if currdist < minidist
        better_offset = i;
        minidist = currdist;
    end
end

for m=1:nmeasures
    pdoffset(m, currinter, min_offset+1:max_offset) = convertFromLogSpaceAndNormalise(hstg(m, currinter, min_offset+1:max_offset));
end

overall_hstg(currinter, :)     = reshape(sum(hstg(find(measuresmask),currinter,:),1), [1, max_offset]);

if runmode == 5
    overall_pdoffset(currinter,min_offset+1:max_offset) = 0;
    overall_pdoffset(currinter, better_offset + 1) = 1;
else
    overall_pdoffset(currinter,min_offset+1:max_offset) = convertFromLogSpaceAndNormalise(overall_hstg(currinter,min_offset+1:max_offset));
end
    
end

