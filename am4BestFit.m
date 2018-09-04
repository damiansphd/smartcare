function [better_offset, hstg] = am4BestFit(meancurvemean, meancurvestd, amIntrCube, measuresmask, normstd, ...
    hstg, currinter, min_offset, max_offset, align_wind, nmeasures, sigmamethod, smoothingmethod)

% am4BestFit - calculates the offset for an intervention by minimising the
% objective function

% update the histogram during alignment process
update_histogram = 1;

% initialise variables
better_offset = 0;
mini = 1000000;

for i = min_offset:max_offset - 1
    [currdist, hstg] = am4CalcObjFcn(meancurvemean, meancurvestd, amIntrCube, measuresmask, ...
        normstd, hstg, currinter, i, max_offset, align_wind, nmeasures, update_histogram, sigmamethod, smoothingmethod);
    if currdist < mini
        better_offset = i;
        mini = currdist;
    end
end
    
end
