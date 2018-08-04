function [dist, hstg] = am4CalcObjFcn(meancurvemean, meancurvestd, amDatacube, amInterventions, measuresmask, normstd, hstg, currinter, curroffset, max_offset, align_wind, nmeasures, update_histogram, sigmamethod, smoothingmethod)

% am4CalcObjFcn - calculates residual sum of squares distance for points in
% curve vs meancurve incorporating offset

dist = 0;
scid   = amInterventions.SmartCareID(currinter);
start = amInterventions.IVScaledDateNum(currinter);

if (update_histogram == 1)
    for m = 1:nmeasures
        hstg(m, currinter, curroffset + 1) = 0;
    end
end

for m = 1:nmeasures
    if smoothingmethod == 2
        tempmean(:,m) = smooth(meancurvemean(:,m),5);
        tempstd(:,m) = smooth(meancurvestd(:,m),5);
    else
        tempmean(:,m) = meancurvemean(:,m);
        tempstd(:,m) = meancurvestd(:,m);
    end
end

for i = 1:align_wind
    for m = 1:nmeasures
        if start - i <= 0
            continue;
        end
        if ~isnan(amDatacube(scid, start - i, m))
            if sigmamethod == 4
                %thisdist = ( (meancurvesum((max_offset + align_wind + 1) - i - curroffset, m)/ meancurvecount((max_offset + align_wind + 1) - i - curroffset, m) ...
                %    - amDatacube(scid, start - i, m)) ^ 2 ) / (2 * (meancurvestd((max_offset + align_wind + 1) - i - curroffset, m) ^ 2) ) ;
                %thisdist = ( (meancurvemean((max_offset + align_wind + 1) - i - curroffset, m) ...
                %    - amDatacube(scid, start - i, m)) ^ 2 ) / ((meancurvestd((max_offset + align_wind + 1) - i - curroffset, m) ^ 2) ) ;
                %thisdist = ( (tempmean((max_offset + align_wind + 1) - i - curroffset, m) ...
                %    - amDatacube(scid, start - i, m)) ^ 2 ) / ((meancurvestd((max_offset + align_wind + 1) - i - curroffset, m) ^ 2) ) ;
                thisdist = ( (tempmean((max_offset + align_wind + 1) - i - curroffset, m) ...
                    - amDatacube(scid, start - i, m)) ^ 2 ) / ((tempstd((max_offset + align_wind + 1) - i - curroffset, m) ^ 2) ) ;

            else
                %thisdist = ( (meancurvesum((max_offset + align_wind + 1) - i - curroffset, m)/ meancurvecount((max_offset + align_wind + 1) - i - curroffset, m) ...
                %    - amDatacube(scid, start - i, m)) ^ 2 ) / (2 * (normstd(scid, m) ^ 2 ) ) ;
                %thisdist = ( (meancurvemean((max_offset + align_wind + 1) - i - curroffset, m) ...
                %    - amDatacube(scid, start - i, m)) ^ 2 ) / ((normstd(scid, m) ^ 2 ) ) ;
                thisdist = ( (tempmean((max_offset + align_wind + 1) - i - curroffset, m) ...
                    - amDatacube(scid, start - i, m)) ^ 2 ) / ((normstd(scid, m) ^ 2 ) ) ;
            end
            % add measures mask here to only include in the total for
            % subset of measures.
            if measuresmask(m) == 1
                dist = dist + thisdist;
            end
            
            if (update_histogram == 1)
                hstg(m, currinter, curroffset + 1) = hstg(m, currinter, curroffset + 1) + thisdist;
            end
        end
    end
end

end
