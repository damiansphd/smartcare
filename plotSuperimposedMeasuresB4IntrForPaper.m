function plotSuperimposedMeasuresB4IntrForPaper(ax, amnormcubesingleintr, amnormcubesingleintrsmth, xl, yl, ...
    tmpmeasures, tmpnmeasures, max_offset, align_wind, offset, ex_start)

% plotSuperimposedMeasuresB4Intr - plots the measures for the period prior
% to a treatment

ylabelposmult = 1.125;

days = xl(1):xl(2);

dfrom = 1; 
dto   = max_offset + align_wind - 1 - offset;

mfrom = 1 + offset; 
mto   = max_offset + align_wind - 1;


for m = 1:tmpnmeasures
    [smcolour, rwcolour] = getColourForMeasure(tmpmeasures.DisplayName{m});
    lstyle = '-';
    lwidth = 1.5;
    %plot(ax, days, amnormcubesingleintr(:, tmpmeasures.Index(m)), ...
    %    'Color', rwcolour, ...
    %    'LineStyle', ':', ...
    %   'Marker', 'o', ...
    %    'LineWidth',1,...
    %    'MarkerSize',2,...
    %    'MarkerEdgeColor','b',...
    %    'MarkerFaceColor','g');

    plot(ax, days(dfrom:dto), amnormcubesingleintrsmth(mfrom:mto, tmpmeasures.Index(m)), ...
        'Color', smcolour, ...
        'LineStyle', lstyle, ...
        'Marker', 'none', ...
        'LineWidth', lwidth);
    
    xlim(ax, xl);
    ylim(ax, yl);
end

if ex_start ~= 0
    [~, ~] = plotVerticalLine(ax, 0, xl, yl, 'black', '-', 0.5); % plot ex_start
end

xlabel(ax, 'Days before/after exacerbation start');
ylabeltext = '\Delta value from exacerbation start (\sigma)';
ylabel(ax, ylabeltext, 'Position',[(xl(1) - 12) (yl(1) + (yl(2) - yl(1) * ylabelposmult))], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Rotation', 0);

end

