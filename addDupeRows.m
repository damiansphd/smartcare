function [alldupeidx, addrows] = addDupeRows(data, alldupeidx, currdupesetidx, addrows, i, mode, detaillog)

% addDupeRows - adds to dupe rows array and relevant index arrays

alldupeidx = [alldupeidx; i];
currdupesetidx    = [currdupesetidx; i];
colname    = getColumnForMeasure(data.RecordingType{i});
dupestd    = std(table2array(data(currdupesetidx, {colname})));
addrow     = data(i, :);
if dupestd == 0
    if detaillog
        fprintf('Exact dupe %6d has same value - keeping one instance\n', i);
    end
    addrows = [addrows; addrow];
else
    if detaillog
        fprintf('Exact dupe %6d has different value - keeping max\n', i);
    end
    if ismember(mode, 'max')
        newval = max(table2array(data(currdupesetidx, {colname})));
    elseif ismember(mode, 'mean')
        newval = mean(table2array(data(currdupesetidx, {colname})));
    end
    addrow(1, {colname}) = array2table(newval);
    addrows = [addrows; addrow];
end

end

