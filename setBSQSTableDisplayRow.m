function [resultrow, resultstring] = setBSQSTableDisplayRow(pmFeatureParamsRow, pmModelParamsRow, modeldayres, measures, nmeasures)

% setBSQSTableDisplayRow - creates the tabular BootStrap Quality Score results 
% row for a given model results file (with less cryptic values for
% parameters).
% Also creates the less crytpic feature combination as a string.

resultrow = table('Size',[1 57], ...
    'VariableTypes', {'cell', 'cell', 'cell', 'double', 'cell', 'double', ...
                      'cell', 'double', 'cell', 'cell', 'double', 'cell', 'cell', 'double', ...
                      'cell', 'cell', 'cell', 'double', 'cell', 'cell', ...
                      'cell', 'double', 'cell', 'double', ...
                      'cell', 'cell', 'cell', 'cell', 'cell', ...
                      'double', 'cell', 'cell', ...
                      'cell', 'cell', 'double', 'double', 'double', ...
                      'double', 'double', 'double', 'double', 'double', ...
                      'double', 'double', 'double', ...
                      'double', 'double', 'double', ...
                      'double', 'double', 'double', ...
                      'double', 'double', 'double', ...
                      'double', 'double', 'double'}, ...
    'VariableNames', {'FeatVer', 'ModelVer', 'StudyDisplayName', 'FeatureDuration', 'FeatFreq', 'LabelMethod', ...
                      'NormMethod', 'NormWindow', 'SmFunction', 'SmWindow', 'SmLength', 'InterpMthd', 'AugMthd', 'MSConst', ...
                      'RawMeas', 'MSMeas', 'BucketMeas', 'NumBuckets', 'Range', 'Volatility', ...
                      'AvgSeg', 'NumAvgSeg', 'VolSeg', 'NumVolSeg', ...
                      'CChange', 'PMean', 'PStd', 'BuckPMean', 'BuckPStd', ...
                      'NBuckPMeas', 'DateFeat', 'DemoFeat', ...
                      'PScore', 'ElecPScore', 'AvgEPV', 'AvgEpiTPred', 'AvgEpiFPred', ...
                      'PRAUC', 'ROCAUC', 'Acc', 'PosAcc', 'NegAcc', ...
                      'PRAUC_AvR', 'PRAUCBestR', 'PRAUCWorstR', ...
                      'ROCAUC_AvR', 'ROCAUCBestR', 'ROCAUCWorstR', ...
                      'Acc_AvR', 'AccBestR', 'AccWorstR', ...
                      'PosAcc_AvR', 'PosAccBestR', 'PosAccWorstR', ...
                      'NegAcc_AvR', 'NegAccBestR', 'NegAccWorstR'});

resultrow.FeatVer     = pmFeatureParamsRow.FeatVer;
resultrow.ModelVer    = pmModelParamsRow.ModelVer;

resultrow.StudyDisplayName = pmFeatureParamsRow.StudyDisplayName;
resultrow.FeatureDuration  = pmFeatureParamsRow.featureduration;

if pmFeatureParamsRow.featfreq == 1
    resultrow.FeatFreq = {'1:Daily'};
elseif pmFeatureParamsRow.featfreq == 2
    resultrow.FeatFreq = {'2:0-5D6+OD'};
elseif pmFeatureParamsRow.featfreq == 3
    resultrow.FeatFreq = {'2:0-5D6-15OD16+OOD'};    
end

resultrow.LabelMethod = pmModelParamsRow.labelmethod;

if pmFeatureParamsRow.normmethod == 1
    resultrow.NormMethod = {'1:MuOvSigOv'};
elseif pmFeatureParamsRow.normmethod == 2
    resultrow.NormMethod = {'2:MuPtSigPt'};
elseif pmFeatureParamsRow.normmethod == 3
    resultrow.NormMethod = {'3:MuWnSigPt'};
elseif pmFeatureParamsRow.normmethod == 4
    resultrow.NormMethod = {'4:MuWnSigOv'};  
end

resultrow.NormWindow = pmFeatureParamsRow.normwindow;

if pmFeatureParamsRow.smfunction == 0
    resultrow.SmFunction = {'0:None'};
elseif pmFeatureParamsRow.smfunction == 1
    resultrow.SmFunction = {'1:Mean'};
elseif pmFeatureParamsRow.smfunction == 2
    resultrow.SmFunction = {'2:Median'};
elseif pmFeatureParamsRow.smfunction == 3
    resultrow.SmFunction = {'3:FMaxOMean'};
elseif pmFeatureParamsRow.smfunction == 4
    resultrow.SmFunction = {'4:FMaxONone'}; 
end

if pmFeatureParamsRow.smwindow == 0
    resultrow.SmWindow = {'0:None'};
elseif pmFeatureParamsRow.smwindow == 1
    resultrow.SmWindow = {'1:Center'};
elseif pmFeatureParamsRow.smwindow == 2
    resultrow.SmWindow = {'2:Trail'};
end

resultrow.SmLength = pmFeatureParamsRow.smlength;

if pmFeatureParamsRow.interpmethod == 0
    resultrow.InterpMthd = {'0:None'};
elseif pmFeatureParamsRow.interpmethod == 1
    resultrow.InterpMthd = {'1:Full'};
elseif pmFeatureParamsRow.interpmethod >= 2
    resultrow.InterpMthd = {sprintf('%d:Range%dd', pmFeatureParamsRow.interpmethod, (pmFeatureParamsRow.interpmethod - 1))};
end

if pmFeatureParamsRow.augmethod == 1
    resultrow.AugMthd = {'1:Reg'};
elseif pmFeatureParamsRow.augmethod >= 2
    resultrow.AugMthd = {sprintf('%d:Aug',pmFeatureParamsRow.augmethod)};
end

resultrow.MSConst = pmFeatureParamsRow.msconst;

resultstring = sprintf('pmfv%smv%sst%slm%d|fd%dff%s|nm%snw%d|sf%ssw%ssl%d|ip%sau%smc%d|', resultrow.FeatVer{1}, resultrow.ModelVer{1}, ...
    resultrow.StudyDisplayName{1}, resultrow.LabelMethod, resultrow.FeatureDuration, resultrow.FeatFreq{1}, ...
    resultrow.NormMethod{1}, resultrow.NormWindow, resultrow.SmFunction{1}, resultrow.SmWindow{1}, resultrow.SmLength, ...
    resultrow.InterpMthd{1}, resultrow.AugMthd{1}, resultrow.MSConst);

if sum(measures.RawMeas) == 0
    rawtext = 'None';
elseif sum(measures.RawMeas) == nmeasures
    rawtext = 'All';
elseif (sum(measures.RawMeas) > 0)
    rawtext = strcat(measures.ShortName{logical(measures.RawMeas)});
end
resultrow.RawMeas = {sprintf('%d:%s', pmFeatureParamsRow.rawmeasfeat, rawtext)};
if sum(measures.RawMeas)~=0
    resultstring = sprintf('%srm%s|', resultstring, resultrow.RawMeas{1});
end

if sum(measures.MSMeas) == 0
    rawtext = 'None';
elseif sum(measures.MSMeas) == nmeasures
    rawtext = 'All';
elseif (sum(measures.MSMeas) > 0)
    rawtext = strcat(measures.ShortName{logical(measures.MSMeas)});
end
resultrow.MSMeas = {sprintf('%d:%s', pmFeatureParamsRow.msfeat, rawtext)};
if sum(measures.MSMeas)~=0
    resultstring = sprintf('%sms%s|', resultstring, resultrow.MSMeas{1});
end

if sum(measures.BucketMeas) == 0
    bucktext = 'None';
elseif sum(measures.BucketMeas) == nmeasures
    bucktext = 'All';
else
    bucktext = strcat(measures.ShortName{logical(measures.BucketMeas)});
end
resultrow.BucketMeas = {sprintf('%d:%s', pmFeatureParamsRow.bucketfeat, bucktext)};
resultrow.NumBuckets = pmFeatureParamsRow.nbuckets;
if sum(measures.BucketMeas) ~= 0
    resultstring = sprintf('%sbf%snb%d|', resultstring, resultrow.BucketMeas{1}, resultrow.NumBuckets);
end

if sum(measures.Range) == 0
    rangetext = 'None';
elseif sum(measures.Range) == nmeasures
    rangetext = 'All';
else
    rangetext = strcat(measures.ShortName{logical(measures.Range)});
end
resultrow.Range = {sprintf('%d:%s', pmFeatureParamsRow.rangefeat, rangetext)};
if sum(measures.Range) ~= 0
    resultstring = sprintf('%srn%s|', resultstring, resultrow.Range{1});
end

if sum(measures.Volatility) == 0
    voltext = 'None';
elseif sum(measures.Volatility) == nmeasures    
    voltext= 'All';
else
    voltext= strcat(measures.ShortName{logical(measures.Volatility)});
end
resultrow.Volatility = {sprintf('%d:%s', pmFeatureParamsRow.volfeat, voltext)};
if sum(measures.Volatility) ~= 0
    resultstring = sprintf('%svo%s|', resultstring, resultrow.Volatility{1});
end

if sum(measures.AvgSeg) == 0
    avgsegtext = 'None';
elseif sum(measures.AvgSeg) == nmeasures    
    avgsegtext= 'All';
else
    avgsegtext= strcat(measures.ShortName{logical(measures.AvgSeg)});
end
resultrow.AvgSeg = {sprintf('%d:%s', pmFeatureParamsRow.avgsegfeat, avgsegtext)};
resultrow.NumAvgSeg = pmFeatureParamsRow.navgseg;
if sum(measures.AvgSeg) ~= 0
    resultstring = sprintf('%sas%sna%d|', resultstring, resultrow.AvgSeg{1}, resultrow.NumAvgSeg);
end

if sum(measures.VolSeg) == 0
    volsegtext = 'None';
elseif sum(measures.VolSeg) == nmeasures    
    volsegtext= 'All';
else
    volsegtext= strcat(measures.ShortName{logical(measures.VolSeg)});
end
resultrow.VolSeg = {sprintf('%d:%s', pmFeatureParamsRow.volsegfeat, volsegtext)};
resultrow.NumVolSeg = pmFeatureParamsRow.nvolseg;
if sum(measures.VolSeg) ~= 0
    resultstring = sprintf('%svs%snv%d|', resultstring, resultrow.VolSeg{1}, resultrow.NumVolSeg);
end

if sum(measures.CChange) == 0
    cchangetext = 'None';
elseif sum(measures.CChange) == nmeasures    
    cchangetext= 'All';
else
    cchangetext= strcat(measures.ShortName{logical(measures.CChange)});
end
resultrow.CChange = {sprintf('%d:%s', pmFeatureParamsRow.cchangefeat, cchangetext)};
if sum(measures.CChange) ~= 0
    resultstring = sprintf('%scc%s|', resultstring, resultrow.CChange{1});
end

if sum(measures.PMean) == 0
    pmeantext = 'None';
elseif sum(measures.PMean) == nmeasures    
    pmeantext= 'All';
else
    pmeantext= strcat(measures.ShortName{logical(measures.PMean)});
end
resultrow.PMean = {sprintf('%d:%s', pmFeatureParamsRow.pmeanfeat, pmeantext)};
if sum(measures.PMean) ~= 0
    resultstring = sprintf('%spm%s|', resultstring, resultrow.PMean{1});
end

if sum(measures.PStd) == 0
    pstdtext = 'None';
elseif sum(measures.PStd) == nmeasures    
    pstdtext= 'All';
else
    pstdtext= strcat(measures.ShortName{logical(measures.PStd)});
end
resultrow.PStd = {sprintf('%d:%s', pmFeatureParamsRow.pstdfeat, pstdtext)};
if sum(measures.PStd) ~= 0
    resultstring = sprintf('%sps%s|', resultstring, resultrow.PStd{1});
end

if sum(measures.BuckPMean) == 0
    buckpmeantext = 'None';
elseif sum(measures.BuckPMean) == nmeasures    
    buckpmeantext= 'All';
else
    buckpmeantext= strcat(measures.ShortName{logical(measures.BuckPMean)});
end
resultrow.BuckPMean = {sprintf('%d:%s', pmFeatureParamsRow.buckpmean, buckpmeantext)};
if sum(measures.BuckPMean) ~= 0
    resultstring = sprintf('%sbm%s', resultstring, resultrow.BuckPMean{1});
end

if sum(measures.BuckPStd) == 0
    buckpstdtext = 'None';
elseif sum(measures.BuckPStd) == nmeasures    
    buckpstdtext= 'All';
else
    buckpstdtext= strcat(measures.ShortName{logical(measures.BuckPStd)});
end
resultrow.BuckPStd = {sprintf('%d:%s', pmFeatureParamsRow.buckpstd, buckpstdtext)};
if sum(measures.BuckPStd) ~= 0
    resultstring = sprintf('%sbs%s', resultstring, resultrow.BuckPStd{1});
end

resultrow.NBuckPMeas = pmFeatureParamsRow.nbuckpmeas;
if sum(measures.BuckPMean) ~= 0 || sum(measures.BuckPStd) ~= 0
    resultstring = sprintf('%snp%d|', resultstring, resultrow.NBuckPMeas);
end

if pmFeatureParamsRow.datefeat == 0
    datetext = 'None';
elseif pmFeatureParamsRow.datefeat == 1
    datetext = 'SinCos';
elseif pmFeatureParamsRow.datefeat > 1
    datetext = sprintf('Buck%d', pmFeatureParamsRow.datefeat);
end
resultrow.DateFeat = {sprintf('%d:%s', pmFeatureParamsRow.datefeat, datetext)};
if pmFeatureParamsRow.datefeat ~= 0
    resultstring = sprintf('%sdf%s|', resultstring, resultrow.DateFeat{1});
end

if pmFeatureParamsRow.demofeat == 1
    demotext = 'None';
elseif pmFeatureParamsRow.demofeat == 2
    demotext = 'All';
elseif pmFeatureParamsRow.demofeat == 3
    demotext = 'Age';
elseif pmFeatureParamsRow.demofeat == 4
    demotext = 'Height';
elseif pmFeatureParamsRow.demofeat == 5
    demotext = 'Weight';
elseif pmFeatureParamsRow.demofeat == 6
    demotext = 'PredFEV1';
elseif pmFeatureParamsRow.demofeat == 7
    demotext =  'Sex';
end
resultrow.DemoFeat = {sprintf('%d:%s', pmFeatureParamsRow.demofeat, demotext)};
if pmFeatureParamsRow.demofeat > 1
    resultstring = sprintf('%sdm%s|', resultstring, resultrow.DemoFeat{1});
end

resultrow.PScore      = {sprintf('%.1f%% (%d/%d/%d)', modeldayres.PScore, modeldayres.HighP, ...
                            modeldayres.MedP, modeldayres.LowP)};
resultrow.ElecPScore  = {sprintf('%.1f%% (%d/%d/%d)', modeldayres.ElecPScore, modeldayres.ElecHighP, ...
                            modeldayres.ElecMedP, modeldayres.ElecLowP)};
resultrow.AvgEPV      = modeldayres.AvgEPV;
resultrow.AvgEpiTPred = modeldayres.AvgEpiTPred;
resultrow.AvgEpiFPred = modeldayres.AvgEpiFPred;    
resultrow.PRAUC       = modeldayres.PRAUC;
resultrow.ROCAUC      = modeldayres.ROCAUC;
resultrow.Acc         = modeldayres.Acc;
resultrow.PosAcc      = modeldayres.PosAcc;
resultrow.NegAcc      = modeldayres.NegAcc;  

end

