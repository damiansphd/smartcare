function printDataDemographics(physdata, smartcareID)

% printDataDemographics - calculates and prints the count, mean, std, min, max
% by measure for the smart care data - either overall (if smartcareID = 0) or 
% by patient (if smartcareID ~=0)

tic
fprintf('Calculate basic data demographics\n');
fprintf('---------------------------------\n');

if (smartcareID == 0)
    idx1 = physdata.SmartCareID >= 0;
else
    idx1 = physdata.SmartCareID == smartcareID;
end

measures = unique(physdata.RecordingType);
for i = 1:size(measures,1)
    m = measures{i};
    idx2 = ismember(physdata.RecordingType, m);
    idx = idx1 & idx2;
    count = sum(idx);
    colname = getColumnForMeasure(m);
    if ismember(class(table2array(physdata(:, {colname}))), {'double'})
        data  = table2array(physdata(idx, colname));
        mmean = mean(data);
        mstd  = std(data);
        mmin  = min(data);
        mmax  = max(data);
        fprintf('Measure %25s has %5d measurements, with mean %8.2f, std %8.2f, min %8.2f, max %8.2f\n', m, count, mmean, mstd, mmin, mmax);
    else
        muniquevals = unique(physdata(idx, colname));
        fprintf('Measure %25s has %5d measurements, with %d unique valuea\n', m, count, size(muniquevals, 1));
    end
end
toc
fprintf('\n');

end

