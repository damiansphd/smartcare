function plotNbrIntrByPatient(physdata, offset, ivandmeasurestable, cdPatient, amInterventions, study)

% plotNbrIntrByPatient - plots bar chart of number of interventions by
% patient (for patients with enough data to be analysed)

goodpattbl = cdPatient(:, {'ID', 'StudyDate', 'PatClinDate'});
goodpattbl.Properties.VariableNames{'ID'} = 'SmartCareID';
goodpattbl.StudyDn   = datenum(goodpattbl.StudyDate) - offset + 1;
goodpattbl.PatClinDn = datenum(goodpattbl.PatClinDate) - offset + 1;

minmeasdn = varfun(@min, physdata(:, {'SmartCareID', 'DateNum'}), 'GroupingVariables', {'SmartCareID'});
goodpattbl = outerjoin(goodpattbl, minmeasdn, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, ...
                        'RightVariables', {'min_DateNum'}, 'Type', 'left');
goodpattbl.Properties.VariableNames{'min_DateNum'} = 'MeasStart';
goodpattbl.StartDate = min(goodpattbl.StudyDn, goodpattbl.MeasStart);

maxmeasdn = varfun(@max, physdata(:, {'SmartCareID', 'DateNum'}), 'GroupingVariables', {'SmartCareID'});
goodpattbl = outerjoin(goodpattbl, maxmeasdn, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, ...
                        'RightVariables', {'max_DateNum'}, 'Type', 'left');                    
goodpattbl.Properties.VariableNames{'max_DateNum'} = 'MeasEnd';
goodpattbl.EndDate = max(goodpattbl.PatClinDn, goodpattbl.MeasEnd);

allintr = varfun(@min, ivandmeasurestable(:, {'SmartCareID', 'IVDateNum'}), 'GroupingVariables', 'SmartCareID');
allintr.Properties.VariableNames{'GroupCount'} = 'NbrAllIntr';
goodpattbl = outerjoin(goodpattbl, allintr, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, ...
                        'RightVariables', {'NbrAllIntr'}, 'Type', 'left');
goodpattbl.NbrAllIntr(isnan(goodpattbl.NbrAllIntr)) = 0;                 
nbrallintr = varfun(@max, goodpattbl(:,{'NbrAllIntr'}), 'GroupingVariables', {'NbrAllIntr'});

predintr = varfun(@min, amInterventions(:, {'SmartCareID', 'IVDateNum'}), 'GroupingVariables', 'SmartCareID');
predintr.Properties.VariableNames{'GroupCount'} = 'NbrPredIntr';
goodpattbl = outerjoin(goodpattbl, predintr, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, ...
                        'RightVariables', {'NbrPredIntr'}, 'Type', 'left');
goodpattbl.NbrPredIntr(isnan(goodpattbl.NbrPredIntr)) = 0;                 
nbrpredintr = varfun(@max, goodpattbl(:,{'NbrPredIntr'}), 'GroupingVariables', {'NbrPredIntr'});

plotsdown   = 2; 
plotsacross = 1;
thisplot = 1;
widthinch = 3.5;
heightinch = 5.5;
fontname = 'Arial';
plottitle = sprintf('%s - Nbr Intr By Patient For Paper', study);
[f, p] = createFigureAndPanelForPaper('', widthinch, heightinch);
ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
hold on;
for i = 1:size(nbrallintr, 1)
    b = bar(ax, nbrallintr.NbrAllIntr(i), nbrallintr.GroupCount(i));
    if i == 1
        b.FaceColor = [1, 1, 1];
    else
        b.FaceColor = [0.6, 0.6, 0.6];
    end
end
ax.FontSize = 6;
ax.FontName = fontname;
xlabel(ax, 'Number of acute pulmonary exacerbations', 'FontSize', 8);
ylabel(ax, 'Number of participants', 'FontSize', 8);
title(ax, 'All Interventions', sprintf('p = %d, n = %d', size(goodpattbl, 1), sum(goodpattbl.NbrAllIntr)), 'FontSize', 8);
xlim(ax, [-0.6, max(nbrallintr.NbrAllIntr) + 0.6]);

thisplot = 2;
ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
hold on;
for i = 1:size(nbrpredintr, 1)
    b = bar(ax, nbrpredintr.NbrPredIntr(i), nbrpredintr.GroupCount(i));
    if i == 1
        b.FaceColor = [1, 1, 1];
    else
        b.FaceColor = [0.6, 0.6, 0.6];
    end
end
ax.FontSize = 6;
ax.FontName = fontname;
xlabel(ax, 'Number of acute pulmonary exacerbations', 'FontSize', 8);
ylabel(ax, 'Number of participants', 'FontSize', 8);
title(ax, 'Predicted Interventions', sprintf('p = %d, n = %d', size(goodpattbl, 1), sum(goodpattbl.NbrPredIntr)), 'FontSize', 8);
xlim(ax, [-0.6, max(nbrpredintr.NbrPredIntr) + 0.6]);

% save plot
plotsubfolder = sprintf('Plots/%s', study);
savePlotInDir(f, plottitle, plotsubfolder);
savePlotInDirAsSVG(f, plottitle, plotsubfolder);
close(f);


end

