function [better_offset, mini, hstg, pdoffset, overall_hstg, overall_pdoffset] = amEMBestFit(meancurvemean, meancurvestd, ...
    amIntrCube, measuresmask, normstd, hstg, pdoffset, overall_hstg, overall_pdoffset, currinter, max_offset, align_wind, ...
    nmeasures, sigmamethod, smoothingmethod, runmode)

% amEMBestFit - calculates the offset for an intervention by minimising the
% objective function

% update the histogram during alignment process
update_histogram = 1;

% initialise variables
better_offset = 0;
mini = 10000000000000000000;

for i = 0:max_offset - 1
    [currdist, hstg] = amEMCalcObjFcn(meancurvemean, meancurvestd, amIntrCube, measuresmask, ...
        normstd, hstg, currinter, i, max_offset, align_wind, nmeasures, update_histogram, sigmamethod, smoothingmethod);
    if currdist < mini
        better_offset = i;
        mini = currdist;
    end
end

for m=1:nmeasures
    pdoffset(m, currinter, :) = convertFromLogSpaceAndNormalise(hstg(m, currinter, :));
end

overall_hstg(currinter, :)     = reshape(sum(hstg(find(measuresmask),currinter,:),1), [1, max_offset]);

if runmode == 5
    overall_pdoffset(currinter,:) = 0;
    overall_pdoffset(currinter, better_offset + 1) = 1;
else
    overall_pdoffset(currinter,:) = convertFromLogSpaceAndNormalise(overall_hstg(currinter,:));
end
    
end

