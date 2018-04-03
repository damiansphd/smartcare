function printDataDemographics(physdata, smartcareID)

% printDataDemographics - calculates and prints the count, mean, std, min, max
% by measure for the smart care data - either overall (if smartcareID = 0) or 
% by patient (if smartcareID ~=0)

tic
fprintf('Calculate basic data demographics\n');
fprintf('---------------------------------\n');

if (smartcareID == 0)
    idx1 = find(physdata.SmartCareID);
else
    idx1 = find(physdata.SmartCareID == smartcareID);
end

measures = unique(physdata.RecordingType);
for i = 1:size(measures,1)
    mmean = 0;mstd = 0;mmin = 0;mmax = 0;mtrue = 0;mfalse = 0;
    m = measures{i};
    idx2 = find(ismember(physdata.RecordingType, m));
    idx = intersect(idx1,idx2);
    count = size(idx,1);
    switch m
        case 'ActivityRecording'
            mmean = mean(physdata.Activity_Steps(idx,:));
            mstd = std(physdata.Activity_Steps(idx,:));
            mmin = min(physdata.Activity_Steps(idx,:));
            mmax = max(physdata.Activity_Steps(idx,:));
        case {'CoughRecording','SleepActivityRecording','WellnessRecording'}
            mmean = mean(physdata.Rating(idx,:));
            mstd = std(physdata.Rating(idx,:));
            mmin = min(physdata.Rating(idx,:));
            mmax = max(physdata.Rating(idx,:));
        case 'LungFunctionRecording'
            mmean = mean(physdata.FEV1_(idx,:));
            mstd = std(physdata.FEV1_(idx,:));
            mmin = min(physdata.FEV1_(idx,:));
            mmax = max(physdata.FEV1_(idx,:));
        case 'O2SaturationRecording'
            mmean = mean(physdata.O2Saturation(idx,:));
            mstd = std(physdata.O2Saturation(idx,:));
            mmin = min(physdata.O2Saturation(idx,:));
            mmax = max(physdata.O2Saturation(idx,:));
        case 'PulseRateRecording'
            mmean = mean(physdata.Pulse_BPM_(idx,:));
            mstd = std(physdata.Pulse_BPM_(idx,:));
            mmin = min(physdata.Pulse_BPM_(idx,:));
            mmax = max(physdata.Pulse_BPM_(idx,:));
        case 'SputumSampleRecording'
            mtrue = size(find(ismember(physdata.SputumSampleTaken_(idx,:),'true')),1);
            mfalse = size(find(~ismember(physdata.SputumSampleTaken_(idx,:),'true')),1);
        case 'TemperatureRecording'
            mmean = mean(physdata.Temp_degC_(idx,:));
            mstd = std(physdata.Temp_degC_(idx,:));
            mmin = min(physdata.Temp_degC_(idx,:));
            mmax = max(physdata.Temp_degC_(idx,:));
        case 'WeightRecording'
            mmean = mean(physdata.WeightInKg(idx,:));
            mstd = std(physdata.WeightInKg(idx,:));
            mmin = min(physdata.WeightInKg(idx,:));
            mmax = max(physdata.WeightInKg(idx,:));
        otherwise
            mmean = -1;
            mstd = -1;
            mmin = -1;
            mmax = -1;
    end
    if isequal(m,'SputumSampleRecording')
        fprintf('Measure %22s has %5d measurements, with true %d and false %d\n', m, count, mtrue, mfalse);
    else
        fprintf('Measure %22s has %5d measurements, with mean %4.2f, std %4.2f, min %4.2f, max %4.2f\n', m, count, mmean, mstd, mmin, mmax);
    end
end
toc
fprintf('\n');

end

