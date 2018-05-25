function [offsets, profile_pre, profile_post, hstg, qual] = amAlignCurves(amNormcube, amInterventions, measures, max_offset, align_wind, nmeasures, ninterventions, run_type, detaillog)

% alignCurves = function to align measurement curves prior to intervention

meancurvesum   = zeros(max_offset + align_wind, nmeasures);
meancurvecount = zeros(max_offset + align_wind, nmeasures);
offsets        = zeros(1, ninterventions);
profile_pre    = zeros(nmeasures, max_offset+align_wind);
profile_post   = zeros(nmeasures, max_offset+align_wind);
hstg           = zeros(nmeasures, ninterventions, max_offset);
hstgc          = zeros(nmeasures, ninterventions, max_offset);
qual = 0;

% calculate mean curve over all interventions
for i = 1:ninterventions
    [meancurvesum, meancurvecount] = amAddToMean(meancurvesum, meancurvecount, amNormcube, amInterventions, i, max_offset, align_wind, nmeasures);
end

% store the mean curves pre-alignment for each measure for plotting
for m = 1:nmeasures
    for day = 1:max_offset + align_wind
        profile_pre(m, day) = meancurvesum(day, m)/meancurvecount(day, m);
    end
end

% iterate to convergence
pnt = 1;
cnt = 0;
ok  = 0;
while 1
    [meancurvesum, meancurvecount] = amRemoveFromMean(meancurvesum, meancurvecount, amNormcube, amInterventions, pnt, max_offset, align_wind, nmeasures);
    %check safety
    ok = 1;
    for i=1:max_offset + align_wind
        for m=1:nmeasures
            if meancurvecount(i,m) < 3
                if detaillog
                    fprintf('Intervention %d, Measure %s, dayprior %d <3 datapoints\n', pnt, measures.Name{m}, i);
                end
                ok = 0;
            end
        end
    end
    
    if ok == 1
        [better_offset, hstg, hstgc] = amBestFit(meancurvesum, meancurvecount, amNormcube, amInterventions, hstg, hstgc, pnt, max_offset, align_wind, nmeasures);
    else
        better_offset = amInterventions.Offset(pnt);
    end
    
    if better_offset ~= amInterventions.Offset(pnt)
        amInterventions.Offset(pnt) = better_offset;
        cnt = cnt+1;
    end
    [meancurvesum, meancurvecount] = amAddToMean(meancurvesum, meancurvecount, amNormcube, amInterventions, pnt, max_offset, align_wind, nmeasures);
        
    pnt = pnt+1;
    if pnt > ninterventions
        pnt = pnt - ninterventions;
        if cnt == 0
            if detaillog
                fprintf('Converged\n');
            end
            break;
        else
            if detaillog
                fprintf('Changed %d offsets on this iteration\n', cnt);
            end
            cnt = 0;
        end
    end
end

%computing the objective function result for converged offset array
for i=1:ninterventions
    amRemoveFromMean(meancurvesum, meancurvecount, amNormcube, amInterventions, i, max_offset, align_wind, nmeasures);
    qual = qual + amCalcObjFcn(meancurvesum, meancurvecount, amNormcube, amInterventions, hstg, hstgc, i, amInterventions.Offset(i), max_offset, align_wind, nmeasures, 0);
    amAddToMean(meancurvesum, meancurvecount, amNormcube, amInterventions, i, max_offset, align_wind, nmeasures);
end

for i=1:ninterventions 
    offsets(i) = amInterventions.Offset(i);
end

% store the mean curves post-alignment for each measure for plotting
for m = 1:nmeasures
    for day = 1:max_offset + align_wind
        profile_post(m, day) = meancurvesum(day, m)/meancurvecount(day, m);
    end
end

% scale the objective function result by the count of data points (for each
% measure, intervention, offset)
hstg(:,:,:) = hstg(:,:,:) ./ hstgc(:,:,:);

basedir = './';
subfolder = 'Plots';
plotsacross = 2;
plotsdown = round((nmeasures + 1) / plotsacross);

f = figure;
set(gcf, 'Units', 'normalized', 'OuterPosition', [0.45, 0, 0.35, 0.92], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = sprintf('Alignment Model - %s - ErrFcn = %7.4f', run_type, qual);
p.TitlePosition = 'centertop'; 
p.FontSize = 16;
p.FontWeight = 'bold';

for m = 1:nmeasures
    xl = [-1 * (max_offset + align_wind) 0];
    yl = [min(min(profile_pre(m,:)), min(profile_post(m,:))) max(max(profile_pre(m,:)), max(profile_post(m,:)))];
    subplot(plotsdown,plotsacross,m,'Parent',p)
    plot([-1 * (max_offset + align_wind): -1], profile_pre(m,:), 'color', 'blue')
    xlim(xl);
    ylim(yl);
    hold on;
    plot([-1 * (max_offset + align_wind): -1], profile_post(m,:), 'color', 'red');
    hold off;
    title(measures.DisplayName(m));
end

subplot(plotsdown, plotsacross, nmeasures + 1, 'Parent', p)
histogram(amInterventions.Offset)
xlim([-0.5 (max_offset - 0.5)]);
ylim([0 50]);
title('Histogram')

filename = sprintf('Alignment Model - %s - Err Function.png', run_type);
saveas(f,fullfile(basedir, subfolder, filename));
filename = sprintf('Alignment Model - %s - Err Function.svg', run_type);
saveas(f,fullfile(basedir, subfolder, filename));

close(f);

end

