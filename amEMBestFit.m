function [better_offset, mini, hstg, pdoffset, overall_hstg, overall_pdoffset] = amEMBestFit(meancurvemean, meancurvestd, amIntrCube, measuresmask, normstd, hstg, pdoffset, overall_hstg, overall_pdoffset, currinter, max_offset, align_wind, nmeasures, sigmamethod, emalignmethod)

% amEMBestFit - calculates the offset for an intervention by minimising the
% objective function

% update the histogram during alignment process
update_histogram = 1;

% initialise variables
better_offset = 0;
mini = 10000000000000000000;

for i = 0:max_offset - 1
    [currdist, hstg] = amEMCalcObjFcn(meancurvemean, meancurvestd, amIntrCube, measuresmask, ...
        normstd, hstg, currinter, i, max_offset, align_wind, nmeasures, update_histogram, sigmamethod);
    if currdist < mini
        better_offset = i;
        mini = currdist;
    end
end

for m=1:nmeasures
    pdoffset(m, currinter, :) = exp(-1 * (hstg(m, currinter, :) - min(hstg(m, currinter, :))));
    pdoffset(m, currinter, :) = pdoffset(m, currinter, :) / sum(pdoffset(m, currinter, :));
end

overall_hstg(currinter, :)     = reshape(sum(hstg(find(measuresmask),currinter,:),1), [1, max_offset]);

if emalignmethod == 1
    overall_pdoffset(currinter,:)     = exp(-1 * (overall_hstg(currinter,:) - min(overall_hstg(currinter, :)))); 
    overall_pdoffset(currinter,:)     = overall_pdoffset(currinter,:) / sum(overall_pdoffset(currinter,:));
else
    overall_pdoffset(currinter,:) = 0;
    overall_pdoffset(currinter, better_offset + 1) = 1;
end

end
