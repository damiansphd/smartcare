clc; clear; close all;

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

[studynbr, study, ~] = selectStudy();
[datamatfile, clinicalmatfile, ~] = getRawDataFilenamesForStudy(study);
[physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[cdPatient, ~, ~, ~, ~, cdPFT, ~, ...
    ~, ~, ~, ~] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);

aminputfile = "CLalignmentmodelinputs_gap10.mat";
fprintf('Loading alignment model Inputs data %s\n', aminputfile);
load(fullfile(basedir, subfolder, aminputfile));

% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(physdata);

% extract clinical FEV1 measures and join with offsets to keep only those patients who
% have enough data (ie the patients left after outlier date handling
pclinicalfev = sortrows(cdPFT(:,{'ID', 'LungFunctionDate', 'FEV1'}), {'ID', 'LungFunctionDate'}, 'ascend');
pclinicalfev.Properties.VariableNames{'ID'} = 'SmartCareID';
pclinicalfev = innerjoin(pclinicalfev, patientoffsets);

% create a scaleddatenum to translate the study date to the same normalised
% scale as measurement data scaled date num
pclinicalfev.ScaledDateNum = datenum(pclinicalfev.LungFunctionDate) - offset - pclinicalfev.PatientOffset + 1;

% extract study date and join with offsets to keep only those patients who
% have enough data (ie the patients left after outlier date handling
pstudydate = sortrows(cdPatient(:,{'ID', 'Hospital', 'StudyNumber', 'StudyDate'}), 'ID', 'ascend');
pstudydate.Properties.VariableNames{'ID'} = 'SmartCareID';
pstudydate = innerjoin(patientoffsets, pstudydate);

% create a scaleddatenum to translate the study date to the same normalised
% scale as measurement data scaled date num
pstudydate.ScaledDateNum = datenum(pstudydate.StudyDate) - offset - pstudydate.PatientOffset;

% extract just the weight measures from smartcare data
%pmeasfev = physdata(ismember(physdata.RecordingType,'LungFunctionRecording'),{'SmartCareID', 'ScaledDateNum', 'CalcFEV1_'});

midx = ismember(measures.DisplayName, {'LungFunction'});
pmeasfev = amDatacube(:, :, midx);
maxdays = size(pmeasfev, 2);

% delete all clinical measures before or after the study period for each patient
pclinicalfev((pclinicalfev.ScaledDateNum < 0) | (pclinicalfev.ScaledDateNum > maxdays), :) = [];

% create initial output table
fevcomptable = innerjoin(pclinicalfev, pstudydate, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, 'RightVariables', {'Hospital', 'StudyNumber'});
fevcomptable = fevcomptable(:, {'SmartCareID', 'Hospital', 'StudyNumber', 'LungFunctionDate', 'ScaledDateNum', 'FEV1'});
fevcomptable.Properties.VariableNames{'FEV1'} = 'ClinFEV1';
fevcomptable.NbrHomeMeas(:)  = 0.0;
fevcomptable.MeanHomeMeas(:) = 0.0;
fevcomptable.StdHomeMeas(:)  = 0.0;

nkeycols  = size(fevcomptable, 2);
nclinmeas = size(fevcomptable, 1);
dwidth = 5;
ndays = (2 * dwidth) + 1;
dwin = nan(nclinmeas,ndays);
dwin = array2table(dwin);

fevcomptable = [fevcomptable, dwin];
for n = 1:ndays
    if n <= dwidth
        fevcomptable.Properties.VariableNames{n + nkeycols} = sprintf('Dminus%d', (dwidth + 1) - n);
    elseif n == dwidth + 1
        fevcomptable.Properties.VariableNames{n + nkeycols} = sprintf('D%d', 0);
    else
        fevcomptable.Properties.VariableNames{n + nkeycols} = sprintf('Dplus%d', n - (dwidth + 1));
    end
end    

for i = 1:size(fevcomptable, 1)
    scid = fevcomptable.SmartCareID(i);
    sdn  = fevcomptable.ScaledDateNum(i);
    fromidx = sdn - dwidth;
    lshift = 0;
    if fromidx <= 0
        lshift = 1 + (-1 * fromidx);
        fromidx = fromidx + lshift;
    end
    if fromidx > maxdays
        continue;
    end
        
    toidx   = sdn + dwidth;
    if toidx > maxdays
        toidx = maxdays;
    end
    
    dwinmeas = pmeasfev(scid, fromidx:toidx);
    fevcomptable.NbrHomeMeas(i)  = sum(~isnan(dwinmeas)); 
    fevcomptable.MeanHomeMeas(i) = mean(dwinmeas, 'omitnan');
    fevcomptable.StdHomeMeas(i)  = std(dwinmeas, 'omitnan');
    startcol = (nkeycols + 1 + lshift);
    
    fevcomptable(i, startcol:(startcol + size(dwinmeas, 2) - 1)) = array2table(dwinmeas);
end

subfolder = 'ExcelFiles';
outputfilename = sprintf('%s_ClinicalVsHomeFEVComparison.xlsx', study);
writetable(fevcomptable,  fullfile(basedir, subfolder, outputfilename), 'Sheet', 'FEV_Comparison');

