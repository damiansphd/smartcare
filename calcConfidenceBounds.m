function [amInterventions] = calcConfidenceBounds(overall_pdoffset, amInterventions, offsets, min_offset, max_offset, ninterventions, confidencethreshold, confidencemode)

% calcConfidenceBounds - calculates the lower and upper confidence bounds
% around the predicted offset

% note - maximum probability mode only works for prob distributions with a
% max of two peaks.

intrcount = array2table([1:ninterventions]');
intrcount.Properties.VariableNames{1} = 'IntrNbr';
amInterventions = [intrcount, amInterventions];
amInterventions.Offset = offsets;
amInterventions.LowerBound1(:) = offsets;
amInterventions.UpperBound1(:) = offsets;
amInterventions.LowerBound2(:) = -1;
amInterventions.UpperBound2(:) = -1;
amInterventions.ConfidenceProb(:) = 0;

for i = 1:ninterventions
    % Contiguous mode: populate the confidence bounds until they contain 
    % at least the probability defined by the confidence threshold. Start 
    % with the most likely day and increment by one day at a time (either 
    % moving left or right to the next most likely
    if confidencemode == 1
        cumprob = sum(overall_pdoffset(i, (amInterventions.LowerBound1(i) + 1):(amInterventions.UpperBound1(i) + 1)));
        leftshift1 = 0;
        rightshift1 = 0;
        while cumprob < confidencethreshold
            % get probabilities for adjacent points on either side
            if amInterventions.LowerBound1(i) > min_offset
                nextleftprob1 = overall_pdoffset(i, (amInterventions.LowerBound1(i) + 1) - 1);
            else
                nextleftprob1 = 0;
            end
            if amInterventions.UpperBound1(i) < max_offset - 1
                nextrightprob1 = overall_pdoffset(i, (amInterventions.UpperBound1(i) + 1) + 1);
            else
                nextrightprob1 = 0;
            end
            if nextleftprob1 > nextrightprob1
                leftshift1 = leftshift1 + 1;
                amInterventions.LowerBound1(i) = amInterventions.Offset(i) - leftshift1;
            else
                rightshift1 = rightshift1 + 1;
                amInterventions.UpperBound1(i) = amInterventions.Offset(i) + rightshift1;
            end
            cumprob = sum(overall_pdoffset(i, amInterventions.LowerBound1(i) + 1:amInterventions.UpperBound1(i) + 1));
            %fprintf('Intervention %2d, Offset = %2d, Lower = %2d, Upper = %2d, leftshift %d, rightshift %d, cumprob %.4f\n', i, amOffsetTable.Offset(i), ...
            %    amOffsetTable.LowerBound1(i), amOffsetTable.UpperBound1(i), leftshift, rightshift, cumprob);
        end
    
        % set the final lower and upper bounds and the probability this covers
        amInterventions.LowerBound1(i) = amInterventions.Offset(i) - leftshift1;
        amInterventions.UpperBound1(i) = amInterventions.Offset(i) + rightshift1;
        amInterventions.ConfidenceProb(i) = cumprob;
        fprintf('Intervention %2d, Offset = %2d, Lower = %2d, Upper = %2d, leftshift %d, rightshift %d, cumprob %.4f\n', ...
            i, amInterventions.Offset(i), amInterventions.LowerBound1(i), amInterventions.UpperBound1(i), ...
            leftshift1, rightshift1, cumprob);
    
    elseif confidencemode == 2
        % Maximum mode: select days in order of most likely days
        [sortedprob, sortedidx] = sort(overall_pdoffset(i, (min_offset + 1):max_offset),'descend');
        cumprob = 0;
        n = 0;
        while cumprob < confidencethreshold
            n = n + 1;
            cumprob = cumprob + sortedprob(n);
        end
        confidencedays = sort(sortedidx(1:n),'ascend');
        amInterventions.LowerBound1(i) = confidencedays(1) - 1;
        if size(confidencedays,2) > 1
            for a = 2:size(confidencedays,2)
                if (confidencedays(a) == confidencedays(a - 1) + 1)
                    continue;
                else
                    amInterventions.UpperBound1(i) = confidencedays(a-1) - 1;
                    amInterventions.LowerBound2(i) = confidencedays(a) - 1;
                end
            end
        else
            a = 1;
        end
        if amInterventions.LowerBound2(i) == -1
            amInterventions.UpperBound1(i) = confidencedays(a) - 1;
        else
            amInterventions.UpperBound2(i) = confidencedays(a) - 1;
        end
        amInterventions.ConfidenceProb(i) = cumprob;
        fprintf('Intervention %2d, Offset = %2d, Lower1 = %2d, Upper1 = %2d, Lower2 = %2d, Upper2 = %2d, cumprob %.4f\n', ...
            i, amInterventions.Offset(i), amInterventions.LowerBound1(i), amInterventions.UpperBound1(i), ...
            amInterventions.LowerBound2(i), amInterventions.UpperBound2(i), cumprob);
    else
        fprintf('Invalid Confidence mode\n');
    end

end

end
