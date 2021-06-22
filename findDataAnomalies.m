% highlight data anomalies to be optionnaly excluded prior to run the alignment model
%
% used to exclude certain outlier points in the model alignment process if 
% exclude anomalies is chosen as a run parameter
% 
% Input:
% ------
% *alignmentmodelinputs_gap*.mat    alignment model inptus
% *datademographicsbypatient.mat    created in loadbreathedata
%
% Output:
% -------
% *dataoutliers.mat     MAT-file storing data outliers

clear; close all; clc;

[studynbr, study, studyfullname] = selectStudy();
treatgap = selectTreatmentGap();

modelinputsmatfile = sprintf('%salignmentmodelinputs_gap%d.mat', study, treatgap);
datademographicsfile = sprintf('%sdatademographicsbypatient.mat', study);
fprintf('\n');

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
fprintf('Loading alignment model Inputs data\n');
load(fullfile(basedir, subfolder, modelinputsmatfile));
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, datademographicsfile));
toc

patientlist = unique(amInterventions.SmartCareID);

% **** Moved logic down inside the measures loop to now skip these measures
% rather than delete them - because otherwise it leaves the wrong measures ID on
% the outliers !!! ****

% delete temperature recordings for smartcare and telemed due to only
% portion of patients completing this meaasure
%if (studynbr == 1 || studynbr == 2)
%    idx = ismember(measures.DisplayName, {'Temperature'});
%    amDatacube(:,:,measures.Index(idx)) = [];
%    measures(idx,:) = [];
%    nmeasures = size(measures,1);
%   measures.Index = [1:nmeasures]';
%end

% delete binary measurement types for Project Breathe (HasColdOrFlu,
% HasHayFever
%if (studynbr == 4)
%    idx = ismember(measures.DisplayName, {'HasColdOrFlu', 'HasHayFever'});
%    amDatacube(:,:,measures.Index(idx)) = [];
%    measures(idx,:) = [];
%    nmeasures = size(measures,1);
%    measures.Index = [1:nmeasures]';
%end

dataoutliers = table('Size',[1 8], ...
    'VariableTypes', {'double',      'double',    'cell',    'double', 'double',         'double' ,     'double', 'double'}, ...
    'VariableNames', {'SmartCareID', 'MeasureID', 'Measure', 'Day',    'NStdDevOutlier', 'Measurement', 'Mean',   'StdDev'});

rowtoadd = dataoutliers;
dataoutliers(1:size(dataoutliers,1),:) = [];


for a = 1:npatients
    if ismember(a, patientlist)
        for m = 1:nmeasures
            if (ismember(study, {'SC', 'TM'}) && ismember(measures.DisplayName(m), {'Temperature'})) || ...
               (ismember(study, {'BR'})       && ismember(measures.DisplayName(m), {'HasColdOrFlu', 'HasHayFever'}))
               fprintf('Skipping measure %s for study %s\n', measures.DisplayName{m}, study)
            else
                % get overall mean and std for the patient and measure
                column = getColumnForMeasure(measures.Name{m});
                ddcolumn = sprintf('Fun_%s',column);
                if size(find(demographicstable.SmartCareID == a & ismember(demographicstable.RecordingType, measures.Name{m})),1) == 0
                    fprintf('Could not find mean & std for patient %d and measure %d so using overall mean & std instead\n', a, m);
                    tempdata = reshape(amDatacube(:, :, m), npatients * ndays, 1);
                    pmmean   = mean(tempdata(~isnan(tempdata)));
                    pmstd    = std(tempdata(~isnan(tempdata)));
                else
                    pmmean   = demographicstable{demographicstable.SmartCareID == a & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(1);
                    pmstd    = demographicstable{demographicstable.SmartCareID == a & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(2);
                end
                rowtoadd.SmartCareID = a;
                rowtoadd.MeasureID   = m;
                rowtoadd.Measure     = measures.Name(m);
                for i = 1:ndays
                    if ~isnan(amDatacube(a, i, m))
                        rowtoadd.Day = i;
                        for n = 3:8
                            if (amDatacube(a, i, m) > pmmean + (n * pmstd)) || (amDatacube(a, i, m) < pmmean - (n * pmstd))
                                rowtoadd.NStdDevOutlier = n;
                                rowtoadd.Measurement    = amDatacube(a, i, m);
                                rowtoadd.Mean           = pmmean;
                                rowtoadd.StdDev         = pmstd;
                                dataoutliers = [dataoutliers ; rowtoadd];
                            end
                        end
                    end
                end
            end
        end
    end
end

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%sdataoutliers.mat', study);
fprintf('Saving data outliers to file %s\n', outputfilename);
fprintf('\n');
save(fullfile(basedir, subfolder, outputfilename), 'dataoutliers');
toc
fprintf('\n');

