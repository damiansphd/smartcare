clear; close all; clc;

version = 'v4c';

fprintf('Running Alignment Model %s\n', version);
fprintf('\n');

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
mumethod = input('Choose methodology (1-2) ');
fprintf('\n');
if mumethod > 3
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


fprintf('Methodology for smoothing method of curve averaging\n');
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
fprintf('2: Enable offset blocking (DO NOT USE)\n');
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

fprintf('Mode for number of starts\n');
fprintf('--------------------------------------------\n');
fprintf('1: Just zero offset start\n');
fprintf('2: Zero offset + 250 Random starts\n');
fprintf('3: Zero offset + 500 Random starts\n');
runmode = input('Choose mode (1-3) ');
fprintf('\n');
if runmode > 3
    fprintf('Invalid choice\n');
    return;
end
if isequal(runmode,'')
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
fprintf('Loading alignment model Inputs data\n');
load(fullfile(basedir, subfolder, modelinputsmatfile));
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, datademographicsfile));
toc

detaillog = true;
max_offset = 25; % should not be greater than ex_start (set lower down) as this implies intervention before exacerbation !
align_wind = 25;
baseplotname = sprintf('%s_AM%s_sig%d_mu%d_ca%d_sm%d_rm%d_ob%d_mm%d_mo%d_dw%d', study, version, sigmamethod, mumethod, curveaveragingmethod, ...
    smoothingmethod, runmode, offsetblockingmethod, measuresmask, max_offset, align_wind);

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
measures.Index = [1:nmeasures]';

% set the measures mask depending on option chosen
if measuresmask == 1
    %measures.Mask(:) = 1;
    idx = ~ismember(measures.DisplayName, {'Activity'});
    measures.Mask(idx) = 1;
elseif measuresmask == 2
    idx = ismember(measures.DisplayName, {'Cough', 'LungFunction', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 3
    %measures.Mask(:) = 1;
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

% populate multiplicative normalisation (sigma) values based on methodology
% selected
normstd = zeros(ninterventions, nmeasures);
for i = 1:ninterventions
    for m = 1:nmeasures
        if sigmamethod == 1
            normstd(i,m) = measures.AlignWindStd(m);
        elseif sigmamethod == 2
            normstd(i,m) = measures.OverallStd(m);
        elseif sigmamethod == 3
            scid = amInterventions.SmartCareID(i);
            column = getColumnForMeasure(measures.Name{m});
            ddcolumn = sprintf('Fun_%s',column);
            if size(find(demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m})),1) == 0
                fprintf('Could not find std for patient %d and measure %d so using overall std for measure instead\n', scid, m);
                normstd(i,m) = measures.OverallStd(m);
            else
                normstd(i,m) = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(2);
            end
        else 
            % for methodology 4, need to calculate dynamically during
            % the alignment process 0 - so leave normstd as zeros for now
        end
    end
end

% adjust by additive normalisation (mu) based on methodology
normmean = zeros(ninterventions, nmeasures);
amIntrNormcube = amIntrDatacube;
for i = 1:ninterventions
    if mumethod == 1
        meanwindow = 8;
    elseif mumethod == 2
        meanwindow = 20;
    else
        meanwindow = 10;
    end
    scid   = amInterventions.SmartCareID(i);
    start = amInterventions.IVScaledDateNum(i);
    if (start - align_wind - meanwindow) <= 0
        meanwindow = start - align_wind - 1;
    end
    for m = 1:nmeasures
        meanwindowdata = amDatacube(scid, (start - align_wind - meanwindow): (start - 1 - align_wind), m);
        meanwindowdata = sort(meanwindowdata(~isnan(meanwindowdata)), 'ascend');
        if size(meanwindowdata,2) >= 3
            if mumethod == 1
                % take mean of mean window (8 days prior to data window -
                % as long as there are 3 or more data points in the window
                normmean(i, m) = mean(meanwindowdata);
            elseif mumethod == 2
                % upper quartile mean of mean window method
                percentile75 = round(size(meanwindowdata,2) * .75) + 1;
                normmean(i, m) = mean(meanwindowdata(percentile75:end));
            else
                % exclude bottom quartile from mean method
                percentile25 = round(size(meanwindowdata,2) * .25) + 1;
                normmean(i, m) = mean(meanwindowdata(percentile25:end));
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
                normmean(i,m) = 0;
            end
        end
        %periodstart = start - align_wind - max_offset;
        %if periodstart <= 0
        %    periodstart = 1;
        %end
        amIntrNormcube(i, 1:(max_offset + align_wind -1), m) = amIntrDatacube(i, 1:(max_offset + align_wind -1), m) - normmean(i,m);
    end
end
toc
fprintf('\n');



tic
fprintf('Running alignment with zero offset start\n');
for i=1:size(amInterventions,1)
        amInterventions.Offset(i) = 0;
end
initial_offsets = amInterventions.Offset;

run_type = 'Zero Offset Start';
[meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd, animatedmeancurvemean, profile_pre, ...
    offsets, animatedoffsets, hstg, ppts, qual, min_offset] = am4AlignCurves(amIntrNormcube, amInterventions, measures, normstd, ...
    max_offset, align_wind, nmeasures, ninterventions, detaillog, sigmamethod, smoothingmethod, offsetblockingmethod);
fprintf('%s - ErrFcn = %7.4f\n', run_type, qual);

% save the zero offset pre-profile to unaligned_profile so all plots show a
% consistent unaligned curve as the pre-profile.
unaligned_profile = profile_pre;

plotname = sprintf('%s_obj%.4f', baseplotname, qual);

% plot and save aligned curves (pre and post)
am4PlotAndSaveAlignedCurves(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, offsets, ...
    measures, 0, min_offset, max_offset, align_wind, nmeasures, run_type, plotname, 0, sigmamethod);
toc
fprintf('\n');

%return;

fprintf('Running alignment with random offset start\n');
if runmode == 3
    niterations = 500;
elseif runmode == 2
    niterations = 250;
else
    niterations = 0;
end

for j=1:niterations
    tic
    for i=1:ninterventions
        amInterventions.Offset(i) = floor(rand * max_offset);
    end
    temp_initial_offsets = amInterventions.Offset;
    run_type = sprintf('Random Offset Start %d', j);
    [temp_meancurvesumsq, temp_meancurvesum, temp_meancurvecount, temp_meancurvemean, temp_meancurvestd, temp_animatedmeancurvemean, temp_profile_pre, ...
        temp_offsets, temp_animatedoffsets, temp_hstg, temp_ppts, temp_qual, temp_min_offset] = am4AlignCurves(amIntrNormcube, amInterventions, measures, normstd, ...
        max_offset, align_wind, nmeasures, ninterventions, detaillog, sigmamethod, smoothingmethod, offsetblockingmethod);

    fprintf('%s - ErrFcn = %7.4f\n', run_type, temp_qual);

    if temp_qual < qual
        % plot and save aligned curves (pre and post) if the result is best
        % so far
        plotname = sprintf('%s_obj%.4f', baseplotname, temp_qual);
        am4PlotAndSaveAlignedCurves(unaligned_profile, temp_meancurvemean, temp_meancurvecount, temp_meancurvestd, ...
            temp_offsets, measures, 0, temp_min_offset, max_offset, align_wind, nmeasures, run_type, plotname, 0, sigmamethod);
        fprintf('Best so far is random start %d\n', j);
        offsets = temp_offsets;
        initial_offsets = temp_initial_offsets;
        profile_pre = temp_profile_pre;
        hstg = temp_hstg;
        ppts = temp_ppts;
        qual = temp_qual;
        min_offset = temp_min_offset;
        meancurvesumsq = temp_meancurvesumsq;
        meancurvesum = temp_meancurvesum;
        meancurvecount = temp_meancurvecount;
        meancurvemean = temp_meancurvemean;
        meancurvestd = temp_meancurvestd;
        animatedmeancurvemean = temp_animatedmeancurvemean;
        animatedoffsets = temp_animatedoffsets;
    end
    toc
end
fprintf('\n');

ex_start = input('Look at best start and enter exacerbation start: ');
fprintf('\n');

tic
run_type = 'Best Alignment';

amInterventions.Offset = offsets;

plotname = sprintf('%s_ex%d_obj%.4f', baseplotname, ex_start, qual);

[sorted_interventions, max_points] = am4VisualiseAlignmentDetail(amIntrNormcube, amInterventions, meancurvemean, ...
    meancurvecount, meancurvestd, offsets, measures, min_offset, max_offset, align_wind, nmeasures, run_type, ...
    study, ex_start, version, curveaveragingmethod);

am4PlotAndSaveAlignedCurves(unaligned_profile, meancurvemean, meancurvecount, meancurvestd, offsets, ...
    measures, max_points, min_offset, max_offset, align_wind, nmeasures, run_type, plotname, ex_start, sigmamethod);

% create overall histogram (summed over measures by intervention/offset)
pdoffset        = zeros(nmeasures, ninterventions, max_offset);
overall_hist         = zeros(ninterventions, max_offset);
overall_hist_all     = zeros(ninterventions, max_offset);
overall_hist_xAL     = zeros(ninterventions, max_offset);
overall_pdoffset     = zeros(ninterventions, max_offset);
overall_pdoffset_all = zeros(ninterventions, max_offset);
overall_pdoffset_xAL = zeros(ninterventions, max_offset);
fitmeasure = zeros(nmeasures, ninterventions);

for j = 1:ninterventions
    overall_hist(j, :)     = reshape(sum(hstg(find(measures.Mask),j,:),1), [1, max_offset]);
    overall_hist_all(j, :) = reshape(sum(hstg(:,j,:),1), [1, max_offset]);
    overall_hist_xAL(j, :) = reshape(sum(hstg(~ismember(measures.DisplayName, {'Activity', 'LungFunction'}),j,:),1), [1, max_offset]);
end

% convert back from log space
for j=1:ninterventions
    for m=1:nmeasures
        pdoffset(m, j, min_offset+1:max_offset) = convertFromLogSpaceAndNormalise(hstg(m, j, min_offset+1:max_offset));
    end
    overall_pdoffset(j, min_offset+1:max_offset)      = convertFromLogSpaceAndNormalise(overall_hist(j, min_offset+1:max_offset));
    overall_pdoffset_all(j, min_offset+1:max_offset)  = convertFromLogSpaceAndNormalise(overall_hist_all(j, min_offset+1:max_offset));
    overall_pdoffset_xAL(j, min_offset+1:max_offset)  = convertFromLogSpaceAndNormalise(overall_hist_xAL(j, min_offset+1:max_offset));
end

toc
fprintf('\n');

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%s_ex%d_obj%.4f.mat', baseplotname, ex_start, qual);
fprintf('Saving alignment model results to file %s\n', outputfilename);
fprintf('\n');   
save(fullfile(basedir, subfolder, outputfilename), 'amDatacube', 'amIntrDatacube', 'amIntrNormcube', 'amInterventions', ...
    'meancurvesumsq', 'meancurvesum', 'meancurvecount', 'meancurvemean', 'meancurvestd', 'animatedmeancurvemean', ...
    'initial_offsets', 'offsets', 'animatedoffsets', 'qual', 'unaligned_profile', 'hstg', 'pdoffset', ...
    'overall_hist', 'overall_hist_all', 'overall_hist_xAL', 'ppts', ...
    'overall_pdoffset', 'overall_pdoffset_all', 'overall_pdoffset_xAL', ...
    'sorted_interventions', 'normmean', 'normstd', 'measures', 'study', 'version', ...
    'min_offset', 'max_offset', 'align_wind', 'ex_start', ...
    'sigmamethod', 'mumethod', 'curveaveragingmethod', 'smoothingmethod', 'offsetblockingmethod', ...
    'measuresmask', 'runmode', 'printpredictions', 'nmeasures', 'ninterventions');
toc
fprintf('\n');

if printpredictions == 1
    tic
    fprintf('Plotting prediction results\n');
    for i=1:ninterventions
        am4PlotsAndSavePredictions(amInterventions, amIntrDatacube, measures, pdoffset, overall_pdoffset, overall_pdoffset_all, overall_pdoffset_xAL, ...
            hstg, overall_hist, overall_hist_all, overall_hist_xAL, offsets, meancurvemean, normmean, ex_start, i, nmeasures, max_offset, align_wind, study, version);
    end
    toc
    fprintf('\n');
end

