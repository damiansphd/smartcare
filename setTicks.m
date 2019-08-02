function [ticks] = setTicks(minval, maxval, nticks)

% setTicks - create an array of ticks for a plot axis

ticks = zeros(nticks, 1);

%ticks(1) = ceil(minval/factor) * factor;
%ticks(nticks) = floor(maxval/factor) * factor;
roundedrange = roundRangeScaled(minval, maxval, 'inner');

ticks(1)      = roundedrange(1);
ticks(nticks) = roundedrange(2);

interval = (ticks(nticks) - ticks(1)) / (nticks - 1);

for i = 2:nticks - 1
    ticks(i) = round(ticks(1) + (i - 1) * interval);
end

end

