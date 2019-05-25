function [resultrow] = setResultTableDisplayRow(mversion, study, sigmamethod, mumethod, ...
    curveaveragingmethod, smoothingmethod, datasmoothmethod, measuresmask, runmode, randomseed, ...
    imputationmode, confidencemode, max_offset, align_wind, ...
    outprior, heldbackpct, confidencethreshold, nlatentcurves, niterations, ex_start, qual, ...
    testsetmatch, testsetsize, testsetdist, measures, nmeasures)

% setResultTableDisplayRow - creates the tabular record for the model run,
% including run parameters, obj fcn, ex starts, and scores vs labelled test data

resultrow = table('Size',[1 24], ...
                 'VariableTypes', {'cell', 'cell', 'cell', 'cell', 'cell', ...
                      'cell', 'double', 'cell', 'cell', 'cell', ...
                      'cell', 'cell', 'double', 'cell', 'double', ...
                      'cell', 'cell', 'double', 'double', 'cell', ...
                      'double', 'double', 'double', 'double'}, ...
                 'VariableNames', {'Version', 'Study', 'Sigma', 'Mu', 'CurveAvg', ...
                      'LCSmooth',  'DataWindow', 'Imputation', 'HeldBackPct', 'OutPrior', ...
                      'ConfMode', 'ConfThresh', 'NumLCSets', 'Measures', 'MaxOffset', ...
                      'DataSmooth', 'RunMode', 'RandomSeed', 'NumIterations', 'ExStarts', ...
                      'ObjFcn', 'TestSetMatch', 'TestSetSize', 'TestSetDist'});

resultrow.Version = mversion;
resultrow.Study   = study;

if sigmamethod == 1
    resultrow.Sigma = {'1:StdMeasDataWindow'};
elseif sigmamethod  == 2
    resultrow.Sigma = {'2:StdMeasStudy'};
elseif sigmamethod  == 3
    resultrow.Sigma = {'3:StdMeasPatient'};
elseif sigmamethod  == 4
    resultrow.Sigma = {'4:StdMeasDataPoint'};
end

if mumethod == 1
    resultrow.Mu = {'1:8dMean'};
elseif mumethod  == 2
    resultrow.Mu = {'2:20dUQMean'};
elseif mumethod  == 3
    resultrow.Mu = {'3:10dMeanXBQ'};
elseif mumethod  == 4
    resultrow.Mu = {'4:10dMeanXBQXOut'};
elseif mumethod  == 5
    resultrow.Mu = {'5:10dMeanXBQXOutOrU50Pat'};
end

if curveaveragingmethod == 1
    resultrow.CurveAvg = {'1:DW'};
elseif curveaveragingmethod == 2
    resultrow.CurveAvg = {'2:DW+Left'};
end

if smoothingmethod == 1
    resultrow.LCSmooth = {'1:None'};
elseif smoothingmethod == 2
    resultrow.LCSmooth = {'2:5dMean'};
end

resultrow.DataWindow = align_wind;

if imputationmode == 1
    resultrow.Imputation = {'1:No'};
    resultrow.HeldBackPct = sprintf('%.1f%%', 0);
elseif imputationmode == 2
    resultrow.Imputation = {'2:Yes'};
    resultrow.HeldBackPct = sprintf('%.1f%%', heldbackpct * 100);
end

resultrow.OutPrior = sprintf('%.1f%%', outprior * 100);

if confidencemode == 1
    resultrow.ConfMode = {'1:Contig'};
elseif confidencemode == 2
    resultrow.ConfMode = {'2:Max'};
end

resultrow.ConfThresh = sprintf('%.1f%%', confidencethreshold * 100);

resultrow.NumLCSets = nlatentcurves;


if sum(measures.Mask) == 0
    rawtext = 'None';
elseif sum(measures.Mask) == nmeasures
    rawtext = 'All';
elseif (sum(measures.Mask) > 0)
    temp = extractBefore(measures.DisplayName(logical(measures.Mask)),3);
    rawtext = strcat(temp{:});
    rawtext = strrep(rawtext, 'WeWe', 'WtWe');
end
resultrow.Measures = {sprintf('%d:%s', measuresmask, rawtext)};

resultrow.MaxOffset = max_offset;

if datasmoothmethod == 1
    resultrow.DataSmooth = {'1:None'};
elseif datasmoothmethod == 2
    resultrow.DataSmooth = {'2:FEV1Max2d'};
elseif datasmoothmethod == 3
    resultrow.DataSmooth = {'3:FEV1Max3d'};
end

if runmode == 4
    resultrow.RunMode = {'4:OffUPDLCRandPM'};
elseif runmode == 5
    resultrow.RunMode = {'5:Off0PM'};
elseif runmode == 6
    resultrow.RunMode = {'6:***DONOTUSE***'};
elseif runmode == 7
    resultrow.RunMode = {'7:OffUPDLCFEV1PM'};
elseif runmode == 8
    resultrow.RunMode = {'8:OffUPDLCFEV1ElecPM'};
elseif runmode == 9
    resultrow.RunMode = {'9:OffUPDLCRandPD'};
elseif runmode == 10
    resultrow.RunMode = {'10:OffUPDLCFEV1ElecPD'};    
elseif runmode == 11
    resultrow.RunMode = {'11:OffUPDLCFEV1ElecPD'};    
end

resultrow.RandomSeed = randomseed;

resultrow.NumIterations = niterations;

resultrow.ExStarts = {sprintf('%d', ex_start)};

resultrow.ObjFcn = qual;

resultrow.TestSetMatch = testsetmatch;
resultrow.TestSetSize  = testsetsize;
resultrow.TestSetDist  = testsetdist;

end
