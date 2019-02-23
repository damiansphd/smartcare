clear; close all; clc;

studynbr = input('Enter Study to run for (1 = SmartCare, 2 = TeleMed): ');
fprintf('\n');

if studynbr == 1
    study = 'SC';
    modelinputsmatfile = 'SCalignmentmodelinputs.mat';
    datademographicsfile = 'SCdatademographicsbypatient.mat';
elseif studynbr == 2
    study = 'TM';
    modelinputsmatfile = 'TMalignmentmodelinputs.mat';
    datademographicsfile = 'TMdatademographicsbypatient.mat';
else
    fprintf('Invalid choice\n');
    return;
end

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
fprintf('Loading alignment model Inputs data\n');
load(fullfile(basedir, subfolder, modelinputsmatfile));
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, datademographicsfile));
toc

patientlist = unique(amInterventions.SmartCareID);

idx = ismember(measures.DisplayName, {'Temperature'});
amDatacube(:,:,measures.Index(idx)) = [];
measures(idx,:) = [];
nmeasures = size(measures,1);
measures.Index = [1:nmeasures]';

dataoutliers = table('Size',[1 8], ...
    'VariableTypes', {'double',      'double',    'cell',    'double', 'double',         'double' ,     'double', 'double'}, ...
    'VariableNames', {'SmartCareID', 'MeasureID', 'Measure', 'Day',    'NStdDevOutlier', 'Measurement', 'Mean',   'StdDev'});

rowtoadd = dataoutliers;
dataoutliers(1:size(dataoutliers,1),:) = [];


for a = 1:npatients
    if ismember(a, patientlist)
        for m = 1:nmeasures
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
                        if (amDatacube(a, i, m) >= pmmean + (n * pmstd)) || (amDatacube(a, i, m) <= pmmean - (n * pmstd))
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

tic
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%sdataoutliers.mat', study);
fprintf('Saving data outliers to file %s\n', outputfilename);
fprintf('\n');
save(fullfile(basedir, subfolder, outputfilename), 'dataoutliers');
toc
fprintf('\n');

