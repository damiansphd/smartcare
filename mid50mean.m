function y = mid50mean(x)

% mid50mean - returns the mean of the mid 50% data points in x (sorted by
% magnitude)

x = sort(x, 'ascend');
percentile25 = round(size(x,1) * .25) + 1;
percentile75 = round(size(x,1) * .75);

y = mean(x(percentile25:percentile75));

end

