function [better_offset, hstg] = am2BestFit(meancurvesum, meancurvecount, amDatacube, amInterventions, measures, normstd, hstg, currinter, max_offset, align_wind, nmeasures)

% am2BestFit - calculates the offset for an intervention by minimising the
% objective function

scid   = amInterventions.SmartCareID(currinter);
start = amInterventions.IVScaledDateNum(currinter);

better_offset = 0;
mini = 1000000;

for i = 0:max_offset - 1
    [currdist, hstg] = am2CalcObjFcn(meancurvesum, meancurvecount, amDatacube, amInterventions, measures, normstd, hstg, currinter, i, max_offset, align_wind, nmeasures, 1);
    if currdist < mini
        better_offset = i;
        mini = currdist;
    end
end
    
end
