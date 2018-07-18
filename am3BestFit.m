function [better_offset, hstg] = am3BestFit(meancurvesum, meancurvecount, meancurvestd, amDatacube, amInterventions, measuresmask, normstd, hstg, currinter, max_offset, align_wind, nmeasures, sigmamethod)

% am3BestFit - calculates the offset for an intervention by minimising the
% objective function

scid   = amInterventions.SmartCareID(currinter);
start = amInterventions.IVScaledDateNum(currinter);

% update the histogram during alignment process
update_histogram = 1;

% initialise variables
better_offset = 0;
mini = 1000000;

for i = 0:max_offset - 1
    [currdist, hstg] = am3CalcObjFcn(meancurvesum, meancurvecount, meancurvestd, amDatacube, amInterventions, measuresmask, ...
        normstd, hstg, currinter, i, max_offset, align_wind, nmeasures, update_histogram, sigmamethod);
    if currdist < mini
        better_offset = i;
        mini = currdist;
    end
end
    
end
