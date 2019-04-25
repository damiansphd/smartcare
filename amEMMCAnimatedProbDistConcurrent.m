function [f, p, niterations] = amEMMCAnimatedProbDistConcurrent(animated_overall_pdoffset, max_offset, ...
    ninterventions, nlatentcurves, basemoviefilename)

% amEMMCAnimatedProbDistConcurrent - function to display animated
% probability distributions through the iterative alignment process,
% handling multiple sets of latent curves


for l = 1:nlatentcurves
    
    moviefilename = sprintf('%s - LC Set %d', basemoviefilename, l);
    v = VideoWriter(moviefilename, 'MPEG-4');
    open(v);

    plotsacross = 10;
    plotsdown = 10;
    for niterations = 1:2000
        if all(animated_overall_pdoffset(l, :, :, niterations)==0)
            break;
        end
    end
    niterations = niterations - 1;
    days = 0:max_offset - 1;

    [f,p] = createFigureAndPanel(sprintf('LC%d Animation of Probability Distributions', l),'portrait','a4');

    for a = 1:ninterventions
        ax(a) = subplot(plotsdown, plotsacross, a, 'Parent', p);
        xl = [min(days) max(days)];
        xlim(xl);
        yl = [min(min(min(animated_overall_pdoffset(l, :, :, 1:niterations),[], 4), [], 3)), ...
              max(max(max(animated_overall_pdoffset(l, :, :, 1:niterations),[], 4), [], 3))];
        ylim(yl);
        title(ax(a), sprintf('%d', a));
        [xl, yl] = plotProbDistribution(ax(a), max_offset, reshape(animated_overall_pdoffset(l, a, :, 1), [max_offset, 1]), xl, yl, 'o', 0.5, 2.0, 'red', 'red');

        an(a) = animatedline(ax(a), days, reshape(animated_overall_pdoffset(l, a, :, 1), [max_offset, 1]), 'Color', 'blue', 'LineStyle', '-', 'Linewidth', 0.5, 'Marker', 'o', 'MarkerSize', 2.0, 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue'); 
    end

    frame = getframe(f);
    writeVideo(v,frame);
    frame = getframe(f);
    writeVideo(v,frame);

    for i = 1:niterations
        for a = 1:ninterventions
            %title(ax(a), sprintf('%d - Iteration %2d', a, i));
            p.Title = sprintf('LC%d Animation of Probability Distributions - Iteration %2d', l, i);
            clearpoints(an(a));
            addpoints(an(a), days, reshape(animated_overall_pdoffset(l, a, :, i), [max_offset, 1]));
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

end


