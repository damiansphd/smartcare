function [diff] = calcDiffOverallPD(overall_pd1, overall_pd2)

% calcDiffProbDistrib  - calculates a measure of difference between two
% probability distributions

diff = sum(max(abs(overall_pd1 - overall_pd2), [], 2));

end

