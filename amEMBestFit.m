function [better_offset, hstg, pdoffset] = amEMBestFit(meancurvemean, meancurvestd, amDatacube, amInterventions, measuresmask, normstd, hstg, pdoffset, currinter, max_offset, align_wind, nmeasures, sigmamethod)

% amEMBestFit - calculates the offset for an intervention by minimising the
% objective function

% update the histogram during alignment process
update_histogram = 1;

% initialise variables
better_offset = 0;
mini = 10000000000000000000;

for i = 0:max_offset - 1
    [currdist, hstg] = amEMCalcObjFcn(meancurvemean, meancurvestd, amDatacube, amInterventions, measuresmask, ...
        normstd, hstg, currinter, i, max_offset, align_wind, nmeasures, update_histogram, sigmamethod);
    if currdist < mini
        better_offset = i;
        mini = currdist;
    end
end

for m=1:nmeasures
    pdoffset(m, currinter, :) = exp(-1 * (hstg(m, currinter, :) - max(hstg(m, currinter, :))));
    pdoffset(m, currinter, :) = pdoffset(m, currinter, :) / sum(pdoffset(m, currinter, :));
end

    
end
