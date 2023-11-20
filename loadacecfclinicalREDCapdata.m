% loads ACE-CF clinical data from REDCap database
% - loads the clinical data from the REDCap data export for a given date
% - stores this data in a set of matlab tables
% - performs some field level data quality checks
% 
% Inputs:
% ------
% - AC-PatientIDmappingFile-yyyymmdd.xlsx - Mapping of internal ID to REDCap ID
% - ArtificialIntelligenceToContro_DataDictionary_yyyy-mm-dd.csv - REDCap data 
% dictionary (to get dropdown id/label mappings)
% - AC-REDCapFieldMappingFile_yyyymmdd.xlsx - REDCap table and field mapping (maps 
% redcap instrument to matlab tables, and redcap fields to matlab columns
% - ArtificialIntelligen_DATA_yyyy-mm-dd_hhmm.csv - REDCap data export file 
% (containing the clinical data for all hospitals & patients
%
% Outputs:
% -------
% acecfclinicaldata.mat with the following variables:
% - acAdmissions          admitted/discharged dates for all hospitalisations
% - acAntibiotics         ab's name, route, homeIV, start/end date
% - acClinicVisits        date, location (e.g. home or clinic)
% - acCRP                 CRP measures
% - acDrugTherapy         CFTR modulators therapy, start/stop date
% - acEndStudy            empty for Breathe - nonrelevant
% - acHghWght             <empty>
% - acMicrobiology        what bacterias in the lungs
% - acOtherVisits         <empty>
% - acPatient             patient profile (including mutations, consent 
% status, and last updated date for the clinical data
% - acPFT                 Pulmonary Function Tests
% - acUnplannedContact    <empty>
%
% Excel file
% AC-PatientIDmappingFile-yyyymmdd.xlsx - updated mapping of internal ID to 
% REDCap ID to include any new patients since previous ingestion 
%
% Histogram of patient clinical data by month of last update.png - plot

clear; clc; close all;

study = 'AC';

basedir = setBaseDir();
subfolder = sprintf('DataFiles/%s/REDCapData', study);

fprintf('Loading the latest clinical data from REDCap\n');
fprintf('--------------------------------------------\n');
fprintf('\n');

% load latest patient ID mapping file
tic
fprintf('Finding the most recent patient id mapping file\n');
fnamematchstr = 'AC-PatientIDMappingFile*';
[redcapidmap] = loadREDCapPatientIDMapFile(basedir, subfolder, fnamematchstr);
toc
fprintf('\n');

% load latest REDCap data dictionary file
tic
fprintf('Finding the most recent REDCap data dictionary file\n');
fnamematchstr = 'ArtificialIntelligenceToContro_DataDictionary*';
[redcapdict] = loadREDCapDictionaryFile(basedir, subfolder, fnamematchstr);
% update hospital dropdown values
redcapdict.Choices_Calculations_ORSliderLabels(ismember(redcapdict.Variable_FieldName, {'hospital'})) = {'1, PAP|2, CDF|3, GGC|4, EDB|5, KCL|6, BEL'};
% convert yes/no fields to look like drop downs so we can process more easily
redcapdict.FieldType(ismember(redcapdict.Variable_FieldName, {'consent_given'})) = {'dropdown'};
redcapdict.FieldType(ismember(redcapdict.Variable_FieldName, {'ab_home'}))       = {'dropdown'};
redcapdict.Choices_Calculations_ORSliderLabels(ismember(redcapdict.Variable_FieldName, {'consent_given'})) = {'0, No|1, Yes'};
redcapdict.Choices_Calculations_ORSliderLabels(ismember(redcapdict.Variable_FieldName, {'ab_home'}))       = {'0, No|1, Yes'};
toc
fprintf('\n');

% load latest REDCap table and field mapping file
tic
fprintf('Finding the most recent table and field mapping file\n');
fnamematchstr = 'AC-REDCapFieldMappingFile*';
[redcaptablemap, redcapfieldmap] = loadREDCapFieldMapFile(basedir, subfolder, fnamematchstr);
toc
fprintf('\n');

% load the latest data export from the REDCap database (covering all
% hospitals)
tic
fprintf('Finding the most recent REDCap data export file\n');
fnamematchstr = 'ArtificialIntelligen_DATA*';
redcapidcol = 'record_id';
[redcapdata, redcapinstrcounts] = loadREDCapDataExportFile(basedir, subfolder, fnamematchstr, redcapdict, redcapidcol);
% update study id columns to be consistent with Breathe
redcapdata.Properties.VariableNames(ismember(redcapdata.Properties.VariableNames, {'study_number'})) = {'study_number2'};
redcapdata.Properties.VariableNames(ismember(redcapdata.Properties.VariableNames, {'study_id'})) = {'study_number'};
redcapdata.Properties.VariableNames(ismember(redcapdata.Properties.VariableNames, {'record_id'})) = {'study_id'};
redcapidcol = 'study_id';
toc
fprintf('\n');

% replace drop down index values with names in the data file
tic
fprintf('Replacing drop down values with names\n');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'hospital');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'cohort');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'biological_sex');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'ethnicity');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'cfgene1');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'cfgene2');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'consent_given');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'dt_name');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'mb_name');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'ab_route');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'ab_reason');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'ab_name');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'ab_protocol_def');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'ab_prescriber');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'ab_home');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'enc_type');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'ue_type');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'ov_type');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'ad_planned');

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
    actable = redcaptablemap.matlab_table{t};
    
    fprintf('Loading data from instrument %-24s to table %-18s: ', rcinstr, actable);
    
    % extract data rows for this instrument/table combination
    trcdata = redcapdata(ismember(redcapdata.redcap_repeat_instrument, {rcinstr}), :);
    
    
    % for ACE-CF, temporarily include complete and unverified records,
    % until enough have been set to complete.
    completefld = sprintf('%s_complete', rcinstr);
    %completeidx = table2array(trcdata(:, {completefld})) == 2;
    
    if size(trcdata, 1) > 0
        completeidx = table2array(trcdata(:, {completefld})) ~= 0;
    else
        completeidx = [];
    end
    
    trcdata = trcdata(completeidx, :);
    %ntrows  = redcapinstrcounts.GroupCount(ismember(redcapinstrcounts.redcap_repeat_instrument, {rcinstr}));
    ntrows = size(trcdata, 1);
    if sum(completeidx) ~= size(completeidx, 1)
        warnsuffix = '**** incomplete status rows filtered ****';
    else
        warnsuffix = '';
    end
    fprintf('%5d status complete rows of %5d total rows %s\n', sum(completeidx), size(completeidx, 1), warnsuffix);
   
    tfieldmap = redcapfieldmap(ismember(redcapfieldmap.redcap_instrument, {rcinstr}), :);

    [mltable] = createAceCFSingleClinicalTable(actable, ntrows);
    
    mltable = populateMLTableFromREDCapData(trcdata, mltable, tfieldmap);

    eval(sprintf('%s = mltable;', actable));

end
toc
fprintf('\n');

% additionally populate the specific derived columns in the relevant tables
tic
fprintf('Populating derived columns\n');
[acPatient, acCRP, acPFT] = populateAceCFDerivedColsInMLTables(acPatient, acCRP, acPFT, acPatDataUpdTo);
toc
fprintf('\n');

% populate default values as necessary
tic
fprintf('Populating default values\n');
defidx = ~ismember(acAntibiotics.HomeIV_s, {'Yes', 'No'});
fprintf('Updating %d blank HomeIV values\n', sum(defidx));
acAntibiotics.HomeIV_s(defidx) = {'No'};


% create stub variable for other visits, unplanned contact, height_weight and end of study for backward compatibility
actable = 'acOtherVisits';
[mltable] = createAceCFSingleClinicalTable(actable, 0);
eval(sprintf('%s = mltable;', actable));

actable = 'acUnplannedContact';
[mltable] = createAceCFSingleClinicalTable(actable, 0);
eval(sprintf('%s = mltable;', actable));

actable = 'acHghtWght';
[mltable] = createAceCFSingleClinicalTable(actable, 0);
eval(sprintf('%s = mltable;', actable));

actable = 'acEndStudy';
[mltable] = createAceCFSingleClinicalTable(actable, 0);
eval(sprintf('%s = mltable;', actable));

% sort rows
tic
fprintf('Sorting rows in tables\n');
acPatient           = sortrows(acPatient,          {'ID'});
acDrugTherapy       = sortrows(acDrugTherapy,      {'ID', 'DrugTherapyStartDate'});
acAdmissions        = sortrows(acAdmissions,       {'ID', 'Admitted'});
acAntibiotics       = sortrows(acAntibiotics,      {'ID', 'StartDate', 'AntibioticName'});
acClinicVisits      = sortrows(acClinicVisits,     {'ID', 'AttendanceDate'});
acOtherVisits       = sortrows(acOtherVisits,      {'ID', 'AttendanceDate'});
acUnplannedContact  = sortrows(acUnplannedContact, {'ID', 'ContactDate'});
acPFT               = sortrows(acPFT,              {'ID', 'LungFunctionDate'});
acCRP               = sortrows(acCRP,              {'ID', 'CRPDate'});
acMicrobiology      = sortrows(acMicrobiology,     {'ID', 'DateMicrobiology'});
acHghtWght          = sortrows(acHghtWght,         {'ID', 'MeasDate'});
toc
fprintf('\n');

% data integrity checks
tic
fprintf('Data Integrity Checks\n');
fprintf('---------------------\n');
% patient data
idx = isnat(acPatient.StudyDate) | isnat(acPatient.DOB);
fprintf('Deleted %d Patients with blank dates\n', sum(idx));
if sum(idx) > 0
    acPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'StudyDate', 'DOB'})
    acPatient(idx, :) = [];
end
fprintf('\n');

idx = acPatient.Height < 120 | acPatient.Height > 220;
fprintf('Found %d Patients height < 1.2m or > 2.2m\n', sum(idx));
if sum(idx) > 0
    acPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'Height'})
end
fprintf('\n');

idx = acPatient.Weight < 35 | acPatient.Weight > 120;
fprintf('Found %d Patients weight < 35kg or > 120kg\n', sum(idx));
if sum(idx) > 0
    acPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'Weight'})
end
fprintf('\n');

idx = acPatient.Age < 18 | acPatient.Age > 60;
fprintf('Found %d Patients aged < 18 or > 60\n', sum(idx));
if sum(idx) > 0
    acPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'StudyDate', 'DOB', 'Age', 'CalcAge', 'CalcAgeExact'})
end
fprintf('\n');

idx = abs(acPatient.PredictedFEV1 - acPatient.CalcPredictedFEV1) > 0.3;
fprintf('Found %d Patients with predicted FEV1 inconsistent with that calculated from age, height, gender (> 300ml diff)\n', sum(idx));
if sum(idx) > 0
    acPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'Age', 'PredictedFEV1', 'CalcPredictedFEV1'})
end
fprintf('\n');

% drug therapy data
idx = isnat(acDrugTherapy.DrugTherapyStartDate);
fprintf('Deleted %d Drug Therapy rows with blank dates\n', sum(idx));
if sum(idx) > 0
    acDrugTherapy(idx,:)
    acDrugTherapy(idx, :) = [];
end
fprintf('\n');

% admission data
idx = isnat(acAdmissions.Admitted) | isnat(acAdmissions.Discharge);
fprintf('Deleted %d Admissions with blank dates\n', sum(idx));
if sum(idx) > 0
    acAdmissions(idx,:)
    acAdmissions(idx, :) = [];
end
fprintf('\n');

idx = acAdmissions.Discharge < acAdmissions.Admitted;
fprintf('Deleted %d Admissions with Discharge before Admission\n', sum(idx));
if sum(idx) > 0
    acAdmissions(idx,:)
    acAdmissions(idx, :) = [];
end
fprintf('\n');

idx = days(acAdmissions.Discharge - acAdmissions.Admitted) > 30;
fprintf('Found %d Admissions > 1 month duration\n', sum(idx));
if sum(idx) > 0
    acAdmissions(idx,:)
end
fprintf('\n');

% antibiotics data
idx = ismember(acAntibiotics.Reason, {'Prophylactic'});
fprintf('Deleted %d Antibiotics with reason Prophylactic\n', sum(idx));
if sum(idx) > 0
    acAntibiotics(idx,:)
    acAntibiotics(idx, :) = [];
end
fprintf('\n');

idx = isnat(acAntibiotics.StartDate) & isnat(acAntibiotics.StopDate);
fprintf('Deleted %d Antibiotics with both blank dates\n', sum(idx));
if sum(idx) > 0
    acAntibiotics(idx,:)
    acAntibiotics(idx, :) = [];
end
fprintf('\n');

idx = isnat(acAntibiotics.StartDate) & ~isnat(acAntibiotics.StopDate);
fprintf('Deleted %d Antibiotics with blank start dates\n', sum(idx));
if sum(idx) > 0
    acAntibiotics(idx,:)
    acAntibiotics(idx, :) = [];
end
fprintf('\n');

idx = ~isnat(acAntibiotics.StartDate) & isnat(acAntibiotics.StopDate);
fprintf('Deleted %d Antibiotics with blank stop dates\n', sum(idx));
if sum(idx) > 0
    acAntibiotics(idx,:)
    acAntibiotics(idx, :) = [];
end
fprintf('\n');

idx = acAntibiotics.StopDate < acAntibiotics.StartDate;
fprintf('Deleted %d Antibiotics with Stop Date before Start Date\n', sum(idx));
if sum(idx) > 0
    acAntibiotics(idx,:)
    acAntibiotics(idx, :) = [];
end
fprintf('\n');

idx = days(acAntibiotics.StopDate - acAntibiotics.StartDate) > 30;
fprintf('Found %d Antibiotics > 1 month duration\n', sum(idx));
if sum(idx) > 0
    acAntibiotics(idx,:)
end
fprintf('\n');

% microbiology data
idx = isnat(acMicrobiology.DateMicrobiology);
fprintf('Found %d Microbiology records with blank dates\n', sum(idx));
%if sum(idx) > 0
%    brMicrobiology(idx,:)
%end
fprintf('\n');

% clinic visits
idx = isnat(acClinicVisits.AttendanceDate);
fprintf('Deleted %d Clinic Visits with blank dates\n', sum(idx));
if sum(idx) > 0
    acClinicVisits(idx,:)
    acClinicVisits(idx, :) = [];
end
fprintf('\n');

% pft
idx = isnat(acPFT.LungFunctionDate);
fprintf('Deleted %d PFT measurements with blank dates\n', sum(idx));
if sum(idx) > 0
    acPFT(idx,:)
    acPFT(idx, :) = [];
end
fprintf('\n');

idx = acPFT.FEV1 == 0;
fprintf('Deleted %d zero PFT measurements\n', sum(idx));
if sum(idx) > 0
    acPFT(idx,:)
    acPFT(idx, :) = [];
end
fprintf('\n');

idx = acPFT.FEV1 > 6 | acPFT.FEV1 < 0.5;
fprintf('Found %d < 0.5l or > 6l PFT Clinical Measurements\n', sum(idx));
if sum(idx) > 0
    acPFT(idx,:)
end
fprintf('\n');

% crp
idx = isnat(acCRP.CRPDate);
fprintf('Deleted %d CRP measurements with blank dates\n', sum(idx));
if sum(idx) > 0
    acCRP(idx,:)
    acCRP(idx, :) = [];
end
fprintf('\n');

idx = acCRP.NumericLevel > 200;
fprintf('Found %d > 200mg/L CRP measurements\n', sum(idx));
if sum(idx) > 0
    acCRP(idx,:)
end
fprintf('\n');

toc
fprintf('\n');

tic
fprintf('Checking for dates in the future\n');
acDrugTherapy(acDrugTherapy.DrugTherapyStartDate > datetime("today"),:)
acAdmissions(acAdmissions.Admitted > datetime("today"),:)
acAdmissions(acAdmissions.Discharge > datetime("today"),:)
acAntibiotics(acAntibiotics.StartDate > datetime("today"), :)
acAntibiotics(acAntibiotics.StopDate > datetime("today"),:)
acClinicVisits(acClinicVisits.AttendanceDate > datetime("today"),:)
acCRP(acCRP.CRPDate > datetime("today"),:)
acPFT(acPFT.LungFunctionDate > datetime("today"),:)
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
outputfilename = 'acecfclinicaldata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder,outputfilename), 'acPatient', 'acDrugTherapy', 'acAdmissions', ...
    'acAntibiotics', 'acClinicVisits', 'acOtherVisits', 'acUnplannedContact', ...
    'acPFT', 'acCRP', 'acHghtWght', 'acMicrobiology', 'acEndStudy');
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

achosp = getListOfAceCFHospitals();
plotsacross = 2;
plotsdown   = size(achosp, 1);

pghght = 3 * plotsdown;
pgwdth = 7;

plottitle = sprintf('%s-Histogram of patient clinical data by month of last update', study);
[f, p] = createFigureAndPanelForPaper(plottitle, pgwdth, pghght);

for i = 1:size(achosp, 1)

    ax = subplot(plotsdown, plotsacross, (2 * i - 1), 'Parent', p);

    histogram(ax, month(acPatient.PatClinDate(ismember(acPatient.Hospital, achosp.Acronym(i)) & ismember(acPatient.ConsentStatus, 'Yes'))));
    xlabel(ax, 'Month');
    ylabel(ax, 'Count');
    title(ax, sprintf('%s Active', achosp.Name{i}));
    xlim(ax, [0.5 12.5]);
    
    ax = subplot(plotsdown, plotsacross, (2 * i), 'Parent', p);
    
    histogram(ax, month(acPatient.PatClinDate(ismember(acPatient.Hospital, achosp.Acronym(i)) & ~ismember(acPatient.ConsentStatus, 'Yes'))));
    xlabel(ax, 'Month');
    ylabel(ax, 'Count');
    title(ax, sprintf('%s Inactive', achosp.Name{i}));
    xlim(ax, [0.5 12.5]);
    
end

plotsubfolder = sprintf('Plots/%s', study);
savePlotInDir(f, sprintf('%s-%s', plottitle, datestr(today, 'yyyymmdd')), plotsubfolder);
close(f);

fprintf('Active patients with aged last update date\n');
fprintf('------------------------------------------\n');
fprintf('\n');
acPatient((today - datenum(acPatient.PatClinDate)) > 62 & ismember(acPatient.ConsentStatus, 'Yes'), ...
    {'ID', 'REDCapID', 'Hospital', 'StudyNumber', 'StudyDate', 'PatClinDate', 'ConsentStatus'})





