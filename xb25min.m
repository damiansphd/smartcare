function y = xb25min(x)

% xb25min - returns the min of the data points excluding the bottom 25% in x (sorted by
% magnitude)  

x = sort(x, 'ascend');

if size(x, 1) == 1
    dim = 2;
elseif size(x, 2) == 1
    dim = 1;
else
    fprintf('**** function only works for vectors ****');
    return
end

percentile25 = round(size(x, dim) * .25) + 1;

y = min(x(percentile25:end));

end