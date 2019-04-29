function [meancurvesumsq, meancurvesum, meancurvecount, meancurvemean, meancurvestd, amInterventions, initial_offsets, initial_latentcurve, ...
    animatedmeancurvemean, profile_pre, animatedoffsets, animatedlc, hstg, pdoffset, overall_hstg, overall_pdoffset, animated_overall_pdoffset, ...
    isOutlier, pptsstruct, qual, min_offset, iter, run_type] = ...
    amEMMCAlignCurves(amIntrCube, amHeldBackcube, amInterventions, outprior, measures, normstd, max_offset, align_wind, ...
    nmeasures, ninterventions, nlatentcurves, detaillog, sigmamethod, smoothingmethod, ...
    runmode, fnmodelrun)

% amEMMCAlignCurves - function to align measurement curves prior to
% intervention (allowing for multiple versions of the latent curves)

aniterations      = 2000;

meancurvesum      = zeros(nlatentcurves, max_offset + align_wind - 1, nmeasures);
meancurvesumsq    = zeros(nlatentcurves, max_offset + align_wind - 1, nmeasures);
meancurvecount    = zeros(nlatentcurves, max_offset + align_wind - 1, nmeasures);

hstg              = zeros(nlatentcurves, nmeasures, ninterventions, max_offset);
pdoffset          = zeros(nlatentcurves, nmeasures, ninterventions, max_offset);
overall_hstg      = zeros(nlatentcurves, ninterventions, max_offset);
overall_pdoffset  = zeros(nlatentcurves, ninterventions, max_offset);

animatedmeancurvemean      = zeros(nlatentcurves, max_offset + align_wind - 1, nmeasures, aniterations);
animated_overall_pdoffset  = zeros(nlatentcurves, ninterventions, max_offset, aniterations);
animatedoffsets            = zeros(ninterventions, aniterations);
animatedlc                 = zeros(ninterventions, aniterations);

isOutlier         = zeros(nlatentcurves, ninterventions, align_wind, nmeasures, max_offset);

min_offset     = 0; % start at zero and no longer changes as offset blocking was removed.
countthreshold = 5; % minimum number of undelying curves that must contribute to a point in the average curve

if runmode == 6
    % *** need to initialise amInterventions.LatentCurve and also change how ***
    % *** the pdoffset and overall pdoffset are initialised to include extra ***
    % *** dimension ***
    %run_type = 'Pre-selected Start';
    % save off amInterventions so it doesn't get overwritten
    %tempamintr = amInterventions;
    %load(fnmodelrun, 'overall_hist', 'amInterventions');
    %overall_hstg = overall_hist;
    %for i = 1:ninterventions
    %    overall_pdoffset(i,:) = convertFromLogSpaceAndNormalise(overall_hstg(i,:));
    %end
    %tempamintr.Offset = amInterventions.Offset;
    %tempamintr.LatentCurve = amInterventions.LatentCurve;
    %amInterventions = tempamintr;
elseif runmode == 7 || 8
    if runmode == 7 
        run_type = 'O-Uniform LC-FEV1Split';
        ntiles = nlatentcurves;
    else
        run_type = 'O-Uniform LC-Elec_ FEV1Split';
        ntiles = nlatentcurves - 1;
    end
    fprintf('Creating Upper and Lower 50%% splits for FEV1\n');
    fprintf('Loading Predictive Model Patient Measures Stats\n');
    basedir = setBaseDir();
    subfolder = 'MatlabSavedVariables';
    load(fullfile(basedir, subfolder, 'SCpredictivemodelinputs.mat'), 'pmPatientMeasStats');
    npmpatients = size(unique(pmPatientMeasStats.PatientNbr),1);
    mfev1idx  = measures.Index(ismember(measures.DisplayName, 'LungFunction'));
    fev1max  = pmPatientMeasStats(pmPatientMeasStats.MeasureIndex == mfev1idx, {'PatientNbr', 'Study', 'ID', 'RobustMax'});
    fev1max = sortrows(fev1max, {'RobustMax'}, 'ascend');
    fev1max.NTile(:) = 0;
    for i = 1:npmpatients
        fev1max.NTile(i) = ceil((i * ntiles)/ npmpatients);
    end
    fev1max = sortrows(fev1max, {'Study', 'ID'}, 'ascend');
    lc = innerjoin(amInterventions, fev1max, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'}, 'LeftVariables', {'SmartCareID'}, 'RightVariables', 'NTile');
    amInterventions.Offset(:) = 0;
    amInterventions.LatentCurve = lc.NTile;
    if runmode == 8
        fprintf('Loading Elective Treatment file\n');
        basedir = setBaseDir();
        pmElectiveTreatments = readtable(fullfile(basedir, 'DataFiles', 'SCelectivetreatments.xlsx'));
        pmElectiveTreatments.ElectiveTreatment(:) = 'Y';
        amInterventions = outerjoin(amInterventions, pmElectiveTreatments, 'LeftKeys', {'SmartCareID', 'Hospital', 'IVScaledDateNum'}, 'RightKeys', {'ID', 'Hospital', 'IVScaledDateNum'}, 'RightVariables', {'ElectiveTreatment'});
        amInterventions.LatentCurve(amInterventions.ElectiveTreatment == 'Y') = ntiles + 1;   
    end    
elseif runmode == 4 || runmode == 5    
    % populate pdoffset & overall_pdoffset with uniform prior distribution
    
    % *** need to initialise amInterventions.LatentCurve and also change how ***
    % *** the pdoffset and overall pdoffset are initialised to include extra ***
    % *** dimension ***
    run_type = 'O-Uniform LC-Random';
    amInterventions.Offset(:) = 0;
    amInterventions.LatentCurve(:) = randi([1, nlatentcurves], [ninterventions, 1]);
else
    fprintf('Unsupported runmode for this version of the alignment model\n');
    return;
end

for i = 1:ninterventions
    for m = 1:nmeasures
        pdoffset(amInterventions.LatentCurve(i), m, i, :) = amEMMCConvertFromLogSpaceAndNormalise(zeros(1, max_offset));
    end
    if runmode == 5
        overall_pdoffset(:, i, :) = 0;
        overall_pdoffset(amInterventions.LatentCurve(i), i, 1) = 1;
    else
        overall_pdoffset(amInterventions.LatentCurve(i), i,:) = amEMMCConvertFromLogSpaceAndNormalise(zeros(1, max_offset));
    end
end

initial_offsets = amInterventions.Offset;
initial_latentcurve = amInterventions.LatentCurve;

animated_overall_pdoffset(:, :, :, 1) = overall_pdoffset;

% calculate initial mean curve over all interventions & prior prob
% distribution for offsets
for i = 1:ninterventions
    [meancurvesumsq, meancurvesum, meancurvecount] = amEMMCAddToMean(meancurvesumsq, meancurvesum, meancurvecount, ...
        overall_pdoffset, amIntrCube, amHeldBackcube, i, min_offset, max_offset, align_wind, nmeasures, nlatentcurves);
end
[meancurvemean, meancurvestd] = amEMMCCalcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);

% store the mean curves pre-alignment for each measure for plotting
profile_pre = meancurvemean;

% iterate to convergence
pnt = 1;
cnt = 0;
iter = 0;
smmpddiff = 100;
pddiffthreshold = 0.00001;
maxiterations = 200;
prior_overall_pdoffset = overall_pdoffset;
miniiter = 0;

while (smmpddiff > pddiffthreshold && iter < maxiterations)
    ok = 1;
    
    % remove current curve from the sum, sumsq, count average curve arrays 
    % before doing bestfit alignment
    [meancurvesumsq, meancurvesum, meancurvecount] = amEMMCRemoveFromMean(meancurvesumsq, meancurvesum, meancurvecount, ...
        overall_pdoffset, amIntrCube, amHeldBackcube, pnt, min_offset, max_offset, align_wind, nmeasures, nlatentcurves);
    
    % find and keep track of points that have too few data points contributing 
    % to them 
    [pptsstruct] = amEMMCFindProblemDataPoints(meancurvesumsq, meancurvesum, meancurvecount, measures.Mask, ...
        min_offset, max_offset, align_wind, nmeasures, countthreshold, nlatentcurves);
    
    % add the adjustments to the various meancurve arrays 
    % and recalc mean and std arrays
    [meancurvesumsq, meancurvesum, meancurvecount] = amEMMCAddAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, pptsstruct, nlatentcurves);
    [meancurvemean, meancurvestd] = amEMMCCalcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);
     
    if ok == 1
        [better_offset, better_curve, hstg, pdoffset, overall_hstg, overall_pdoffset, isOutlier] = amEMMCBestFit(meancurvemean, meancurvestd, amIntrCube, amHeldBackcube, ...
            measures.Mask, measures.OverallRange, normstd, hstg, pdoffset, overall_hstg, overall_pdoffset, isOutlier, outprior, ...
            pnt, min_offset, max_offset, align_wind, nmeasures, sigmamethod, smoothingmethod, runmode, nlatentcurves);
    else
        better_offset = amInterventions.Offset(pnt);
        better_curve  = amInterventions.LatentCurve(pnt);
    end
    
    if better_offset ~= amInterventions.Offset(pnt) || better_curve ~= amInterventions.LatentCurve(pnt)
        if detaillog
            if better_offset ~= amInterventions.Offset(pnt)
                fprintf('amIntervention.Offset(%2d):      Updated from %2d to %2d\n', pnt, amInterventions.Offset(pnt), better_offset);
            end
            if better_curve ~= amInterventions.LatentCurve(pnt)
                fprintf('amIntervention.LatentCurve(%2d): Updated from %2d to %2d\n', pnt, amInterventions.LatentCurve(pnt), better_curve);
            end
        end
        amInterventions.Offset(pnt)      = better_offset;
        amInterventions.LatentCurve(pnt) = better_curve;
        cnt = cnt + 1;
        miniiter = miniiter+1;
        if miniiter < aniterations
            animatedmeancurvemean(:, :, :, miniiter)         = meancurvemean;
            animatedoffsets(:,miniiter)                      = amInterventions.Offset;
            animatedlc(:,miniiter)                           = amInterventions.LatentCurve;
            animated_overall_pdoffset(:, :, :, miniiter + 1) = overall_pdoffset;
        else
            fprintf('Exceeded storage for animated iterations\n');
        end
    end
    [meancurvesumsq, meancurvesum, meancurvecount] = amEMMCRemoveAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, pptsstruct, nlatentcurves);
    [meancurvesumsq, meancurvesum, meancurvecount] = amEMMCAddToMean(meancurvesumsq, meancurvesum, meancurvecount, ...
        overall_pdoffset, amIntrCube, amHeldBackcube, pnt, min_offset, max_offset, align_wind, nmeasures, nlatentcurves);
    [meancurvemean, meancurvestd] = amEMMCCalcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);
    
    pnt = pnt+1;
    if pnt > ninterventions
        iter = iter + 1;
        pnt = pnt - ninterventions;
        miniiter = miniiter+1;
        if miniiter < aniterations
            animatedmeancurvemean(:, :, :, miniiter)         = meancurvemean;
            animatedoffsets(:,miniiter)                      = amInterventions.Offset;
            animatedlc(:,miniiter)                           = amInterventions.LatentCurve;
            animated_overall_pdoffset(:, :, :, miniiter + 1) = overall_pdoffset;
        else
            fprintf('Exceeded storage for animated iterations\n');
        end
        
        [smmpddiff, ssspddiff] = amEMMCCalcDiffOverallPD(overall_pdoffset, prior_overall_pdoffset);
        % compute the overall objective function each time we've iterated
        % through the full set of interventions
        % ** don't update the histogram here to avoid double counting on the best
        % offset day **
        update_histogram = 0;
        qual = 0;
        qualcount = 0;
        for i=1:ninterventions
            [meancurvesumsq, meancurvesum, meancurvecount] = amEMMCRemoveFromMean(meancurvesumsq, meancurvesum, meancurvecount, ...
                overall_pdoffset, amIntrCube, amHeldBackcube, i, min_offset, max_offset, align_wind, nmeasures, nlatentcurves);
            [meancurvesumsq, meancurvesum, meancurvecount] = amEMMCAddAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, pptsstruct, nlatentcurves);
            [meancurvemean, meancurvestd] = amEMMCCalcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);
            
            lc = amInterventions.LatentCurve(i);
            [iqual, icount] = amEMMCCalcObjFcn(meancurvemean(lc, :, :), meancurvestd(lc, :, :), amIntrCube, amHeldBackcube, ...
                isOutlier(lc, :, :, :, :), outprior, measures.Mask, measures.OverallRange, normstd, hstg(lc, :, :, :), i, ...
                amInterventions.Offset(i), max_offset, align_wind, nmeasures, update_histogram, sigmamethod, smoothingmethod);
            
            qual = qual + iqual;
            qualcount = qualcount + icount;
            
            %fprintf('Intervention %d, qual = %.4f\n', i, qual/qualcount);
    
            [meancurvesumsq, meancurvesum, meancurvecount] = amEMMCRemoveAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, pptsstruct, nlatentcurves);
            [meancurvesumsq, meancurvesum, meancurvecount] = amEMMCAddToMean(meancurvesumsq, meancurvesum, meancurvecount, ...
                overall_pdoffset, amIntrCube, amHeldBackcube, i, min_offset, max_offset, align_wind, nmeasures, nlatentcurves);
            [meancurvemean, meancurvestd] = amEMMCCalcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);
        end
        
        qual = qual / qualcount;
        
        if cnt == 0
            fprintf('No changes on iteration %2d, obj fcn = %.8f, prob distrib diff: smm = %.6f sss = %.6f\n', iter, qual, smmpddiff, ssspddiff);
        else
            fprintf('Changed %2d offsets on iteration %2d, obj fcn = %.8f, prob distrib diff: smm = %.6f sss = %.6f\n', cnt, iter, qual, smmpddiff, ssspddiff);
        end
        cnt = 0;
        prior_overall_pdoffset = overall_pdoffset;
        
        %temp = input('Continue ? ');
    end
end

[meancurvesumsq, meancurvesum, meancurvecount] = amEMMCAddAdjacentAdjustments(meancurvesumsq, meancurvesum, meancurvecount, pptsstruct, nlatentcurves);
[meancurvemean, meancurvestd] = amEMMCCalcMeanAndStd(meancurvesumsq, meancurvesum, meancurvecount, min_offset, max_offset, align_wind);

end

