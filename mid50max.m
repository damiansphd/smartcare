function y = mid50max(x)

% mid50std - returns the std of the mid 50% data points in x (sorted by
% magnitude)  

x = sort(x, 'ascend');
percentile25 = round(size(x,1) * .25) + 1;
percentile75 = round(size(x,1) * .75);

y = max(x(percentile25:percentile75));

end

