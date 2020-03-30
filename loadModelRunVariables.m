function [meancurvemean1, meancurvecount1, measures1, min_offset1, max_offset1, ...
    align_wind1, nmeasures1, ex_start1, countthreshold1] = loadModelRunVariables(basedir, subfolder, modelrun)

% loadModelRunVariables - convenience function to load model run variables

fprintf('Loading output from model run1\n');
load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun)), 'meancurvemean', 'meancurvecount', ...
    'measures', 'min_offset', 'max_offset', 'align_wind', 'nmeasures', 'ex_start', 'countthreshold');

meancurvemean1  = meancurvemean;
meancurvecount1 = meancurvecount;
measures1       = measures;
min_offset1     = min_offset;
max_offset1     = max_offset;
align_wind1     = align_wind;
nmeasures1      = nmeasures;
ex_start1       = ex_start;
countthreshold1 = countthreshold;

end
