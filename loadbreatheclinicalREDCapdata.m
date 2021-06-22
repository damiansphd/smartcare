% loads Breathe clinical data from REDCap database
% - loads the clinical data from the REDCap data export for a given date
% - stores this data in a set of matlab tables
% - performs some field level data quality checks
% 
% Inputs:
% ------
% - PatientIDmappingFile-yyyymmdd.xlsx - Mapping of internal ID to REDCap ID
% - AnalysisOfRemoteMonitoringVirt_DataDictionary_yyyy-mm-dd.csv - REDCap data 
% dictionary (to get dropdown id/label mappings)
% - REDCapFieldMappingFile_yyyymmdd.xlsx - REDCap table and field mapping (maps 
% redcap instrument to matlab tables, and redcap fields to matlab columns
% - AnalysisOfRemoteMoni_DATA_yyyy-mm-dd_hhmm.csv - REDCap data export file 
% (containing the clinical data for all hospitals & patients
%
% Outputs:
% -------
% breatheclinicaldata.mat with the following variables:
% - brAdmissions          admitted/discharged dates for all hospitalisations
% - brAntibiotics         ab's name, route, homeIV, start/end date
% - brClinicVisits        date, location (e.g. home or clinic)
% - brCRP                 CRP measures
% - brDrugTherapy         CFTR modulators therapy, start/stop date
% - brEndStudy            empty for Breathe - nonrelevant
% - brHghWght             height, weight (and seldom BMI, H_z & W_z scores)
% - brMicrobiology        what bacterias in the lungs
% - brOtherVisits         e.g. annual reviews, emergencies
% - brPatient             patient profile (including mutations, consent 
% status, and last updated date for the clinical data
% - brPFT                 Pulmonary Function Tests
% - brUnplannedContact    Patient contacting hospitals e.g. call
%
% Excel file
% PatientIDmappingFile-yyyymmdd.xlsx - updated mapping of internal ID to 
% REDCap ID to include any new patients since previous ingestion 
%
% Histogram of patient clinical data by month of last update.png - plot

clear; clc; close all;

study = 'BR';

basedir = setBaseDir();
subfolder = sprintf('DataFiles/%s/REDCapData', study);

fprintf('Loading the latest clinical data from REDCap\n');
fprintf('--------------------------------------------\n');
fprintf('\n');

% load latest patient ID mapping file
tic
fprintf('Finding the most recent patient id mapping file\n');
[redcapidmap] = loadREDCapPatientIDMapFile(basedir, subfolder);
toc
fprintf('\n');

% load latest REDCap data dictionary file
tic
fprintf('Finding the most recent REDCap data dictionary file\n');
[redcapdict] = loadREDCapDictionaryFile(basedir, subfolder);
toc
fprintf('\n');

% load latest REDCap table and field mapping file
tic
fprintf('Finding the most recent table and field mapping file\n');
[redcaptablemap, redcapfieldmap] = loadREDCapFieldMapFile(basedir, subfolder);
toc
fprintf('\n');

% load the latest data export from the REDCap database (covering all
% hospitals)
tic
fprintf('Finding the most recent REDCap data export file\n');
[redcapdata, redcapinstrcounts] = loadREDCapDataExportFile(basedir, subfolder, redcapdict);
toc
fprintf('\n');

% replace drop down index values with names in the data file
tic
fprintf('Replacing drop down values with names\n');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'mb_name');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'up_type_of_contact');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'ov_visit_type');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'cv_location');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'ab_name');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'dt_name');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'cfgene1');
[redcapdata] = replaceDropDownValuesWithNames(redcapdata, redcapdict, 'cfgene2');
toc
fprintf('\n');

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
    brtable = redcaptablemap.matlab_table{t};
    
    fprintf('Loading data from instrument %-17s to table %-18s: ', rcinstr, brtable);
    
    % extract data rows for this instrument/table combination
    trcdata = redcapdata(ismember(redcapdata.redcap_repeat_instrument, {rcinstr}), :);
    completefld = sprintf('%s_complete', rcinstr);
    completeidx = table2array(trcdata(:, {completefld})) == 2;
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

    [mltable] = createBreatheSingleClinicalTable(brtable, ntrows);
    
    mltable = populateMLTableFromREDCapData(trcdata, mltable, tfieldmap);

    eval(sprintf('%s = mltable;', brtable));

end
toc
fprintf('\n');

% additionally populate the specific derived columns in the relevant tables
tic
fprintf('Populating derived columns\n');
[brPatient, brCRP, brPFT] = populateDerivedColsInMLTables(brPatient, brCRP, brPFT);
toc
fprintf('\n');

% create stub variable for end of study for backward compatibility
brtable = 'brEndStudy';
[mltable] = createBreatheSingleClinicalTable(brtable, 0);
eval(sprintf('%s = mltable;', brtable));

% sort rows
tic
fprintf('Sorting rows in tables\n');
brPatient           = sortrows(brPatient,          {'ID'});
brDrugTherapy       = sortrows(brDrugTherapy,      {'ID', 'DrugTherapyStartDate'});
brAdmissions        = sortrows(brAdmissions,       {'ID', 'Admitted'});
brAntibiotics       = sortrows(brAntibiotics,      {'ID', 'StartDate', 'AntibioticName'});
brClinicVisits      = sortrows(brClinicVisits,     {'ID', 'AttendanceDate'});
brOtherVisits       = sortrows(brOtherVisits,      {'ID', 'AttendanceDate'});
brUnplannedContact  = sortrows(brUnplannedContact, {'ID', 'ContactDate'});
brPFT               = sortrows(brPFT,              {'ID', 'LungFunctionDate'});
brCRP               = sortrows(brCRP,              {'ID', 'CRPDate'});
brMicrobiology      = sortrows(brMicrobiology,     {'ID', 'DateMicrobiology'});
brHghtWght          = sortrows(brHghtWght,         {'ID', 'MeasDate'});
toc
fprintf('\n');

% data integrity checks
tic
fprintf('Data Integrity Checks\n');
fprintf('---------------------\n');
% patient data
idx = isnat(brPatient.StudyDate) | isnat(brPatient.DOB);
fprintf('Found %d Patients with blank dates\n', sum(idx));
if sum(idx) > 0
    brPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'StudyDate', 'DOB'})
    brPatient(idx, :) = [];
end
idx = brPatient.Height < 120 | brPatient.Height > 220;
fprintf('Found %d Patients height < 1.2m or > 2.2m\n', sum(idx));
if sum(idx) > 0
    brPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'Height'})
end
idx = brPatient.Weight < 35 | brPatient.Weight > 120;
fprintf('Found %d Patients weight < 35kg or > 120kg\n', sum(idx));
if sum(idx) > 0
    brPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'Weight'})
end
idx = brPatient.Age < 18 | brPatient.Age > 60;
fprintf('Found %d Patients aged < 18 or > 60\n', sum(idx));
if sum(idx) > 0
    brPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'StudyDate', 'DOB', 'Age', 'CalcAge', 'CalcAgeExact'})
end
idx = abs(brPatient.Age - brPatient.CalcAge) > 1;
fprintf('Found %d Patients age inconsistent with age calculated from DOB (> 1yr difference)\n', sum(idx));
if sum(idx) > 0
    brPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'StudyDate', 'DOB', 'Age', 'CalcAge', 'CalcAgeExact'})
end
idx = abs(brPatient.PredictedFEV1 - brPatient.CalcPredictedFEV1) > 0.3;
fprintf('Found %d Patients with predicted FEV1 inconsistent with that calculated from age, height, gender (> 300ml diff)\n', sum(idx));
if sum(idx) > 0
    brPatient(idx,{'ID', 'Hospital', 'StudyNumber', 'Age', 'PredictedFEV1', 'CalcPredictedFEV1'})
end

% drug therapy data
% TODO % clean drug therapy namings (see unique(brDrugTherapy.DrugTherapyType)
idx = isnat(brDrugTherapy.DrugTherapyStartDate);
fprintf('Found %d Drug Therapy rows with blank dates\n', sum(idx));
if sum(idx) > 0
    brDrugTherapy(idx,:)
    brDrugTherapy(idx, :) = [];
end

% admission data
idx = isnat(brAdmissions.Admitted) | isnat(brAdmissions.Discharge);
fprintf('Found %d Admissions with blank dates\n', sum(idx));
if sum(idx) > 0
    brAdmissions(idx,:)
    brAdmissions(idx, :) = [];
end
idx = brAdmissions.Discharge < brAdmissions.Admitted;
fprintf('Found %d Admissions with Discharge before Admission\n', sum(idx));
if sum(idx) > 0
    brAdmissions(idx,:)
    brAdmissions(idx, :) = [];
end
idx = days(brAdmissions.Discharge - brAdmissions.Admitted) > 30;
fprintf('Found %d Admissions > 1 month duration\n', sum(idx));
if sum(idx) > 0
    brAdmissions(idx,:)
    % do not delete this as they may be legitimate
    % brAdmissions(idx, :) = [];
end

% antibiotics data
idx = isnat(brAntibiotics.StartDate) & isnat(brAntibiotics.StopDate);
fprintf('Found %d Antibiotics with both blank dates\n', sum(idx));
if sum(idx) > 0
    brAntibiotics(idx,:)
    brAntibiotics(idx, :) = [];
end
idx = isnat(brAntibiotics.StartDate) & ~isnat(brAntibiotics.StopDate);
fprintf('Found %d Antibiotics with blank start dates\n', sum(idx));
if sum(idx) > 0
    brAntibiotics(idx,:)
    brAntibiotics(idx, :) = [];
end
idx = ~isnat(brAntibiotics.StartDate) & isnat(brAntibiotics.StopDate);
fprintf('Found %d Antibiotics with blank stop dates\n', sum(idx));
if sum(idx) > 0
    brAntibiotics(idx,:)
    brAntibiotics(idx, :) = [];
end
idx = brAntibiotics.StopDate < brAntibiotics.StartDate;
fprintf('Found %d Antibiotics with Stop Date before Start Date\n', sum(idx));
if sum(idx) > 0
    brAntibiotics(idx,:)
    brAntibiotics(idx, :) = [];
end
idx = days(brAntibiotics.StopDate - brAntibiotics.StartDate) > 30;
fprintf('Found %d Antibiotics > 1 month duration\n', sum(idx));
if sum(idx) > 0
    brAntibiotics(idx,:)
    % do not delete this as they may be legitimate
    %brAntibiotics(idx, :) = [];
end

% microbiology data
idx = isnat(brMicrobiology.DateMicrobiology);
fprintf('Found %d Microbiology records with blank dates\n', sum(idx));
%if sum(idx) > 0
%    brMicrobiology(idx,:)
%end

% clinic visits
idx = isnat(brClinicVisits.AttendanceDate);
fprintf('Found %d Clinic Visits with blank dates\n', sum(idx));
if sum(idx) > 0
    brClinicVisits(idx,:)
    brClinicVisits(idx, :) = [];
end

% other visits
idx = isnat(brOtherVisits.AttendanceDate);
fprintf('Found %d Other Visits with blank dates\n', sum(idx));
if sum(idx) > 0
    brOtherVisits(idx,:)
    brOtherVisits(idx, :) = [];
end

% unplanned contacts
idx = isnat(brUnplannedContact.ContactDate);
fprintf('Found %d Unplanned Contacts with blank dates\n', sum(idx));
if sum(idx) > 0
    brUnplannedContact(idx,:)
    brUnplannedContact(idx, :) = [];
end

% pft
idx = isnat(brPFT.LungFunctionDate);
fprintf('Found %d PFT measurements with blank dates\n', sum(idx));
if sum(idx) > 0
    brPFT(idx,:)
    brPFT(idx, :) = [];
end
idx = brPFT.FEV1 == 0;
fprintf('Found %d zero PFT measurements\n', sum(idx));
if sum(idx) > 0
    brPFT(idx,:)
    brPFT(idx, :) = [];
end
idx = brPFT.FEV1 > 6 | brPFT.FEV1 < 0.5;
fprintf('Found %d < 0.5l or > 6l PFT Clinical Measurements\n', sum(idx));
if sum(idx) > 0
    brPFT(idx,:)
    brPFT(idx, :) = [];
end

% crp
idx = isnat(brCRP.CRPDate);
fprintf('Found %d CRP measurements with blank dates\n', sum(idx));
if sum(idx) > 0
    brCRP(idx,:)
    brCRP(idx, :) = [];
end
idx = brCRP.NumericLevel > 200;
fprintf('Found %d > 200mg/L CRP measurements\n', sum(idx));
if sum(idx) > 0
    brCRP(idx,:)
end

% crp
idx = isnat(brHghtWght.MeasDate);
fprintf('Found %d Height Weight measurements with blank dates\n', sum(idx));
if sum(idx) > 0
    brHghtWght(idx,:)
    brHghtWght(idx, :) = [];
end
idx = brHghtWght.Weight < 35 | brHghtWght.Weight > 120;
fprintf('Found %d < 35kg or > 120kg Weight measurements\n', sum(idx));
if sum(idx) > 0
    brHghtWght(idx,:)
end
toc
fprintf('\n');

tic
fprintf('Checking for dates in the future\n');
brDrugTherapy(brDrugTherapy.DrugTherapyStartDate > datetime("today"),:)
brAdmissions(brAdmissions.Admitted > datetime("today"),:)
brAdmissions(brAdmissions.Discharge > datetime("today"),:)
brAntibiotics(brAntibiotics.StartDate > datetime("today"), :)
brAntibiotics(brAntibiotics.StopDate > datetime("today"),:)
brClinicVisits(brClinicVisits.AttendanceDate > datetime("today"),:)
brOtherVisits(brOtherVisits.AttendanceDate > datetime("today"),:)
brUnplannedContact(brUnplannedContact.ContactDate > datetime("today"),:)
brCRP(brCRP.CRPDate > datetime("today"),:)
brPFT(brPFT.LungFunctionDate > datetime("today"),:)
brHghtWght(brHghtWght.MeasDate > datetime("today"),:)
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
outputfilename = 'breatheclinicaldata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder,outputfilename), 'brPatient', 'brDrugTherapy', 'brAdmissions', ...
    'brAntibiotics', 'brClinicVisits', 'brOtherVisits', 'brUnplannedContact', ...
    'brPFT', 'brCRP', 'brHghtWght', 'brMicrobiology', 'brEndStudy');
toc
fprintf('\n');

% save updated patient id mapping table to excel
tic
basedir = setBaseDir();
subfolder = sprintf('DataFiles/%s/REDCapData/IDMappingFiles', study);
outputfilename = sprintf('PatientIDMappingFile-%s.xlsx', datestr(today, 'yyyymmdd'));
fprintf('Saving patient ID mapping table to file %s\n', outputfilename);
writetable(redcapidmap, fullfile(basedir, subfolder, outputfilename), 'Sheet', 'IDMap')
toc
fprintf('\n');

% plot histograms by hospital and by month of last patient clinical data
% update

brhosp = getListOfBreatheHospitals();
plotsacross = 2;
plotsdown   = ceil(size(brhosp, 1)/plotsacross);

pghght = 3 * plotsdown;
pgwdth = 7;

plottitle = sprintf('Histogram of patient clinical data by month of last update');
[f, p] = createFigureAndPanelForPaper(plottitle, pgwdth, pghght);

for i = 1:size(brhosp, 1)

    ax = subplot(plotsdown, plotsacross, i, 'Parent', p);

    histogram(ax, month(brPatient.PatClinDate(ismember(brPatient.Hospital, brhosp.Acronym(i)))));
    
    xlabel(ax, 'Month');
    ylabel(ax, 'Count');
    title(ax, brhosp.Name{i});
    xlim(ax, [1 12]);
    
    
end

plotsubfolder = sprintf('Plots/%s', study);
savePlotInDir(f, plottitle, plotsubfolder);
close(f);


