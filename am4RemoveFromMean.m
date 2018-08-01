function [meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = am4RemoveFromMean(meancurvedata, meancurvesum, meancurvecount, meancurvemean, meancurvestd, amDatacube, amInterventions, currinter, max_offset, align_wind, nmeasures, curveaveragingmethod, smoothingmethod)

% am4RemoveFromMean - remove a curve from the mean curve (sum and count)

scid   = amInterventions.SmartCareID(currinter);
start = amInterventions.IVScaledDateNum(currinter);
offset = amInterventions.Offset(currinter);

if curveaveragingmethod == 1
    averagewindow = align_wind;
else
    averagewindow = max_offset + align_wind - offset;
end

meancurvedata(:, :, currinter) = nan;

for m = 1:nmeasures
    for i = 1:averagewindow
        if start - i <= 0
            continue;
        end
        if ~isnan(amDatacube(scid, start - i, m))
            meancurvesum((max_offset + align_wind + 1) - offset - i, m)   = meancurvesum((max_offset + align_wind + 1) - offset - i, m)   - amDatacube(scid, start - i, m);
            meancurvecount((max_offset + align_wind + 1) - offset - i, m) = meancurvecount((max_offset + align_wind + 1) - offset - i, m) - 1;
            %meancurvemean((max_offset + align_wind + 1) - offset - i, m) = meancurvesum((max_offset + align_wind + 1) - offset - i, m) / meancurvecount((max_offset + align_wind + 1) - offset - i, m);
            meancurvestd((max_offset + align_wind + 1) - offset - i, m) = std(meancurvedata((max_offset + align_wind + 1) - offset - i, m, ~isnan(meancurvedata((max_offset + align_wind + 1) - offset - i, m,:))));
        end
        meancurvemean((max_offset + align_wind + 1) - offset - i, m) = meancurvesum((max_offset + align_wind + 1) - offset - i, m) / meancurvecount((max_offset + align_wind + 1) - offset - i, m);
    end
    %if smoothingmethod == 2
    %    meancurvemean(:,m) = smooth(meancurvemean(:,m),3);
    %end
end

end