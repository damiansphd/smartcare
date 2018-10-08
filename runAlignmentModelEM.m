clear; close all; clc;

version = 'vEM2';

fprintf('Running Alignment Model %s\n', version);
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

fprintf('Methodology for multiplicative normalisation (sigma)\n');
fprintf('----------------------------------------------------\n');
fprintf('1: Std for Data Window across interventions by measure\n');
fprintf('2: Std across all data by measure\n');
fprintf('3: Std across all data by patient and measure\n');
fprintf('4: Std for each data point in the average curve\n');
sigmamethod = input('Choose methodology (1-4) ');
fprintf('\n');
if sigmamethod > 4
    fprintf('Invalid choice\n');
    return;
end
if isequal(sigmamethod,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('Methodology for additive normalisation (mu)\n');
fprintf('-------------------------------------------\n');
fprintf('1: Mean for 8 days prior to data window\n');
fprintf('2: Upper Quartile Mean for 20 days prior to data window\n');
fprintf('3: Exclude bottom quartile from Mean for 10 days prior to data window\n');
fprintf('4: Exclude bottom quartile and data outliers from Mean for 10 days prior to data window\n');
fprintf('5: same as 4) but for sequential interventions and not enough data points in mean window, use upper 50%% mean over all patient data\n');
mumethod = input('Choose methodology (1-5) ');
fprintf('\n');
if mumethod > 5
    fprintf('Invalid choice\n');
    return;
end
if isequal(mumethod,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('Methodology for duration of curve averaging\n');
fprintf('-------------------------------------------\n');
fprintf('1: Just data window (DO NOT USE)\n');
fprintf('2: Data window + data to the left\n');
curveaveragingmethod = input('Choose methodology (1-2) ');
fprintf('\n');
if curveaveragingmethod > 2
    fprintf('Invalid choice\n');
    return;
end
if isequal(curveaveragingmethod,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('Methodology for smoothing method during curve alignment\n');
fprintf('---------------------------------------------------\n');
fprintf('1: Raw data\n');
fprintf('2: Smoothed data (5 days)\n');
smoothingmethod = input('Choose methodology (1-2) ');
fprintf('\n');
if smoothingmethod > 2
    fprintf('Invalid choice\n');
    return;
end
if isequal(smoothingmethod,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('Methodology for offset blocking\n');
fprintf('-------------------------------\n');
fprintf('1: Disable offset blocking\n');
fprintf('2: Enable offset blocking ppts (DO NOT USE)\n');
offsetblockingmethod = input('Choose methodology (1-2) ');
fprintf('\n');
if offsetblockingmethod > 2
    fprintf('Invalid choice\n');
    return;
end
if isequal(offsetblockingmethod,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('Measures to include in alignment calculation\n');
fprintf('--------------------------------------------\n');
%fprintf('1: All\n');
fprintf('1: All exceot Activity\n');
fprintf('2: Cough, Lung Function, Wellness\n');
fprintf('3: All except Activity and Lung Function\n');
measuresmask = input('Choose measures (1-3) ');
fprintf('\n');
if measuresmask > 3
    fprintf('Invalid choice\n');
    return;
end
if isequal(measuresmask,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('Methodology for EM alignment\n');
fprintf('----------------------------\n');
fprintf('4: Uniform start, use prob distribution in alignment\n');
fprintf('5: Uniform start, use point mass of offset in alignment\n');
fprintf('6: Pick start state from other model runs\n');
runmode = input('Choose methodology (1-2) ');
fprintf('\n');
if runmode < 4 || runmode > 6
    fprintf('Invalid choice\n');
    return;
end
if isequal(runmode,'')
    fprintf('Invalid choice\n');
    return;
end

if runmode == 6
    modelrun = selectModelRunFromList('pd');
else
    modelrun = '';
end

fprintf('Run imputation ?\n');
fprintf('----------------------------\n');
fprintf('1: No\n');
fprintf('2: Yes - with 1%% of data points held back\n');
imputationmode = input('Choose run mode(1-2) ');
fprintf('\n');
if imputationmode > 2
    fprintf('Invalid choice\n');
    return;
end
if isequal(imputationmode,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('\n');
printpredictions = input('Print predictions (1=Yes, 2=No) ? ');
if printpredictions > 2
    fprintf('Invalid choice\n');
    return;
end
if isequal(printpredictions,'')
    fprintf('Invalid choice\n');
    return;
end

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
fnmodelrun = fullfile(basedir, subfolder, sprintf('%s.mat',modelrun));
fprintf('Loading alignment model Inputs data\n');
load(fullfile(basedir, subfolder, modelinputsmatfile));
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, datademographicsfile));
fprintf('Loading data outliers\n');
load(fullfile(basedir, subfolder, dataoutliersfile));
toc

tic
fprintf('Preparing input data\n');

detaillog = true;
max_offset = 25; % should not be greater than ex_start (set lower down) as this implies intervention before exacerbation !
align_wind = 25;
% define prior probability of a data point being an outlier
outprior = 0.01;
baseplotname = sprintf('%s_AM%s_sig%d_mu%d_ca%d_sm%d_rm%d_ob%d_im%d_mm%d_mo%d_dw%d', study, version, sigmamethod, mumethod, curveaveragingmethod, ...
    smoothingmethod, runmode, offsetblockingmethod, imputationmode, measuresmask, max_offset, align_wind);

% set the measures mask depending on option chosen
if measuresmask == 1
    %measures.Mask(:) = 1;
    idx = ~ismember(measures.DisplayName, {'Activity'});
    measures.Mask(idx) = 1;
elseif measuresmask == 2
    idx = ismember(measures.DisplayName, {'Cough', 'LungFunction', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 3
    idx = ~ismember(measures.DisplayName, {'Activity', 'LungFunction'});
    measures.Mask(idx) = 1;
else
    % shouldn't ever get here - but default to just cough if it ever
    % happens
    idx = ismember(measures.DisplayName, {'Cough'});
end

% create cube for data window data by intervention (for each measure)
amIntrDatacube = NaN(ninterventions, max_offset + align_wind - 1, nmeasures);
for i = 1:ninterventions
    scid   = amInterventions.SmartCareID(i);
    start = amInterventions.IVScaledDateNum(i);
    
    icperiodend = align_wind + max_offset -1;
    dcperiodend = start - 1;
    
    if curveaveragingmethod == 1
        icperiodstart = align_wind;
        dcperiodstart = start - align_wind;
    else
        icperiodstart = 1;
        dcperiodstart = start - (align_wind + max_offset - 1);
    end
    
    if dcperiodstart <= 0
        icperiodstart = icperiodstart - dcperiodstart + 1;
        dcperiodstart = 1;
    end
    
    for m = 1:nmeasures
        amIntrDatacube(i, (icperiodstart:icperiodend), m) = amDatacube(scid, dcperiodstart:dcperiodend, m);
    end
end

% add columns for Data Window Completeness and Flag for Sequential
% Intervention to amInterventions table
for i = 1:ninterventions
    scid = amInterventions.SmartCareID(i);
    actualpoints = 0;
    maxpoints = 0;
    for m = 1:nmeasures
        if (measures.Mask(m) == 1)
            actualpoints = actualpoints + sum(~isnan(amIntrDatacube(i, max_offset:max_offset+align_wind-1, m)));
            maxpoints = maxpoints + align_wind;
        end
    end
    amInterventions.DataWindowCompleteness(i) = 100 * actualpoints/maxpoints;
    if i >= 2
        if (amInterventions.SmartCareID(i) == amInterventions.SmartCareID(i-1) ...
                && amInterventions.IVDateNum(i) - amInterventions.IVDateNum(i-1) < 50)
            amInterventions.SequentialIntervention(i) = 'Y';
        end
    end
end

% remove any interventions where the start is less than the alignment
% window
%idx = find(amInterventions.IVScaledDateNum <= align_wind);
%amInterventions(idx,:) = [];
%amIntrDatacube(idx,:,:) = [];
%ninterventions = size(amInterventions,1);

% remove temperature readings as insufficient datapoints for a number of
% the interventions
idx = ismember(measures.DisplayName, {'Temperature'});
amDatacube(:,:,measures.Index(idx)) = [];
measures(idx,:) = [];
nmeasures = size(measures,1);
measures.Index = [1:nmeasures]';

% calculate the overall & alignment window std for each measure and store in measures
% table. Also the overall min, max and range values by measure (across all
% patients and days)
for m = 1:nmeasures
    %tempdata = zeros(ninterventions * align_wind, 1);
    tempdata = 0;
    for i = 1:ninterventions
        scid   = amInterventions.SmartCareID(i);
        start = amInterventions.IVScaledDateNum(i);
        periodstart = start - align_wind;
        if periodstart < 1
            periodstart = 1;
        end
        tempdata = [tempdata; reshape(amDatacube(scid, periodstart:(start - 1), m), start - periodstart, 1)];  
        %tempdata( ((i-1) * align_wind) + 1 : (i * align_wind) ) = reshape(amDatacube(scid, (start - align_wind):(start - 1), m), align_wind, 1);
    end
    tempdata(1) = [];
    
    measures.AlignWindStd(m) = std(tempdata(~isnan(tempdata)));
    tempdata = reshape(amDatacube(:, :, m), npatients * ndays, 1);
    measures.OverallStd(m) = std(tempdata(~isnan(tempdata)));
    [measures.OverallMin(m), measures.OverallMax(m)] = getMeasureOverallMinMax(demographicstable, measures.Name{m});
    measures.OverallRange(m) = measures.OverallMax(m) - measures.OverallMin(m);
end

% populate multiplicative normalisation (sigma) values based on methodology
% selected
normstd = calculateSigmaNormalisation(amInterventions, measures, demographicstable, ninterventions, nmeasures, sigmamethod);

% calculate additive normalisation (mu) based on methodology
% and then create normalised data cube.

normmean = calculateMuNormalisation(amDatacube, amInterventions, measures, demographicstable, ...
    dataoutliers, align_wind, ninterventions, nmeasures, mumethod);

% populate normalised data cube by intervention
% for sigma methods 1, 2, & 3 just normalise by mu (as the sigma is
% constant for a given intervention/measure and is incorporated in the
% model objective function
% for sigma methos 4, need to normalise by mu and sigma here as the model
% is using a by day/measure sigma.
amIntrNormcube = amIntrDatacube;
for i = 1:ninterventions
    for m = 1:nmeasures
        if sigmamethod == 4
            amIntrNormcube(i, 1:(max_offset + align_wind -1), m) = ...
                (amIntrDatacube(i, 1:(max_offset + align_wind -1), m) - normmean(i, m)) / normstd(i, m);
        else 
            amIntrNormcube(i, 1:(max_offset + align_wind -1), m) = ...
                (amIntrDatacube(i, 1:(max_offset + align_wind -1), m) - normmean(i, m));
        end
    end
end

amHeldBackcube = zeros(ninterventions, max_offset + align_wind - 1, nmeasures);
if imputationmode ==2
    heldbackpct = 0.01;
    for i = 1:ninterventions
        for d = max_offset:max_offset + align_wind -1
            for m = 1:nmeasures
                if ~isnan(amIntrDatacube(i, d, m))
                    holdback = rand;
                    if holdback <= heldbackpct
                        amHeldBackcube(i, d, m) = 1;
                    end
                end
            end
        end
    end
end

toc
fprintf('\n');

tic
fprintf('Running alignment\n');
% should really move this into AlignCurves function or override with value
% loaded in there
for i=1:size(amInterventions,1)
        amInterventions.Offset(i) = 0;
end
initial_offsets = amInterventions.Offset;

if runmode == 6
    run_type = 'Pre-selected Start';
else
    run_type = 'Uniform Start';
end
[meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd, animatedmeancurvemean, profile_pre, ...
    offsets, animatedoffsets, hstg, pdoffset, overall_hist, overall_pdoffset, animated_overall_pdoffset, ...
    isOutlier, ppts, qual, min_offset] = amEMAlignCurves(amIntrNormcube, amHeldBackcube, amInterventions, outprior, measures, ...
    normstd, max_offset, align_wind, nmeasures, ninterventions, detaillog, sigmamethod, smoothingmethod, offsetblockingmethod, runmode, fnmodelrun);
fprintf('%s - ErrFcn = %7.4f\n', run_type, qual);

% save the zero offset pre-profile to unaligned_profile so all plots show a
% consistent unaligned curve as the pre-profile.
unaligned_profile = profile_pre;

plotname = sprintf('%s_obj%.4f', baseplotname, qual);

% plot and save aligned curves (pre and post)
amEMPlotAndSaveAlignedCurves(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, offsets, ...
    measures, 0, min_offset, max_offset, align_wind, nmeasures, run_type, plotname, 0, sigmamethod);

toc
fprintf('\n');

%return;

ex_start = input('Look at best start and enter exacerbation start: ');
fprintf('\n');

tic
run_type = 'Best Alignment';

amInterventions.Offset = offsets;

plotname = sprintf('%s_ex%d_obj%.4f', baseplotname, ex_start, qual);

[sorted_interventions, max_points] = amEMVisualiseAlignmentDetail(amIntrNormcube, amHeldBackcube, amInterventions, meancurvemean, ...
    meancurvecount, meancurvestd, overall_pdoffset, offsets, measures, min_offset, max_offset, align_wind, nmeasures, run_type, ...
    study, ex_start, version, curveaveragingmethod);

amEMPlotAndSaveAlignedCurves(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, offsets, ...
    measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, plotname, ex_start, sigmamethod);

% create additional overall histograms and prob distributions
overall_hist_all = zeros(ninterventions, max_offset);
overall_hist_xAL = zeros(ninterventions, max_offset);
overall_pdoffset_all = zeros(ninterventions, max_offset);
overall_pdoffset_xAL = zeros(ninterventions, max_offset);
fitmeasure = zeros(nmeasures, ninterventions);

for j = 1:ninterventions
    overall_hist_all(j, :) = reshape(sum(hstg(:,j,:),1), [1, max_offset]);
    overall_hist_xAL(j, :) = reshape(sum(hstg(~ismember(measures.DisplayName, {'Activity', 'LungFunction'}),j,:),1), [1, max_offset]);
end

% convert back from log space
for j=1:ninterventions
    overall_pdoffset_all(j, min_offset+1:max_offset)  = convertFromLogSpaceAndNormalise(overall_hist_all(j, min_offset+1:max_offset));
    overall_pdoffset_xAL(j, min_offset+1:max_offset)  = convertFromLogSpaceAndNormalise(overall_hist_xAL(j, min_offset+1:max_offset));
end

totaloutliers = 0;
totalpoints = 0;
for i = 1:ninterventions
       totaloutliers = totaloutliers + sum(sum(isOutlier(i, :, :, offsets(i) + 1)));
       totalpoints   = totalpoints + sum(sum(~isnan(amIntrDatacube(i, max_offset:max_offset + align_wind -1, :))));
end

totalpoints = totalpoints - sum(sum(sum(amHeldBackcube)));

[amImputedCube] = calcImputedProbabilities(amIntrNormcube, amHeldBackcube, ...
    meancurvemean, meancurvestd, normstd, overall_pdoffset, max_offset, align_wind, ...
    nmeasures, ninterventions,sigmamethod, smoothingmethod, imputationmode);

toc
fprintf('\n');

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%s_ex%d_obj%.4f.mat', baseplotname, ex_start, qual);
fprintf('Saving alignment model results to file %s\n', outputfilename);
fprintf('\n');
save(fullfile(basedir, subfolder, outputfilename), 'amDatacube', 'amIntrDatacube', 'amIntrNormcube', 'amHeldBackcube', ...
    'amImputedCube', 'amInterventions', ...
    'meancurvesumsq', 'meancurvesum', 'meancurvecount', 'meancurvemean', 'meancurvestd', 'animatedmeancurvemean', ...
    'initial_offsets', 'offsets', 'animatedoffsets', 'qual', 'unaligned_profile', 'hstg', 'pdoffset', ...
    'overall_hist', 'overall_hist_all', 'overall_hist_xAL', 'ppts', 'isOutlier', 'outprior', 'totaloutliers', 'totalpoints', ...
    'overall_pdoffset', 'overall_pdoffset_all', 'overall_pdoffset_xAL', 'animated_overall_pdoffset', ...
    'sorted_interventions', 'normmean', 'normstd', 'measures', 'study', 'version', ...
    'min_offset', 'max_offset', 'align_wind', 'ex_start', ...
    'sigmamethod', 'mumethod', 'curveaveragingmethod', 'smoothingmethod', 'offsetblockingmethod', ...
    'measuresmask', 'runmode', 'imputationmode', 'printpredictions', 'nmeasures', 'ninterventions');
toc
fprintf('\n');

if printpredictions == 1
    tic
    fprintf('Plotting prediction results\n');
    for i=1:ninterventions
        amEMPlotsAndSavePredictions(amInterventions, amIntrDatacube, amHeldBackcube, measures, pdoffset, overall_pdoffset, ...
            overall_pdoffset_all, overall_pdoffset_xAL, hstg, overall_hist, overall_hist_all, overall_hist_xAL, offsets, ...
            meancurvemean, normmean, normstd, isOutlier, ex_start, i, nmeasures, max_offset, align_wind, study, version);
    end
    toc
    fprintf('\n');
end




