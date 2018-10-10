function [amIntrDatacube] = createIntrDatacube(amDatacube, amInterventions, align_wind, max_offset, ninterventions, nmeasures, curveaveragingmethod)

% createIntrDatacube - creates the data cube for offset + alignement window
% by intervention (for each measure)

amIntrDatacube = NaN(ninterventions, max_offset + align_wind - 1, nmeasures);

for i = 1:ninterventions
    scid   = amInterventions.SmartCareID(i);
    start = amInterventions.IVScaledDateNum(i);
    
    icperiodend = align_wind + max_offset -1;
    dcperiodend = start - 1;
    
    if curveaveragingmethod == 1
        icperiodstart = align_wind;
        dcperiodstart = start - align_wind;
    else
        icperiodstart = 1;
        dcperiodstart = start - (align_wind + max_offset - 1);
    end
    
    if dcperiodstart <= 0
        icperiodstart = icperiodstart - dcperiodstart + 1;
        dcperiodstart = 1;
    end
    
    for m = 1:nmeasures
        amIntrDatacube(i, (icperiodstart:icperiodend), m) = amDatacube(scid, dcperiodstart:dcperiodend, m);
    end
end

end

