function [physdata, physdata_original, offset] = loadAndCorrectSmartCareData(scdatafile,patientid, detaillog)

% loadAndCorrectSmartCareData - performs the following
%       1) loads smartcare data file
%       2) removes dummy entries
%       3) fixes one incorrect UserName
%       4) adds and populates columns for SmartCareID and Days Offset
%       5) removes unwanted columns
%       6) fixes blanks for measures

tic
fprintf('Loading SmartCare data file: %s\n', scdatafile);
fprintf('---------------------------------------\n');
physdata = readtable(scdatafile);
physdata.Properties.Description = 'Table containing SmartCare measurement data';
physdata_original = physdata;
fprintf('SmartCare data has %d rows\n', size(physdata,1));

% save memory by defining these columns as categorical
%physdata.UserName = categorical(physdata.UserName);
%physdata.RecordingType = categorical(physdata.RecordingType);

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
%add column for SmartCareID and Date offsets
number = zeros(size(physdata,1),1);
number = array2table(number);
number.Properties.VariableNames{1} = 'SmartCareID';
days = zeros(size(physdata,1),2);
days = array2table(days);
days.Properties.VariableNames{1} = 'ScaledDateNum';
days.Properties.VariableNames{2} = 'DateNum';
physdata = [number days physdata];

% day offset - add 1sec to correctly handle measurements taken at exactly
% midnight
minmdate = min(physdata.Date_TimeRecorded);
offset = datenum(datetime(year(minmdate), month(minmdate), day(minmdate)));
physdata.DateNum = ceil(datenum(datetime(physdata.Date_TimeRecorded)+seconds(1))-offset);

%sort patientid file by the ID
patientid = sortrows(patientid,'SmartCareID','ascend');

fprintf('Adding SmartCare ID to the data table\n');
fprintf('-------------------------------------\n');
totupdates = 0;
for i = 1:size(patientid,1)
    id = patientid.Patient_ID{i};
    scid = patientid.SmartCareID(i);
    idx = find(ismember(physdata.UserID, id));
    if detaillog
        fprintf('Updating SmartCareID %3d for UserID %22s - %4d rows updated\n', scid, id, size(idx,1));
    end
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
% remove unused information, take a copy first
% physdata2 = physdata;
fprintf('Trim data table of unneeded data\n');
fprintf('--------------------------------\n');
fprintf('Removing unused columns - UserID, FEV10, Calories, SputumSampleTaken,Activity_Points\n');
%physdata(:,{'UserID','FEV10','Calories','SputumSampleTaken_','Activity_Points'}) = [];
physdata(:,{'UserID','FEV10','Calories','Activity_Points'}) = [];
toc
fprintf('\n');

tic
% correct for blank entries
fprintf('Correcting blank entries\n');
fprintf('------------------------\n');

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
physdata.SputumSampleTaken_l = physdata.SputumSampleTaken_;
physdata.SputumSampleTaken_i(:) = 0;
physdata.SputumSampleTaken_ = [];
physdata.SputumSampleTaken_ = physdata.SputumSampleTaken_i;
physdata.SputumSampleTaken_i = [];

idx1 = find(ismember(physdata.RecordingType, 'SputumSampleRecording'));
idx2 = find(ismember(physdata.SputumSampleTaken_l,'true'));
idx = intersect(idx1,idx2);
physdata.SputumSampleTaken_(idx) = 1;
idx1 = find(ismember(physdata.RecordingType, 'SputumSampleRecording'));
idx2 = find(~ismember(physdata.SputumSampleTaken_l,'true'));

% switch these for emem heatmap
idx = intersect(idx1,idx1);
%idx = intersect(idx1,idx2);
fprintf('Removing %4d sputum sample measurements\n', size(idx,1));
physdata(idx,:) = [];

physdata.SputumSampleTaken_l = [];
% comment this out for emem heatmap
physdata.SputumSampleTaken_ = [];





% Temperature Recording - remove blanks
idx1 = find(ismember(physdata.RecordingType, 'TemperatureRecording'));
idx2 = find(isnan(physdata.Temp_degC_));
idx = intersect(idx1,idx2);
fprintf('Removing %4d blank temperature measurements\n', size(idx,1));
physdata(idx,:) = [];

fprintf('SmartCare data now has %d rows\n', size(physdata,1));
toc
fprintf('\n');

end

