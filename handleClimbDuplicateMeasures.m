function [physdata] = handleClimbDuplicateMeasures(physdata, study, doupdates, detaillog)

% handleClimbDuplicateMeasures -  Analyse and correct for duplicate measures
% Duplicates are of three types - for a given patient ID and recordingtype :-
%           1) multiple rows with exactly the same date/time
%           2) multiple rows within 60 minutes
%           3) multiple rows for the same day

dupefile = sprintf('%sDuplicates.xlsx', study);
%fitbitrecording = {'CalorieRecording', 'RestingHRRecording', 'MinsAsleepRecording', 'MinsAwakeRecording'};

fprintf('Handling Breathe Duplicates\n');
fprintf('---------------------------\n');
tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
demographicsmatfile = sprintf('%sdatademographicsbypatient.mat', study);
fprintf('Loading demographic data by patient\n');
load(fullfile(basedir, subfolder, demographicsmatfile));
toc
fprintf('\n');

% first ensure physdata is sorted correctly
physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');

% 1) Fix all exact date/time dupes
tic
fprintf('1) Exact date/time duplicates\n');
dupeidx = [];
addrows = [];
currdupeset = [];
pair = false;
mode = 'max';
for i = 1:size(physdata, 1) - 1
    if (physdata.SmartCareID(i)            == physdata.SmartCareID(i + 1)        && ...
        ismember(physdata.RecordingType(i),   physdata.RecordingType(i + 1))     && ...
        physdata.Date_TimeRecorded(i)      == physdata.Date_TimeRecorded(i + 1)  )
    
        dupeidx = [dupeidx; i];
        currdupeset = [currdupeset; i];
        pair = true;
    else
        if pair == true
            [dupeidx, addrows] = addDupeRows(physdata, dupeidx, currdupeset, addrows, i, mode, detaillog);
        end
        pair = false;
        currdupeset = [];
    end
end
if pair == true
    i = i + 1;
    [dupeidx, addrows] = addDupeRows(physdata, dupeidx, currdupeset, addrows, i, mode, detaillog);
end

writetable(physdata(dupeidx, :), fullfile(basedir, 'ExcelFiles', dupefile), 'Sheet', 'ExactTimeDupes');

% apply necessary updates.
if doupdates
    fprintf('Deleting %d exact duplicates, and adding back %d single rows\n', size(dupeidx, 1), size(addrows, 1));
    physdata(dupeidx, :) = [];
    physdata = [physdata; addrows];
    physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
end
toc
fprintf('\n');

% 2) Fix all similar time dupes
tic
fprintf('2) Similar date/time duplicates\n');
dupeidx = [];
addrows = [];
currdupeset = [];
pair = false;
mode = 'max';
for i = 1:size(physdata, 1) - 1
    if (physdata.SmartCareID(i)            == physdata.SmartCareID(i + 1)               && ...
        ismember(physdata.RecordingType(i),   physdata.RecordingType(i + 1))            && ...
        minutes(physdata.Date_TimeRecorded(i + 1) - physdata.Date_TimeRecorded(i)) < 60 )
    
        dupeidx = [dupeidx; i];
        currdupeset = [currdupeset; i];
        pair = true;
    else
        if pair == true
            [dupeidx, addrows] = addDupeRows(physdata, dupeidx, currdupeset, addrows, i, mode, detaillog);
        end
        pair = false;
        currdupeset = [];
    end
end
if pair == true
    i = i + 1;
    [dupeidx, addrows] = addDupeRows(physdata, dupeidx, currdupeset, addrows, i, mode, detaillog);
end

writetable(physdata(dupeidx, :), fullfile(basedir, 'ExcelFiles', dupefile), 'Sheet', 'SimilarTimeDupes');

%temp = physdata(dupeidx, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded', 'DateNum'});
%temp2 = varfun(@mean, temp, 'GroupingVariables', {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'});
%writetable(temp2(:, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded', 'GroupCount'}), fullfile(basedir, 'ExcelFiles', dupefile), 'Sheet', 'SimilarTimeDupes');

% apply necessary updates.
if doupdates
    fprintf('Deleting %d similar time duplicates, and adding back %d single rows\n', size(dupeidx, 1), size(addrows, 1));
    physdata(dupeidx, :) = [];
    physdata = [physdata; addrows];
end
physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
toc
fprintf('\n');

% 3) Fix all same day dupes
tic
fprintf('3) Same day duplicates \n');
dupeidx = [];
addrows = [];
currdupeset = [];
pair = false;
mode = 'mean';
for i = 1:size(physdata, 1) - 1
    if (physdata.SmartCareID(i)            == physdata.SmartCareID(i + 1)               && ...
        ismember(physdata.RecordingType(i),   physdata.RecordingType(i + 1))            && ...
        physdata.DateNum(i + 1)            == physdata.DateNum(i)                       )
    
        dupeidx = [dupeidx; i];
        currdupeset = [currdupeset; i];
        pair = true;
    else
        if pair == true
            [dupeidx, addrows] = addDupeRows(physdata, dupeidx, currdupeset, addrows, i, mode, detaillog);
        end
        pair = false;
        currdupeset = [];
    end
end
if pair == true
    i = i + 1;
    [dupeidx, addrows] = addDupeRows(physdata, dupeidx, currdupeset, addrows, i, mode, detaillog);
end

writetable(physdata(dupeidx, :), fullfile(basedir, 'ExcelFiles', dupefile), 'Sheet', 'SameDayDupes');

%temp = physdata(dupeidx, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded', 'DateNum'});
%temp2 = varfun(@mean, temp, 'GroupingVariables', {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'});
%writetable(temp2(:, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded', 'GroupCount'}), fullfile(basedir, 'ExcelFiles', dupefile), 'Sheet', 'SameDayDupes');

% apply necessary updates.
if doupdates
    fprintf('Deleting %d same day duplicates, and adding back %d single rows\n', size(dupeidx, 1), size(addrows, 1));
    physdata(dupeidx, :) = [];
    physdata = [physdata; addrows];
end
physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
toc
fprintf('\n');

end

