function [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMRemoveFromMean(meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, currinter, max_offset, align_wind, nmeasures)

% amEMRemoveFromMean - remove a curve from the mean curve (sum and count) 
% - from all possible offsets, weighted by the overall probability of 
% each offset

for offset = 0:max_offset-1
    for m = 1:nmeasures
        for i = 1:align_wind
            if ~isnan(amIntrCube(currinter, align_wind + 1 - i, m))
                meancurvedata(max_offset + align_wind - offset - i, m, currinter) = meancurvedata(max_offset + align_wind - offset - i, m, currinter) - (amIntrCube(currinter, align_wind + 1 - i, m) * overall_pdoffset(currinter, offset + 1));
                meancurvesum(max_offset + align_wind - offset - i, m)   = meancurvesum(max_offset + align_wind - offset - i, m)   - (amIntrCube(currinter, align_wind + 1 - i, m) * overall_pdoffset(currinter, offset + 1));
                meancurvecount(max_offset + align_wind - offset - i, m) = meancurvecount(max_offset + align_wind - offset - i, m) - overall_pdoffset(currinter, offset + 1);
                %meancurvestd(max_offset + align_wind - offset - i, m) = std(meancurvedata(max_offset + align_wind - offset - i, m, meancurvedata(max_offset + align_wind - offset - i, m,:)~=0));
            end
            meancurvemean(max_offset + align_wind - offset - i, m) = meancurvesum(max_offset + align_wind - offset - i, m) / meancurvecount(max_offset + align_wind - offset - i, m);
            meancurvestd(max_offset + align_wind - offset - i, m) = std(meancurvedata(max_offset + align_wind - offset - i, m, meancurvedata(max_offset + align_wind - offset - i, m,:)~=0));
        end
    end
end

end
