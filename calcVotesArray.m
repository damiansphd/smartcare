function [truevotes, falsevotes] = calcVotesArray(amLabelledInterventions, amInterventions, ...
    align_wind, max_offset)

% calcVotesArray - calculates the true and false votes across the labelled test data

maxub= max(max(amLabelledInterventions.UpperBound1), max(amLabelledInterventions.UpperBound2(amLabelledInterventions.UpperBound2~=0)));
minlb= min(min(amLabelledInterventions.LowerBound1), min(amLabelledInterventions.LowerBound2(amLabelledInterventions.LowerBound2~=0)));
labelrange = maxub - minlb + 1;

arrayrange = align_wind + (-1 * minlb) - 1;

truevotes  = zeros(size(amInterventions, 1), arrayrange);
falsevotes = zeros(size(amInterventions, 1), arrayrange);

for i = 1:size(amInterventions, 1)
    %votesrow = zeros(1, align_wind);
    votesrow = zeros(1, labelrange);
    lrow = amLabelledInterventions(i, :);
    offset = amInterventions.Offset(i);
    % Lower and Upper Bounds are currently stored relative to the
    % previously chosen ex_start date. Need to convert to 'offset' space
    % before using them here.
    %ub1 = lrow.UpperBound1 - lrow.ExStart + 1;
    %lb1 = lrow.LowerBound1 - lrow.ExStart + 1;
    %ub2 = lrow.UpperBound2 - lrow.ExStart + 1;
    %lb2 = lrow.LowerBound2 - lrow.ExStart + 1;
    ub1 = lrow.UpperBound1 - minlb + 1;
    lb1 = lrow.LowerBound1 - minlb + 1;
    ub2 = lrow.UpperBound2 - minlb + 1;
    lb2 = lrow.LowerBound2 - minlb + 1;
    predrange = (ub1 - lb1 + 1);
    if ub2 ~= lb2
        predrange = predrange + (ub2 - lb2 + 1);
    end
    votesrow(lb1:ub1) = 1/predrange;
    if ub2 ~= lb2
        votesrow(lb2:ub2) = 1/predrange;
    end
    %votesrow((arrayshift + 1 + lb1 - offset):(arrayshift + 1 + ub1 - offset)) = 1/predrange;
    %if ub2 ~= lb2
    %    votesrow((arrayshift + 1 + lb2 - offset):(arrayshift + 1 + ub2 - offset)) = 1/predrange;
    %end
    
    %truevotes(i, adjpos:adjpos + align_wind - 1)  = votesrow;
    %falsevotes(i, adjpos:adjpos + align_wind - 1) = 1 - votesrow;
    %truevotes(i,:) = votesrow;
    %falsevotes(i,:) = 1 - votesrow;
    truevotes(i, (arrayrange + 1 + minlb - offset):arrayrange + 1 +maxub - offset)  = votesrow;
    falsevotes(i, (arrayrange + 1 + minlb - offset):arrayrange + 1 +maxub - offset) = 1 - votesrow;
end

end

