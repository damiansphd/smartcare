function [physdataout, physdupes, tunique] = handleDuplicateMeasures(physdata, smartcareID, doupdates)

% handleDuplicateMeasures -  Analyse and correct for duplicate measures
% Duplicates are of three types - for a given patient ID and recordingtype :-
%           1) multiple rows with exactly the same date/time
%           2) multiple rows within a few minutes
%           3) multiple rows for the same day

tic

% first ensure physdata is sorted correctly
physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');

idxna = find(~ismember(physdata.RecordingType,'ActivityRecording'));
idxa = find(ismember(physdata.RecordingType,'ActivityRecording'));

% first deal with duplicates with exactly the same date/time
diffDTR = diff(physdata.Date_TimeRecorded);
exactidx = find(diffDTR == 0);
exactpairidx = unique([ exactidx ; exactidx+1 ]); % need to add next row for each diff of zero

% first fix non-activity dupes - all exact dupes have same values. 
% temp = varfun(@std, physdata(intersect(exactpairidx,idxna),:), 'GroupingVariables', {'SmartCareID','DateNum','UserName','RecordingType','Date_TimeRecorded'})
% Collapse by removing just first row of dupe pair (exactidx)
% for now just build idx of rows to delete
delexactnaidx = intersect(exactidx, idxna);

% next deal with activity dupes
delexactpairaidx = intersect(exactpairidx,idxa);




% handle duplicates - first analyse how many by recording type
fprintf('Handling duplicates - first look at demographics of duplicates\n');
%physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'DateNum'}, 'ascend');
t = physdata(:,:);
%[tunique, tI, tJ] = unique(t(:,{'SmartCareID', 'RecordingType', 'DateNum', 'Date_TimeRecorded'}));
[tunique, tI, tJ] = unique(t(:,{'SmartCareID', 'RecordingType', 'DateNum'}));

number = zeros(size(tunique,1),5);
number = array2table(number);
number.Properties.VariableNames{1} = 'Count';
number.Properties.VariableNames{2} = 'Mean';
number.Properties.VariableNames{3} = 'Std';
number.Properties.VariableNames{4} = 'Min';
number.Properties.VariableNames{5} = 'Max';
tunique = [tunique number];

physdupes = physdata;
physdupes(:,:) = [];
%for i = 1:size(tunique,1)
for i = 1:1
    idx = find(tJ==i);
    tunique.Count(i) = size(idx,1);
    if size(idx,1) > 1
        switch tunique.RecordingType{i}
            case 'ActivityRecording'
                tunique.Mean(i) = mean(t.Activity_Steps(idx));
                tunique.Std(i) = std(t.Activity_Steps(idx));
                tunique.Min(i) = min(t.Activity_Steps(idx));
                tunique.Max(i) = max(t.Activity_Steps(idx));
            case {'CoughRecording','SleepActivityRecording','WellnessRecording'}
                tunique.Mean(i) = mean(t.Rating(idx));
                tunique.Std(i) = std(t.Rating(idx));
                tunique.Min(i) = min(t.Rating(idx));
                tunique.Max(i) = max(t.Rating(idx));
            case 'LungFunctionRecording'
                tunique.Mean(i) = mean(t.FEV1_(idx));
                tunique.Std(i) = std(t.FEV1_(idx));
                tunique.Min(i) = min(t.FEV1_(idx));
                tunique.Max(i) = max(t.FEV1_(idx));
            case 'O2SaturationRecording'
                tunique.Mean(i) = mean(t.O2Saturation(idx));
                tunique.Std(i) = std(t.O2Saturation(idx));
                tunique.Min(i) = min(t.O2Saturation(idx));
                tunique.Max(i) = max(t.O2Saturation(idx));
            case 'PulseRateRecording'
                tunique.Mean(i) = mean(t.Pulse_BPM_(idx));
                tunique.Std(i) = std(t.Pulse_BPM_(idx));
                tunique.Min(i) = min(t.Pulse_BPM_(idx));
                tunique.Max(i) = max(t.Pulse_BPM_(idx));
            case 'SputumSampleRecording'
                tunique.Mean(i) = 0;
                tunique.Std(i) = 0;
                tunique.Min(i) = 0;
                tunique.Max(i) = 0;
            case 'TemperatureRecording'
                tunique.Mean(i) = mean(t.Temp_degC_(idx));
                tunique.Std(i) = std(t.Temp_degC_(idx));
                tunique.Min(i) = min(t.Temp_degC_(idx));
                tunique.Max(i) = max(t.Temp_degC_(idx));
            case 'WeightRecording'
                tunique.Mean(i) = mean(t.WeightInKg(idx));
                tunique.Std(i) = std(t.WeightInKg(idx));
                tunique.Min(i) = min(t.WeightInKg(idx));
                tunique.Max(i) = max(t.WeightInKg(idx));
            otherwise
                mmean = -1;
                mstd = -1;
                mmin = -1;
                mmax = -1; 
        end
        physdupes = [physdupes;t(idx,:)];
    end
    if (round(i/1000) == i/1000)
            fprintf('Processed %5d rows\n', i);
    end
    fflush(stdout);    
end
toc
fprintf('\n'); 




physdataout = physdata;
end

