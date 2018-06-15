clear; close all; clc;

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
modelinputsmatfile = 'alignmentmodelinputs.mat';
datademographicsfile = 'datademographicsbypatient.mat';
fprintf('Loading Alignment Model Inputs data\n');
load(fullfile(basedir, subfolder, modelinputsmatfile));
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, datademographicsfile));
toc

detaillog = true;
max_offset = 30; % should not be greater than ex_start (set lower down) as this implies intervention before exacerbation !
align_wind = 20;

% remove temperature readings as insufficient datapoints for a number of
% the interventions
%idx = ismember(measures.DisplayName, {'Temperature'});
%idx = ismember(measures.DisplayName, {'Temperature', 'Activity', 'LungFunction', 'O2Saturation', 'PulseRate', 'SleepActivity', 'Weight'});
idx = ismember(measures.DisplayName, {'Temperature', 'Wellness', 'Activity', 'LungFunction', 'O2Saturation', 'PulseRate', 'SleepActivity', 'Weight'});
%idx = ismember(measures.DisplayName, {'Temperature', 'Activity', 'O2Saturation', 'PulseRate', 'SleepActivity', 'Weight'});
%idx = ismember(measures.DisplayName, {'Temperature', 'Activity', 'Cough', 'LungFunction', 'SleepActivity', 'Wellness'});


amDatacube(:,:,measures.Index(idx)) = [];
amNormcube(:,:,measures.Index(idx)) = [];
measures(idx,:) = [];
nmeasures = size(measures,1);
measures.Index = [1:nmeasures]';
unaligned_profile = zeros(nmeasures, max_offset+align_wind);
problower = zeros(ninterventions, 1);
probupper = zeros(ninterventions, 1);

tic
fprintf('Running alignment with zero offset start\n');
for i=1:size(amInterventions,1)
        amInterventions.Offset(i) = 0;
end
best_initial_offsets = amInterventions.Offset;

run_type = 'Zero Offset Start';
[best_offsets, best_profile_pre, best_profile_post, best_histogram, best_qual] = amAlignCurves(amNormcube, amInterventions, measures, max_offset, align_wind, nmeasures, ninterventions, run_type, detaillog);
fprintf('%s - ErrFcn = %7.4f\n', run_type, best_qual);
% save the zero offset pre-profile to unaligned_profile so all plots show a
% consistent unaligned curve as the pre-profile.
unaligned_profile = best_profile_pre;
% plot and save aligned curves (pre and post)
amPlotAndSaveAlignedCurves(unaligned_profile, best_profile_post, best_offsets, best_qual, measures, max_offset, align_wind, nmeasures, run_type)
toc
fprintf('\n');

fprintf('Running alignment with random offset start\n');
niterations = 500;
%niterations = 0;
for j=1:niterations
    tic
    for i=1:ninterventions
        amInterventions.Offset(i) = floor(rand * max_offset);
    end
    initial_offsets = amInterventions.Offset;
    run_type = sprintf('Random Offset Start %d', j);
    [offsets, profile_pre, profile_post, histogram, qual] = amAlignCurves(amNormcube, amInterventions, measures, max_offset, align_wind, nmeasures, ninterventions, run_type, detaillog);
    fprintf('%s - ErrFcn = %7.4f\n', run_type, qual);
    if qual < best_qual
        % plot and save aligned curves (pre and post) if the result is best
        % so far
        amPlotAndSaveAlignedCurves(unaligned_profile, profile_post, offsets, qual, measures, max_offset, align_wind, nmeasures, run_type)
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

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('alignmentmodelresults-obj%d.mat', round(best_qual*10000));
fprintf('Saving alignment model results to file %s\n', outputfilename);
fprintf('\n');
save(fullfile(basedir, subfolder, outputfilename), 'best_initial_offsets', 'best_offsets', 'best_profile_pre', 'best_profile_post', 'unaligned_profile', 'best_histogram', 'best_qual');

ex_start = input('Look at best start and enter exacerbation start: ');
toc
fprintf('\n');

tic
% calculate overall lower and upper bound 75% confidence levels
fprintf('Calculate overall lower and upper bound 75%% confidence levels');
hstgorig = best_histogram;
hstgorig(isnan(hstgorig)) = 0;
agghstg = zeros(ninterventions, max_offset);
for j = 1:ninterventions
        agghstg(j,:) = sum(hstgorig(:, j, :),1);
        normconst = norm(reshape(agghstg(j, :),[1 max_offset]),inf);
        if normconst == 0
            normconst = 1;
        end
        agghstg(j,:) = agghstg(j,:) / normconst;
end
agghstg = 1 - agghstg;
agghstg = agghstg ./ sum(agghstg,2);

%probthreshold = 0.75;
% changed to 1s.d on normal distribution
probthreshold = 0.6827;
cumprob = 0;
for j = 1:ninterventions
    problower(j) = best_offsets(j);
    probupper(j) = best_offsets(j);
    for i = 0:max_offset - 1
        if best_offsets(j) + i >= max_offset
            probupper(j) = max_offset - 1;
        else
            probupper(j) = best_offsets(j) + i;
        end
        if best_offsets(j) - i <= 0
            problower(j) = 0;
        else
            problower(j) = best_offsets(j) - i;
        end
        cumprob = sum(agghstg(j,problower(j)+1:probupper(j)+1),2);
        if cumprob >= probthreshold
            fprintf('For intervention %2d: best_offset %2d 75%% confidence levels are lower = %2d upper = %2d\n', j, best_offsets(j), problower(j), probupper(j));
            break;
        end  
    end
end

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('alignmentmodelresults-obj%d.mat', round(best_qual*10000));
fprintf('Saving alignment model results to file %s\n', outputfilename);
fprintf('\n');
save(fullfile(basedir, subfolder, outputfilename), 'best_initial_offsets', 'best_offsets', 'best_profile_pre', 'best_profile_post', ...
    'unaligned_profile', 'best_histogram', 'best_qual', 'ex_start', 'agghstg', 'problower', 'probupper');


% do l_1 normalisation of the histogram to obtain posterior probabilities,
% person x feature fixed
for m=1:nmeasures
    for j=1:ninterventions
        best_histogram(m, j, :) = best_histogram(m, j, :) / norm(reshape(best_histogram(m, j, :),[1 max_offset]),inf);
    end
end
toc
fprintf('\n');

tic
fprintf('Plotting prediction results\n');
%for i=1:ninterventions
for i = 42:44
    amPlotsAndSavePredictions(amInterventions, amDatacube, measures, demographicstable, best_histogram, best_offsets, problower, probupper, ex_start, i, nmeasures, max_offset, align_wind);
    amPlotsAndSaveMeasuresVsMeanCurve(amInterventions, amNormcube, measures, demographicstable, best_profile_post, best_histogram, best_offsets, problower, probupper, ex_start, i, nmeasures, max_offset, align_wind)

end
toc
fprintf('\n');


