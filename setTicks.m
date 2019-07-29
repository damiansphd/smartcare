function [ticks] = setTicks(minval, maxval, nticks)

% setTicks - create an array of ticks for a plot axis

if (maxval - minval) > 40
    factor = 10;
else
    factor = 1;
end

ticks = zeros(nticks, 1);

ticks(1) = ceil(minval/factor) * factor;
ticks(nticks) = floor(maxval/factor) * factor;

interval = (ticks(nticks) - ticks(1)) / (nticks - 1);

for i = 2:nticks - 1
    ticks(i) = round(ticks(1) + (i - 1) * interval);
end

end

