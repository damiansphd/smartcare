function [pmFeatureIndex, pmMuIndex, pmSigmaIndex, pmRawMeasFeats, pmMSFeats, pmBuckMeasFeats, pmRangeFeats, pmVolFeats, ...
        pmAvgSegFeats, pmVolSegFeats, pmCChangeFeats, pmPMeanFeats, pmPStdFeats, ...
        pmBuckPMeanFeats, pmBuckPStdFeats, pmDateFeats, pmDemoFeats, ...
        pmIVLabels, pmABLabels, pmExLabels, pmExLBLabels, pmExABLabels, pmExABxElLabels] ...
        = createFeatureAndLabelArrays(nexamples, nmeasures, predictionduration, ...
          nrawfeatures, nmsfeatures, nbucketfeatures, nrangefeatures, nvolfeatures, navgsegfeatures, ...
          nvolsegfeatures, ncchangefeatures, npmeanfeatures, npstdfeatures, ...
          nbuckpmeanfeatures, nbuckpstdfeatures, ndatefeatures, ndemofeatures) 
    
pmFeatureIndex = table('Size',[nexamples, 12], ...
    'VariableTypes', {'double', 'cell', 'double', 'datetime', 'double', 'double', ...
                      'cell', 'double', 'cell', 'double', 'double', 'double'}, ...
    'VariableNames', {'PatientNbr', 'Study', 'ID', 'CalcDate', 'CalcDatedn', 'ScenType', ...
                      'Scenario', 'BaseExample', 'Measure', 'Frequency', 'Percentage', 'MSExample'});

pmMuIndex         = zeros(nexamples, nmeasures);
pmSigmaIndex      = zeros(nexamples, nmeasures);

pmRawMeasFeats   = zeros(nexamples, nrawfeatures);
pmMSFeats        = zeros(nexamples, nmsfeatures);
pmBuckMeasFeats  = zeros(nexamples, nbucketfeatures);
pmRangeFeats     = zeros(nexamples, nrangefeatures);
pmVolFeats       = zeros(nexamples, nvolfeatures);
pmAvgSegFeats    = zeros(nexamples, navgsegfeatures);
pmVolSegFeats    = zeros(nexamples, nvolsegfeatures); 
pmCChangeFeats   = zeros(nexamples, ncchangefeatures);
pmPMeanFeats     = zeros(nexamples, npmeanfeatures);
pmPStdFeats      = zeros(nexamples, npstdfeatures);
pmBuckPMeanFeats = zeros(nexamples, nbuckpmeanfeatures);
pmBuckPStdFeats  = zeros(nexamples, nbuckpstdfeatures);
pmDateFeats      = zeros(nexamples, ndatefeatures);
pmDemoFeats      = zeros(nexamples, ndemofeatures);

pmIVLabels         = false(nexamples, predictionduration);
pmExLabels         = false(nexamples, predictionduration);
pmABLabels         = false(nexamples, predictionduration);
pmExLBLabels       = false(nexamples, predictionduration);
pmExABLabels       = false(nexamples, 1);
pmExABxElLabels    = false(nexamples, 1);

end

