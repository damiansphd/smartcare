function [earlybirds, nightowls] = analyseOvernightMeasures(physdata, smartcareID)

% analyseOvernightMeasures - analyses measures recorded between 00:00 and
% 03:59 to ascertain whether to adjust measurement day to prior day

daterange = 3;
nrowstoshow = 100;
tic
% index or rows for smartcare id (all or single patient)
if (smartcareID == 0)
    idxs = find(physdata.SmartCareID);
else
    idxs = find(physdata.SmartCareID == smartcareID);
end

% index rows of all measurment types except ActivityRecording
idxm = find(~ismember(physdata.RecordingType, 'ActivityRecording'));

% find list of patients who regularly take measurements between 3am and
% 4:59am (earlybirds)
idxe = find(hour(datetime(physdata.Date_TimeRecorded))== 3 | hour(datetime(physdata.Date_TimeRecorded))==4);
idxe = intersect(idxm, idxe);
[earlybirds, eI, eJ] = unique(physdata.SmartCareID(idxe));
ecount = zeros(size(earlybirds,1),1);
for e = 1:size(earlybirds,1)
    ecount(e) = size(find(eJ==e),1);
end
earlybirds = earlybirds(find(ecount>=10));

% find list of patients who regularly take measurements between 12am and
% 1:59am (night owls)
idxn = find(hour(datetime(physdata.Date_TimeRecorded))== 0 | hour(datetime(physdata.Date_TimeRecorded))==1);
idxn = intersect(idxm, idxn);
[nightowls, nI, nJ] = unique(physdata.SmartCareID(idxn));
ncount = zeros(size(nightowls,1),1);
for n = 1:size(nightowls,1)
    ncount(n) = size(find(nJ==n),1);
end
nightowls = nightowls(find(ncount>=10));

% Commented out the below queries to avoid streams of output. Uncomment to
% see the restuls

% then look at early measures (12-1:59am) for early birds
%idxe2 = find(hour(datetime(physdata.Date_TimeRecorded))== 0 | hour(datetime(physdata.Date_TimeRecorded))==1);
%idx = intersect(idxs,idxe2);
%idx = intersect(idxm, idx);
%idxe3 = find(ismember(string(physdata.SmartCareID), string(earlybirds)));
%idx = intersect(idx, idxe3);
%fprintf('Early measures (12-1:59am) for early birds (regularly measure 3-4:59am)\n');
%printSmartCareData(sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend'), nrowstoshow);

% then look at late measures (3-4:59am) for nightowls
%idxn2 = find(hour(datetime(physdata.Date_TimeRecorded))== 3 | hour(datetime(physdata.Date_TimeRecorded))==4);
%idx = intersect(idxs,idxn2);
%idx = intersect(idxm, idx);
%idxn3 = find(ismember(string(physdata.SmartCareID), string(nightowls)));
%idx = intersect(idx, idxn3);
%fprintf('Late measures (3-4:59am) for nightowls (regularly measure 12-1:59am)\n');
%printSmartCareData(sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend'), nrowstoshow);

% then look at early measures (12-1:59am) for neither earlybirds or nightowls%
%both = [earlybirds;nightowls];
%idxe2 = find(hour(datetime(physdata.Date_TimeRecorded))== 0 | hour(datetime(physdata.Date_TimeRecorded))==1);
%idx = intersect(idxs,idxe2);
%idx = intersect(idxm, idx);
%idxe3 = find(~ismember(string(physdata.SmartCareID), string(both)));
%idx = intersect(idx, idxe3);
%fprintf('Early measures (12-1:59am) for neither earlybirds or nightowls\n');
%printSmartCareData(sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend'), nrowstoshow);

% then look at late measures (3-4:59am) for neither earlybirds or nightowls
%both = [earlybirds;nightowls];
%idxe2 = find(hour(datetime(physdata.Date_TimeRecorded))== 3 | hour(datetime(physdata.Date_TimeRecorded))==4);
%idx = intersect(idxs,idxe2);
%idx = intersect(idxm, idx);
%idxe3 = find(~ismember(string(physdata.SmartCareID), string(both)));
%idx = intersect(idx, idxe3);
%fprintf('Late measures (3-4:59am) for neither earlybirds or nightowls \n');
%printSmartCareData(sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend'), nrowstoshow);

% then look at 2-2:59am) for early birds
%idxe2 = find(hour(datetime(physdata.Date_TimeRecorded))== 2 | hour(datetime(physdata.Date_TimeRecorded))== 2);
%idx = intersect(idxs,idxe2);
%idx = intersect(idxm, idx);
%idxe3 = find(ismember(string(physdata.SmartCareID), string(earlybirds)));
%idx = intersect(idx, idxe3);
%fprintf('2-2:59am measures for early birds (regularly measure 3-4:59am)\n');
%printSmartCareData(sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend'), nrowstoshow);

% then look at 2-2:59am for nightowls
%idxn2 = find(hour(datetime(physdata.Date_TimeRecorded))== 2 | hour(datetime(physdata.Date_TimeRecorded))==2);
%idx = intersect(idxs,idxn2);
%idx = intersect(idxm, idx);
%idxn3 = find(ismember(string(physdata.SmartCareID), string(nightowls)));
%idx = intersect(idx, idxn3);
%fprintf('2-2:59am measures for nightowls (regularly measure 12-1:59am)\n');
%printSmartCareData(sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend'), nrowstoshow);

% then look at 2-2:59am for neither earlybirds or nightowls
%both = [earlybirds;nightowls];
%idxe2 = find(hour(datetime(physdata.Date_TimeRecorded))== 2 | hour(datetime(physdata.Date_TimeRecorded))==2);
%idx = intersect(idxs,idxe2);
%idx = intersect(idxm, idx);
%idxe3 = find(~ismember(string(physdata.SmartCareID), string(both)));
%idx = intersect(idx, idxe3);
%fprintf('2-2:59am measures for neither earlybirds or nightowls \n');
%printSmartCareData(sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend'), nrowstoshow);
%toc
%fprintf('\n');

% from the above, for non-activity measurements, the only candidates to
% shift the date for are those taken between 00:00-00:59am. Do further
% anaylsis on these

% first get all pairs of SmartCareID and DateNum for measurements 00:00-00:59am
% (ex-activity measurements)

idxe2 = find(hour(datetime(physdata.Date_TimeRecorded))== 0);
idx = intersect(idxs,idxe2);
idx = intersect(idxm, idx);
%idxe3 = find(ismember(string(physdata.SmartCareID), string(earlybirds)));
%idx = intersect(idx, idxe3);
fprintf('%d measures taken between 00:00-00:59am\n', size(idx,1));
nrowstoshow = 1000;
printSmartCareData(sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend'), nrowstoshow);

postmidnightmeasures = unique(physdata(idx,{'SmartCareID','DateNum'}));

nrowstoshow = 50;
daterange = 1;
includeactivity = false;
for i = 1:size(postmidnightmeasures,1)
    scid = postmidnightmeasures.SmartCareID(i);
    datenum = postmidnightmeasures.DateNum(i);
    printSmartCareData(sortrows(getMeasuresForPatientAndDateRange(physdata, scid, datenum, daterange, includeactivity), {'SmartCareID','Date_TimeRecorded','RecordingType'}, 'ascend'), nrowstoshow);
end

% ====> for each, then get +/-1 day of readings (ex-Activity) and ascertain
% ====> whether should be for prior day or not

fprintf('Analysing rows of interest from above queries\n');

%earlyrows = [ 130,14 ; 137,14  ; 140,49  ; 171,489 ; 195,397 ];
earlyrows = [  63,258 ;  79,88  ; 93,186  ; 113,149 ; 153,382 ; 196,353];
laterows =  [ 45,173 ; 127,171 ; 128,228 ];
twoamrows = [ 56,182 ; 139,55  ; 127,206 ; 47,123  ; 59,191  ; 121,467 ];
relrows = [];

fprintf('Further analysis of 00:00-00:59 measures for non-nightowls\n\n');

%for a = 1:size(earlyrows,1)
%    relrows = getMeasuresForPatientAndDateRange(physdata, earlyrows(a,1), earlyrows(a,2), daterange);
%    printSmartCareData(sortrows(relrows, {'SmartCareID','Date_TimeRecorded','RecordingType'}, 'ascend'), nrowstoshow);
%end

%fprintf('Early measures\n');
%printSmartCareData(sortrows(relrows, {'SmartCareID','Date_TimeRecorded','RecordingType'}, 'ascend'), nrowstoshow);
%relrows = [];

%for a = 1:size(laterows,1)
%    relrows = [relrows;getMeasuresForPatientAndDateRange(physdata, laterows(a,1), laterows(a,2), daterange)];
%end
%fprintf('Late measures\n');
%printSmartCareData(sortrows(relrows, {'SmartCareID','Date_TimeRecorded','RecordingType'}, 'ascend'), nrowstoshow);
%relrows = [];

%for a = 1:size(twoamrows,1)
%    relrows = [relrows;getMeasuresForPatientAndDateRange(physdata, twoamrows(a,1), twoamrows(a,2), daterange)];
%end
%fprintf('2-2:59am measures\n');
%printSmartCareData(sortrows(relrows, {'SmartCareID','Date_TimeRecorded','RecordingType'}, 'ascend'), nrowstoshow);


end

