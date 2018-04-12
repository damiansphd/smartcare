function [physdataout] = analyseOvernightMeasures(physdata, smartcareID, doupdates, detaillog)

% analyseOvernightMeasures - analyses measures recorded between 00:00 and
% 03:59 to ascertain whether to adjust measurement day to prior day

% first start with non-activity measures

fprintf('Analysing overnight measures (non-Activity)\n');
fprintf('-------------------------------------------\n');

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
fprintf('Found %d earlybirds - regularly measure between 03:00-04:59am\n', size(earlybirds,1));

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
fprintf('Found %d nightowls - regularly measure between 00:00-01:59am\n', size(nightowls,1));
toc
fprintf('\n');

% Commented out the below queries to avoid streams of output. Uncomment to
% see the restuls

%nrowstoshow = 100;

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
fprintf('%d non-activity measures taken between 00:00-00:59am\n', size(idx,1));
if detaillog
    nrowstoshow = 500;
    printSmartCareData(sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend'), nrowstoshow);
end

tic
if detaillog
    fprintf('Further analyse measures taken between 00:00-00:59\n');
    fprintf('\n');
end
midnightto1ammeasures = unique(physdata(idx,{'SmartCareID','DateNum'}));
proposedupdate = zeros(size(midnightto1ammeasures,1),1);
nupdates = 0;
if detaillog
    fprintf('           :        :   Prior Day   :   Prior Day   :  Current Day  :  Current Day  :  Proposed\n');
    fprintf('  Patient  :  Date  :  02:00-22:59  :  23:00-23:59  :  00:00-00:59  :  02:00-23:59  :   Update \n');
    fprintf('  _______  :  ____  :  ___________  :  ___________  :  ___________  :  ___________  :  ________\n');
end

for i = 1:size(midnightto1ammeasures,1)
    scid = midnightto1ammeasures.SmartCareID(i);
    datenum = midnightto1ammeasures.DateNum(i);
    idx1 = find(physdata.SmartCareID == scid);
    cidx2 = find(physdata.DateNum == datenum & hour(datetime(physdata.Date_TimeRecorded)) == 0);
    cidx = intersect(idx1,cidx2);
    cidx = intersect(cidx,idxm);
    sidx2 = find(physdata.DateNum == datenum & hour(datetime(physdata.Date_TimeRecorded)) >= 2);
    sidx = intersect(idx1,sidx2);
    sidx = intersect(sidx,idxm);
    p1idx2 = find(physdata.DateNum == (datenum-1) & hour(datetime(physdata.Date_TimeRecorded)) >=2 & hour(datetime(physdata.Date_TimeRecorded)) < 23);
    p1idx = intersect(idx1,p1idx2);
    p1idx = intersect(p1idx,idxm);
    p2idx2 = find(physdata.DateNum == (datenum-1) & hour(datetime(physdata.Date_TimeRecorded)) == 23);
    p2idx = intersect(idx1,p2idx2);
    p2idx = intersect(p2idx,idxm);
    
    % update to prior day if no readings for prior day (before 23:00) and
    % either readings on prior day after 23:00 or readings later the same
    % day
    if (size(p1idx,1)==0 & (size(p2idx,1) >=1 | size(sidx,1) >=1))
        proposedupdate(i) = 1;
        if doupdates
            physdata.DateNum(cidx) = physdata.DateNum(cidx) - 1;
            nupdates = nupdates + size(cidx,1);
        end
    end
    if detaillog   
        fprintf('    %3d        %3d         %3d             %3d             %3d             %3d             %1d\n', scid, datenum, size(p1idx,1), size(p2idx,1), size(cidx,1), size(sidx,1), proposedupdate(i));
    end
end
if doupdates
    fprintf('\n');
    fprintf('Updated a total of %3d overnight non-activity measures to the prior day\n', nupdates);
    fprintf('\n');
end
toc
fprintf('\n');

% now look at activity measures

fprintf('Analysing overnight measures (Activity)\n');
fprintf('-------------------------------------------\n');

idxa = find(ismember(physdata.RecordingType, 'ActivityRecording'));

idxa2 = find(hour(datetime(physdata.Date_TimeRecorded)) >= 3 & hour(datetime(physdata.Date_TimeRecorded)) <= 5);
idx = intersect(idxa, idxa2);
idx = intersect(idxs,idx);

fprintf('%d activity measures taken between 03:00-05:59am\n', size(idx,1));
if detaillog
    nrowstoshow = 200;
    printSmartCareData(sortrows(physdata(idx,:),{'SmartCareID', 'Date_TimeRecorded'}, 'ascend'), nrowstoshow);
end

tic
if detaillog
    fprintf('Further analyse measures taken between 00:00-05:59\n');
    fprintf('\n');
end
overnightactivitymeasures = unique(physdata(idx,{'SmartCareID','DateNum'}));
proposedupdateact = zeros(size(overnightactivitymeasures,1),1);

if detaillog
    fprintf('           :        :   Activity    :   Activity    :   Activity    :   Activity    :  NonActivity\n');
    fprintf('           :        :   Prior Day   :  Prior Curr   :  Current Day  :  Current Day  :  Prior Curr \n');
    fprintf('  Patient  :  Date  :  02:00-22:59  :  23:00-02:59  :  03:00-05:59  :  06:00-23:59  :  23:00-05:59\n');
    fprintf('  _______  :  ____  :  ___________  :  ___________  :  ___________  :  ___________  :  ___________\n');
end

for i = 1:size(overnightactivitymeasures,1)
    scid = overnightactivitymeasures.SmartCareID(i);
    datenum = overnightactivitymeasures.DateNum(i);
    idx1 = find(physdata.SmartCareID == scid);
    cidx2 = find(physdata.DateNum == datenum & hour(datetime(physdata.Date_TimeRecorded)) >= 3 & hour(datetime(physdata.Date_TimeRecorded)) <= 5);
    cidx = intersect(idx1,cidx2);
    cidx = intersect(cidx,idxa);
    sidx2 = find(physdata.DateNum == datenum & hour(datetime(physdata.Date_TimeRecorded)) >= 6);
    sidx = intersect(idx1,sidx2);
    sidx = intersect(sidx,idxa);
    p1idx2 = find(physdata.DateNum == (datenum-1) & hour(datetime(physdata.Date_TimeRecorded)) >=2 & hour(datetime(physdata.Date_TimeRecorded)) < 23);
    p1idx = intersect(idx1,p1idx2);
    p1idx = intersect(p1idx,idxa);
    p2idx2 = find((physdata.DateNum == (datenum-1) & hour(datetime(physdata.Date_TimeRecorded)) == 23) | (physdata.DateNum == datenum & hour(datetime(physdata.Date_TimeRecorded)) <= 2));
    p2idx = intersect(idx1,p2idx2);
    p2idx = intersect(p2idx,idxa);
    nidx2 = find((physdata.DateNum == (datenum-1) & hour(datetime(physdata.Date_TimeRecorded)) == 23) | (physdata.DateNum == datenum & hour(datetime(physdata.Date_TimeRecorded)) <= 5));
    nidx = intersect(idx1,nidx2);
    nidx = intersect(nidx,idxm);
    
    if detaillog
        %fprintf('    %3d        %3d         %3d             %3d             %3d             %3d             %3d            %1d\n', ...
        %    scid, datenum, size(p1idx,1), size(p2idx,1), size(cidx,1), size(sidx,1), size(nidx,1), proposedupdateact(i));
        fprintf('    %3d        %3d         %3d             %3d             %3d             %3d             %3d\n', ...
            scid, datenum, size(p1idx,1), size(p2idx,1), size(cidx,1), size(sidx,1), size(nidx,1));
    end
end
toc
fprintf('\n');

if doupdates
    tic
    fprintf('Updating Date offset for Activity measures 00:00-05:59\n');
    fprintf('------------------------------------------------------\n');
    idx2 = find(hour(datetime(physdata.Date_TimeRecorded))<6);
    idx = intersect(idxa,idx2);
    fprintf('Updating %4d date offsets to prior day for activity measures between 00:00 and 05:59\n', size(idx,1));
    physdata.DateNum(idx) = physdata.DateNum(idx) - 1;
    toc
    fprintf('\n'); 
end

physdataout = physdata;
end

