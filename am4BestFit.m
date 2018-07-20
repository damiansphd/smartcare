function [better_offset, hstg] = am4BestFit(meancurvemean, meancurvestd, amDatacube, amInterventions, measuresmask, normstd, hstg, currinter, max_offset, align_wind, nmeasures, sigmamethod)

% am4BestFit - calculates the offset for an intervention by minimising the
% objective function

scid   = amInterventions.SmartCareID(currinter);
start = amInterventions.IVScaledDateNum(currinter);

% update the histogram during alignment process
update_histogram = 1;

% initialise variables
better_offset = 0;
mini = 1000000;

for i = 0:max_offset - 1
    [currdist, hstg] = am4CalcObjFcn(meancurvemean, meancurvestd, amDatacube, amInterventions, measuresmask, ...
        normstd, hstg, currinter, i, max_offset, align_wind, nmeasures, update_histogram, sigmamethod);
    if currdist < mini
        better_offset = i;
        mini = currdist;
    end
end
    
end
