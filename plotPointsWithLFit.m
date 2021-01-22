function [grad, studydateval] = plotPointsWithLFit(mtable, extbl, ax, yl, p, scid, fromd, tod, ...
    exclwind, periodtype, meastype, bestwind, gradtype, twindow, offset)

% plotPointsWithLFit - plots a set of points and dates along with linear
% fit

grad = 0;
studydateval = 0;
col1 = [0, 0.65, 1];
col2 = 'red';
col3 = [0.65 0.65 0.65];

ax.FontSize = 8;
ax.FontName = 'Arial';
ax.TickDir = 'out';
    
pmtbl = mtable((mtable.Date >= fromd) & (mtable.Date < tod), :);
pextbl = extbl((extbl.StopDate >= fromd) & (extbl.StartDate < tod), :);

fexidx = false(size(pmtbl, 1), 1);
if ismember(gradtype, {'ExIV'})
    fexidx = zeros(size(pmtbl, 1), 1);
    for i = 1:size(pextbl, 1) 
        fexidx = fexidx | (pmtbl.Date >= pextbl.StartDate(i) - days(exclwind)) & (pmtbl.Date < pextbl.StopDate(i));    
    end
else % pick best in <bestwind> months
    fexidx = true(size(pmtbl, 1), 1);
    nperiods = ceil(twindow/bestwind);
    for n = 1:nperiods
        pidx = (pmtbl.Date >= fromd + calmonths((n-1) * bestwind)) & (pmtbl.Date < fromd + calmonths(n * bestwind));
        if sum(pidx) > 0
            [~, i] = max(pmtbl.Amount(pidx));
            tmpidx = true(sum(pidx), 1);
            tmpidx(i) = false;
            fexidx(pidx) = tmpidx;
        end 
    end
end

if size(pmtbl, 1) > 1
    
    if sum(fexidx) > 0
        line(ax, pmtbl.Date(fexidx), pmtbl.Amount(fexidx), ...
                    'Color', col2, ...
                    'LineStyle', 'none', ...
                    'LineWidth', 1, ...
                    'Marker', 'o', ...
                    'MarkerSize', 1,...
                    'MarkerEdgeColor', col2, ...
                    'MarkerFaceColor', col2);
    end  
    
    if sum(~fexidx) >= 2
        fmdl = fitlm(pmtbl.DateNum(~fexidx), pmtbl.Amount(~fexidx), 'linear');
        ffit = predict(fmdl, pmtbl.DateNum(~fexidx));
        grad = fmdl.Coefficients.Estimate(2);
        studydateval = predict(fmdl, datenum(fromd) - offset);

        line(ax, pmtbl.Date(~fexidx), pmtbl.Amount(~fexidx), ...
                    'Color', col1, ...
                    'LineStyle', 'none', ...
                    'LineWidth', 1, ...
                    'Marker', 'o', ...
                    'MarkerSize', 4,...
                    'MarkerEdgeColor', col1, ...
                    'MarkerFaceColor', col1);

        line(ax, pmtbl.Date(~fexidx), ffit, ...
                    'Color', col3, ...
                    'LineStyle', '-', ...
                    'LineWidth', 1, ...
                    'Marker', 'none', ...
                    'MarkerSize', 2,...
                    'MarkerEdgeColor', col3, ...
                    'MarkerFaceColor', col3);

    end
    
    title(ax, sprintf('Patient %d (%d): %s %s %s', p, scid, meastype, periodtype, gradtype));

    xl = [fromd, tod];
    xlim(xl);
    ylim(yl);
    xtickangle(ax, 45);
    xlabel(ax, 'Date', 'FontSize', 8);
    ylabel(ax, meastype, 'FontSize', 8);
end

end

