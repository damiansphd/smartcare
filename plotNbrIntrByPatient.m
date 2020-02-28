function plotNbrIntrByPatient(physdata, offset, ivandmeasurestable, cdPatient, study)

% plotNbrIntrByPatient - plots bar chart of number of interventions by
% patient (for patients with enough data to be analysed)

goodpatlist = unique(physdata.SmartCareID);

%goodpattbl = table('Size',[size(goodpatlist, 1), 6], ...
%    'VariableTypes', {'double',      'double',     'double',    'double',    'double',     'double'}, ...
%    'VariableNames', {'SmartCareID', 'StudyStart', 'MeasStart', 'StartDate', 'EndDateNum', 'NbrIntr'});

goodpattbl = table('Size',[size(goodpatlist, 1), 1], ...
    'VariableTypes', {'double'}, ...
    'VariableNames', {'SmartCareID'});

goodpattbl.SmartCareID = goodpatlist;
goodpattbl = innerjoin(goodpattbl, cdPatient, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'}, 'RightVariables', {'StudyDate'});
goodpattbl.StudyDn = datenum(goodpattbl.StudyDate) - offset + 1;

minmeasdn = varfun(@min, physdata(:, {'SmartCareID', 'DateNum'}), 'GroupingVariables', {'SmartCareID'});
maxmeasdn = varfun(@max, physdata(:, {'SmartCareID', 'DateNum'}), 'GroupingVariables', {'SmartCareID'});

goodpattbl = innerjoin(goodpattbl, minmeasdn, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, ...
                        'RightVariables', {'min_DateNum'});
goodpattbl.Properties.VariableNames{'min_DateNum'} = 'MeasStart';
goodpattbl.StartDate = min(goodpattbl.StudyDn, goodpattbl.MeasStart);

goodpattbl.StudyEnd = goodpattbl.StudyDn + 183;
goodpattbl = innerjoin(goodpattbl, maxmeasdn, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, ...
                        'RightVariables', {'max_DateNum'});
goodpattbl.Properties.VariableNames{'max_DateNum'} = 'MeasEnd';
goodpattbl.EndDate = max(goodpattbl.StudyEnd, goodpattbl.MeasEnd);


intrjoin = innerjoin(ivandmeasurestable, goodpattbl, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, ...
                        'RightVariables', {'StartDate', 'EndDate'});

%filtintr = intrjoin(intrjoin.IVStopDateNum >= intrjoin.StartDate & intrjoin.IVDateNum <= intrjoin.EndDate + 20, :);
filtintr = intrjoin;
filtintr = varfun(@min, filtintr(:, {'SmartCareID', 'IVDateNum'}), 'GroupingVariables', 'SmartCareID');
filtintr.Properties.VariableNames{'GroupCount'} = 'NbrIntr';

goodpattbl = outerjoin(goodpattbl, filtintr, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, ...
                        'RightVariables', {'NbrIntr'});
goodpattbl.NbrIntr(isnan(goodpattbl.NbrIntr)) = 0;                 
nbrintr = varfun(@max, goodpattbl(:,{'NbrIntr'}), 'GroupingVariables', {'NbrIntr'});


plotsdown   = 1; 
plotsacross = 1;
thisplot = 1;
widthinch = 3.5;
heightinch = 2.5;
fontname = 'Arial';
plottitle = sprintf('%s - Nbr Intr By Patient For Paper', study);
[f, p] = createFigureAndPanelForPaper('', widthinch, heightinch);
ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
hold on;
for i = 1:size(nbrintr, 1)
    b = bar(ax, nbrintr.NbrIntr(i), nbrintr.GroupCount(i));
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
xlim(ax, [-0.6, 6.6]);
% save plot
plotsubfolder = sprintf('Plots/%s', study);
savePlotInDir(f, plottitle, plotsubfolder);
savePlotInDirAsSVG(f, plottitle, plotsubfolder);
close(f);


end

