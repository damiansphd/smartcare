function plotMeasuresByHour(physdata, smartcareID, imagefilename)

% plotMeasuresByHour - for each measure, plot a histogram of number of 
% measures by hour recorded. For all data (if smartcareid = 0) or for a given
% patient (if smartcareid ~= 0)
% Use this to inform whether to adjust date offset 


% index or rows for smartcare id (all or single patient)
if (smartcareID == 0)
    idxs = find(physdata.SmartCareID);
else
    idxs = find(physdata.SmartCareID == smartcareID);
end

tic
fprintf('Plot number of measures recorded by hour for each measure\n');
fprintf('---------------------------------------------------------\n');

measures = unique(physdata.RecordingType);
for i = 1:size(measures,1)
    m = measures{i};
    idxm = find(ismember(physdata.RecordingType, m));
    idx = intersect(idxs,idxm);
    figure;
    histogram(hour(datetime(physdata.Date_TimeRecorded(idx))));
    legend(sprintf('Count of %s by Hour of Day',m), 'location', 'north');    
end
toc
