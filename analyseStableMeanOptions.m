clear; close all; clc;

defaultmessage = {' ' ; 'DEFAULT' ; 'NO DATA'};
fprintf('Comparing stable mean methods\n');
fprintf('\n');

studynbr = input('Enter Study to run for (1 = SmartCare, 2 = TeleMed): ');
fprintf('\n');

if studynbr == 1
    study = 'SC';
    modelinputsmatfile = 'SCalignmentmodelinputs.mat';
    datademographicsfile = 'SCdatademographicsbypatient.mat';
    dataoutliersfile = 'SCdataoutliers.mat';
elseif studynbr == 2
    study = 'TM';
    modelinputsmatfile = 'TMalignmentmodelinputs.mat';
    datademographicsfile = 'TMdatademographicsbypatient.mat';
    dataoutliersfile = 'TMdataoutliers.mat';
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
fprintf('Loading data outliers\n');
load(fullfile(basedir, subfolder, dataoutliersfile));
toc

tic
fprintf('Preparing input data\n');

max_offset = 25; % should not be greater than ex_start (set lower down) as this implies intervention before exacerbation !
align_wind = 25;

% remove any interventions where the start is less than the alignment
% window
amInterventions(amInterventions.IVScaledDateNum <= align_wind,:) = [];
ninterventions = size(amInterventions,1);

% remove temperature readings as insufficient datapoints for a number of
% the interventions
idx = ismember(measures.DisplayName, {'Temperature'});
amDatacube(:,:,measures.Index(idx)) = [];
measures(idx,:) = [];
nmeasures = size(measures,1);
measures.Index = (1:nmeasures)';

% create cube for data window data by intervention (for each measure)
amIntrDatacube = NaN(ninterventions, max_offset + align_wind - 1, nmeasures);
for i = 1:ninterventions
    scid   = amInterventions.SmartCareID(i);
    start = amInterventions.IVScaledDateNum(i);
    
    icperiodend = align_wind + max_offset -1;
    dcperiodend = start - 1;
    
    icperiodstart = 1;
    dcperiodstart = start - (align_wind + max_offset - 1);
    
    if dcperiodstart <= 0
        icperiodstart = icperiodstart - dcperiodstart + 1;
        dcperiodstart = 1;
    end
    
    for m = 1:nmeasures
        amIntrDatacube(i, (icperiodstart:icperiodend), m) = amDatacube(scid, dcperiodstart:dcperiodend, m);
    end
end

% calculate additive normalisation (mu) based on methodology
nmethods = 6;
allnormmean = zeros(ninterventions, nmeasures, nmethods);
defaultmean = zeros(ninterventions, nmeasures, nmethods);
pdefaultcount = 0;
nodatacount = 0;

fprintf('\n');


for i = 1:ninterventions
    
    scid   = amInterventions.SmartCareID(i);
    start = amInterventions.IVScaledDateNum(i);
    
    fprintf('Interventiond %2d (patient %3d, start %3d)\n', i, scid, start);
    fprintf('-----------------------------------------\n');
            
    for m = 1:nmeasures
        for mumethod = 1:nmethods
            if mumethod == 1
                meanwindow = 8;
            elseif mumethod == 2
                meanwindow = 20;        
            else
                meanwindow = 10;
            end
            if (start - align_wind - meanwindow) <= 0
                meanwindow = start - align_wind - 1;
            end
            meanwindowdata = amDatacube(scid, (start - align_wind - meanwindow): (start - 1 - align_wind), m);
            if mumethod == 4
                tmpdataoutliers =  dataoutliers(dataoutliers.NStdDevOutlier==5 & dataoutliers.SmartCareID == scid & dataoutliers.MeasureID == m,:);
                for d = 1:size(tmpdataoutliers,1)
                    if (start - align_wind - meanwindow) <= tmpdataoutliers.Day(d) && (start - 1 - align_wind) >= tmpdataoutliers.Day(d)
                        fprintf('For Invervention %d, excluding Data outlier (ID %d, Measure %d, Day %d) from meanwindow\n', i, scid, m, tmpdataoutliers.Day(d));
                        meanwindowdata(tmpdataoutliers.Day(d) - (start - align_wind - meanwindow) + 1) = [];
                    end
                end
            end
            if mumethod == 5
                alldata = sort(amDatacube(scid, ~isnan(amDatacube(scid, :, m)), m),'ascend');
                percentile50 = round(size(alldata,2) * .5) + 1;
                upper50mean = mean(alldata(percentile50:end));
                meanwindowdata(1:meanwindow) = upper50mean;
            end
            if mumethod == 6
                alldata = sort(amDatacube(scid, ~isnan(amDatacube(scid, :, m)), m),'ascend');
                percentile25 = round(size(alldata,2) * .25) + 1;
                percentile75 = round(size(alldata,2) * .75);
                mid50mean = mean(alldata(percentile25:percentile75));
                meanwindowdata(1:meanwindow) = mid50mean;
            end 
            meanwindowdata = sort(meanwindowdata(~isnan(meanwindowdata)), 'ascend');
            if size(meanwindowdata,2) >= 3
                if mumethod == 1 || mumethod == 5 || mumethod == 6
                    % take mean of mean window (8 days prior to data window -
                    % as long as there are 3 or more data points in the window
                    allnormmean(i, m, mumethod) = mean(meanwindowdata(1:end));
                elseif mumethod == 2
                    % upper quartile mean of mean window method
                    percentile75 = round(size(meanwindowdata,2) * .75) + 1;
                    allnormmean(i, m, mumethod) = mean(meanwindowdata(percentile75:end));
                elseif mumethod == 3
                    % exclude bottom quartile from mean method
                    percentile25 = round(size(meanwindowdata,2) * .25) + 1;
                    allnormmean(i, m, mumethod) = mean(meanwindowdata(percentile25:end));
                else
                    % exclude bottom quartile from mean method
                    % and data outliers
                    percentile25 = round(size(meanwindowdata,2) * .25) + 1;
                    allnormmean(i, m, mumethod) = mean(meanwindowdata(percentile25:end));
                end          
            else
                % if not enough data points in the mean window, use the
                % patients inter-quartile mean
                if size(find(demographicstable.SmartCareID(demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}))),1) > 0
                    %fprintf('Using inter-quartile mean for intervention %d, measure %d\n', i, m);
                    column = getColumnForMeasure(measures.Name{m});
                    ddcolumn = sprintf('Fun_%s',column);
                    allnormmean(i, m, mumethod) = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(5);
                    defaultmean(i, m, mumethod) = 1;
                    pdefaultcount = pdefaultcount + 1;
                else
                    %fprintf('No measures for intervention %d, measure %d\n', i, m);
                    allnormmean(i,m, mumethod) = 0;
                    defaultmean(i, m, mumethod) = 2;
                    nodatacount = nodatacount + 1;
                end
            end
            fprintf('Measure %d %15s, mumethod %d window size %2d, mean %8.2f %s\n', ...
                m, measures.DisplayName{m}, mumethod, size(meanwindowdata,2), allnormmean(i, m, mumethod), ...
                defaultmessage{defaultmean(i, m, mumethod) + 1});
        end
        fprintf('\n');
    end
end

fprintf('\n');
fprintf('Patient/measure default count %d\n', pdefaultcount);
fprintf('No data count %d\n', nodatacount);
fprintf('\n');
