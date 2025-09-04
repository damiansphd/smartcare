% loads BronchEx clinical data from REDCap database
% - loads the clinical data from the REDCap data export for a given date
% - stores this data in a set of matlab tables
% - performs some field level data quality checks
% 
% Inputs:
% ------
% - BE-PatientIDmappingFile-yyyymmdd.xlsx - Mapping of internal ID to REDCap ID
% - BronchEx_DataDictionary_yyyy-mm-dd.csv - REDCap data 
% dictionary (to get dropdown id/label mappings)
% - BE-REDCapFieldMappingFile_yyyymmdd.xlsx - REDCap table and field mapping (maps 
% redcap instrument to matlab tables, and redcap fields to matlab columns
% - BronchEx_DATA_yyyy-mm-dd_hhmm.csv - REDCap data export file 
% (containing the clinical data for all hospitals & patients
%
% Outputs:
% -------
% bronchexclinicaldata.mat with the following variables:
% - beAdmissions          admitted/discharged dates for all hospitalisations
% - beAntibiotics         ab's name, route, homeIV, start/end date
% - beClinicVisits        date, location (e.g. home or clinic)
% - beCRP                 CRP measures (Empty - n/a for BronchEx)
% - beDrugTherapy         CFTR modulators (Empty - n/a for BronchEx)
% - beEndStudy            (Empty - n/a for BronchEx)
% - beHghWght             (Empty - n/a for BronchEx)
% - beMicrobiology        what bacterias in the lungs
% - beOtherVisits         (Empty - n/a for BronchEx)
% - bePatient             patient profile (including mutations, consent 
% status, and last updated date for the clinical data
% - bePFT                 Pulmonary Function Tests
% - beUnplannedContact    (Empty - n/a for BronchEx)
%
% Excel file
% BE-PatientIDmappingFile-yyyymmdd.xlsx - updated mapping of internal ID to 
% REDCap ID to include any new patients since previous ingestion 
%
% Histogram of patient clinical data by month of last update.png - plot

clear; clc; close all;

study = 'BE';

basedir = setBaseDir();
subfolder = sprintf('DataFiles/%s/REDCapData', study);

fprintf('Loading the latest clinical data from REDCap\n');
fprintf('--------------------------------------------\n');
fprintf('\n');

% load latest patient ID mapping file
tic
fprintf('Finding the most recent patient id mapping file\n');
fnamematchstr = '*-PatientIDMappingFile*';
[redcapidmap] = loadREDCapPatientIDMapFile(basedir, subfolder, fnamematchstr);
toc
fprintf('\n');

% load latest REDCap data dictionary file
tic
fprintf('Finding the most recent REDCap data dictionary file\n');
fnamematchstr = '*_DataDictionary*';
[redcapdict] = loadREDCapDictionaryFile(basedir, subfolder, fnamematchstr);
% update hospital dropdown values - n/a for BronchEx
%hosplist = getListOfAceCFHospitals();
%hospdropdown = createAceCFHospDropDownList(hosplist);
%redcapdict.Choices_Calculations_ORSliderLabels(ismember(redcapdict.Variable_FieldName, {'hospital'})) = hospdropdown;

%redcapdict.Choices_Calculations_ORSliderLabels(ismember(redcapdict.Variable_FieldName, {'hospital'})) = {'1, PAP|2, CDF|3, GGC|4, EDB|5, KCL|6, BEL'};
% convert yes/no fields to look like drop downs so we can process more easily
redcapdict.FieldType(ismember(redcapdict.Variable_FieldName, {'consent'}))      = {'dropdown'};
redcapdict.FieldType(ismember(redcapdict.Variable_FieldName, {'dt_hill_crit'})) = {'dropdown'};
redcapdict.Choices_Calculations_ORSliderLabels(ismember(redcapdict.Variable_FieldName, {'consent'}))      = {'0, No|1, Yes'};
redcapdict.Choices_Calculations_ORSliderLabels(ismember(redcapdict.Variable_FieldName, {'dt_hill_crit'})) = {'0, No|1, Yes'};
toc
fprintf('\n');

% load latest REDCap table and field mapping file
tic
fprintf('Finding the most recent table and field mapping file\n');
fnamematchstr = 'BE-REDCapFieldMappingFile*';
[redcaptablemap, redcapfieldmap, recordeventcolmap] = loadacecfREDCapFieldMapFile(basedir, subfolder, fnamematchstr);
toc
fprintf('\n');

% load the latest data export from the REDCap database (covering all
% hospitals)
tic
fprintf('Finding the most recent REDCap data export file\n');
fnamematchstr = 'BronchEx*';
redcapidcol = 'record_id';
[redcapdata, redcapinstrcounts] = loadREDCapDataExportFile(basedir, subfolder, fnamematchstr, redcapdict, redcapidcol);
% update study id columns to be consistent with Breathe
redcapdata.Properties.VariableNames(ismember(redcapdata.Properties.VariableNames, {'study_id'})) = {'study_number'};
redcapdata.Properties.VariableNames(ismember(redcapdata.Properties.VariableNames, {'record_id'})) = {'study_id'};
redcapidcol = 'study_id';
toc
fprintf('\n');

% replace drop down index values with names in the data file
tic
fprintf('Replacing drop down values with names\n');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'biological_sex');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'ethnicity');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'consent');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'mb_name');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'enc_type');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'ue_type');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'dt_name');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'dt_usage');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'dt_category');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'dt_abx_route');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'dt_hill_crit');
toc
fprintf('\n');

% add hospital column to redcapdata for backward compatibility
tic
fprintf('Adding hardcoded hospital column for backward compatibility\n');
[redcapdata] = addBronchExHospitalCol(redcapdata);
toc
fprintf('\n');

redcapdata = sortrows(redcapdata, {'redcap_repeat_instrument', redcapidcol, 'redcap_repeat_instance'}, {'Ascend', 'Ascend', 'Ascend'});

% add a record to the id mapping file for each new patient (assigning a new
% internal id for each)
tic
fprintf('Assigning new study_ids for new patients and adding to the mapping file\n');
[redcapidmap] = addNewPatientsToMappingTable(redcapdata, redcapidmap);
toc
fprintf('\n');

% add internal id, hospital, and study number to all records in the red cap
% data table for convenience
tic
fprintf('Adding internal id, hospital and study number to all records in redcap data table\n');
[redcapdata] = addIDsToREDCapDataTable(redcapdata, redcapidmap, redcapfieldmap);
toc
fprintf('\n');

% load the data from each redcap instrument to the respective matlab table
tic
fprintf('Loading data from REDCap to Matlab\n');
ntables = size(redcaptablemap, 1);
for t = 1:ntables
    rcinstr = redcaptablemap.redcap_instrument{t};
    betable = redcaptablemap.matlab_table{t};
    if sum(ismember(recordeventcolmap.redcap_instrument, {rcinstr})) > 0
        receventfld = recordeventcolmap.record_event_col{ismember(recordeventcolmap.redcap_instrument, {rcinstr})};
    else
        receventfld = '';
    end
    
    fprintf('Loading data from instrument %-24s to table %-18s: ', rcinstr, betable);
    
    % extract data rows for this instrument/table combination
    trcdata = redcapdata(ismember(redcapdata.redcap_repeat_instrument, {rcinstr}), :);
    ntrowsorig = size(trcdata, 1);
    % for BronchEx, temporarily include complete and unverified records,
    % until enough have been set to complete.
    completefld = sprintf('%s_complete', rcinstr);
    %completeidx = table2array(trcdata(:, {completefld})) == 2;
    if size(trcdata, 1) > 0
        completeidx = table2array(trcdata(:, {completefld})) ~= 0;
    else
        completeidx = [];
    end
    trcdata = trcdata(completeidx, :);
    
    if sum(completeidx) ~= size(completeidx, 1)
        warnsuff1 = sprintf('**** %3d incomplete status rows **** ', size(completeidx, 1) - sum(completeidx));
    else
        warnsuff1 = '';
    end
    
    % for ACE-CF, delete the placeholder rows that indicate none of those
    % events have happened.
    if size(trcdata, 1) > 0 && ~isempty(receventfld)
        receventidx = table2array(trcdata(:, {receventfld})) ~= 0;
    else
        receventidx = true(size(trcdata,1), 1);
    end
    trcdata = trcdata(receventidx, :);
    
    if sum(receventidx) ~= size(receventidx, 1)
        warnsuff2 = sprintf('**** %3d no record event rows   ****', size(receventidx, 1) - sum(receventidx));
    else
        warnsuff2 = '';
    end
    
    ntrows = size(trcdata, 1);
    fprintf('Ingested %5d rows of %5d total rows %s%s\n', ntrows, ntrowsorig, warnsuff1, warnsuff2);
   
    tfieldmap = redcapfieldmap(ismember(redcapfieldmap.redcap_instrument, {rcinstr}), :);

    [mltable] = createBronchExSingleClinicalTable(betable, ntrows);
    
    mltable = populateMLTableFromREDCapData(trcdata, mltable, tfieldmap);

    eval(sprintf('%s = mltable;', betable));

end
toc
fprintf('\n');

% filter drug therapies information to just include exacerbation related
% antibiotic treatments
tic
norigrows = size(beAntibiotics, 1);
beAntibiotics = beAntibiotics(ismember(beAntibiotics.DrugType, {'Antibiotics'}) & ismember(beAntibiotics.Reason, {'Exacerbation'}), :);
nfiltrows = size(beAntibiotics, 1);
fprintf('Filtered %d non-exacerbation, non antibiotic related records\n', norigrows - nfiltrows);
toc
fprintf('\n');


% additionally populate the specific derived columns in the relevant tables
tic
fprintf('Populating derived columns\n');
[bePatient, bePFT] = populateBronchExDerivedColsInMLTables(bePatient, bePFT);
toc
fprintf('\n');

% create stub variable for other visits, unplanned contact, height_weight and end of study for backward compatibility
betable = 'beDrugTherapy';
[mltable] = createBronchExSingleClinicalTable(betable, 0);
eval(sprintf('%s = mltable;', betable));

betable = 'beOtherVisits';
[mltable] = createBronchExSingleClinicalTable(betable, 0);
eval(sprintf('%s = mltable;', betable));

betable = 'beUnplannedContact';
[mltable] = createBronchExSingleClinicalTable(betable, 0);
eval(sprintf('%s = mltable;', betable));

betable = 'beCRP';
[mltable] = createBronchExSingleClinicalTable(betable, 0);
eval(sprintf('%s = mltable;', betable));

betable = 'beHghtWght';
[mltable] = createBronchExSingleClinicalTable(betable, 0);
eval(sprintf('%s = mltable;', betable));

betable = 'beEndStudy';
[mltable] = createBronchExSingleClinicalTable(betable, 0);
eval(sprintf('%s = mltable;', betable));

% sort rows
tic
fprintf('Sorting rows in tables\n');
bePatient           = sortrows(bePatient,          {'ID'});
beAdmissions        = sortrows(beAdmissions,       {'ID', 'Admitted'});
beAntibiotics       = sortrows(beAntibiotics,      {'ID', 'StartDate', 'AntibioticName'});
beClinicVisits      = sortrows(beClinicVisits,     {'ID', 'AttendanceDate'});
bePFT               = sortrows(bePFT,              {'ID', 'LungFunctionDate'});
beMicrobiology      = sortrows(beMicrobiology,     {'ID', 'DateMicrobiology'});
toc
fprintf('\n');

% data integrity checks
tic
fprintf('Data Integrity Checks\n');
fprintf('---------------------\n');
% patient data
idx = isnat(bePatient.StudyDate) | isnat(bePatient.DOB);
fprintf('Deleted %d Patients with blank dates\n', sum(idx));
if sum(idx) > 0
    disp(bePatient(idx,{'ID', 'Hospital', 'StudyNumber', 'StudyDate', 'DOB'}));
    bePatient(idx, :) = [];
end
fprintf('\n');

% duplicate partition keys
tmp = groupcounts(bePatient, {'PartitionKey'});
duppartkey = tmp.PartitionKey(tmp.GroupCount > 1);
idx = ismember(bePatient.PartitionKey, duppartkey);
if sum(idx) > 0
    fprintf('***** %d duplicate partition keys detected - please correct in REDCap before continuing (deleting for now) ****\n', sum(idx));
    disp(bePatient(ismember(bePatient.PartitionKey, duppartkey), {'ID', 'Hospital', 'StudyNumber', 'StudyNumber2', 'PartitionKey'}));
    bePatient(idx, :) = [];
end

% invalid partition keys (not 36 characters in length)
idx = strlength(bePatient.PartitionKey)~=36;
fprintf('Deleted %d Patients with invalid partition key\n', sum(idx));
if sum(idx) > 0
    disp(bePatient(idx,{'ID', 'Hospital', 'StudyNumber', 'StudyDate', 'DOB', 'PartitionKey'}));
    bePatient(idx, :) = [];
end
fprintf('\n');

idx = bePatient.Height < 120 | bePatient.Height > 220;
fprintf('Found %d Patients height < 1.2m or > 2.2m\n', sum(idx));
if sum(idx) > 0
    disp(bePatient(idx,{'ID', 'Hospital', 'StudyNumber', 'Height'}));
end
fprintf('\n');

idx = bePatient.Weight < 35 | bePatient.Weight > 120;
fprintf('Found %d Patients weight < 35kg or > 120kg\n', sum(idx));
if sum(idx) > 0
    disp(bePatient(idx,{'ID', 'Hospital', 'StudyNumber', 'Weight'}));
end
fprintf('\n');

idx = abs(bePatient.PredictedFEV1 - bePatient.CalcPredictedFEV1) > 0.3;
fprintf('Found %d Patients with predicted FEV1 inconsistent with that calculated from age, height, gender (> 300ml diff)\n', sum(idx));
if sum(idx) > 0
    disp(bePatient(idx,{'ID', 'Hospital', 'StudyNumber', 'Age', 'PredictedFEV1', 'CalcPredictedFEV1'}));
end
fprintf('\n');

% admission data
idx = isnat(beAdmissions.Admitted) | isnat(beAdmissions.Discharge);
fprintf('Deleted %d Admissions with blank dates\n', sum(idx));
if sum(idx) > 0
    disp(beAdmissions(idx,:));
    beAdmissions(idx, :) = [];
end
fprintf('\n');

idx = beAdmissions.Discharge < beAdmissions.Admitted;
fprintf('Deleted %d Admissions with Discharge before Admission\n', sum(idx));
if sum(idx) > 0
    disp(beAdmissions(idx,:));
    beAdmissions(idx, :) = [];
end
fprintf('\n');

idx = days(beAdmissions.Discharge - beAdmissions.Admitted) > 30;
fprintf('Found %d Admissions > 1 month duration\n', sum(idx));
if sum(idx) > 0
    disp(beAdmissions(idx,:));
end
fprintf('\n');

% antibiotics data
%idx = ismember(beAntibiotics.Reason, {'Prophylactic'});
%fprintf('Deleted %d Antibiotics with reason Prophylactic\n', sum(idx));
%if sum(idx) > 0
%    disp(beAntibiotics(idx,:));
%    beAntibiotics(idx, :) = [];
%end
%fprintf('\n');

idx = isnat(beAntibiotics.StartDate) & isnat(beAntibiotics.StopDate);
fprintf('Deleted %d Antibiotics with both blank dates\n', sum(idx));
if sum(idx) > 0
    disp(beAntibiotics(idx,:));
    beAntibiotics(idx, :) = [];
end
fprintf('\n');

idx = isnat(beAntibiotics.StartDate) & ~isnat(beAntibiotics.StopDate);
fprintf('Deleted %d Antibiotics with blank start dates\n', sum(idx));
if sum(idx) > 0
    disp(beAntibiotics(idx,:));
    beAntibiotics(idx, :) = [];
end
fprintf('\n');

idx = ~isnat(beAntibiotics.StartDate) & isnat(beAntibiotics.StopDate);
fprintf('Deleted %d Antibiotics with blank stop dates\n', sum(idx));
if sum(idx) > 0
    disp(beAntibiotics(idx,:));
    beAntibiotics(idx, :) = [];
end
fprintf('\n');

idx = beAntibiotics.StopDate < beAntibiotics.StartDate;
fprintf('Deleted %d Antibiotics with Stop Date before Start Date\n', sum(idx));
if sum(idx) > 0
    disp(beAntibiotics(idx,:));
    beAntibiotics(idx, :) = [];
end
fprintf('\n');

idx = days(beAntibiotics.StopDate - beAntibiotics.StartDate) > 30;
fprintf('Found %d Antibiotics > 1 month duration\n', sum(idx));
if sum(idx) > 0
    disp(beAntibiotics(idx,:));
end
fprintf('\n');

% microbiology data
idx = isnat(beMicrobiology.DateMicrobiology);
fprintf('Found %d Microbiology records with blank dates\n', sum(idx));
%if sum(idx) > 0
%    disp(brMicrobiology(idx,:))
%end
fprintf('\n');

% clinic visits
idx = isnat(beClinicVisits.AttendanceDate);
fprintf('Deleted %d Clinic Visits with blank dates\n', sum(idx));
if sum(idx) > 0
    disp(beClinicVisits(idx,:));
    beClinicVisits(idx, :) = [];
end
fprintf('\n');

% pft
idx = isnat(bePFT.LungFunctionDate);
fprintf('Deleted %d PFT measurements with blank dates\n', sum(idx));
if sum(idx) > 0
    disp(bePFT(idx,:));
    bePFT(idx, :) = [];
end
fprintf('\n');

idx = bePFT.FEV1 == 0;
fprintf('Deleted %d zero PFT measurements\n', sum(idx));
if sum(idx) > 0
    disp(bePFT(idx,:));
    bePFT(idx, :) = [];
end
fprintf('\n');

idx = bePFT.FEV1 > 6 | bePFT.FEV1 < 0.5;
fprintf('Found %d < 0.5l or > 6l PFT Clinical Measurements\n', sum(idx));
if sum(idx) > 0
    disp(bePFT(idx,:));
end
fprintf('\n');

toc
fprintf('\n');

tic
fprintf('Checking for dates in the future\n');
disp(beAdmissions(beAdmissions.Admitted > datetime("today"),:));
disp(beAdmissions(beAdmissions.Discharge > datetime("today"),:));
disp(beAntibiotics(beAntibiotics.StartDate > datetime("today"), :));
disp(beAntibiotics(beAntibiotics.StopDate > datetime("today"),:));
disp(beClinicVisits(beClinicVisits.AttendanceDate > datetime("today"),:));
disp(bePFT(bePFT.LungFunctionDate > datetime("today"),:));
toc
fprintf('\n');

fprintf('Row Counts by table\n');
fprintf('-------------------\n');
for t = 1:size(redcaptablemap, 1)
    eval(sprintf('mltable = %s;', redcaptablemap.matlab_table{t}));
    fprintf('%-18s: %5d rows\n', redcaptablemap.matlab_table{t}, size(mltable, 1));
end
fprintf('\n');


% save output files
tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
[~, outputfilename, ~] = getRawDataFilenamesForStudy(study);
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder,outputfilename), 'bePatient', 'beDrugTherapy', 'beAdmissions', ...
    'beAntibiotics', 'beClinicVisits', 'beOtherVisits', 'beUnplannedContact', ...
    'bePFT', 'beCRP', 'beHghtWght', 'beMicrobiology', 'beEndStudy');
toc
fprintf('\n');

% save updated patient id mapping table to excel
tic
basedir = setBaseDir();
subfolder = sprintf('DataFiles/%s/REDCapData/IDMappingFiles', study);
outputfilename = sprintf('%s-PatientIDMappingFile-%s.xlsx', study, datestr(today, 'yyyymmdd'));
fprintf('Saving patient ID mapping table to file %s\n', outputfilename);
writetable(redcapidmap, fullfile(basedir, subfolder, outputfilename), 'Sheet', 'IDMap')
toc
fprintf('\n');

% plot histograms by hospital and by month of last patient clinical data
% update

behosp = getListOfBronchExHospitals();
plotsacross = 2;
plotsdown   = size(behosp, 1);

pghght = 3 * plotsdown;
pgwdth = 7;

plottitle = sprintf('%s-Histogram of patient clinical data by month of last update', study);
[f, p] = createFigureAndPanelForPaper(plottitle, pgwdth, pghght);

for i = 1:size(behosp, 1)

    ax = subplot(plotsdown, plotsacross, (2 * i - 1), 'Parent', p);

    histogram(ax, month(bePatient.PatClinDate(ismember(bePatient.Hospital, behosp.Acronym(i)) & ismember(bePatient.ConsentStatus, 'Yes'))));
    xlabel(ax, 'Month');
    ylabel(ax, 'Count');
    title(ax, sprintf('%s Active', behosp.Name{i}));
    xlim(ax, [0.5 12.5]);
    
    ax = subplot(plotsdown, plotsacross, (2 * i), 'Parent', p);
    
    histogram(ax, month(bePatient.PatClinDate(ismember(bePatient.Hospital, behosp.Acronym(i)) & ~ismember(bePatient.ConsentStatus, 'Yes'))));
    xlabel(ax, 'Month');
    ylabel(ax, 'Count');
    title(ax, sprintf('%s Inactive', behosp.Name{i}));
    xlim(ax, [0.5 12.5]);
    
end

plotsubfolder = sprintf('Plots/%s', study);
savePlotInDir(f, sprintf('%s-%s', plottitle, datestr(today, 'yyyymmdd')), plotsubfolder);
close(f);






