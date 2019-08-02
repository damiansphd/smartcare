function plotSuperimposedAlignedCurvesForPaper(ax, meancurvemean, xl, yl, ...
    tmpmeasures, tmpnmeasures, min_offset, max_offset, align_wind, ex_start, study)

% plotSuperimposedAlignedCurves - plots the aligned curves for each of the
% measures superimposed on a single plot to show any timing differences in
% the declines

anchor = 1; % latent curve is to be anchored on the plot (right side at min_offset)

[tmpmeasures] = sortMeasuresForPaper(study, tmpmeasures);

for m = 1:tmpnmeasures
    thiscolour = getColourForMeasure(tmpmeasures.DisplayName{m});
    lstyle = '-';
    lwidth = 1.5;
    [xl, yl] = plotLatentCurve(ax, max_offset, (align_wind + ex_start), (min_offset + ex_start), meancurvemean(:, tmpmeasures.Index(m)), xl, yl, thiscolour, lstyle, lwidth, anchor);
end

if ex_start ~= 0
    [xl, yl] = plotVerticalLine(ax, 0, xl, yl, 'black', '-', 0.5); % plot ex_start
end

end

