clear; close all; clc;

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
[studynbr1, study1, studyfullname1] = selectStudy();
[modelrun1, modelidx1, models1] = amEMMCSelectModelRunFromDir(study1, '',      '', 'IntrFilt', 'TGap',       '');

fprintf('\n');

[studynbr2, study2, studyfullname2] = selectStudy();
[modelrun2, modelidx2, models2] = amEMMCSelectModelRunFromDir(study2, '',      '', 'IntrFilt', 'TGap',       '');

[meancurvemean1, meancurvecount1, measures1, min_offset1, max_offset1, ...
    align_wind1, nmeasures1, ex_start1, countthreshold1] = loadModelRunVariables(basedir, subfolder, modelrun1);

[meancurvemean2, meancurvecount2, measures2, min_offset2, max_offset2, ...
    align_wind2, nmeasures2, ex_start2, countthreshold2] = loadModelRunVariables(basedir, subfolder, modelrun2);

invmeasarray1 = getInvertedMeasures(study1);
pridx1 = measures1.Index(ismember(measures1.DisplayName, invmeasarray1));

invmeasarray2 = getInvertedMeasures(study2);
pridx2 = measures2.Index(ismember(measures2.DisplayName, invmeasarray2));

meanwindow = 7;
smoothwdth = 4;
compactplot = true;
shifttext = sprintf('%ddMeanShift', meanwindow);
plottitle   = sprintf('%svs%s Typical Profile Comparison %s', study1, study2, shifttext);

if ismember(study1, {'SC'}) && ismember(study2, {'CL'})
    commonmeas = {'Cough'; 'O2Saturation'; 'PulseRate'; 'SleepActivity'; 'Weight'; 'Wellness'};
    ncommonmeas = size(commonmeas, 1);
elseif ismember(study1, {'CL'}) && ismember(study2, {'CL'})
    commonmeas = {'Activity'; 'Appetite'; 'Breathlessness'; 'Cough'; ...
                  'O2Saturation'; 'PulseRate'; 'RespiratoryRate'; 'SleepActivity'; ...
                  'SleepDisturbance'; 'SputumVolume'; 'Temperature'; 'Tiredness'; ...
                  'Weight'; 'Wellness'};
    ncommonmeas = size(commonmeas, 1);
end

meancurvemean1(1, :, pridx1) = meancurvemean1(1, :, pridx1) * -1;
for m = 1:nmeasures1
    meancurvemean1(1, meancurvecount1(1, :, m) < countthreshold1, m) = NaN;
    meancurvemean1(1, :, m) = movmean(meancurvemean1(1, :, m), smoothwdth, 'omitnan');
    vertshift1 = mean(meancurvemean1(1, (align_wind1 + max_offset1 + ex_start1 - meanwindow):(align_wind1 + max_offset1 + ex_start1), m));
    meancurvemean1(1, :, m) = meancurvemean1(1, :, m) - vertshift1;
    fprintf('For curve %d and measure %13s, vertical shift is %.3f\n', 1, measures1.DisplayName{m}, -vertshift1);
end

meancurvemean2(1, :, pridx2) = meancurvemean2(1, :, pridx2) * -1;
for m = 1:nmeasures2
    meancurvemean2(1, meancurvecount2(1, :, m) < countthreshold2, m) = NaN;
    meancurvemean2(1, :, m) = movmean(meancurvemean2(1, :, m), smoothwdth, 'omitnan');
    vertshift2 = mean(meancurvemean2(1, (align_wind2 + max_offset2 + ex_start2 - meanwindow):(align_wind2 + max_offset2 + ex_start2), m));
    meancurvemean2(1, :, m) = meancurvemean2(1, :, m) - vertshift2;
    fprintf('For curve %d and measure %13s, vertical shift is %.3f\n', 2, measures2.DisplayName{m}, -vertshift2);
end

if ncommonmeas <= 9
    plotsacross = 3;
elseif ncommonmeas <= 16
    plotsacross = 4;
else
    plotsacross = 5;
end
plotsdown   = ceil(ncommonmeas/plotsacross);
pghght = 11;
pgwdth = 8.5;

[f, p] = createFigureAndPanelForPaper('', pgwdth, pghght);


% set the plot range over all curves to ensure comparable visual scaling
yl = [min(min(min(min(meancurvemean1))), min(min(min(meancurvemean2))) )...
      max(max(max(max(meancurvemean1))), max(max(max(meancurvemean1))) )];

xfrom1 = -1 * (align_wind1 + max_offset1 - 1 + ex_start1);
xto1   = -1 * (1 + ex_start1);
xfrom2 = -1 * (align_wind2 + max_offset2 - 1 + ex_start2);
xto2   = -1 * (1 + ex_start2);

xl = [min(xfrom1, xfrom2), max(xto1, xto2)];


legendtext = {study1; study2};


col1 = [0, 0.447, 0.741];
col2 = [0.85, 0.325, 0.098];
lstyle = '-';
lwidth = 1.5;
anchor = 1;

tmp_meancurvemean1  = reshape(meancurvemean1(1, :, :),  [max_offset1 + align_wind1 - 1, nmeasures1]);
tmp_meancurvemean2  = reshape(meancurvemean2(1, :, :),  [max_offset2 + align_wind2 - 1, nmeasures2]);
for cm = 1:ncommonmeas
    ax = subplot(plotsdown, plotsacross, cm, 'Parent', p);
    ax.FontSize = 8;
    ax.FontName = 'Arial';
    ax.TickDir = 'out';
    
    xlabel(ax, 'Days from exacerbation start');
    ylabel(ax, 'Change from stable baseline (s.d.)');
    %if cm/plotsacross == round(cm/plotsacross)
    %    legend(ax, legendtext, 'Location', 'eastoutside', 'FontSize', 6);
    %end
    title(ax, commonmeas{cm});
    midx1 = measures1.Index(ismember(measures1.DisplayName, commonmeas(cm)));
    midx2 = measures2.Index(ismember(measures2.DisplayName, commonmeas(cm)));
%    [xl, yl] = plotLatentCurve(ax, max_offset1, (align_wind1 + ex_start1), (min_offset1 + ex_start1), meancurvemean1(:, midx1), xl, yl, col1, lstyle, lwidth, anchor);
%    [xl, yl] = plotLatentCurve(ax, max_offset2, (align_wind2 + ex_start2), (min_offset2 + ex_start2), meancurvemean2(:, midx2), xl, yl, col1, lstyle, lwidth, anchor);

    
    dfrom1 = max_offset1 + align_wind1 - 1;
    dto1   = 1;
    line(ax, (-1 * dfrom1):(-1 * dto1), ...
        tmp_meancurvemean1(:, midx1), ...
        'Color', col1, ...
        'LineStyle', lstyle, ...
        'LineWidth', lwidth);
    
    dfrom2 = max_offset2 + align_wind2 - 1;
    dto2   = 1;
    line(ax, (-1 * dfrom2):(-1 * dto2), ...
        tmp_meancurvemean2(:,midx2), ...
        'Color', col2, ...
        'LineStyle', lstyle, ...
        'LineWidth', lwidth);
    
end

% save plot
savePlotInDir(f, plottitle, 'Plots');
close(f);

