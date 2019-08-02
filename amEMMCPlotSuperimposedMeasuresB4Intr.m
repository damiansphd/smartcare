function amEMMCPlotSuperimposedMeasuresB4Intr(amIntrNormcube, amInterventions, ...
    measures, max_offset, align_wind, nmeasures, ninterventions, ex_start, plotsubfolder, shiftmode)

% amEMMCPlotSuperimposedAlignedCurves - wrapper around the
% plotSuperimposedAlignedCurves to plot for each set of latent curves

if shiftmode == 1
    shifttext = 'MeanShift';
elseif shiftmode == 2
    shifttext = 'MaxShift';
elseif shiftmode == 3
    shifttext = 'ExZeroShift';
elseif shiftmode == 4
    meanwindow = 7;
    shifttext = sprintf('%ddMeanShift', meanwindow);
else
    fprintf('**** Unknown shift mode ****\n');
end

plotsacross = 1;
plotsdown   = 1;

smoothwdth = 4;

for i = 1:ninterventions
%for i = 45:45
scenAearlylateexac = [1, 6];
scenPsubpop1candidates = [8, 39, 41, 42, 96];
scenPsubpop1example    = [42];
scenPsubpop2Pcandidates = [33, 37, 43, 46, 50, 52, 67, 69];
scenPsubpop2example    = [52];
scenPsubpop3Pcandidates = [1, 4, 6, 9, 32, 45, 62, 66, 72, 87];
scenPsubpop3example    = [6];
scenPsubpopexamples = [42, 52, 6, 45, 1];
%scenPsubpopexamples = [42, 52, 45];

if ismember(i, scenPsubpopexamples)
    amnormcubesingleintr = amIntrNormcube(i, :, :);
    aminterventionsrow   = amInterventions(i, :);
    amnormcubesingleintrsmth = amnormcubesingleintr;
    tmp_ex_start = ex_start(aminterventionsrow.LatentCurve);
    tmp_offset   = aminterventionsrow.Offset;
    plotname = sprintf('Super-Imposed Measures - Intervention %d Participant ID %d Hosp %3s, Treatment Date %s', aminterventionsrow.IntrNbr, ...
        aminterventionsrow.SmartCareID, aminterventionsrow.Hospital{1}, datestr(aminterventionsrow.IVStartDate, 29));
    
    % Preprocess the measures :-
    % 1) invert pulse rate
    % 2) apply a vertical shift (using methodology selected)
    pridx = ismember(measures.DisplayName, {'PulseRate'});
    amnormcubesingleintr(1, :, pridx) = amnormcubesingleintr(1, :, pridx) * -1;
    for m = 1:nmeasures
        amnormcubesingleintrsmth(1, :, m) = movmean(amnormcubesingleintr(1, :, m), smoothwdth, 'omitnan');
        if all(isnan(amnormcubesingleintrsmth(1, 1:(align_wind + max_offset + tmp_ex_start + tmp_offset), m)))
                vertshift = 0;
        else
            if shiftmode == 1
                vertshift = mean(amnormcubesingleintrsmth(1, 1:(align_wind + max_offset + tmp_ex_start + tmp_offset), m), 'omitnan');
            elseif shiftmode == 2
                vertshift = max(amnormcubesingleintrsmth(1, 1:(align_wind + max_offset + tmp_ex_start + tmp_offset), m), 'omitnan');
            elseif shiftmode == 3
                vertshift = amnormcubesingleintrsmth(1, find(~isnan(amnormcubesingleintrsmth(1, 1:(align_wind + max_offset + tmp_ex_start + tmp_offset), m)), 1, 'last'), m);
            elseif shiftmode == 4
                vertshift = mean(amnormcubesingleintrsmth(1, (align_wind + max_offset + tmp_ex_start + tmp_offset - meanwindow):(align_wind + max_offset + tmp_ex_start + tmp_offset), m), 'omitnan');
            end
        end
        amnormcubesingleintr(1, :, m) = amnormcubesingleintr(1, :, m) - vertshift;
        amnormcubesingleintrsmth(1, :, m) = amnormcubesingleintrsmth(1, :, m) - vertshift;
        fprintf('For intervention %3d, measure %13s, vertical shift is %.3f\n', i, measures.DisplayName{m}, -vertshift);
    end

    % set the plot range over all curves to ensure comparable visual scaling
    xfrom = -1 * (align_wind + max_offset - 1);
    xto   = -1;
    xl = [xfrom, xto];
    %yl = [min(min(amnormcubesingleintrsmth(1, :, logical(measures.Mask)))) ...
    %      max(max(amnormcubesingleintrsmth(1, :, logical(measures.Mask))))];
    yl = [-4, 4];

    % plot all measures superimposed
    tmp_amnormcubesingleintr  = reshape(amnormcubesingleintr(1, :, :),  [max_offset + align_wind - 1, nmeasures]);
    tmp_amnormcubesingleintrsmth  = reshape(amnormcubesingleintrsmth(1, :, :),  [max_offset + align_wind - 1, nmeasures]);

    plottitle   = sprintf('%s - %s', plotname, shifttext);
    [f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');
    ax = subplot(plotsdown, plotsacross, 1, 'Parent',p);
    hold on;
    plotSuperimposedMeasuresB4Intr(ax, tmp_amnormcubesingleintr, tmp_amnormcubesingleintrsmth, xl, yl, ...
        measures, max_offset, align_wind, tmp_ex_start, tmp_offset, plottitle);
    hold off;
    % save plot
    savePlotInDir(f, plottitle, plotsubfolder);
    savePlotInDirAsSVG(f, plottitle, plotsubfolder);
    close(f);
end

end

end
