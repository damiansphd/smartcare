function [f, p, niterations] = animatedAlignmentSequential(animatedmeancurvemean, profile_pre, measures, max_offset, align_wind, nmeasures, moviefilename)

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
    ax = subplot(plotsdown,plotsacross,m, 'Parent', p);
    xl = [min(days) max(days)];
    xlim(xl);
    yl = [min(min(profile_pre(:,m)), min(min(animatedmeancurvemean(:,m,1:niterations),[],3))), ...
        max(max(profile_pre(:,m)), max(max(animatedmeancurvemean(:,m,1:niterations),[],3)))];
    ylim(yl);
    if measures.Mask(m) == 1
        title(sprintf('%s - Iteration %2d', measures.DisplayName{m}, 1), 'BackgroundColor', 'green');
    else
        title(sprintf('%s - Iteration %2d', measures.DisplayName{m}, 1));
    end
    line(days, profile_pre(:,m), 'Color', 'red', 'LineStyle', ':', 'Linewidth', 0.5);
    line(days, smooth(profile_pre(:,m),5), 'Color', 'red', 'LineStyle', '-', 'Linewidth', 0.5);

    an1 = animatedline(days, profile_pre(:,m), 'Color', 'blue', 'LineStyle', ':', 'Linewidth', 0.5);
    an2 = animatedline(days, smooth(profile_pre(:,m),5), 'Color', 'blue', 'LineStyle', '-', 'Linewidth', 0.5);
    
    frame = getframe(f);
    writeVideo(v,frame);

    pause(0.5);

    for i = 1:niterations
        if measures.Mask(m) == 1
            title(sprintf('%s - Iteration %2d', measures.DisplayName{m}, i), 'BackgroundColor', 'green');
        else
            title(sprintf('%s - Iteration %2d', measures.DisplayName{m}, i));
        end
        title(sprintf('%s - Iteration %2d', measures.DisplayName{m}, i));
        clearpoints(an1);
        addpoints(an1, days, animatedmeancurvemean(:, m, i));
        clearpoints(an2);
        addpoints(an2, days, smooth(animatedmeancurvemean(:, m, i),5));
        drawnow nocallbacks;
        %pause(0.01);
        
        frame = getframe(f);
        writeVideo(v,frame);
        
    end

end

close(v);
close(f);

end

