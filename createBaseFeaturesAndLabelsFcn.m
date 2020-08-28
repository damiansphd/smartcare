function [pmFeatureIndex, pmMuIndex, pmSigmaIndex, pmRawMeasFeats, pmMSFeats, pmBuckMeasFeats, pmRangeFeats, pmVolFeats, ...
        pmAvgSegFeats, pmVolSegFeats, pmCChangeFeats, pmPMeanFeats, pmPStdFeats, ...
        pmBuckPMeanFeats, pmBuckPStdFeats, pmDateFeats, pmDemoFeats, ...
        pmIVLabels, pmABLabels, pmExLabels, pmExLBLabels, pmExABLabels, pmExABxElLabels] = ...
    createBaseFeaturesAndLabelsFcn(pmPatients, pmAntibiotics, pmAMPred, ...
            pmDatacube, pmInterpVolcube, pmInterpSegVolcube, ...
            pmInterpRangecube, pmInterpSegAvgcube, pmBucketedcube, pmMSDatacube, ...
            pmMuNormcube, pmSigmaNormcube, pmBuckMuNormcube, pmBuckSigmaNormcube, ...
            pmMucube, pmSigmacube, ...
            measures, nmeasures, npatients, maxdays, ...
            maxfeatureduration, maxnormwindow, basefeatparamsrow)
 
% createBaseFeaturesAndLabelsFcn - function to create the base sets of features and
% labels for each example in the overall data set - for all measures for a given 
% feature duration, normalisation method and smoothing method.

% first calculate total number of examples (patients * run days) to
% pre-allocate tables/arrays
nexamples = 0;
for p = 1:npatients
    pabs = pmAntibiotics(pmAntibiotics.PatientNbr == p, :);
    pampred = pmAMPred(pmAMPred.PatientNbr == p, :);
    for d = (maxfeatureduration + maxnormwindow):maxdays
        %if d <= (pmPatients.LastMeasdn(p) - pmPatients.FirstMeasdn(p) + 1) && ...
        %   (~any(pabs.StartDate <= pmPatients.FirstMeasDate(p) + days(d - 1) & ...
        %         pabs.StopDate  >= pmPatients.FirstMeasDate(p) + days(d - 1)))
        if d <= (pmPatients.LastMeasdn(p) - pmPatients.FirstMeasdn(p) + 1) && ...
           (~any(pabs.RelStartdn         <= d & pabs.RelStopdn              >= d)) && ...
           (~any(pampred.IVScaledDateNum <= d & pampred.IVScaledStopDateNum >= d))
            nexamples = nexamples + 1;
        end
    end
end

% set various variables
[featureduration, predictionduration, datefeat, nbuckets, navgseg, nvolseg, nbuckpmeas, ...
          nrawfeatures, nmsfeatures, nbucketfeatures, nrangefeatures, nvolfeatures, navgsegfeatures, ...
          nvolsegfeatures, ncchangefeatures, npmeanfeatures, npstdfeatures, ...
          nbuckpmeanfeatures, nbuckpstdfeatures, ndatefeatures, ndemofeatures] = ...
            setBaseNumMeasAndFeatures(basefeatparamsrow, nmeasures);

example = 1;

[pmFeatureIndex, pmMuIndex, pmSigmaIndex, pmRawMeasFeats, pmMSFeats, pmBuckMeasFeats, pmRangeFeats, pmVolFeats, ...
        pmAvgSegFeats, pmVolSegFeats, pmCChangeFeats, pmPMeanFeats, pmPStdFeats, ...
        pmBuckPMeanFeats, pmBuckPStdFeats, pmDateFeats, pmDemoFeats, ...
        pmIVLabels, pmABLabels, pmExLabels, pmExLBLabels, pmExABLabels, pmExABxElLabels] ...
        = createFeatureAndLabelArrays(nexamples, nmeasures, predictionduration, ...
          nrawfeatures, nmsfeatures, nbucketfeatures, nrangefeatures, nvolfeatures, navgsegfeatures, ...
          nvolsegfeatures, ncchangefeatures, npmeanfeatures, npstdfeatures, ...
          nbuckpmeanfeatures, nbuckpstdfeatures, ndatefeatures, ndemofeatures); 

fprintf('Processing data for patients\n');
for p = 1:npatients
    pabs = pmAntibiotics(pmAntibiotics.PatientNbr == p, :);
    pampred = pmAMPred(pmAMPred.PatientNbr == p, :);
    
    if ndemofeatures ~= 0
        age      = pmPatients.Age(p)      / max(pmPatients.Age);
        height   = pmPatients.Height(p)   / max(pmPatients.Height);
        weight   = pmPatients.Weight(p)   / max(pmPatients.Weight);
        predfev1 = pmPatients.PredFEV1(p) / max(pmPatients.PredFEV1);
        if pmPatients.Sex{p}(1) == 'F'
            sex = 0;
        else
            sex = 1;
        end
    end
    
    for d = (maxfeatureduration + maxnormwindow):maxdays
        % only include this run day for the period between first and last measurement for
        % patient for days when the patient wasn't on antibiotics (both from raw AB treatment 
        %data plus grouped AB treatment data from intervention list.
        % potentially add a check on completeness of raw data in this
        % window
        %if d <= (pmPatients.LastMeasdn(p) - pmPatients.FirstMeasdn(p) + 1) && ...
        %   (~any(pabs.StartDate <= pmPatients.FirstMeasDate(p) + days(d - 1) & ...
        %         pabs.StopDate  >= pmPatients.FirstMeasDate(p) + days(d - 1)))
        if d <= (pmPatients.LastMeasdn(p) - pmPatients.FirstMeasdn(p) + 1) && ...
           (~any(pabs.RelStartdn         <= d & pabs.RelStopdn              >= d)) && ...
           (~any(pampred.IVScaledDateNum <= d & pampred.IVScaledStopDateNum >= d))   
             
            pmFeatureIndex.PatientNbr(example) = pmPatients.PatientNbr(p);
            pmFeatureIndex.Study(example)      = pmPatients.Study(p);
            pmFeatureIndex.ID(example)         = pmPatients.ID(p);
            pmFeatureIndex.CalcDatedn(example) = d;
            pmFeatureIndex.CalcDate(example)   = pmPatients.FirstMeasDate(p) + days(d - 1);
            
            pmFeatureIndex.ScenType(example)    = 0;
            pmFeatureIndex.Scenario(example)    = {'Actual'};
            pmFeatureIndex.BaseExample(example) = 0;
            pmFeatureIndex.Measure{example}     = '';
            pmFeatureIndex.Percentage(example)  = 0;
            pmFeatureIndex.Frequency(example)   = 0;
            pmFeatureIndex.MSExample(example)   = 0;
            
            pmMuIndex(example, :)    = reshape(pmMucube(p, d - featureduration + 1, :), [1 nmeasures]);
            pmSigmaIndex(example, :) = reshape(pmSigmacube(p, d - featureduration + 1, :), [1 nmeasures]);
                  
            % 1) Raw features
            pmRawMeasFeats(example, :) = reshape(pmDatacube(p, (d - featureduration + 1): d, :), [1, nrawfeatures]);
            
            % 2) Missingness features
            pmMSFeats(example, :) = reshape(pmMSDatacube(p, (d - featureduration + 1): d, :), [1, nmsfeatures]);
            
            % 3) Bucketed features
            pmBuckMeasFeats(example, :) = reshape(reshape(pmBucketedcube(p, (d - featureduration + 1): d, :, :), [featureduration  * nmeasures, nbuckets])', ...
                    [1, nbucketfeatures]);
            
            % 4) Range features
            pmRangeFeats(example, :) = reshape(pmInterpRangecube(p, d, :), [1, nrangefeatures]);
            
            % 5) Volatility features
            pmVolFeats(example, :) = reshape(pmInterpVolcube(p, (d - (featureduration - 1) + 1): d, :), [1, nvolfeatures]);
            
            % 6) add average measuresment segment features
            pmAvgSegFeats(example, :) = reshape(reshape(pmInterpSegAvgcube(p, d, :, :), [nmeasures, navgseg])', ...
                    [1, navgsegfeatures]);
            
            % 7) add average volatility segment features
            pmVolSegFeats(example, :) = reshape(reshape(pmInterpSegVolcube(p, d, :, :), [nmeasures, nvolseg])', ...
                    [1, nvolsegfeatures]);
            
            % 8) contiguous change feature
            for m = 1:nmeasures
                cchange = 0;
                for i = 2:navgseg
                    if (measures.Factor(m) * pmInterpSegAvgcube(p, d, m, i)) > (measures.Factor(m) * pmInterpSegAvgcube(p, d, m, (i - 1)))
                        cchange = cchange +  (measures.Factor(m) * pmInterpSegAvgcube(p, d, m, i)) - (measures.Factor(m) * pmInterpSegAvgcube(p, d, m, (i - 1)));
                    else
                        break;
                    end
                end
                pmCChangeFeats(example, m) = cchange;
            end
            
            % 9) patient mean features
            pmPMeanFeats(example, :) = reshape(pmMuNormcube(p, d - featureduration + 1, :), [1, npmeanfeatures]);
            
            % 10) patient std features
            pmPStdFeats(example, :) = reshape(pmSigmaNormcube(p, d - featureduration + 1, :), [1, npstdfeatures]);
            
            % 11) bucketed patient mean features
            pmBuckPMeanFeats(example, :) = reshape(reshape(pmBuckMuNormcube(p, d - featureduration + 1, :, :), [nmeasures, nbuckpmeas])', ...
                    [1, nbuckpmeanfeatures]);
            
            % 12) bucketed patient std features
            pmBuckPStdFeats(example, :) = reshape(reshape(pmBuckSigmaNormcube(p, d - featureduration + 1, :, :), [nmeasures, nbuckpmeas])', ...
                    [1, nbuckpstdfeatures]);
            
            % 13) Date feature
            pmDateFeats(example, :) = createCyclicDateFeatures(pmFeatureIndex.CalcDate(example), ndatefeatures, datefeat);
            
            % 14) Patient demographic features (Age, Height, Weight, Sex,
            % PredFEV1
            pmDemoFeats(example, 1) = age;
            pmDemoFeats(example, 2) = height;
            pmDemoFeats(example, 3) = weight;
            pmDemoFeats(example, 4) = predfev1;
            pmDemoFeats(example, 5) = sex;
            
            % Label 1: for each patient/day, create row in IV label array
            pmIVLabels(example, :) = checkABInTimeWindow(pmFeatureIndex(example, :), ...
                    pmAntibiotics(pmAntibiotics.PatientNbr == p & ismember(pmAntibiotics.Route, 'IV'), :), predictionduration);
            
            % Label 3: for each patient/day, create row in AB label array (Oral + IV
            % AB)
            pmABLabels(example, :) = checkABInTimeWindow(pmFeatureIndex(example, :), ...
                    pmAntibiotics(pmAntibiotics.PatientNbr == p, :), predictionduration);    
                
            % Labels 2 & 4: label arrays for Exacerbation having started in
            % the last n days. First uses Prediction day, second uses lower
            % bound as the ex start point
            pmExLabels(example, :) = checkExStartInTimeWindow(pmFeatureIndex(example, :), ...
                    pampred, predictionduration, 'Pred');
                
            pmExLBLabels(example, :) = checkExStartInTimeWindow(pmFeatureIndex(example, :), ...
                    pampred, predictionduration, 'LB');    
                
            % Label 5: Labels for Exacerbation period (ie between predicted
            % ex start and treatment date)
            pmExABLabels(example, :) = checkInExStartToTreatmentWindow(pmFeatureIndex(example, :), ...
                    pampred, pmAntibiotics(pmAntibiotics.PatientNbr == p, :), 'All');
                
            % Label 6: Labels for Exacerbation period (ie between predicted
            % ex start and treatment date) but exclude elective treatments
            pmExABxElLabels(example, :) = checkInExStartToTreatmentWindow(pmFeatureIndex(example, :), ...
                    pampred, pmAntibiotics(pmAntibiotics.PatientNbr == p, :), 'xEl');

            example = example + 1;
        end
    end
    fprintf('.');
    if (p/50) == round(p/50)
        fprintf('\n');
    end
end
fprintf('\n');

fprintf('Normalising Feature Arrays\n');

munorm         = duplicateMeasuresByFeatures(pmMuIndex, featureduration, nmeasures);
sigmanorm      = duplicateMeasuresByFeatures(pmSigmaIndex, featureduration, nmeasures);
pmRawMeasFeats = (pmRawMeasFeats - munorm) ./ sigmanorm;

% and set missing values to be -100 (out of range constant).
pmRawMeasFeats(logical(pmMSFeats)) = basefeatparamsrow.msconst;

% pmMSFeats doesn't need normalising as it's a binary feature

munorm         = duplicateMeasuresByFeatures(pmMuIndex, navgseg, nmeasures);
sigmanorm      = duplicateMeasuresByFeatures(pmSigmaIndex, navgseg, nmeasures);
pmAvgSegFeats  = (pmAvgSegFeats - munorm) ./ sigmanorm;

pmRangeFeats   = pmRangeFeats ./ pmSigmaIndex;

pmCChangeFeats = pmCChangeFeats ./ pmSigmaIndex;

sigmanorm      = duplicateMeasuresByFeatures(pmSigmaIndex, featureduration - 1, nmeasures);
pmVolFeats     = pmVolFeats ./ sigmanorm;

sigmanorm      = duplicateMeasuresByFeatures(pmSigmaIndex, nvolseg, nmeasures);
pmVolSegFeats  = pmVolSegFeats ./ sigmanorm;

end