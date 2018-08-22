function [f, p, niterations] = animatedProbDistConcurrent(animated_overall_pdoffset, max_offset, ninterventions, moviefilename)

% animatedALingmentConcurrent - function to display animated curve
% alignment and offset histogram through the iterative alignment process

v = VideoWriter(moviefilename, 'MPEG-4');
open(v);

plotsacross = 10;
plotsdown = 10;
for niterations = 1:2000
    if all(animated_overall_pdoffset(:,:,niterations)==0)
        break;
    end
end
niterations = niterations - 1;
days = 0:max_offset - 1;

[f,p] = createFigureAndPanel('Animation of Probability Distributions','portrait','a4');

for a = 1:ninterventions
    ax(a) = subplot(plotsdown, plotsacross, a, 'Parent', p);
    xl = [min(days) max(days)];
    xlim(xl);
    yl = [min(min(min(animated_overall_pdoffset(:,:,1:niterations),[],3), [], 2)), ...
          max(max(max(animated_overall_pdoffset(:,:,1:niterations),[],3), [], 2))];
    ylim(yl);
    title(ax(a), sprintf('%d', a));
    [xl, yl] = plotProbDistribution(ax(a), max_offset, animated_overall_pdoffset(a,:, 1), xl, yl, 'o', 0.5, 2.0, 'red', 'red');

    an(a) = animatedline(ax(a), days, animated_overall_pdoffset(a,:, 1), 'Color', 'blue', 'LineStyle', '-', 'Linewidth', 0.5, 'Marker', 'o', 'MarkerSize', 2.0, 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue'); 
end

frame = getframe(f);
writeVideo(v,frame);
frame = getframe(f);
writeVideo(v,frame);

for i = 1:niterations
    for a = 1:ninterventions
        %title(ax(a), sprintf('%d - Iteration %2d', a, i));
        p.Title = sprintf('Animation of Probability Distributions - Iteration %2d', i);
        clearpoints(an(a));
        addpoints(an(a), days, animated_overall_pdoffset(a,:, i));
    end
    drawnow nocallbacks;
    
    frame = getframe(f);
    writeVideo(v,frame);
    frame = getframe(f);
    writeVideo(v,frame);
end

close(v);
close(f);

end


