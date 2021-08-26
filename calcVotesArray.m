function [truevotes, falsevotes, nvotes] = calcVotesArray(amLabelledInterventions, amInterventions, ...
    overall_pdoffset, max_offset)

% calcVotesArray - calculates the true and false votes across the labelled test data

maxub= max(max(amLabelledInterventions.UpperBound1), max(amLabelledInterventions.UpperBound2(amLabelledInterventions.UpperBound2~=0)));
minlb= min(min(amLabelledInterventions.LowerBound1), min(amLabelledInterventions.LowerBound2(amLabelledInterventions.LowerBound2~=0)));
labelrange = maxub - minlb + 1;

arrayrange = max_offset - 1 + (-1 * minlb);

truevotes  = zeros(size(amInterventions, 1), arrayrange);
falsevotes = zeros(size(amInterventions, 1), arrayrange);
nvotes = 0;

for i = 1:size(amInterventions, 1)
    votesrow = zeros(1, labelrange);
    %lrow = amLabelledInterventions(i, :);
    lrow = amLabelledInterventions(   amLabelledInterventions.SmartCareID   == amInterventions.SmartCareID(i) ...
                                    & amLabelledInterventions.IVDateNum     == amInterventions.IVDateNum(i), :);
    % only score this example if a corresponding labelled intervention exists
    if size(lrow, 1) == 1
        nvotes = nvotes + 1;
        pdoffset = overall_pdoffset(i,:);
        %offset = amInterventions.Offset(i);
        % Lower and Upper Bounds are currently stored relative treatment date.
        % Need to create values in the array space
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
        %truevotes(i, (arrayrange + 1 + minlb - offset):arrayrange + 1 + maxub - offset)  = votesrow;
        %falsevotes(i, (arrayrange + 1 + minlb - offset):arrayrange + 1 + maxub - offset) = 1 - votesrow;
        for o = 0:max_offset - 1
            truevotes(i, (arrayrange + 1 + minlb - o):arrayrange + 1 + maxub - o)  = truevotes(i, (arrayrange + 1 + minlb - o):arrayrange + 1 + maxub - o)  + votesrow       * pdoffset(o + 1);
            falsevotes(i, (arrayrange + 1 + minlb - o):arrayrange + 1 + maxub - o) = falsevotes(i, (arrayrange + 1 + minlb - o):arrayrange + 1 + maxub - o) + (1 - votesrow) * pdoffset(o + 1);
        end
    end
end

end

