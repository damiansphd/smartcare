function [auFeatureIndex, auMuIndex, auSigmaIndex, auRawMeasFeats, auMSFeats, auBuckMeasFeats, auRangeFeats, auVolFeats, ...
        auAvgSegFeats, auVolSegFeats, auCChangeFeats, auPMeanFeats, auPStdFeats, ...
        auBuckPMeanFeats, auBuckPStdFeats, auDateFeats, auDemoFeats, ...
        auIVLabels, auABLabels, auExLabels, auExLBLabels, auExABLabels, auExABxElLabels] ...
        = augmentFeaturesAndLabels(pmFeatureIndex, pmMuIndex, pmSigmaIndex, pmRawMeasFeats, pmMSFeats, pmBuckMeasFeats, ...
        pmRangeFeats, pmVolFeats, pmAvgSegFeats, pmVolSegFeats, pmCChangeFeats, pmPMeanFeats, pmPStdFeats, ...
        pmBuckPMeanFeats, pmBuckPStdFeats, pmDateFeats, pmDemoFeats, ...
        pmIVLabels, pmABLabels, pmExLabels, pmExLBLabels, pmExABLabels, pmExABxElLabels, basefeatparamsrow, ...
        nmeasures)


% first create augmented feature and label arrays.
norigexamples = size(pmFeatureIndex, 1);
multiplier = basefeatparamsrow.augmethod;
naugexamples  = norigexamples * multiplier;

nmsscentypes = 4;

outrangeconst = basefeatparamsrow.msconst;

[~, predictionduration, ~, ~, ~, ~, ~, ...
          nrawfeatures, nmsfeatures, nbucketfeatures, nrangefeatures, nvolfeatures, navgsegfeatures, ...
          nvolsegfeatures, ncchangefeatures, npmeanfeatures, npstdfeatures, ...
          nbuckpmeanfeatures, nbuckpstdfeatures, ndatefeatures, ndemofeatures] = ...
            setBaseNumMeasAndFeatures(basefeatparamsrow, nmeasures);

[auFeatureIndex, auMuIndex, auSigmaIndex, auRawMeasFeats, auMSFeats, auBuckMeasFeats, auRangeFeats, auVolFeats, ...
        auAvgSegFeats, auVolSegFeats, auCChangeFeats, auPMeanFeats, auPStdFeats, ...
        auBuckPMeanFeats, auBuckPStdFeats, auDateFeats, auDemoFeats, ...
        auIVLabels, auABLabels, auExLabels, auExLBLabels, auExABLabels, auExABxElLabels] ...
        = createFeatureAndLabelArrays(naugexamples, nmeasures, predictionduration, ...
          nrawfeatures, nmsfeatures, nbucketfeatures, nrangefeatures, nvolfeatures, navgsegfeatures, ...
          nvolsegfeatures, ncchangefeatures, npmeanfeatures, npstdfeatures, ...
          nbuckpmeanfeatures, nbuckpstdfeatures, ndatefeatures, ndemofeatures); 

 
fprintf('Augmenting data set with missingness scenarios\n');
tic
fprintf('First copying over existing data\n');
% first need to copy over existing examples, and add entries to the new
% missingness scenario index
auFeatureIndex(1:norigexamples, :)   = pmFeatureIndex;
auMuIndex(1:norigexamples, :)        = pmMuIndex;
auSigmaIndex(1:norigexamples, :)     = pmSigmaIndex;

auRawMeasFeats(1:norigexamples, :)   = pmRawMeasFeats;
auMSFeats(1:norigexamples, :)        = pmMSFeats;
auBuckMeasFeats(1:norigexamples, :)  = pmBuckMeasFeats;
auRangeFeats(1:norigexamples, :)     = pmRangeFeats;
auVolFeats(1:norigexamples, :)       = pmVolFeats;
auAvgSegFeats(1:norigexamples, :)    = pmAvgSegFeats;
auVolSegFeats(1:norigexamples, :)    = pmVolSegFeats;
auCChangeFeats(1:norigexamples, :)   = pmCChangeFeats;
auPMeanFeats(1:norigexamples, :)     = pmPMeanFeats;
auPStdFeats(1:norigexamples, :)      = pmPStdFeats;
auBuckPMeanFeats(1:norigexamples, :) = pmBuckPMeanFeats;
auBuckPStdFeats(1:norigexamples, :)  = pmBuckPStdFeats;
auDateFeats(1:norigexamples, :)      = pmDateFeats;
auDemoFeats(1:norigexamples, :)      = pmDemoFeats;

auIVLabels(1:norigexamples, :)       = pmIVLabels;
auABLabels(1:norigexamples, :)       = pmABLabels;
auExLabels(1:norigexamples, :)       = pmExLabels;
auExLBLabels(1:norigexamples, :)     = pmExLBLabels;
auExABLabels(1:norigexamples)        = pmExABLabels;
auExABxElLabels(1:norigexamples)     = pmExABxElLabels;

toc
fprintf('\n');
tic
fprintf('Next augmenting data set to be %dx larger\n', multiplier);
% make repeatable
rng(2);
for i = (norigexamples + 1):naugexamples
    % first choose an example at random
    baseex = randi(norigexamples);
    
    auFeatureIndex(i, :)   = pmFeatureIndex(baseex, :);
    auMuIndex(i, :)        = pmMuIndex(baseex, :);
    auSigmaIndex(i, :)     = pmSigmaIndex(baseex, :);
    
    auRawMeasFeats(i, :)   = pmRawMeasFeats(baseex, :);
    auMSFeats(i, :)        = pmMSFeats(baseex, :);
    auBuckMeasFeats(i, :)  = pmBuckMeasFeats(baseex, :);
    auRangeFeats(i, :)     = pmRangeFeats(baseex, :);
    auAvgSegFeats(i, :)    = pmAvgSegFeats(baseex, :);
    auVolFeats(i, :)       = pmVolFeats(baseex, :);
    auVolSegFeats(i, :)    = pmVolSegFeats(baseex, :);
    auCChangeFeats(i, :)   = pmCChangeFeats(baseex, :);
    auPMeanFeats(i, :)     = pmPMeanFeats(baseex, :);
    auPStdFeats(i, :)      = pmPStdFeats(baseex, :);
    auBuckPMeanFeats(i, :) = pmBuckPMeanFeats(baseex, :);
    auBuckPStdFeats(i, :)  = pmBuckPStdFeats(baseex, :);
    auDateFeats(i, :)      = pmDateFeats(baseex, :);
    auDemoFeats(i, :)      = pmDemoFeats(baseex, :);
    
    auIVLabels(i, :)       = pmIVLabels(baseex, :);
    auABLabels(i, :)       = pmABLabels(baseex, :);
    auExLabels(i, :)       = pmExLabels(baseex, :);
    auExLBLabels(i, :)     = pmExLBLabels(baseex, :);
    auExABLabels(i)        = pmExABLabels(baseex);
    auExABxElLabels(i)     = pmExABxElLabels(baseex);
    
    % then choose missingness scenario type at random
    % then choose relevant parameter at random (within allowed values)
    msscen = randi(nmsscentypes);
    auFeatureIndex.ScenType(i)   = msscen;
    auFeatureIndex.BaseExample(i) = baseex;
    
    switch msscen
        case 1
            % remove data points at a fixed frequency
            msfreq = randi(3) + 1;
            nmrawfeat = nrawfeatures/nmeasures;
            nreps = ceil(nmrawfeat/msfreq);
            freqidx = false(1, msfreq);
            freqidx(1) = true;
            featidx = repmat(freqidx, 1, nreps);
            featidx = featidx(1:nmrawfeat);
            for m = 1:nmeasures
                tmpdata = auRawMeasFeats(i, (((m - 1) * nmrawfeat) + 1):(m * nmrawfeat));
                tmpdata(featidx) = outrangeconst;
                auRawMeasFeats(i, (((m - 1) * nmrawfeat) + 1):(m * nmrawfeat)) = tmpdata;
            end
            auFeatureIndex.Scenario{i}  = 'Frequency';
            auFeatureIndex.Frequency(i) = msfreq;
        case 2
            % remove a percentage of data points at random
            mspct = rand(1) * 100;
            %pcttype   = randi(3);
            %switch pcttype
            %    case 1
            %        mspct = 50;
            %    case 2
            %        mspct = 33.33;
            %    case 3
            %        mspct = 25;
            %end
            nrem = ceil(nrawfeatures * mspct / 100);
            posarray = randperm(nrawfeatures, nrem);
            featidx = false(1, nrawfeatures);
            featidx(posarray) = true;
            auRawMeasFeats(i, featidx) = outrangeconst;
            auFeatureIndex.Scenario{i} = 'Percentage';
            auFeatureIndex.Percentage(i) = mspct;
        case 3
            % inherit actual missingness from another example
            msex = baseex;
            while msex == baseex
                msex = randi(norigexamples);
            end
            featidx = auRawMeasFeats(msex, :) == outrangeconst;
            auRawMeasFeats(i, featidx) = outrangeconst;
            auFeatureIndex.Scenario{i} = 'Reuse Actual';
            auFeatureIndex.MSExample(i) = msex;
        case 4
            % remove all data points for one or more measures
            msmeas = randi([0 1], 1, nmeasures);
            nmrawfeat = nrawfeatures/nmeasures;
            featidx = false(1, nrawfeatures);
            for m = 1:nmeasures
                featidx((((m - 1) * nmrawfeat) + 1):(m * nmrawfeat)) = msmeas(m);
            end
            auRawMeasFeats(i, featidx) = outrangeconst;
            auFeatureIndex.Scenario{i} = 'Remove all points';
            str_x = num2str(msmeas);
            str_x(isspace(str_x)) = '';
            auFeatureIndex.Measure{i}  = str_x;
    end
    
    % update missingness features accordingly
    msidx = zeros(1, nmsfeatures);
    msidx(auRawMeasFeats(i,:) == outrangeconst) = 1;
    auMSFeats(i, :) = msidx; 
    
    if ((i - norigexamples)/100) == round((i - norigexamples)/100)
        fprintf('.');
        if ((i - norigexamples)/5000) == round((i - norigexamples)/5000)
            fprintf('\n');
        end
    end
end
fprintf('\n');
toc
fprintf('\n');

end

