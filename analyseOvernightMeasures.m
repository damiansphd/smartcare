function [earlybirds, nightowls] = analyseOvernightMeasures(physdata, smartcareID)

% analyseOvernightMeasures - analyses measures recorded between 00:00 and
% 03:59 to ascertain whether to adjust measurement day to prior day

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

% then look at early measures (12-1:59am) for early birds
idxe2 = find(hour(datetime(physdata.Date_TimeRecorded))== 0 | hour(datetime(physdata.Date_TimeRecorded))==1);
idx = intersect(idxs,idxe2);
idx = intersect(idxm, idx);
idxe3 = find(ismember(string(physdata.SmartCareID), string(earlybirds)));
idx = intersect(idx, idxe3);
fprintf('Early measures (12-1:59am) for early birds (regularly measure 3-4:59am)\n');
sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend')

% then look at late measures (3-4:59am) for nightowls
idxn2 = find(hour(datetime(physdata.Date_TimeRecorded))== 3 | hour(datetime(physdata.Date_TimeRecorded))==4);
idx = intersect(idxs,idxn2);
idx = intersect(idxm, idx);
idxn3 = find(ismember(string(physdata.SmartCareID), string(nightowls)));
idx = intersect(idx, idxn3);
fprintf('Late measures (3-4:59am) for nightowls (regularly measure 12-1:59am)\n');
sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend')

% then look at early measures (12-1:59am) for neither earlybirds or nightowls
both = [earlybirds;nightowls];
idxe2 = find(hour(datetime(physdata.Date_TimeRecorded))== 0 | hour(datetime(physdata.Date_TimeRecorded))==1);
idx = intersect(idxs,idxe2);
idx = intersect(idxm, idx);
idxe3 = find(~ismember(string(physdata.SmartCareID), string(both)));
idx = intersect(idx, idxe3);
fprintf('Early measures (12-1:59am) for neither earlybirds or nightowls\n');
sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend')

% then look at late measures (3-4:59am) for neither earlybirds or nightowls
both = [earlybirds;nightowls];
idxe2 = find(hour(datetime(physdata.Date_TimeRecorded))== 3 | hour(datetime(physdata.Date_TimeRecorded))==4);
idx = intersect(idxs,idxe2);
idx = intersect(idxm, idx);
idxe3 = find(~ismember(string(physdata.SmartCareID), string(both)));
idx = intersect(idx, idxe3);
fprintf('Late measures (3-4:59am) for neither earlybirds or nightowls \n');
sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend')

% then look at 2-2:59am) for early birds
idxe2 = find(hour(datetime(physdata.Date_TimeRecorded))== 2 | hour(datetime(physdata.Date_TimeRecorded))== 2);
idx = intersect(idxs,idxe2);
idx = intersect(idxm, idx);
idxe3 = find(ismember(string(physdata.SmartCareID), string(earlybirds)));
idx = intersect(idx, idxe3);
fprintf('2-2:59am measures for early birds (regularly measure 3-4:59am)\n');
sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend')

% then look at 2-2:59am for nightowls
idxn2 = find(hour(datetime(physdata.Date_TimeRecorded))== 2 | hour(datetime(physdata.Date_TimeRecorded))==2);
idx = intersect(idxs,idxn2);
idx = intersect(idxm, idx);
idxn3 = find(ismember(string(physdata.SmartCareID), string(nightowls)));
idx = intersect(idx, idxn3);
fprintf('2-2:59am measures for nightowls (regularly measure 12-1:59am)\n');
sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend')

% then look at 2-2:59am for neither earlybirds or nightowls
both = [earlybirds;nightowls];
idxe2 = find(hour(datetime(physdata.Date_TimeRecorded))== 2 | hour(datetime(physdata.Date_TimeRecorded))==2);
idx = intersect(idxs,idxe2);
idx = intersect(idxm, idx);
idxe3 = find(~ismember(string(physdata.SmartCareID), string(both)));
idx = intersect(idx, idxe3);
fprintf('2-2:59am measures for neither earlybirds or nightowls \n');
sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend')

toc
fprintf('\n');

fprintf('Analysing rows of interest from above queries\n');

earlyrows = [ 130,14 ; 137,14  ; 140,49  ; 171,489 ; 195,397 ];
laterows =  [ 45,173 ; 127,171 ; 128,228 ];
twoamrows = [ 56,182 ; 139,55  ; 127,206 ; 47,123  ; 59,191  ; 121,467 ];
relrows = [];

for a = 1:size(earlyrows,1)
    relrows = [relrows;getMeasuresForPatientAndDateRange(physdata, earlyrows(a,1), earlyrows(a,2), 5)];
end
fprintf('Early measures\n');
sortrows(relrows, {'SmartCareID','Date_TimeRecorded','RecordingType'}, 'ascend')
relrows = [];

for a = 1:size(laterows,1)
    relrows = [relrows;getMeasuresForPatientAndDateRange(physdata, laterows(a,1), laterows(a,2), 5)];
end
fprintf('Late measures\n');
sortrows(relrows, {'SmartCareID','Date_TimeRecorded','RecordingType'}, 'ascend')
relrows = [];

for a = 1:size(twoamrows,1)
    relrows = [relrows;getMeasuresForPatientAndDateRange(physdata, twoamrows(a,1), twoamrows(a,2), 5)];
end
fprintf('2-2:59am measures\n');
sortrows(relrows, {'SmartCareID','Date_TimeRecorded','RecordingType'}, 'ascend')


end

