function [diff] = amEMMCCalcDiffOverallPD(overall_pd1, overall_pd2)

% amEMMCCalcDiffProbDistrib  - calculates a measure of difference between two
% probability distributions

diff = sum(max(max(abs(overall_pd1 - overall_pd2), [], 3), [], 1));

end

