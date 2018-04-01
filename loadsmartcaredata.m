clear; clc; close;

scdatafile = 'mydata.csv';
patientidfile = 'patientid.xlsx';

% patient id file + corrections
tic
fprintf('Loading Patient ID file: %s\n', patientidfile);
patientid = readtable(patientidfile);
patientid.Properties.Description = 'Table containing mapping of UserID to SmartCareID';
patientid.Properties.VariableNames{3} = 'SmartCareID';
fprintf('Patient ID data has %d rows\n', size(patientid,1));

badids = table({'TKpptiCA5cASNKU0VSmx4' ;'Cujq-NEcld_Keu_W1-Nw5' ; 'Q0Wf614z94DSTy6nXjyw7';'0HeWh64M_zc5U512xqzAs4';'1au5biSTt0bNWgfl0Wltr5'}, ... 
               {'-TKpptiCA5cASNKU0VSmx4';'-Cujq-NEcld_Keu_W1-Nw5';'-Q0Wf614z94DSTy6nXjyw7';'0HeWh64M_zc5U5l2xqzAs4';'1au5biSTt0bNWgfI0WItr5'}, ...
               'VariableNames', {'Patient_ID','Correct_ID'});
idx = find(ismember(patientid(:,'Patient_ID'), badids(:,'Patient_ID')));
fprintf('Updating incorrect Patient IDs - %d rows\n', size(idx,1));
for i = 1:size(idx,1)
    patientid.Patient_ID{idx(i)} = badids.Correct_ID{i};
end
toc
fprintf('\n');

% hard code this one as it had a trailing ' at the end of the id causing
% mismatches
patientid.Patient_ID{23} = 'h503el8mUI5hP-fwcnonk6';

% SmartCare measurement data + corrections
tic
fprintf('Loading SmartCare data file: %s\n', scdatafile);
physdata = readtable(scdatafile);
physdata.Properties.Description = 'Table containing SmartCare measurement data';
physdata1_original = physdata;
fprintf('SmartCare data has %d rows\n', size(physdata,1));
toc
fprintf('\n');

% update incorrect StudyID FPH0011 to FPH011
idx = find(ismember(physdata.UserName, 'FPH0011'));
fprintf('Updating incorrect StudyID FPH0011 to FPH011 - %d rows\n', size(idx,1));
physdata{idx,'UserName'} = {'FPH011'};

% remove dummy user measurements
dummies = {'EmemTest','PapBen','PapworthSummer','Ryan007','Texas','010wessex','davetest','scguest'};
idx = find(ismember(physdata.UserName, dummies));
fprintf('Removing dummy users - %d rows\n', size(idx,1));
physdata(idx,:) = [];

fprintf('SmartCare data now has %d rows\n', size(physdata,1));
toc
fprintf('\n');

tic
%add column for SmartCareID
number = zeros(size(physdata,1),1);
number = array2table(number);
number.Properties.VariableNames{1} = 'SmartCareID';
day = zeros(size(physdata,1),1);
day = array2table(day);
day.Properties.VariableNames{1} = 'DateNum'; 
physdata = [number day physdata];

%sort both files by the ID
patientid = sortrows(patientid,'SmartCareID','ascend');
%physdata = sortrows(physdata,'UserID','ascend');

totupdates = 0;
for i = 1:size(patientid,1)
    id = patientid.Patient_ID{i};
    scid = patientid.SmartCareID(i);
    idx = find(ismember(physdata.UserID, id));
    fprintf('Updating SmartCareID %3d for UserID %22s - %4d rows updated\n', scid, id, size(idx,1));
    physdata.SmartCareID(idx) = scid;
    totupdates = totupdates + size(idx,1);
end

fprintf('Total rows updated = %d\n', totupdates);
fprintf('Rows with no SmartCareID match = %4d\n', size(physdata,1)-totupdates);

idx = find(physdata.SmartCareID ==0);
missedids = unique(physdata(idx,'UserID'));

if (size(missedids,1) > 0)
    fprintf('UserIDs not matched are :-\n');
    for i = 1:size(missedids,1)
        fprintf('%23s\n', missedids.UserID{i});
    end
end
toc
fprintf('\n');

tic
% time offset
offset  = datenum(datetime(2015,8,5,0,0,0)); 
physdata.DateNum = ceil(datenum(datetime(physdata.Date_TimeRecorded))-offset);
physdata1 = physdata;

% correct for blank entries
fprintf('Correcting blank entries\n');

% Activity_Steps - update blanks to zeros
idx1 = find(ismember(physdata.RecordingType, 'ActivityRecording'));
idx2 = find(isnan(physdata.Activity_Steps));
idx = intersect(idx1,idx2);
fprintf('Updating %4d blank activity measurements to 0\n', size(idx,1));
physdata.Activity_Steps(idx) = 0;

% Cough, Wellness & Sleep Recording - remove blanks
idx1 = find(ismember(physdata.RecordingType, {'CoughRecording';'WellnessRecording';'SleepActivityRecording'}));
idx2 = find(isnan(physdata.Rating));
idx = intersect(idx1,idx2);
fprintf('Removing %4d blank cough, wellness and sleep measurements\n', size(idx,1));
physdata(idx,:) = [];

% Sputum Sample Recording - remove blanks
idx1 = find(ismember(physdata.RecordingType, 'SputumSampleRecording'));
idx2 = find(~ismember(physdata.SputumSampleTaken_,'true'));
idx = intersect(idx1,idx2);
fprintf('Removing %4d sputum sample measurements\n', size(idx,1));
physdata(idx,:) = [];

% Temperature Recording - remove blanks
idx1 = find(ismember(physdata.RecordingType, 'TemperatureRecording'));
idx2 = find(isnan(physdata.Temp_degC_));
idx = intersect(idx1,idx2);
fprintf('Removing %4d blank temperature measurements\n', size(idx,1));
physdata(idx,:) = [];

fprintf('\n');

% handle anomalies in the data
fprintf('Correcting anomalies in the data\n');

% Activity Reading - > 30,000 steps
idx1 = find(ismember(physdata.RecordingType, 'ActivityRecording'));
idx2 = find(physdata.Activity_Steps > 30000);
idx = intersect(idx1,idx2);
fprintf('Found    %4d activity measurements > 30,000\n', size(idx,1));
%temp = sortrows(physdata(idx,:), {'SmartCareID', 'DateNum'}, 'ascend');
%temp(:, {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','Activity_Steps'})

% Lung Function - FEV1% < 10% or > 130%
idx1 = find(ismember(physdata.RecordingType, 'LungFunctionRecording'));
idx2 = find(physdata.FEV1_ < 10 | physdata.FEV1_ > 130);
idx3 = intersect(idx1,idx2);
idx4 = find(physdata.SmartCareID ~= 227);
idx = intersect(idx3,idx4);
fprintf('Removing %4d lung function measurements < 10%% or > 130%% (except patient 227)\n', size(idx,1));
%temp = sortrows(physdata(idx,:), {'SmartCareID', 'DateNum'}, 'ascend');
%temp(:, {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','FEV1_'})
physdata(idx,:) = [];

% note looked further at FEV1% < 20%, all seemed valid except patients 172
% and 197 who had multiple (2 or 3) readings within a couple of minutes and
% the low score was an outlier. When handling duplicates for FEV1%, propose
% to take max on a given day rather than average.

% O2 Saturation < 80% or > 100%
idx1 = find(ismember(physdata.RecordingType, 'O2SaturationRecording'));
idx2 = find(physdata.O2Saturation < 80 | physdata.O2Saturation > 100);
idx = intersect(idx1,idx2);
fprintf('Found    %4d O2 saturation measurements > 100%% or < 80%%\n', size(idx,1));
%temp = sortrows(physdata(idx,:), {'SmartCareID', 'DateNum'}, 'ascend');
%temp(:, {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','O2Saturation'})
% for now, just remove the 127% measures as these are clearly spurios.
% leave the 103% and 104% measures for patient 82 until I get an answer
% back from Andres as to whether this is possible, or whether they should
% be capped at 100%
idx2 = find(physdata.O2Saturation == 127 | physdata.O2Saturation < 80);
idx = intersect(idx1,idx2);
fprintf('Removing %4d O2 saturation measurements = 127%% or < 80%%\n', size(idx,1));
physdata(idx,:) = [];

% Pulse Rate (BPM) < 50 or > 150
idx1 = find(ismember(physdata.RecordingType, 'PulseRateRecording'));
idx2 = find(physdata.Pulse_BPM_ < 50 | physdata.Pulse_BPM_ > 150);
idx = intersect(idx1,idx2);
fprintf('Found    %4d Pulse Rate measurements < 50 or > 150\n', size(idx,1));
%temp = sortrows(physdata(idx,:), {'SmartCareID', 'DateNum'}, 'ascend');
%temp(:, {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','Pulse_BPM_'})
% remove those with < 48 and == 511
idx2 = find(physdata.Pulse_BPM_ < 48 | physdata.Pulse_BPM_ == 511);
idx = intersect(idx1,idx2);
fprintf('Removing %4d Pulse Rate measurements < 48 or == 511\n', size(idx,1));
physdata(idx,:) = [];

% Temperature Recording - convert 4 readings taken in degF to degC
idx1 = find(ismember(physdata.RecordingType, 'TemperatureRecording'));
idx2 = find(physdata.Temp_degC_ > 96 & physdata.Temp_degC_ < 99);
idx = intersect(idx1,idx2);
fprintf('Converting %2d temperature measurements in degF to degC\n', size(idx,1));
physdata.Temp_degC_(idx) = (physdata.Temp_degC_(idx) - 32) / 1.8;

% Temperature Recording - remove illogical values (< 30 degC or > 50 degC)
idx1 = find(ismember(physdata.RecordingType, 'TemperatureRecording'));
idx2 = find(physdata.Temp_degC_ < 30 | physdata.Temp_degC_ > 50);
idx = intersect(idx1,idx2);
%temp = sortrows(physdata(idx,:), {'SmartCareID', 'DateNum'}, 'ascend');
%temp(:, {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','Temp_degC_'})
fprintf('Removing %4d illogical temperature measurements (>50degC or <30degC)\n', size(idx,1));
physdata(idx,:) = [];

% Weight Recording - < 35kg or > 125kg
idx1 = find(ismember(physdata.RecordingType, 'WeightRecording'));
idx2 = find(physdata.WeightInKg < 35 | physdata.WeightInKg > 125);
idx = intersect(idx1,idx2);
%temp = sortrows(physdata(idx,:), {'SmartCareID', 'DateNum'}, 'ascend');
%temp(:, {'SmartCareID','UserName','RecordingType','Date_TimeRecorded','WeightInKg'})
fprintf('Removing %4d weight measurements < 35kg or > 125kg\n', size(idx,1));
physdata(idx,:) = [];

toc
fprintf('\n');

fprintf('SmartCare data now has %d rows\n', size(physdata,1));
fprintf('\n');

tic
% remove unused information, take a copy first
physdata2 = physdata;
fprintf('Removing unused columns - UserID, FEV10, Calories, Activity_Points\n');
physdata(:,{'UserID','FEV10','Calories','Activity_Points'}) = [];
toc
fprintf('\n');

tic
%measures = unique(physdata(:,'RecordingType'));
measures = unique(physdata.RecordingType);
for i = 1:size(measures,1)
    mmean = 0;mstd = 0;mmin = 0;mmax = 0;mtrue = 0;mfalse = 0;
    m = measures{i};
    idx = find(ismember(physdata.RecordingType, m));
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

tic
outputfilename = 'smartcaredata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(outputfilename, 'physdata', 'physdata1_original', 'patientid', 'measures');
toc

%tunique = unique(t(:,{'DateNum','RecordingType','SmartCareID'}));
%number = zeros(size(tunique,1),2);
%number = array2table(number);
%number.Properties.VariableNames{1} = 'Total';
%number.Properties.VariableNames{2} = 'Count';
%tunique = [tunique number];



%patientlist = unique(patientid.SmartCareID(:));
%for i = 1:size(patientlist,1)
%    scid = patientlist(i);
%   
%end


