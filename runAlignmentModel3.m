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

fprintf('Methodology for multiplicative normalisation (sigma)\n');
fprintf('----------------------------------------------------\n');
fprintf('1: Std for Data Window across interventions by measure\n');
fprintf('2: Std across all data by measure\n');
fprintf('3: Std across all data by patient and measure\n');
multiplicativenormmethod = input('Choose methodology (1-3) ');
fprintf('\n');
if multiplicativenormmethod > 3
    fprintf('Invalid methodology\n');
    return;
end

fprintf('Methodology for additive normalisation (mu)\n');
fprintf('-------------------------------------------\n');
fprintf('1: Mean for 8 days prior to data window\n');
fprintf('2: Upper Quartile Mean for 8 days prior to data window\n');
additivenormmethod = input('Choose methodology (1-2) ');
fprintf('\n');
if additivenormmethod > 2
    fprintf('Invalid methodology\n');
    return;
end

fprintf('Methodology for curve averaging\n');
fprintf('-------------------------------------------\n');
fprintf('1: Just data window\n');
fprintf('2: Data window + data to the left\n');
curveaveragingmethod = input('Choose methodology (1-2) ');
fprintf('\n');
if curveaveragingmethod > 2
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
    if additivenormmethod == 1
        meanwindow = 8;
    else
        meanwindow = 20;
    end
    scid   = amInterventions.SmartCareID(i);
    start = amInterventions.IVScaledDateNum(i);
    if (start - align_wind - meanwindow) <= 0
        meanwindow = start - align_wind - 1;
    end
    for m = 1:nmeasures
        meanwindowdata = amDatacube(scid, start - align_wind - meanwindow: start - align_wind - 1, m);
        meanwindowdata = sort(meanwindowdata(~isnan(meanwindowdata)), 'ascend');
        if size(meanwindowdata,2) >= 3
            if additivenormmethod == 1
                % take mean of mean window (8 days prior to data window -
                % as long as there are 3 or more data points in the window
                normmean(i, m) = mean(meanwindowdata);
            else
                % upper quartile mean of mean window method
                percentile75 = round(size(meanwindowdata,2) * .75) + 1;
                normmean(i, m) = mean(meanwindowdata(percentile75:end));
            end
        else
            % if not enough data points in the mean window, use the
            % patients inter-quartile mean
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
[best_offsets, best_profile_pre, best_profile_post, best_count_post, best_histogram, best_qual] = am3AlignCurves(amNormcube, ...
    amInterventions, measures, normstd, max_offset, align_wind, nmeasures, ninterventions, ...
    run_type, detaillog, curveaveragingmethod);
fprintf('%s - ErrFcn = %7.4f\n', run_type, best_qual);
% save the zero offset pre-profile to unaligned_profile so all plots show a
% consistent unaligned curve as the pre-profile.
unaligned_profile = best_profile_pre;
% plot and save aligned curves (pre and post)
am3PlotAndSaveAlignedCurves(unaligned_profile, best_profile_post, best_count_post, best_offsets, best_qual, measures, 0, max_offset, align_wind, nmeasures, run_type, study, 0)
toc
fprintf('\n');

fprintf('Running alignment with random offset start\n');
if curveaveragingmethod == 1
    niterations = 500;
else
    niterations = 500;
end
%niterations = 200;
%niterations = 0;
for j=1:niterations
    tic
    for i=1:ninterventions
        amInterventions.Offset(i) = floor(rand * max_offset);
    end
    initial_offsets = amInterventions.Offset;
    run_type = sprintf('Random Offset Start %d', j);
    [offsets, profile_pre, profile_post, count_post, histogram, qual] = am3AlignCurves(amNormcube, ...
        amInterventions, measures, normstd, max_offset, align_wind, nmeasures, ninterventions, ...
        run_type, detaillog, curveaveragingmethod);
    fprintf('%s - ErrFcn = %7.4f\n', run_type, qual);
    if qual < best_qual
        % plot and save aligned curves (pre and post) if the result is best
        % so far
        am3PlotAndSaveAlignedCurves(unaligned_profile, profile_post, count_post, offsets, qual, measures, 0, max_offset, align_wind, nmeasures, run_type, study, 0)
        fprintf('Best so far is random start %d\n', j);
        best_offsets = offsets;
        best_initial_offsets = initial_offsets;
        best_profile_pre = profile_pre;
        best_profile_post = profile_post;
        best_count_post = count_post;
        best_histogram = histogram;
        best_qual = qual; 
    end
    toc
end
fprintf('\n');

ex_start = input('Look at best start and enter exacerbation start: ');
fprintf('\n');

run_type = 'Best Alignment';

[sorted_interventions, max_points] = am3VisualiseAlignmentDetail(amDatacube, amInterventions, best_offsets, best_profile_pre, ...
    best_profile_post, best_count_post, measures, max_offset, align_wind, nmeasures, run_type, study, ex_start, curveaveragingmethod);

am3PlotAndSaveAlignedCurves(unaligned_profile, best_profile_post, best_count_post, best_offsets, best_qual, measures, max_points, max_offset, align_wind, nmeasures, run_type, study, ex_start)

%return;

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
    am3PlotsAndSavePredictions(amInterventions, amDatacube, measures, demographicstable, best_histogram, overall_hist, ...
        best_offsets, best_profile_post, normmean, ex_start, i, nmeasures, max_offset, align_wind, study);
end
toc
fprintf('\n');

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%salignmentmodelv3results-obj%d.mat', study, round(best_qual*10000));
fprintf('Saving alignment model results to file %s\n', outputfilename);
fprintf('\n');
save(fullfile(basedir, subfolder, outputfilename), 'amDatacube', 'amNormcube', 'amInterventions','best_initial_offsets', ...
    'best_offsets', 'best_profile_pre', 'best_profile_post', 'unaligned_profile', 'best_histogram', 'best_qual', ...
    'best_count_post', 'sorted_interventions', 'ex_start', 'normmean', 'normstd', 'study', 'multiplicativenormmethod', ...
    'max_offset', 'align_wind', 'measures', 'nmeasures', 'ninterventions', 'overall_hist');
toc

