function votesarray = calcVotesArray(amLabelledInterventions, amInterventions, ...
    align_wind, max_offset)

% calcVotesArray - calculates the votes array across the labelled test data

votesarray = zeros(size(amInterventions, 1), align_wind + max_offset - 1);
% an offset of zero is equivalent to day 25 in the 49 day window (data
% window + max offset)
baselinepos = 25;

for i = 1:size(amInterventions, 1)
    votesrow = zeros(1, align_wind);
    lrow = amLabelledInterventions(i, :);
    offset = amInterventions.Offset(i);
    % Lower and Upper Bounds are currently stored relative to the
    % previously chosen ex_start date. Need to convert to 'offset' space
    % before using them here.
    ub1 = lrow.UpperBound1 - lrow.ExStart + 1;
    lb1 = lrow.LowerBound1 - lrow.ExStart + 1;
    ub2 = lrow.UpperBound2 - lrow.ExStart + 1;
    lb2 = lrow.LowerBound2 - lrow.ExStart + 1;
    predrange = (ub1 - lb1 + 1);
    if ub2 ~= lb2
        predrange = predrange + (ub2 - lb2 + 1);
    end
    votesrow(lb1:ub1) = 1/predrange;
    if ub2 ~= lb2
        votesrow(lb2:ub2) = 1/predrange;
    end
    adjpos = baselinepos - offset;
    votesarray(i, adjpos:adjpos + align_wind - 1) = votesrow;
end

end

