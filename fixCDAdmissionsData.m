function [cdAdmissionsOut] = fixCDAdmissionsData(cdAdmissions)

% fixAdmissionsData - fix data anomalies in Clinical Admissions data

tic
fprintf('Fixing Admissions data anomalies\n');
fprintf('--------------------------------\n');

% fix NULL StopDate's
idx1 = find(ismember(cdAdmissions.Discharge,{'NULL'}));
idx2 = find(cdAdmissions.ID == 241);
idx = intersect(idx1,idx2);
cdAdmissions.Discharge(idx) = {'11-Sep-2016'};
updates = size(idx,1);
idx1 = find(ismember(cdAdmissions.Discharge,{'0215-12-09'}));
idx2 = find(cdAdmissions.ID == 32);
idx = intersect(idx1,idx2);
cdAdmissions.Discharge(idx) = {'09-Dec-2015'};
updates = updates + size(idx,1);
fprintf('Fixing %2d NULL or mis-typed Discharge dates\n', updates);

% now can convert StopDate to a datetime format
cdAdmissions.Discharge = datetime(cdAdmissions.Discharge);

% fix illogical datas
idx1 = find(cdAdmissions.ID == 35);
idx2 = find(cdAdmissions.HospitalAdmissionID == 66);
idx = intersect(idx1,idx2);
updates = size(idx,1);
cdAdmissions.Admitted(idx) = datetime('10-Mar-2016');

idx1 = find(cdAdmissions.ID == 72);
idx2 = find(cdAdmissions.HospitalAdmissionID == 124);
idx = intersect(idx1,idx2);
updates = updates + size(idx,1);
cdAdmissions.Admitted(idx) = datetime('27-Jul-2016');
fprintf('Fixed %2d illogical Admitted and Discharge dates\n', updates);

% check for any remaining date anomalies (expect to see only those for
% extended treatments
idx = find((datenum(cdAdmissions.Discharge) - datenum(cdAdmissions.Admitted) < 1) | (datenum(cdAdmissions.Discharge) - datenum(cdAdmissions.Admitted) > 30));
fprintf('There are %d remaining short/illogical (< 1 day) or long (> 30 days) duration admissionts\n', size(idx,1));
%cdAdmissions(idx,:)

% note pending followups from Emem on two items
% 1) patient 143 had a same-day discharge on 20-Jun-2016
% 2) patient 59 had two hospital admissions but no IV treatments listed for
% either time period

cdAdmissionsOut = cdAdmissions;

toc
fprintf('\n');

end

