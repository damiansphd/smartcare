function amEMMCPlotHistOfTimeSinceLastExacerbation(pmPatients, amInterventions, ivandmeasurestable, ...
        npatients, maxdays, plotname, plotsubfolder, nlatentcurves)
    
% amEMMCPlotHistogramTimeSinceLastExacerbation - function to plot
% histograms of the time since last exacerbation (for all exacerbations)
% Split into two sets - 1) those where we know the time since last
% exacerbation, and 2) those where we only know it is at least since the
% start of the study

plottitle   = sprintf('%s - Histogram of Time Since Last Exacerbation', plotname);

pghght = 5;
pgwdth = 8;

[f, p] = createFigureAndPanelForPaper('', pgwdth, pghght);

ivandmeasurestable = innerjoin(ivandmeasurestable, unique(amInterventions(:,{'SmartCareID', 'PatientOffset'})), 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, 'RightVariables', {'PatientOffset'});
ivandmeasurestable.IVScaledDateNum = ivandmeasurestable.IVDateNum - ivandmeasurestable.PatientOffset;
ivandmeasurestable.IVScaledStopDateNum = ivandmeasurestable.IVStopDateNum - ivandmeasurestable.PatientOffset;

amInterventions.LastTreatEnd(:)       = -100;
amInterventions.TimeSinceLastTreat(:) = -100;
amInterventions.Category(:)           = 0;

for i = 1:size(amInterventions, 1)
    scid = amInterventions.SmartCareID(i);
    pred = amInterventions.Pred(i);
    %currstopdn = amInterventions.IVScaledStopDateNum(i);
    previdx = find(ivandmeasurestable.SmartCareID == scid & ivandmeasurestable.IVScaledStopDateNum < pred + 5, 1, 'last');
    if size(previdx, 1) ~= 0
        amInterventions.LastTreatEnd(i)       = ivandmeasurestable.IVScaledStopDateNum(previdx);
        amInterventions.TimeSinceLastTreat(i) = amInterventions.Pred(i) - amInterventions.LastTreatEnd(i);
        amInterventions.Category(i)           = 1;
    else 
        amInterventions.TimeSinceLastTreat(i) = amInterventions.Pred(i);
        amInterventions.Category(i)           = 2;
    end
end

%maxtime = max(amInterventions.TimeSinceLastTreat(amInterventions.Category == 1));
%binedges = [0, 21, 42, 63, 84, 105, 126, 147, 168];
binedges = [0, 28, 56, 84, 112, 140, 168];
maxperbin = 40;

ax = subplot(2, 2, 1,'Parent', p);
histogram(ax, amInterventions.TimeSinceLastTreat(amInterventions.Category == 1), 'BinEdges', binedges, 'LineWidth', 1);
ax.YLim = [0 maxperbin];
ax.XLim = [0, max(binedges)];
ax.XTick = binedges;
xlabel(ax, 'Days Since Last Treatment');
ylabel(ax, 'Number of Exacerbations');
ax.FontSize = 10;
ax.FontWeight = 'bold';

ax = subplot(2, 2, 2,'Parent', p);
histogram(ax, amInterventions.TimeSinceLastTreat(amInterventions.Category == 2), 'BinEdges', binedges, 'LineWidth', 1);
ax.YLim = [0 maxperbin];
ax.XLim = [0, max(binedges)];
ax.XTick = binedges;
xlabel(ax, 'Days Since Study Start');
ylabel(ax, 'Number of Exacerbations');
ax.FontSize = 10;
ax.FontWeight = 'bold';

binedges = [0, 21, 42, 63, 84, 105, 126, 147, 168];
%binedges = [0, 28, 56, 84, 112, 140, 168];
maxperbin = 40;

ax = subplot(2, 2, 3,'Parent', p);
histogram(ax, amInterventions.TimeSinceLastTreat(amInterventions.Category == 1), 'BinEdges', binedges, 'LineWidth', 1);
ax.YLim = [0 maxperbin];
ax.XLim = [0, max(binedges)];
ax.XTick = binedges;
xlabel(ax, 'Days Since Last Treatment');
ylabel(ax, 'Number of Exacerbations');
ax.FontSize = 10;
ax.FontWeight = 'bold';

ax = subplot(2, 2, 4,'Parent', p);
histogram(ax, amInterventions.TimeSinceLastTreat(amInterventions.Category == 2), 'BinEdges', binedges, 'LineWidth', 1);
ax.YLim = [0 maxperbin];
ax.XLim = [0, max(binedges)];
ax.XTick = binedges;
xlabel(ax, 'Days Since Study Start');
ylabel(ax, 'Number of Exacerbations');
ax.FontSize = 10;
ax.FontWeight = 'bold';


% save plot
savePlotInDir(f, plottitle, plotsubfolder);
savePlotInDirAsSVG(f, plottitle, plotsubfolder);
close(f);

fprintf('\n');


end
