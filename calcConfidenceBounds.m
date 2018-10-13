function [amOffsetTable] = calcConfidenceBounds(overall_pdoffset, amInterventions, offsets, min_offset, max_offset, ninterventions, confidencethreshold)

% calcConfidenceBounds - calculates the lower and upper confidence bounds
% around the predicted offset

amOffsetTable = amInterventions(:, {'SmartCareID','IVScaledDateNum', 'IVStartDate'});
intrcount = array2table([1:ninterventions]');
intrcount.Properties.VariableNames{1} = 'IntrNbr';
amOffsetTable = [intrcount, amOffsetTable];

amOffsetTable.Offset = offsets;
amOffsetTable.LowerBound(:) = offsets;
amOffsetTable.UpperBound(:) = offsets;
amOffsetTable.ConfidenceProb(:) = 0;

for i = 1:ninterventions
    cumprob = sum(overall_pdoffset(i, (amOffsetTable.LowerBound(i) + 1):(amOffsetTable.UpperBound(i) + 1)));
    leftshift = 0;
    rightshift = 0;
    while cumprob < confidencethreshold
        if amOffsetTable.LowerBound(i) > min_offset
            leftprob = overall_pdoffset(i, (amOffsetTable.Offset(i) + 1) - (leftshift + 1));
        else
            leftprob = 0;
        end
        if amOffsetTable.UpperBound(i) < max_offset - 1
            rightprob = overall_pdoffset(i, (amOffsetTable.Offset(i) + 1) + (rightshift + 1));
        else
            rightprob = 0;
        end
        if leftprob > rightprob
            leftshift = leftshift + 1;
            amOffsetTable.LowerBound(i) = amOffsetTable.Offset(i) - leftshift;
        else
            rightshift = rightshift + 1;
            amOffsetTable.UpperBound(i) = amOffsetTable.Offset(i) + rightshift;
        end
        cumprob = sum(overall_pdoffset(i, amOffsetTable.LowerBound(i) + 1:amOffsetTable.UpperBound(i) + 1));
        %fprintf('Intervention %2d, Offset = %2d, Lower = %2d, Upper = %2d, leftshift %d, rightshift %d, cumprob %.4f\n', i, amOffsetTable.Offset(i), ...
        %    amOffsetTable.LowerBound(i), amOffsetTable.UpperBound(i), leftshift, rightshift, cumprob);
    end
    amOffsetTable.LowerBound(i) = amOffsetTable.Offset(i) - leftshift;
    amOffsetTable.UpperBound(i) = amOffsetTable.Offset(i) + rightshift;
    amOffsetTable.ConfidenceProb(i) = cumprob;
    fprintf('Intervention %2d, Offset = %2d, Lower = %2d, Upper = %2d, leftshift %d, rightshift %d, cumprob %.4f\n', i, amOffsetTable.Offset(i), ...
            amOffsetTable.LowerBound(i), amOffsetTable.UpperBound(i), leftshift, rightshift, cumprob);
end


end

