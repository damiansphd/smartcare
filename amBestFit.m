function [better_offset, hstg] = amBestFit(meancurvesum, meancurvecount, amNormcube, amInterventions, hstg, currinter, max_offset, align_wind, nmeasures)

% amBestFit - calculates the offset for an intervention by minimising the
% objective function

scid   = amInterventions.SmartCareID(currinter);
start = amInterventions.IVScaledDateNum(currinter);

better_offset = 0;
mini = 1000000;
for m = 1:nmeasures
    for i = 1:max_offset
            hstg(m, currinter, i) = 0;
    end
end

for i = 0:max_offset - 1
    [currdist, hstg] = amCalcObjFcn(meancurvesum, meancurvecount, amNormcube, amInterventions, hstg, currinter, i, max_offset, align_wind, nmeasures, 1);
    if currdist < mini
        better_offset = i;
        mini = currdist;
    end
end
    
end
