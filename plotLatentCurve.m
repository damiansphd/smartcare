function [xl, yl] = plotLatentCurve(ax, max_offset, align_wind, offset, meancurve, xl, yl, colour, linestyle, linewidth, anchor)

% plotLatentCurve - plots the latent curve actual and smoothed

if anchor == 1
    dfrom = max_offset + align_wind -1;
    dto = offset + 1;
else
    dfrom = max_offset + align_wind - 1 - offset;
    dto = 1;
end
    
line(ax, (-1 * dfrom):(-1 * dto), ...
    meancurve(1:max_offset + align_wind - 1 - offset), ...
    'Color', colour, ...
    'LineStyle', linestyle, ...
    'LineWidth', linewidth);
                        
%line(ax, ((-1 * (max_offset + align_wind - 1)) + offset: -1), ...
%    (meancurve(1:max_offset + align_wind - 1 - offset)), ...
%    'Color', colour, ...
%    'LineStyle', linestyle, ...
%    'LineWidth', linewidth);

xl = [min(min((-1 * (max_offset + align_wind - 1))), xl(1)) max(max(-1), xl(2))];
xlim(xl);
yl = [min(min(meancurve(1:max_offset + align_wind - 1 - offset) * 0.99), yl(1)) max(max(meancurve(1:max_offset + align_wind - 1 - offset) * 1.01), yl(2))];
if yl(1)==yl(2)
    yl = [yl(1), yl(1)+0.01];
end
ylim(yl);

end

