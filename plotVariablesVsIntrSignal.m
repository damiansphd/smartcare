function plotVariablesVsIntrSignal(amLabelledInterventions, plotsubfolder, study)

% plotVariablesVsIntrSignal - visualisation of intr signal status vs time, plus
% box plots of variables vs intr signal for interventions
% with enough data

amlabintr = amLabelledInterventions(amLabelledInterventions.Sparse=='N', {'SmartCareID', 'Hospital', 'IVStartDate', 'IVDateNum', 'Route', 'DrugTherapy', 'NoSignal'});

plottitle = sprintf('%s Interventions - Signal vs Time Analysis', study);
pghght = 11;
pgwdth = 8;

plotsdown = 3;
plotsacross = 1;
thisplot = 1;

ycats = {'N'; 'M'; 'Y'};

ysubcats1 = {'Oral'; 'IVPBO'; 'IV'};
offsets1 = [-0.1, 0, 0.1];
ysubcats2 = {'None'; 'Symkevi'; 'Triple Therapy'};
offsets2 = [-0.1, 0, 0.1];

colarray = [0     , 0.4470, 0.7410 ; ...
            0.8500, 0.3250, 0.0980 ; ...
            0.9290, 0.6940, 0.1250 ; ...
            0.4940, 0.1840, 0.5560];

[f, p] = createFigureAndPanelForPaper(plottitle, pgwdth, pghght);

ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
hold on;
sc = 1;
for y = 1:size(ycats, 1)
    idx = ismember(amlabintr.NoSignal, ycats(y));
    ydata = ones(sum(idx), 1) * y;
    scatter(ax, amlabintr.IVStartDate(idx), ydata, [], colarray(sc, :), 'filled');
end
ax.YAxis.TickValues = [1, 2, 3];
ax.YAxis.Limits = [0 4];
ax.YAxis.TickLabels = ycats;
title(ax, 'Signal vs Study Days - all examples with enough data');
xlabel(ax, 'Study Days');
ylabel(ax, 'No Signal ?');
legend({'All'},'Location','eastoutside','NumColumns',1)
hold off;

thisplot = thisplot + 1;
ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
hold on;
for y = 1:size(ycats, 1)
    idx = ismember(amlabintr.NoSignal, ycats(y));
    for sc = 1:size(ysubcats1, 1)
        scidx = idx & ismember(amlabintr.Route, ysubcats1(sc));
        ydata = (ones(sum(scidx), 1) * y) + offsets1(sc);
        scatter(ax, amlabintr.IVStartDate(scidx), ydata, [], colarray(sc, :), 'filled');
    end
end
ax.YAxis.TickValues = [1, 2, 3];
ax.YAxis.Limits = [0 4];
ax.YAxis.TickLabels = ycats;
title(ax, 'Signal vs Study Days - by Treatment type');
xlabel(ax, 'Study Days');
ylabel(ax, 'No Signal ?');
legend(ysubcats1,'Location','eastoutside','NumColumns',1)
hold off;


thisplot = thisplot + 1;
ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
hold on;
for y = 1:size(ycats, 1)
    idx = ismember(amlabintr.NoSignal, ycats(y));
    for sc = 1:size(ysubcats2, 1)
        scidx = idx & ismember(amlabintr.DrugTherapy, ysubcats2(sc));
        ydata = (ones(sum(scidx), 1) * y) + offsets2(sc);
        scatter(ax, amlabintr.IVStartDate(scidx), ydata, [], colarray(sc, :), 'filled');
    end
end
ax.YAxis.TickValues = [1, 2, 3];
ax.YAxis.Limits = [0 4];
ax.YAxis.TickLabels = ycats;
title(ax, 'Signal vs Study Days - by Treatment type');
xlabel(ax, 'Study Days');
ylabel(ax, 'No Signal ?');
legend(ysubcats2,'Location','eastoutside','NumColumns',1)
hold off;

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
%savePlotInDirAsSVG(f, plottitle, plotsubfolder);
close(f);

scattervartext = {'Time',                   'Scatter' ...
                  'BMI',                      'Box';  ...
                  'Age',                      'Box'};     

barvartext = {'Pct Gender'; ...
              'Pct Type of AB Treatments'; ...
              'Mod Therapy'; ...
              'Pct Mod Therapy'};

end

