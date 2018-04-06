function [cdAntibioticsOut] = fixCDAntibioticsData(cdAntibiotics)

% fixAntibioticData - fix data anomalies in Clinical Antibiotics data

tic
fprintf('Fixing Antibiotics data anomalies\n');
fprintf('---------------------------------\n');
% remove duplicate rows
idx1 = find(cdAntibiotics.ID == 76);
idx2 = find(ismember(cdAntibiotics.StopDate,{'NULL', '02-Feb-2017'}));
idx = intersect(idx1,idx2);
updates = size(idx,1);
fprintf('Removing %2d duplicate rows\n', updates);
cdAntibiotics(idx,:) = [];

% fix NULL StopDate's
idx1 = find(ismember(cdAntibiotics.StopDate,{'NULL'}));
idx2 = find(cdAntibiotics.ID == 74);
idx = intersect(idx1,idx2);
cdAntibiotics.StopDate(idx) = {'12-Jan-2017'};
updates = size(idx,1);
idx2 = find(cdAntibiotics.ID == 241);
idx = intersect(idx1,idx2);
cdAntibiotics.StopDate(idx) = {'11-Sep-2016'};
updates = updates + size(idx,1);
fprintf('Fixing %2d NULL StopDates\n', updates);

% now can convert StopDate to a datetime format
cdAntibiotics.StopDate = datetime(cdAntibiotics.StopDate);

% harmonise 'Intravenous' and 'Iv' to be 'IV'
idx = find(ismember(cdAntibiotics.Route, {'Intravenous', 'Iv'}));
cdAntibiotics.Route(idx) = {'IV'};
updates = size(idx,1);
% harmonise 'PO' to be 'Oral'
idx = find(ismember(cdAntibiotics.Route, {'PO'}));
cdAntibiotics.Route(idx) = {'Oral'};
updates = updates + size(idx,1);
% fix NULL values in Route, where HomeIV_s_ has the value needed
idx1 = find(ismember(cdAntibiotics.Route, {'NULL'}));
idx2 = find(ismember(cdAntibiotics.HomeIV_s_, {'IV','Yes'}));
idx = intersect(idx1,idx2);
cdAntibiotics.Route(idx) = {'IV'};
updates = updates + size(idx,1);
fprintf('Harmonised %3d values for Route\n', updates);

% check this has harmonised/fixed all entries for Route
% unique(cdAntibiotics.Route)

% fix illogical datas
idx1 = find(cdAntibiotics.ID == 207);
idx2 = find(cdAntibiotics.AntibioticID >= 468 & cdAntibiotics.AntibioticID <= 470);
idx = intersect(idx1,idx2);
updates = size(idx,1);
cdAntibiotics.StopDate(idx) = datetime('09-Jun-2016');

idx1 = find(cdAntibiotics.ID == 32);
idx2 = find(cdAntibiotics.AntibioticID == 77 | cdAntibiotics.AntibioticID == 78);
idx = intersect(idx1,idx2);
updates = updates + size(idx,1);
cdAntibiotics.StartDate(idx) = datetime('29-Dec-2015');

idx1 = find(cdAntibiotics.ID == 68);
idx2 = find(cdAntibiotics.AntibioticID == 300);
idx = intersect(idx1,idx2);
updates = updates + size(idx,1);
cdAntibiotics.StopDate(idx) = datetime('28-Jun-2016');

idx1 = find(cdAntibiotics.ID == 37);
idx2 = find(cdAntibiotics.AntibioticID == 111 | cdAntibiotics.AntibioticID == 112);
idx = intersect(idx1,idx2);
updates = updates + size(idx,1);
cdAntibiotics.StopDate(idx) = datetime('18-Jul-2016');

idx1 = find(cdAntibiotics.ID == 113);
idx2 = find(cdAntibiotics.AntibioticID == 171 | cdAntibiotics.AntibioticID == 172);
idx = intersect(idx1,idx2);
updates = updates + size(idx,1);
cdAntibiotics.StartDate(idx) = datetime('18-Dec-2015');

idx1 = find(cdAntibiotics.ID == 113);
idx2 = find(cdAntibiotics.AntibioticID == 173);
idx = intersect(idx1,idx2);
updates = updates + size(idx,1);
cdAntibiotics.StartDate(idx) = datetime('21-Dec-2015');

idx1 = find(cdAntibiotics.ID == 202);
idx2 = find(cdAntibiotics.AntibioticID == 384 | cdAntibiotics.AntibioticID == 385);
idx = intersect(idx1,idx2);
updates = updates + size(idx,1);
cdAntibiotics.StartDate(idx) = datetime('19-Feb-2017');

idx1 = find(cdAntibiotics.ID == 204);
idx2 = find(cdAntibiotics.AntibioticID == 373);
idx = intersect(idx1,idx2);
updates = updates + size(idx,1);
cdAntibiotics.StopDate(idx) = datetime('28-Oct-2016');

fprintf('Fixed %2d illogical Start and Stop Dates\n', updates);

% check for any remaining date anomalies (expect to see only those for
% extended treatments
idx = find((datenum(cdAntibiotics.StopDate) - datenum(cdAntibiotics.StartDate) < 1) | (datenum(cdAntibiotics.StopDate) - datenum(cdAntibiotics.StartDate) > 30));
fprintf('There are %d remaining legitimate long term (> 30 days) Antibiotic treatments\n', size(idx,1));
%cdAntibiotics(idx,:)

cdAntibioticsOut = cdAntibiotics;

toc
fprintf('\n');

end

