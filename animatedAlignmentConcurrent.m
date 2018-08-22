function [f, p, niterations] = animatedAlignmentConcurrent(animatedmeancurvemean, animatedoffsets, profile_pre, measures, max_offset, align_wind, nmeasures, ninterventions, moviefilename)

% animatedALingmentConcurrent - function to display animated curve
% alignment and offset histogram through the iterative alignment process

v = VideoWriter(moviefilename, 'MPEG-4');
open(v);

plotsacross = 3;
plotsdown = 3;
for niterations = 1:2000
    if all(animatedmeancurvemean(:,:,niterations)==0)
        break;
    end
end
niterations = niterations - 1;
days = -1 * (max_offset+align_wind-1):-1;

[f,p] = createFigureAndPanel('Animation of Curve Alignment','portrait','a4');

for m = 1:nmeasures
    ax(m) = subplot(plotsdown, plotsacross, m, 'Parent', p);
    xl = [min(days) max(days)];
    xlim(xl);
    yl = [min(min(profile_pre(:,m)), min(min(animatedmeancurvemean(:,m,1:niterations),[],3))), ...
        max(max(profile_pre(:,m)), max(max(animatedmeancurvemean(:,m,1:niterations),[],3)))];
    ylim(yl);
    if measures.Mask(m) == 1
        title(ax(m), sprintf('%s - Iteration %2d', measures.DisplayName{m}, 1), 'BackgroundColor', 'green');
    else
        title(ax(m), sprintf('%s - Iteration %2d', measures.DisplayName{m}, 1));
    end
    line(ax(m),days, profile_pre(:,m), 'Color', 'red', 'LineStyle', ':', 'Linewidth', 0.5);
    line(ax(m), days, smooth(profile_pre(:,m),5), 'Color', 'red', 'LineStyle', '-', 'Linewidth', 0.5);

    an(m) = animatedline(ax(m), days, profile_pre(:,m), 'Color', 'blue', 'LineStyle', ':', 'Linewidth', 0.5);
    ansm(m) = animatedline(ax(m), days, smooth(profile_pre(:,m),5), 'Color', 'blue', 'LineStyle', '-', 'Linewidth', 0.5);
    
end
ax(m + 1) = subplot(plotsdown, plotsacross, m + 1, 'Parent', p);
title(ax(m + 1), sprintf('Histogram of Offsets - Iteration %2d', 1));
histogram(-1 * animatedoffsets(:,1))
xlim([(-1 * max_offset) + 0.5, 0.5]);
ylim([0 ninterventions]);

frame = getframe(f);
writeVideo(v,frame);
frame = getframe(f);
writeVideo(v,frame);

pause(1);

for i = 1:niterations
    for m = 1:nmeasures
        if measures.Mask(m) == 1
            title(ax(m), sprintf('%s - Iteration %2d', measures.DisplayName{m}, i), 'BackgroundColor', 'green');
        else
            title(ax(m), sprintf('%s - Iteration %2d', measures.DisplayName{m}, i));
        end
        clearpoints(an(m));
        addpoints(an(m), days, animatedmeancurvemean(:, m, i));
        clearpoints(ansm(m));
        addpoints(ansm(m), days, smooth(animatedmeancurvemean(:, m, i),5)); 
    end
    drawnow nocallbacks;
    title(ax(m + 1), sprintf('Histogram of Offsets - Iteration %2d', i));
    histogram(ax(m+1), -1 * animatedoffsets(:,i))
    xlim([(-1 * max_offset) + 0.5, 0.5]);
    ylim([0 ninterventions]);
    
    frame = getframe(f);
    writeVideo(v,frame);
    frame = getframe(f);
    writeVideo(v,frame);
end

close(v);
close(f);

end


