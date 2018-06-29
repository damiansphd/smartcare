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
    fprintf('Invalid study\n');
    return;
end

fprintf('Methodology for multiplicative normalisation\n');
fprintf('--------------------------------------------\n');
fprintf('1: Std for Data Window across interventions by measure\n');
fprintf('2: Std across all data by measure\n');
fprintf('3: Std across all data by patient and measure\n');
multiplicativenormmethod = input('Choose methodology (1-3) ');
fprintf('\n');
if multiplicativenormmethod > 3
    fprintf('Invalid methodology\n');
    return;
end
tic
basedir = './';
subfolder = 'MatlabSavedVariables';
fprintf('Loading alignment model Inputs data\n');
load(fullfile(basedir, subfolder, modelinputsmatfile));
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, datademographicsfile));
toc

detaillog = true;
max_offset = 25; % should not be greater than ex_start (set lower down) as this implies intervention before exacerbation !
align_wind = 25;

% remove any interventions where the start is less than the alignment
% window
amInterventions(amInterventions.IVScaledDateNum <= align_wind,:) = [];
ninterventions = size(amInterventions,1);

% remove temperature readings as insufficient datapoints for a number of
% the interventions
%idx = ismember(measures.DisplayName, {'Temperature'});
%idx = ismember(measures.DisplayName, {'Temperature', 'Wellness', 'Activity', 'LungFunction', 'O2Saturation', 'PulseRate', 'SleepActivity', 'Weight'});
idx = ismember(measures.DisplayName, {'Temperature', 'Activity', 'O2Saturation', 'PulseRate', 'SleepActivity', 'Weight'});
%idx = ismember(measures.DisplayName, {'Temperature', 'Activity', 'Cough', 'LungFunction', 'SleepActivity', 'Wellness'});
amDatacube(:,:,measures.Index(idx)) = [];
measures(idx,:) = [];
nmeasures = size(measures,1);
measures.Index = [1:nmeasures]';
unaligned_profile = zeros(nmeasures, max_offset+align_wind);
overall_hist = zeros(ninterventions, max_offset);

% calculate the overall & alignment window std for each measure and store in measures
% table
for m = 1:nmeasures
    tempdata = zeros(ninterventions * align_wind, 1);
    for i = 1:ninterventions
        scid   = amInterventions.SmartCareID(i);
        start = amInterventions.IVScaledDateNum(i);
        tempdata( ((i-1) * align_wind) + 1 : (i * align_wind) ) = reshape(amDatacube(scid, (start - align_wind):(start - 1), m), align_wind, 1);
    end
    measures.AlignWindStd(m) = std(tempdata(~isnan(tempdata)));
    tempdata = reshape(amDatacube(:, :, m), npatients * ndays, 1);
    measures.OverallStd(m) = std(tempdata(~isnan(tempdata)));
end

% populate multiplicative normalisation values based on methodology
% selected
validids = unique(demographicstable.SmartCareID);
normstd = zeros(npatients, nmeasures);
for i = 1:npatients
    for m = 1:nmeasures
        if multiplicativenormmethod == 1
            normstd(i,m) = measures.AlignWindStd(m);
        elseif multiplicativenormmethod == 2
            normstd(i,m) = measures.OverallStd(m);
        else
            if ismember(i,validids)
                scid = i;
                column = getColumnForMeasure(measures.Name{m});
                ddcolumn = sprintf('Fun_%s',column);
                if size(find(demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m})),1) == 0
                    normstd(i,m) = measures.OverallStd(m);
                else
                    normstd(i,m) = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(2);
                end
            end
        end
    end
end

% adjust by additive normalisation

normmean = zeros(ninterventions, nmeasures);
amNormcube = amDatacube;
for i = 1:ninterventions
    meanwindow = 7;
    scid   = amInterventions.SmartCareID(i);
    start = amInterventions.IVScaledDateNum(i);
    if (start - align_wind - meanwindow) <= 0
        meanwindow = start - align_wind - 1;
    end
    for m = 1:nmeasures
        meanwindowdata = amDatacube(scid, start - align_wind - meanwindow: start - align_wind - 1, m);
        if size(meanwindowdata(~isnan(meanwindowdata)),2) >= 3
            normmean(i, m) = mean(meanwindowdata(~isnan(meanwindowdata)));
        else
            if size(find(demographicstable.SmartCareID(demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}))),1) > 0
                fprintf('Using inter-quartile mean for intervention %d, measure %d\n', i, m);
                column = getColumnForMeasure(measures.Name{m});
                ddcolumn = sprintf('Fun_%s',column);
                normmean(i, m) = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(5);
            else
                fprintf('No measures for intervention %d, measure %d\n', i, m);
                normean(i,m) = 0;
            end
        end
        periodstart = start - align_wind - max_offset;
        if periodstart <= 0
            periodstart = 1;
        end
        amNormcube(scid, (periodstart):(start), m) = amDatacube(scid, (periodstart):(start), m) - normmean(i,m);
    end
end
fprintf('\n');

tic
fprintf('Running alignment with zero offset start\n');
for i=1:size(amInterventions,1)
        amInterventions.Offset(i) = 0;
end
best_initial_offsets = amInterventions.Offset;

run_type = 'Zero Offset Start';
[best_offsets, best_profile_pre, best_profile_post, best_histogram, best_qual] = am2AlignCurves(amNormcube, amInterventions, measures, normstd, max_offset, align_wind, nmeasures, ninterventions, run_type, detaillog);
fprintf('%s - ErrFcn = %7.4f\n', run_type, best_qual);
% save the zero offset pre-profile to unaligned_profile so all plots show a
% consistent unaligned curve as the pre-profile.
unaligned_profile = best_profile_pre;
% plot and save aligned curves (pre and post)
am2PlotAndSaveAlignedCurves(unaligned_profile, best_profile_post, best_offsets, best_qual, measures, max_offset, align_wind, nmeasures, run_type, study)
toc
fprintf('\n');

fprintf('Running alignment with random offset start\n');
niterations = 500;
%niterations = 200;
%niterations = 0;
for j=1:niterations
    tic
    for i=1:ninterventions
        amInterventions.Offset(i) = floor(rand * max_offset);
    end
    initial_offsets = amInterventions.Offset;
    run_type = sprintf('Random Offset Start %d', j);
    [offsets, profile_pre, profile_post, histogram, qual] = am2AlignCurves(amNormcube, amInterventions, measures, normstd, max_offset, align_wind, nmeasures, ninterventions, run_type, detaillog);
    fprintf('%s - ErrFcn = %7.4f\n', run_type, qual);
    if qual < best_qual
        % plot and save aligned curves (pre and post) if the result is best
        % so far
        am2PlotAndSaveAlignedCurves(unaligned_profile, profile_post, offsets, qual, measures, max_offset, align_wind, nmeasures, run_type, study)
        fprintf('Best so far is random start %d\n', j);
        best_offsets = offsets;
        best_initial_offsets = initial_offsets;
        best_profile_pre = profile_pre;
        best_profile_post = profile_post;
        best_histogram = histogram;
        best_qual = qual; 
    end
    toc
end
fprintf('\n');

ex_start = input('Look at best start and enter exacerbation start: ');
fprintf('\n');

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%salignmentmodel2results-obj%d.mat', study, round(best_qual*10000));
fprintf('Saving alignment model results to file %s\n', outputfilename);
fprintf('\n');
save(fullfile(basedir, subfolder, outputfilename), 'best_initial_offsets', 'best_offsets', 'best_profile_pre', 'best_profile_post', ...
    'unaligned_profile', 'best_histogram', 'best_qual', 'ex_start');

% create overall histogram (summed over measures by intervention/offset)
for j = 1:ninterventions
    overall_hist(j, :) = reshape(sum(best_histogram(:,j,:),1), [1, max_offset]);
end

% save raw results from objfcn
hstgorig = best_histogram;
overall_hstorig = overall_hist;

% convert back from log space
for j=1:ninterventions
    for m=1:nmeasures
        best_histogram(m, j, :) = exp(-1 * best_histogram(m, j, :));
        best_histogram(m, j, :) = best_histogram(m, j, :) / sum(best_histogram(m, j, :));
    end
    overall_hist(j,:) = exp(-1 * overall_hist(j,:));
    overall_hist(j,:) = overall_hist(j,:) / sum(overall_hist(j,:));
end

toc
fprintf('\n');

tic
fprintf('Plotting prediction results\n');
for i=1:ninterventions
%for i = 42:44
    am2PlotsAndSavePredictions(amInterventions, amDatacube, measures, demographicstable, best_histogram, overall_hist, ...
        best_offsets, best_profile_post, normmean, ex_start, i, nmeasures, max_offset, align_wind, study);
end
toc
fprintf('\n');


