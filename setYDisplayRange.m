function [ydisplayrange] = setYDisplayRange(miny, maxy, lowrangelimit)

% setYDisplayRange - function to scale y axis of plots appropriately
    
if (maxy - miny) >= lowrangelimit
    scaledunit = (maxy - miny) * 0.1;
    ydisplaymin = miny - scaledunit;
    ydisplaymax = maxy + scaledunit;
else
    ydisplaymin = 0.5 * (maxy + miny) - 0.5 * lowrangelimit;
    ydisplaymax = 0.5 * (maxy + miny) + 0.5 * lowrangelimit;
    if ydisplaymin < 0
        ydisplaymax = ydisplaymax - ydisplaymin;
        ydisplaymin = 0;
    end
end

ydisplayrange = [round(ydisplaymin, 1), round(ydisplaymax, 1)];

end

