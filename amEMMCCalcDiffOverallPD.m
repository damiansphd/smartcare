function [smmdiff, sssdiff] = amEMMCCalcDiffOverallPD(overall_pd1, overall_pd2)

% amEMMCCalcDiffProbDistrib  - calculates a measure of difference between two
% probability distributions

smmdiff = sum(max(max(abs(overall_pd1 - overall_pd2), [], 3), [], 1));
sssdiff = sum(sum(sum(abs(overall_pd1 - overall_pd2))));

end

