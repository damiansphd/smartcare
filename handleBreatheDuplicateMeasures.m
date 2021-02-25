function [physdata] = handleBreatheDuplicateMeasures(physdata, study, doupdates, detaillog)

% handleBreatheDuplicateMeasures -  Analyse and correct for duplicate measures
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

% first set cell array of all sleep measures and associated physdata column
sleepmeas = {'MinsAsleepRecording'; 'MinsAwakeRecording'};
sleepcol  = {'Sleep'};

% 1 First fix exact date/time/amount dupes for sleep (need to be handled
% separately because of the need to sum multiple genuine sleep records that
% can be created by fitbit on any given day
tic
fprintf('1) Exact date/time/amount duplicates for sleep\n');

% first ensure physdata is sorted correctly
physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded', sleepcol{1}}, 'ascend');

dupeidx = [];
addrows = [];
currdupeset = [];
pair = false;
totsame = 0;
totmax  = 0;
totmean = 0;
totsum  = 0;
for i = 1:size(physdata, 1) - 1
    if (physdata.SmartCareID(i)              == physdata.SmartCareID(i + 1)              && ...
        ismember(physdata.RecordingType(i),  sleepmeas)                                  && ...
        ismember(physdata.RecordingType(i),  physdata.RecordingType(i + 1))              && ...
        physdata.Date_TimeRecorded(i)        == physdata.Date_TimeRecorded(i + 1)        && ...
        table2array(physdata(i, sleepcol)) == table2array(physdata(i + 1, sleepcol)) )
    
        dupeidx = [dupeidx; i];
        currdupeset = [currdupeset; i];
        pair = true;
    else
        if pair == true
            mode = 'na'; % as this section is for same value matches, mode is irrelevant
            [dupeidx, addrows, nsame, nmax, nmean, nsum] = addDupeRows(physdata, dupeidx, currdupeset, addrows, i, mode, detaillog);
            totsame = totsame + nsame;
            totmax  = totmax  + nmax;
            totmean = totmean + nmean;
            totsum  = totsum  + nsum;
        end
        pair = false;
        currdupeset = [];
    end
end
if pair == true
    i = i + 1;
    mode = 'na'; % as this section is for same value matches, mode is irrelevant
    [dupeidx, addrows, nsame, nmax, nmean, nsum] = addDupeRows(physdata, dupeidx, currdupeset, addrows, i, mode, detaillog);
    totsame = totsame + nsame;
    totmax  = totmax  + nmax;
    totmean = totmean + nmean;
    totsum  = totsum  + nsum;
end

writetable(physdata(dupeidx, :), fullfile(basedir, 'ExcelFiles', dupefile), 'Sheet', 'ExactTimeAmtSleepDupes');

% apply necessary updates.
if doupdates
    fprintf('Deleting %d exact amount sleep duplicates, and adding back %d single rows\n', size(dupeidx, 1), size(addrows, 1));
    fprintf('Same %d, diffmax %d, diffmean %d, diffsum %d, checksum %d\n', totsame, totmax, totmean, ...
                totsum, size(dupeidx, 1) - totsame - totmax - totmean - totsum);
    physdata(dupeidx, :) = [];
    physdata = [physdata; addrows];
    physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
end
toc
fprintf('\n');

% 2) Remaingin exact date/time dupes
fprintf('2) Remaining exact date/time duplicates - sleep diff value, other meas same and diff value\n');
dupeidx = [];
addrows = [];
currdupeset = [];
pair = false;
totsame = 0;
totmax  = 0;
totmean = 0;
totsum  = 0;
for i = 1:size(physdata, 1) - 1
    if (physdata.SmartCareID(i)            == physdata.SmartCareID(i + 1)        && ...
        ismember(physdata.RecordingType(i),   physdata.RecordingType(i + 1))     && ...
        physdata.Date_TimeRecorded(i)      == physdata.Date_TimeRecorded(i + 1)  )
    
        dupeidx = [dupeidx; i];
        currdupeset = [currdupeset; i];
        pair = true;
    else
        if pair == true
            if ismember(physdata.RecordingType(i), sleepmeas)
                mode = 'sum';
            else
                mode = 'max';
            end
            [dupeidx, addrows, nsame, nmax, nmean, nsum] = addDupeRows(physdata, dupeidx, currdupeset, addrows, i, mode, detaillog);
            totsame = totsame + nsame;
            totmax  = totmax  + nmax;
            totmean = totmean + nmean;
            totsum  = totsum  + nsum;
        end
        pair = false;
        currdupeset = [];
    end
end
if pair == true
    i = i + 1;
    if ismember(physdata.RecordingType(i), sleepmeas)
        mode = 'sum';
    else
        mode = 'max';
    end
    [dupeidx, addrows, nsame, nmax, nmean, nsum] = addDupeRows(physdata, dupeidx, currdupeset, addrows, i, mode, detaillog);
    totsame = totsame + nsame;
    totmax  = totmax  + nmax;
    totmean = totmean + nmean;
    totsum  = totsum  + nsum;
end

writetable(physdata(dupeidx, :), fullfile(basedir, 'ExcelFiles', dupefile), 'Sheet', 'ExactTimeDupes');

% apply necessary updates.
if doupdates
    fprintf('Deleting %d exact duplicates, and adding back %d single rows\n', size(dupeidx, 1), size(addrows, 1));
    fprintf('Same %d, diffmax %d, diffmean %d, diffsum %d, checksum %d\n', totsame, totmax, totmean, ...
                totsum, size(dupeidx, 1) - totsame - totmax - totmean - totsum);
    physdata(dupeidx, :) = [];
    physdata = [physdata; addrows];
    physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
end
toc
 fprintf('\n');

% 3) Fix all similar time dupes
tic
fprintf('3) Similar date/time duplicates\n');
dupeidx = [];
addrows = [];
currdupeset = [];
pair = false;
totsame = 0;
totmax  = 0;
totmean = 0;
totsum  = 0;
for i = 1:size(physdata, 1) - 1
    if (physdata.SmartCareID(i)            == physdata.SmartCareID(i + 1)               && ...
        ismember(physdata.RecordingType(i),   physdata.RecordingType(i + 1))            && ...
        minutes(physdata.Date_TimeRecorded(i + 1) - physdata.Date_TimeRecorded(i)) < 60 )
    
        dupeidx = [dupeidx; i];
        currdupeset = [currdupeset; i];
        pair = true;
    else
        if pair == true
            if ismember(physdata.RecordingType(i), sleepmeas)
                mode = 'sum';
            else
                mode = 'max';
            end
            [dupeidx, addrows, nsame, nmax, nmean, nsum] = addDupeRows(physdata, dupeidx, currdupeset, addrows, i, mode, detaillog);
            totsame = totsame + nsame;
            totmax  = totmax  + nmax;
            totmean = totmean + nmean;
            totsum  = totsum  + nsum;
        end
        pair = false;
        currdupeset = [];
    end
end
if pair == true
    i = i + 1;
    if ismember(physdata.RecordingType(i), sleepmeas)
        mode = 'sum';
    else
        mode = 'max';
    end
    [dupeidx, addrows, nsame, nmax, nmean, nsum] = addDupeRows(physdata, dupeidx, currdupeset, addrows, i, mode, detaillog);
    totsame = totsame + nsame;
    totmax  = totmax  + nmax;
    totmean = totmean + nmean;
    totsum  = totsum  + nsum;
end

writetable(physdata(dupeidx, :), fullfile(basedir, 'ExcelFiles', dupefile), 'Sheet', 'SimilarTimeDupes');

% apply necessary updates.
if doupdates
    fprintf('Deleting %d similar time duplicates, and adding back %d single rows\n', size(dupeidx, 1), size(addrows, 1));
    fprintf('Same %d, diffmax %d, diffmean %d, diffsum %d, checksum %d\n', totsame, totmax, totmean, ...
                totsum, size(dupeidx, 1) - totsame - totmax - totmean - totsum);
    physdata(dupeidx, :) = [];
    physdata = [physdata; addrows];
end
physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
toc
fprintf('\n');

% 4) Fix all same day dupes
tic
fprintf('4) Same day duplicates \n');
dupeidx = [];
addrows = [];
currdupeset = [];
pair = false;
mode = 'mean';
totsame = 0;
totmax  = 0;
totmean = 0;
totsum  = 0;
for i = 1:size(physdata, 1) - 1
    if (physdata.SmartCareID(i)            == physdata.SmartCareID(i + 1)               && ...
        ismember(physdata.RecordingType(i),   physdata.RecordingType(i + 1))            && ...
        physdata.DateNum(i + 1)            == physdata.DateNum(i)                       )
    
        dupeidx = [dupeidx; i];
        currdupeset = [currdupeset; i];
        pair = true;
    else
        if pair == true
            if ismember(physdata.RecordingType(i), sleepmeas)
                mode = 'sum';
            else
                mode = 'mean';
            end
            [dupeidx, addrows, nsame, nmax, nmean, nsum] = addDupeRows(physdata, dupeidx, currdupeset, addrows, i, mode, detaillog);
            totsame = totsame + nsame;
            totmax  = totmax  + nmax;
            totmean = totmean + nmean;
            totsum  = totsum  + nsum;
        end
        pair = false;
        currdupeset = [];
    end
end
if pair == true
    i = i + 1;
    if ismember(physdata.RecordingType(i), sleepmeas)
        mode = 'sum';
    else
        mode = 'mean';
    end
    [dupeidx, addrows, nsame, nmax, nmean, nsum] = addDupeRows(physdata, dupeidx, currdupeset, addrows, i, mode, detaillog);
    totsame = totsame + nsame;
    totmax  = totmax  + nmax;
    totmean = totmean + nmean;
    totsum  = totsum  + nsum;
end

writetable(physdata(dupeidx, :), fullfile(basedir, 'ExcelFiles', dupefile), 'Sheet', 'SameDayDupes');

% apply necessary updates.
if doupdates
    fprintf('Deleting %d same day duplicates, and adding back %d single rows\n', size(dupeidx, 1), size(addrows, 1));
    fprintf('Same %d, diffmax %d, diffmean %d, diffsum %d, checksum %d\n', totsame, totmax, totmean, ...
                totsum, size(dupeidx, 1) - totsame - totmax - totmean - totsum);
    physdata(dupeidx, :) = [];
    physdata = [physdata; addrows];
end
physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'Date_TimeRecorded'}, 'ascend');
toc
fprintf('\n');

end

