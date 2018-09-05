function [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd] = amEMRemoveFromMean(meancurvesumsq, meancurvesum, ...
    meancurvecount, meancurvemean, meancurvestd, overall_pdoffset, amIntrCube, currinter, min_offset, max_offset, align_wind, nmeasures)

% amEMRemoveFromMean - remove a curve from the mean curve from all 
% possible offsets, weighted by the overall probability of each offset

for offset = min_offset:max_offset-1
    % place the current intervention curve into every possible offset
    % position, weighted by the probability each offset position is the
    % right one
    for m = 1:nmeasures
        for i = 1:(max_offset + align_wind - 1 - offset)
            if ~isnan(amIntrCube(currinter, max_offset + align_wind - i, m))
                meancurvesumsq(max_offset + align_wind - offset - i, m) = meancurvesumsq(max_offset + align_wind - offset - i, m) - ((amIntrCube(currinter, max_offset + align_wind - i, m) ^ 2) * overall_pdoffset(currinter, offset + 1));
                meancurvesum(max_offset + align_wind - offset - i, m)   = meancurvesum(max_offset + align_wind - offset - i, m)   -  (amIntrCube(currinter, max_offset + align_wind - i, m)      * overall_pdoffset(currinter, offset + 1));
                meancurvecount(max_offset + align_wind - offset - i, m) = meancurvecount(max_offset + align_wind - offset - i, m) - overall_pdoffset(currinter, offset + 1);
            end
        end
    end
end


%meancurvemean(1:(max_offset + align_wind - 1 - min_offset),:) = meancurvesum(1:(max_offset + align_wind - 1 - min_offset),:) ./ meancurvecount(1:(max_offset + align_wind - 1 - min_offset),:);

%meancurvestd(1:(max_offset + align_wind - 1 - min_offset),:)  = ((meancurvesumsq(1:(max_offset + align_wind - 1 - min_offset),:) ./ meancurvecount(1:(max_offset + align_wind - 1 - min_offset),:)) ...
%                                                                - (meancurvemean(1:(max_offset + align_wind - 1 - min_offset),:) .* meancurvemean(1:(max_offset + align_wind - 1 - min_offset),:))) .^ 0.5;


meancurvemean = meancurvesum ./ meancurvecount;
meancurvestd  = (abs((meancurvesumsq ./ meancurvecount) - (meancurvemean .* meancurvemean))) .^ 0.5;

if min_offset > 0
    meancurvemean((max_offset + align_wind - min_offset): (max_offset + align_wind - 1),:) = 0;
    meancurvestd((max_offset + align_wind - min_offset): (max_offset + align_wind - 1),:)  = 0;
end

end
