function [physdataout] = analyseAndHandleDateOutliers(physdata, doupdates)

% analyseAndHandleDateOutliers - function to do the following :-
%
% 1) visualise heatmaps of patients and measures - all patients, 
% 2) removes outlier measures (long gap before active study period or
%    sporadic measures after active study period
% 3) deletes rows for patients with < 40 days duration or < 35 days of
%    multiple measurement days
% 4) recreate heatmaps at various points and observe results

tic

fprintf('Analysing and Handling Date Outliers in the Measurement data\n');
fprintf('------------------------------------------------------------\n');

% ensure physdata is sorted correctly
physdata = sortrows(physdata, {'SmartCareID', 'DateNum', 'RecordingType'}, 'ascend');

% create colormap
temp = hsv;
colors(1,:)  = [0 0 0];     % black for no measures
colors(2,:)  = temp(4,:);
colors(3,:)  = temp(6,:);
colors(4,:)  = temp(8,:);
colors(5,:)  = temp(10,:);
colors(6,:)  = temp(12,:);
colors(7,:)  = temp(14,:);
colors(8,:)  = temp(16,:);
colors(9,:)  = temp(18,:);

filenameappend = 'PreDateOutlierHandling';
fullfilename = strcat('HeatmapAllPatients', filenameappend, '.png');

% create heatmap for all patients and measures
fprintf('Creating heatmap for all patients\n');
f1 = createHeatmapOfPatientsAndMeasures(physdata(:,{'SmartCareID','ScaledDateNum'}), colors, 'Heatmap of Patient Measures', 1, 1, 'a3');
saveas(f1,fullfilename);

toc
fprintf('\n');

tic
% handle outlier measurements
fprintf('Handling outlier date measurements across all patients\n');
pdcountmtable = varfun(@max, physdata(:, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});
fdeltable = physdata(1:1,{'SmartCareID','ScaledDateNum'});
ldeltable = physdata(1:1,{'SmartCareID','ScaledDateNum'});
rowtoadd = fdeltable;
rowtoadd.SmartCareID = 0;
rowtoadd.ScaledDateNum = 0;
fdeltable = [];
ldeltable = [];

allpatients = unique(physdata.SmartCareID);
for i = 1:size(allpatients,1)
    scid = allpatients(i);
    idx = find(pdcountmtable.SmartCareID == scid);
    outlier = true;
    a = 1;
    while (outlier == true & (a+8) < size(idx,1))
        firstdate = pdcountmtable.ScaledDateNum(idx(a));
        firstcount = pdcountmtable.GroupCount(idx(a));
        next5date = pdcountmtable.ScaledDateNum(idx(a+8));
        if (next5date - firstdate > 12 | firstcount == 1)
            rowtoadd.SmartCareID = scid;
            rowtoadd.ScaledDateNum = firstdate;
            fdeltable = [fdeltable;rowtoadd];
            a = a+1;
        else
            outlier = false;
        end
    end
    outlier = true;
    a = size(idx,1);
    while (outlier == true & a-10 > 0)
        lastdate = pdcountmtable.ScaledDateNum(idx(a));
        lastcount = pdcountmtable.GroupCount(idx(a));
        prev10date = pdcountmtable.ScaledDateNum(idx(a-10));
        if (lastdate - prev10date > 16 | lastcount == 1)
            rowtoadd.SmartCareID = scid;
            rowtoadd.ScaledDateNum = lastdate;
            ldeltable = [ldeltable;rowtoadd];
            a = a-1;
        else
            outlier = false;
        end
    end        
end
 
if doupdates
    fidx = [];
    lidx = [];
    for i = 1:size(fdeltable,1)
        idx = find(physdata.SmartCareID == fdeltable.SmartCareID(i) & physdata.ScaledDateNum == fdeltable.ScaledDateNum(i));
        fidx = [fidx;idx];
    end
    for i = 1:size(ldeltable,1)
        idx = find(physdata.SmartCareID == ldeltable.SmartCareID(i) & physdata.ScaledDateNum == ldeltable.ScaledDateNum(i));
        lidx = [lidx;idx];
    end
    fprintf('Removing %4d outlier first measures for %2d patients\n', size(fidx,1), size(unique(fdeltable.SmartCareID),1));
    fprintf('Removing %4d outlier last  measures for %2d patients\n', size(lidx,1), size(unique(ldeltable.SmartCareID),1));
    idx = [fidx;lidx];
    physdata(idx,:) = [];
    fprintf('SmartCare data now has %d rows\n', size(physdata,1));
end
toc
fprintf('\n');

tic
% recalc ScaledDateNum with the days from first measurement (by patient)
physdata = scaleDaysByPatient(physdata, doupdates);

filenameappend = 'PostOutlierDateHandling';
fullfilename = strcat('HeatmapAllPatients', filenameappend, '.png');
shortfilename = strcat('HeatmapShortDurationPatients', filenameappend, '.png');

% re-create heatmap for all patients and measures
fprintf('Re-creating heatmap for all patients\n');
f2 = createHeatmapOfPatientsAndMeasures(physdata(:,{'SmartCareID','ScaledDateNum'}), colors, 'Heatmap of Patient Measures - Post Date Outliers', 1, 1, 'a3');
saveas(f2,fullfilename);

toc
fprintf('\n');

tic
% handling short duration patients (< 40 day duration of measures
% or <= 35 total days of more than 1 measurement)
fprintf('Handling short duration patients (< 40 day duration of measures or <= 35 total days of more than 1 measurement)\n');

% create heatmap for short duration patients
fprintf('Creating heatmap for short duration patients\n');
pmaxdtable = varfun(@max, physdata(:,{'SmartCareID', 'ScaledDateNum'}), 'GroupingVariables', {'SmartCareID'});
sdidx = find(pmaxdtable.max_ScaledDateNum <40);
shortdurationpatients = unique(pmaxdtable.SmartCareID(sdidx));
sdpidx = find(ismember(physdata.SmartCareID, shortdurationpatients));
pdcountmtable = varfun(@max, physdata(:, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});
pcountdtable = varfun(@max, pdcountmtable(:, {'SmartCareID'}), 'GroupingVariables', {'SmartCareID'});
pcountdtable2m = varfun(@max, pdcountmtable(pdcountmtable.GroupCount>1, {'SmartCareID'}), 'GroupingVariables', {'SmartCareID'});
pcountdtable2m.Properties.VariableNames{'GroupCount'} = 'MultipleMeasuresDayCount';
pcountdtable = innerjoin(pcountdtable,pcountdtable2m);

fewdayspatients = pcountdtable.SmartCareID(find(pcountdtable.MultipleMeasuresDayCount <= 35));
sdpidx = find(ismember(physdata.SmartCareID, unique([shortdurationpatients ; fewdayspatients])));
f3 = createHeatmapOfPatientsAndMeasures(physdata(sdpidx,{'SmartCareID','ScaledDateNum'}), colors, 'Heatmap of Short Duration Patients', 1.0, 0.5, 'a4');
saveas(f3,shortfilename);

if doupdates
    % remove all measures for patients with < 40 days duration or <= 35 total days of more than 1 measurement
    fprintf('Removing %4d measures for %2d patients with < 40 days duration or <= 35 total days of more than 1 measurement\n', ...
        size(sdpidx,1), size(unique([shortdurationpatients ; fewdayspatients]),1));
    physdata(sdpidx,:) = [];
    fprintf('SmartCare data now has %d rows\n', size(physdata,1));
end
toc
fprintf('\n');

tic
filenameappend = 'PostShortDurationHandling';
fullfilename = strcat('HeatmapAllPatients', filenameappend, '.png');

% re-create heatmap for all patients and measures
fprintf('Re-creating heatmap for all patients\n');
f4 = createHeatmapOfPatientsAndMeasures(physdata(:,{'SmartCareID','ScaledDateNum'}), colors, 'Heatmap of Patient Measures Post Short Duration', 1, 1, 'a3');
saveas(f4,fullfilename);

toc
fprintf('\n');

tic
% add handling for 'sparse' patients here
fprintf('Handline patients with sparse measurements\n');
pdcountmtable = varfun(@max, physdata(:, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});
pcountdtable = varfun(@max, pdcountmtable(:, {'SmartCareID'}), 'GroupingVariables', {'SmartCareID'});
pcountdtable.Properties.VariableNames{'GroupCount'} = 'DayCount';
pmaxdtable = varfun(@max, physdata(:,{'SmartCareID', 'ScaledDateNum'}), 'GroupingVariables', {'SmartCareID'});
pmaxdtable.Properties.VariableNames{'GroupCount'} = 'MeasureCount';
pdensitymtable = innerjoin(pmaxdtable,pcountdtable);

pcountdtable2m = varfun(@max, pdcountmtable(pdcountmtable.GroupCount>1, {'SmartCareID'}), 'GroupingVariables', {'SmartCareID'});
pcountdtable2m.Properties.VariableNames{'GroupCount'} = 'MultipleMeasuresDayCount';
pdensitymtable = innerjoin(pdensitymtable,pcountdtable2m);

pdensitymtable.Density = pdensitymtable.DayCount./pdensitymtable.max_ScaledDateNum;
pdensitymtable.MultipleMeasuresDensity = pdensitymtable.MultipleMeasuresDayCount./pdensitymtable.max_ScaledDateNum;

lowdensityidx = find(pdensitymtable.MultipleMeasuresDensity < 0.5);
lowdensitypatients = pdensitymtable.SmartCareID(lowdensityidx);
delidx = find(ismember(physdata.SmartCareID, lowdensitypatients));

if doupdates
    % remove all measures for patients with low density of multiple measurement days
    fprintf('Removing %4d measures for %2d patients with low density of multiple measurement days\n', ...
        size(delidx,1), size(lowdensitypatients,1));
    physdata(delidx,:) = [];
    fprintf('SmartCare data now has %d rows\n', size(physdata,1));
end
toc
fprintf('\n');

tic
filenameappend = 'PostSparsePatientHandling';
fullfilename = strcat('HeatmapAllPatients', filenameappend, '.png');

% re-create heatmap for all patients and measures
fprintf('Re-creating heatmap for all patients\n');
f5 = createHeatmapOfPatientsAndMeasures(physdata(:,{'SmartCareID','ScaledDateNum'}), colors, 'Heatmap of Patient Measures - Final', 1, 1, 'a3');
saveas(f5,fullfilename);

toc
fprintf('\n');

physdataout = physdata;

end

