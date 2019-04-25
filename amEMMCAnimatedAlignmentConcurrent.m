function [f, p, niterations] = amEMMCAnimatedAlignmentConcurrent(animatedmeancurvemean, animatedoffsets, animatedlc, animated_overall_pdoffset, ...
    profile_pre, measures, max_offset, align_wind, nmeasures, ninterventions, nlatentcurves, runmode, basemoviefilename)

% amEMMCAnimatedAlingmentConcurrent - function to display animated curve
% alignment and offset histogram through the iterative alignment process
% and able to handle multiple sets of latent curves

for l = 1:nlatentcurves
    
    moviefilename = sprintf('%s - LC Set %d', basemoviefilename, l);
    v = VideoWriter(moviefilename, 'MPEG-4');
    open(v);

    plotsacross = 3;
    plotsdown = 3;
    for niterations = 1:2000
        if all(animatedmeancurvemean(l, :, :, niterations)==0)
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
        yl = [min(min(profile_pre(l, :, m)), min(min(animatedmeancurvemean(l, :, m, 1:niterations),[],4))), ...
              max(max(profile_pre(l, :, m)), max(max(animatedmeancurvemean(l, :, m, 1:niterations),[],4)))];
        ylim(yl);
        if measures.Mask(m) == 1
            title(ax(m), sprintf('LC%d %s - Iteration %2d', l, measures.DisplayName{m}, 1), 'BackgroundColor', 'green');
        else
            title(ax(m), sprintf('LC%d %s - Iteration %2d', l, measures.DisplayName{m}, 1));
        end
        line(ax(m),days, profile_pre(l, :, m), 'Color', 'red', 'LineStyle', ':', 'Linewidth', 0.5);
        line(ax(m), days, smooth(profile_pre(l, :, m),5), 'Color', 'red', 'LineStyle', '-', 'Linewidth', 0.5);

        an(m) = animatedline(ax(m), days, profile_pre(l, :, m), 'Color', 'blue', 'LineStyle', ':', 'Linewidth', 0.5);
        ansm(m) = animatedline(ax(m), days, smooth(profile_pre(l, :, m),5), 'Color', 'blue', 'LineStyle', '-', 'Linewidth', 0.5);

    end

    ax(m + 1) = subplot(plotsdown, plotsacross, m + 1, 'Parent', p);
    title(ax(m + 1), sprintf('LC%d Histogram of Offsets - Iteration %2d', l, 1));
    if runmode == 4 || runmode == 6 || runmode == 7
        bar((-1 * max_offset) + 1: 0, reshape(sum(animated_overall_pdoffset(l, :, max_offset:-1:1, 1), 2), [1 max_offset]), 0.5, 'FaceColor', 'black', 'FaceAlpha', 0.25, 'LineWidth', 0.2);
    else
        histogram(-1 * animatedoffsets(animatedlc(:,1) == l, 1))
    end
    xlim([((-1 * max_offset) + 0.5) 0.5]);
    ylim([0 ninterventions/2]);

    frame = getframe(f);
    writeVideo(v,frame);
    frame = getframe(f);
    writeVideo(v,frame);

    pause(1);

    for i = 1:niterations
        for m = 1:nmeasures
            if measures.Mask(m) == 1
                title(ax(m), sprintf('LC%d %s - Iteration %2d', l, measures.DisplayName{m}, i), 'BackgroundColor', 'green');
            else
                title(ax(m), sprintf('LC%d %s - Iteration %2d', l, measures.DisplayName{m}, i));
            end
            clearpoints(an(m));
            addpoints(an(m), days, animatedmeancurvemean(l, :, m, i));
            clearpoints(ansm(m));
            addpoints(ansm(m), days, smooth(animatedmeancurvemean(l, :, m, i),5)); 
        end
        drawnow nocallbacks;
        title(ax(m + 1), sprintf('LC%d Histogram of Offsets - Iteration %2d', l, i));
        if runmode == 4 || runmode == 6 || runmode == 7
            bar((-1 * max_offset) + 1: 0, reshape(sum(animated_overall_pdoffset(l, :, max_offset:-1:1, i), 2), [1 max_offset]), 0.5, 'FaceColor', 'black', 'FaceAlpha', 0.25, 'LineWidth', 0.2);
        else
            histogram(-1 * animatedoffsets(animatedlc(:,i) == l, i))
        end
        xlim([((-1 * max_offset) + 0.5) 0.5]);
        ylim([0 ninterventions/2]);

        frame = getframe(f);
        writeVideo(v,frame);
        frame = getframe(f);
        writeVideo(v,frame);
    end

    close(v);
    close(f);

end

end


