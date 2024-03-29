function [brDTExStats, sumtable, hospsumtable] = calcExFrequencyByDT(offset, ivandmeasurestable, cdPatient, cdDrugTherapy, amInterventions, study, textsuffix)

% calcExFrequencyByDT - function to analyse the frequency of exacerbations
% (per patient year in the study) by type of drug therapy.

tic
brDTExStats = table('Size',[1 11], ...
    'VariableTypes', {'double', 'cell',     'cell',        'cell',   'datetime',  'double',  'datetime', 'double', 'double',  'double',  'double'}, ...
    'VariableNames', {'ID',     'Hospital', 'StudyNumber', 'DTType', 'StartDate', 'StartDn', 'EndDate',  'EndDn',  'NbrDays', 'NbrIntr', 'NbrPredIntr'});

rowtoadd = brDTExStats;
brDTExStats(1, :) = [];

for p = 1:size(cdPatient, 1)
    
    scid      = cdPatient.ID(p);
    pstartd   = cdPatient.StudyDate(p);
    pendd     = cdPatient.PatClinDate(p);
    
    pdt       = cdDrugTherapy(cdDrugTherapy.ID == scid & cdDrugTherapy.DrugTherapyStartDate < pendd, :);
    pallintr  = ivandmeasurestable(ivandmeasurestable.SmartCareID == scid, :);
    ppredintr = amInterventions(amInterventions.SmartCareID == scid, :);

    rowtoadd.ID = scid;
    rowtoadd.Hospital = cdPatient.Hospital(p);
    rowtoadd.StudyNumber = cdPatient.StudyNumber(p);
    fprintf('Processing patient %d (%s/%s)\n', scid, cdPatient.Hospital{p}, cdPatient.StudyNumber{p});
    
    addnonerow = false;
    currstartd = pstartd;
    if size(pdt, 1) == 0
        % patient has never taken modulator therapy - set the end of 'None'
        % period to the end of their data collection period
        currendd = pendd;
        addnonerow = true;
    else
        % patient has been on modulator therapy for at least some of the
        % time
        if pdt.DrugTherapyStartDate(1) > pstartd
            % if they started mod therapy after the study start, add the info
            % for the none period
            currendd = pdt.DrugTherapyStartDate(1) - days(1);
            addnonerow = true;
        else
            % otherwise don't add a none period and set currend to study
            % start as nothing should be added before the study start
            currendd = pstartd - days(1);
        end
    end
    
    if addnonerow
        rowtoadd.DTType      = harmoniseDrugTherapyName('None');
        rowtoadd.StartDate   = currstartd;
        rowtoadd.StartDn     = datenum(currstartd) - offset + 1;
        rowtoadd.EndDate     = currendd;
        rowtoadd.EndDn       = datenum(currendd) - offset + 1;
        rowtoadd.NbrDays     = rowtoadd.EndDn - rowtoadd.StartDn + 1;
        rowtoadd.NbrIntr     = sum(pallintr.IVDateNum  >= rowtoadd.StartDn & pallintr.IVDateNum  < rowtoadd.EndDn);
        rowtoadd.NbrPredIntr = sum(ppredintr.IVDateNum >= rowtoadd.StartDn & ppredintr.IVDateNum < rowtoadd.EndDn);

        brDTExStats = [brDTExStats; rowtoadd];
    end

    for dt = 1:size(pdt, 1)
        
        currstartd = currendd + days(1);
        if dt == size(pdt, 1)
            currendd = pendd;
        else
            currendd = pdt.DrugTherapyStartDate(dt + 1) - days(1);
        end
        
        rowtoadd.DTType      = harmoniseDrugTherapyName(pdt.DrugTherapyType(dt));
        rowtoadd.StartDate   = currstartd;
        rowtoadd.StartDn     = datenum(currstartd) - offset + 1;
        rowtoadd.EndDate     = currendd;
        rowtoadd.EndDn       = datenum(currendd) - offset + 1;
        rowtoadd.NbrDays     = rowtoadd.EndDn - rowtoadd.StartDn + 1;
        rowtoadd.NbrIntr     = sum(pallintr.IVDateNum  >= rowtoadd.StartDn & pallintr.IVDateNum  < rowtoadd.EndDn);
        rowtoadd.NbrPredIntr = sum(ppredintr.IVDateNum >= rowtoadd.StartDn & ppredintr.IVDateNum < rowtoadd.EndDn);
        
        brDTExStats = [brDTExStats; rowtoadd];
    end
    
    % integrity check
    if datenum(pendd) - datenum(pstartd) + 1 ~= sum(brDTExStats.NbrDays(brDTExStats.ID == scid))
        fprintf('**** Integrity Issue - Patient Study period = %d, Sum by drug therapy = %d ****\n', ...
            datenum(pendd) - datenum(pstartd) + 1, sum(brDTExStats.NbrDays(brDTExStats.ID == scid)));
    end
    
    
end

sumtable = varfun(@sum, brDTExStats, 'InputVariables', {'NbrDays', 'NbrIntr', 'NbrPredIntr'}, 'GroupingVariables', {'DTType'});
sumtable.AnnualFreq = 365 * sumtable.sum_NbrIntr ./ sumtable.sum_NbrDays;
sumtable.AnnualPredFreq = 365 * sumtable.sum_NbrPredIntr ./ sumtable.sum_NbrDays;
hospsumtable = varfun(@sum, brDTExStats, 'InputVariables', {'NbrDays', 'NbrIntr', 'NbrPredIntr'}, 'GroupingVariables', {'Hospital', 'DTType'});
hospsumtable.AnnualFreq = 365 * hospsumtable.sum_NbrIntr ./ hospsumtable.sum_NbrDays; 
hospsumtable.AnnualPredFreq = 365 * hospsumtable.sum_NbrPredIntr ./ hospsumtable.sum_NbrDays;

daysthresh = 10000;
tempsumtable = sumtable(sumtable.sum_NbrDays > daysthresh, :);

plotsdown   = 1; 
plotsacross = 3;
thisplot = 1;
widthinch = 11;
heightinch = 5;
fontname = 'Arial';
plottitle = sprintf('%s - Modulator Therapy Impact - %s', study, textsuffix);
[f, p] = createFigureAndPanelForPaper('', widthinch, heightinch);

ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
hold on;
b = bar(ax, tempsumtable.sum_NbrDays);
set(ax, 'xticklabel', tempsumtable.DTType);
set(ax, 'yticklabel', {'0', '50,000', '100,000', '150,000', '200,000', '250,000'});
ax.XTick = [1, 2, 3];
ax.YTick = [0, 50000, 100000, 150000, 200000, 250000];
ylim(ax, [0, 250000]);
xtickangle(ax, 30);
b.FaceColor = 'flat';
b.CData     = [0.0000, 0.4470, 0.7410; ...
               0.8500, 0.3250, 0.0980; ...
               0.9290, 0.6940, 0.1250];
ax.FontSize = 8;
ax.FontName = fontname;
ax.FontWeight = 'bold';
xlabel(ax, 'Modulator Therapy', 'FontSize', 10);
ylabel(ax, 'Nbr Days in Study', 'FontSize', 10);
title(ax, '(a) Number of Study Days', 'FontSize', 10);
hold off;

thisplot = thisplot + 1;
ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
hold on;
if ismember(textsuffix, {'ExclElect'})
    b = bar(ax, tempsumtable.sum_NbrPredIntr);
else
    b = bar(ax, tempsumtable.sum_NbrIntr);
end
set(ax, 'xticklabel', tempsumtable.DTType);

ax.XTick = [1, 2, 3];

if ismember(textsuffix, {'ExclElect'})
    set(ax, 'yticklabel', {'0', '25', '50', '75', '100'});
    ax.YTick = [0, 25, 50, 75, 100];
    ylim(ax, [0, 100]);
else
    set(ax, 'yticklabel', {'0', '100', '200', '300', '400', '500', '600'});
    ax.YTick = [0, 100, 200, 300, 400, 500, 600];
    ylim(ax, [0, 600]);
end
xtickangle(ax, 30);
b.FaceColor = 'flat';
b.CData     = [0.0000, 0.4470, 0.7410; ...
               0.8500, 0.3250, 0.0980; ...
               0.9290, 0.6940, 0.1250];
ax.FontSize = 8;
ax.FontName = fontname;
ax.FontWeight = 'bold';
xlabel(ax, 'Modulator Therapy', 'FontSize', 10);
ylabel(ax, 'Nbr Interventions', 'FontSize', 10);
title(ax, '(b) Number of Interventions', 'FontSize', 10);
hold off;

thisplot = thisplot + 1;
ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
hold on;
if ismember(textsuffix, {'ExclElect'})
    b = bar(ax, tempsumtable.AnnualPredFreq);
else
    b = bar(ax, tempsumtable.AnnualFreq);
end

set(ax, 'xticklabel', tempsumtable.DTType);

ax.XTick = [1, 2, 3];

if ismember(textsuffix, {'ExclElect'})
    set(ax, 'yticklabel', {'0', '0.1', '0.2', '0.3', '0.4', '0.5'});
    ax.YTick = [0, 0.1, 0.2, 0.3, 0.4, 0.5];
    ylim(ax, [0, 0.5]);
else
    set(ax, 'yticklabel', {'0', '0.5', '1.0', '1.5', '2.0'});
    ax.YTick = [0, 0.5, 1.0, 1.5, 2.0];
    ylim(ax, [0, 2]);
end
xtickangle(ax, 30);
b.FaceColor = 'flat';
b.CData     = [0.0000, 0.4470, 0.7410; ...
               0.8500, 0.3250, 0.0980; ...
               0.9290, 0.6940, 0.1250];
xtips = b.XEndPoints;
ytips = b.YEndPoints;
labels = string(round(b.YData, 2));
text(xtips, ytips, labels,'HorizontalAlignment','center', ...
    'VerticalAlignment','bottom');
ax.FontSize = 8;
ax.FontName = fontname;
ax.FontWeight = 'bold';
xlabel(ax, 'Modulator Therapy', 'FontSize', 10);
ylabel(ax, 'Annual APE Frequency', 'FontSize', 10);
title(ax, '(c) Annual APE Frequency', 'FontSize', 10);
hold off;
toc
fprintf('\n');

% save plot
plotsubfolder = sprintf('Plots/%s', study);
savePlotInDir(f, plottitle, plotsubfolder);
savePlotInDirAsSVG(f, plottitle, plotsubfolder);
close(f);

end

