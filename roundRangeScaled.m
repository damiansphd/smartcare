function [roundedrange] = roundRangeScaled(lowval, highval, direction)

% roundScaled - scale a number appropriate to its magnitude

if (highval - lowval) <= 0.2
    factor = 0.05;
elseif (highval - lowval) < 0.5
    factor = 0.1;
elseif (highval - lowval) < 1
    factor = 0.2;
elseif (highval - lowval) < 2.5
    factor = 0.5;
elseif (highval - lowval) < 5
    factor = 1;
elseif (highval - lowval) < 20
    factor = 2;
elseif (highval - lowval) < 40
    factor = 5;
elseif (highval - lowval) < 100
    factor = 10;
elseif (highval - lowval) < 200
    factor = 20;
elseif (highval - lowval) < 400
    factor = 50;
elseif (highval - lowval) < 1000
    factor = 100;
elseif (highval - lowval) < 2000
    factor = 200;
elseif (highval - lowval) < 4000
    factor = 500;    
elseif (highval - lowval) < 10000
    factor = 1000;
elseif (highval - lowval) < 20000
    factor = 2000;
elseif (highval - lowval) < 40000
    factor = 5000;
else
    factor = 10000;
end

roundedrange = zeros(1,2);

if ismember(direction, {'inner'})
    roundedrange(1) = ceil(lowval/factor) * factor;
    roundedrange(2) = floor(highval/factor) * factor;
elseif ismember(direction, {'outer'})
    roundedrange(1) = floor(lowval/factor) * factor;
    roundedrange(2) = ceil(highval/factor) * factor;
else
    fprintf('**** Unknown Direction ****\n');
end

