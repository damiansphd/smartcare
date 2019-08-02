function [roundedrange] = setYDisplayRange(miny, maxy, lowrangelimit)

% setYDisplayRange - function to scale y axis of plots appropriately

if (maxy - miny) >= lowrangelimit
    %scaledunit = (maxy - miny) * 0.1;
    %ydisplaymin = miny - scaledunit;
    %ydisplaymax = maxy + scaledunit;
    roundedrange = roundRangeScaled(miny, maxy, 'outer');
else
    ydisplaymin = 0.5 * (maxy + miny) - 0.5 * lowrangelimit;
    ydisplaymax = 0.5 * (maxy + miny) + 0.5 * lowrangelimit;
    if ydisplaymin < 0
        ydisplaymax = ydisplaymax - ydisplaymin;
        ydisplaymin = 0;
    end
    roundedrange = roundRangeScaled(ydisplaymin, ydisplaymax, 'outer');
end

%ydisplayrange = [round(ydisplaymin, 1), round(ydisplaymax, 1)];


end

