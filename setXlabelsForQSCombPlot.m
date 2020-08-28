function [xlabel] = setXlabelsForQSCombPlot(bsqstablerow, filename, type)

% setXlabelsForQSCombPlot - sets the xlabel for the QS Comb plot

if type == 1
    if contains(filename, '-MS')
        tempstring = split(bsqstablerow.MSMeas{1}, ':');
    else
        tempstring = split(bsqstablerow.RawMeas{1}, ':');
        if ismember(tempstring(1), {'1'})
            tempstring = split(bsqstablerow.Volatility{1}, ':');
            if ismember(tempstring(1), {'1'})
                tempstring = split(bsqstablerow.PMean{1}, ':');
            end 
        end
    end
elseif type == 2 || type == 3
    tempstring = split(bsqstablerow.InterpMthd{1}, ':');
end

xlabel = tempstring(2);

end

