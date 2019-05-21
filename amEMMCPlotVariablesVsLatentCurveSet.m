function amEMMCPlotVariablesVsLatentCurveSet(amInterventions, initial_latentcurve, pmPatients, pmPatientMeasStats, ...
        cdMicrobiology, cdAntibiotics, cdAdmissions, cdCRP, measures, plotname, plotsubfolder, ninterventions, nlatentcurves)
    
% amEMMCPlotVariablesVsLatentCurveSet - compact plots of various variables
% against latent curve set assigned to try and observe correlations

scattervartext = {'Stable FEV1'; ...
                'BMI';  ...
                'Age';  ...
                'Duration of exacerbation'; ...
                'Day of Year'; ...
                'CRP Adm'; ...
                'CRP Stable'};

polarvartext = {'Day of Year'};

barvartext = {%'Gender'; ...
              'Pct Gender'; ...
              %'Nbr of Interventions'; ...
              'Pct Nbr of Interventions'; ...
              'Pct Pseudomonas'; ...
              'Pct Staphylococcus'; ...
              'Pct One or Both'};

nscattervars   = size(scattervartext, 1);
scattervardata = zeros(ninterventions, nscattervars);

npolarvars     = size(polarvartext, 1);
polarvardata   = zeros(ninterventions, npolarvars);

nbarvars       = size(barvartext, 1);

amInterventions.InitialLC = initial_latentcurve;

% Scatter plot variables
% 1) Robust Max FEV1
mfev1idx  = measures.Index(ismember(measures.DisplayName, 'LungFunction'));
fev1max  = pmPatientMeasStats(pmPatientMeasStats.MeasureIndex == mfev1idx, {'PatientNbr', 'Study', 'ID', 'RobustMax'});
lc = innerjoin(amInterventions, fev1max, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'}, 'LeftVariables', {'SmartCareID', 'IVStartDate', 'IVScaledDateNum', 'LatentCurve', 'InitialLC'}, 'RightVariables', {'RobustMax'});
scattervardata(:, 1) = lc.RobustMax;

% 2 & 3) BMI, Age
pmPatients.BMI = pmPatients.Weight ./ ((pmPatients.Height * 0.01) .^ 2);
lc = innerjoin(lc, pmPatients, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'}, 'RightVariables', {'BMI', 'Sex', 'Age'});
scattervardata(:, 2) = lc.BMI;
scattervardata(:, 3) = lc.Age;

% 4) Duration of Exacerbation
amInterventions.Duration = amInterventions.IVScaledDateNum - amInterventions.Pred;
lc = innerjoin(lc, amInterventions, 'LeftKeys', {'SmartCareID', 'IVScaledDateNum'}, 'RightKeys', {'SmartCareID', 'IVScaledDateNum'}, 'RightVariables', {'Duration'});
scattervardata(:, 4) = lc.Duration;

% 5) Day of year
lc.DayOfYear = day(lc.IVStartDate, 'dayofyear');
lc.DaysInYear = day(datetime(year(lc.IVStartDate), 12, 31), 'dayofyear');
lc.PolarDays = (lc.DayOfYear ./ lc.DaysInYear) * 360;
scattervardata(:, 5) = lc.DayOfYear;
polarvardata(:, 1) = lc.PolarDays;

% 6 & 7) CRP on admission & Stable CRP (average on hospital discharge for each patient over study period)
for i = 1:size(lc, 1)
    crpadmidx = find(cdCRP.ID == lc.SmartCareID(i) & cdCRP.CRPDate >= (lc.IVStartDate(i) - days(2)) & cdCRP.CRPDate <= (lc.IVStartDate(i) + days(20)));
    if size(crpadmidx, 1) ~= 0
        scattervardata(i, 6) = max(cdCRP.NumericLevel(crpadmidx));
    end
    admidx = cdAdmissions.ID == lc.SmartCareID(i) & cdAdmissions.Admitted >= (lc.IVStartDate(i) - days(2)) & cdAdmissions.Admitted <= (lc.IVStartDate(i) + days(20));
    if sum(admidx, 1) ~= 0
        dischargedate = max(cdAdmissions.Discharge(admidx));
        crpstabarray = cdCRP.NumericLevel(cdCRP.ID == lc.SmartCareID(i) & cdCRP.CRPDate >= (dischargedate - days(5)) & cdCRP.CRPDate <= (dischargedate + days(5)));
        if size(crpstabarray, 1) ~= 0
            scattervardata(i, 7) = mean(crpstabarray);
        end
    end
end

plotsdown   = 3; 
plotsacross = ceil((nscattervars + nbarvars + npolarvars)/plotsdown);
pointsize = 36;
if nlatentcurves == 1
    cmap = [0, 1, 0];
elseif nlatentcurves == 2
    cmap = [0, 1, 0 ; 0, 0, 1 ];
elseif nlatentcurves == 3
    cmap = [0, 1, 0 ; 0, 0, 1 ; 1, 0, 0 ];
elseif nlatentcurves == 4
    cmap = [0, 1, 0 ; 0, 0, 1 ; 1, 0, 0 ; 1 0 1];
else
    fprintf('Add more colours to the palette\n');
    return;
end

plottitle = sprintf('%s - Variables vs Latent Curve Set', plotname);
[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');
colormap(f, cmap);
thisplot = 1;
for v = 1:nscattervars
    ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
    scatter(ax, lc.LatentCurve, scattervardata(:, v), pointsize, lc.LatentCurve, 'filled', 'MarkerFaceAlpha', 0.3);
    ax.FontSize = 6;
    title(ax, scattervartext{v}, 'FontSize', 8);
    xlim(ax, [0.5 nlatentcurves + 0.5]);
    xlabel(ax, 'Latent Curve Set', 'FontSize', 8);
    ylabel(ax, scattervartext{v}, 'FontSize', 8);
    thisplot = thisplot + 1;    
end

for v = 1:npolarvars
    ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
    pax = polaraxes(p, 'Units', ax.Units,'Position', ax.Position);
    delete(ax);
    polarscatter(pax, polarvardata(:, v), (lc.LatentCurve / 5) + 1, pointsize, lc.LatentCurve, 'filled', 'MarkerFaceAlpha', 0.3);
    pax.ThetaZeroLocation = 'top';
    pax.ThetaDir          = 'clockwise';
    pax.ThetaGrid         = 'off';
    pax.RGrid             = 'off';
    pax.RTickLabel        = {};
    pax.FontSize          = 6;
    pax.ThetaTick         = [0 90 180 270];
    title(pax, polarvartext{v}, 'FontSize', 8);
    thisplot = thisplot + 1;    
end

for v = 1:nbarvars
    if ismember(barvartext(v), {'Gender', 'Pct Gender'})
        nbarsplits = 2;
        barvardata = zeros(nlatentcurves, nbarsplits);
        for n = 1:nlatentcurves
            barvardata(n, 1) = sum(lc.LatentCurve == n & ismember(lc.Sex, 'Male'));
            barvardata(n, 2) = sum(lc.LatentCurve == n & ismember(lc.Sex, 'Female'));
        end
        if ismember(barvartext(v), 'Pct Gender')
            barvardata = 100 * (barvardata ./ sum(barvardata, 2));
        end
        legendtext = {'M', 'F'};
        
    elseif ismember(barvartext(v), {'Pct Pseudomonas', 'Pct Staphylococcus', 'Pct One or Both'})
        pseudpat = unique(cdMicrobiology.ID(contains(lower(cdMicrobiology.Microbiology), 'pseud')));
        staphpat = unique(cdMicrobiology.ID(contains(lower(cdMicrobiology.Microbiology), 'staph') | contains(lower(cdMicrobiology.Microbiology), 'mrsa')));
        bothpat  = pseudpat(ismember(pseudpat, staphpat));
        onlypseudpat = pseudpat(~ismember(pseudpat, bothpat));
        onlystaphpat = staphpat(~ismember(staphpat, bothpat));
        if ismember(barvartext(v), {'Pct Pseudomonas'})
            lc.Microbiology(:) = 2;
            lc.Microbiology(ismember(lc.SmartCareID, pseudpat)) = 1;
            legendtext = {'Yes', 'No'};
        elseif ismember(barvartext(v), {'Pct Staphylococcus'})
            lc.Microbiology(:) = 2;
            lc.Microbiology(ismember(lc.SmartCareID, staphpat)) = 1;
            legendtext = {'Yes', 'No'};
        elseif ismember(barvartext(v), {'Pct One or Both'})
            lc.Microbiology(:) = 4;
            lc.Microbiology(ismember(lc.SmartCareID, onlystaphpat)) = 3;
            lc.Microbiology(ismember(lc.SmartCareID, onlypseudpat)) = 2;
            lc.Microbiology(ismember(lc.SmartCareID, bothpat)) = 1;
            legendtext = {'Both', 'Pseud', 'Staph', 'Neither'};
        end
        nbarsplits = max(lc.Microbiology);
        barvardata = zeros(nlatentcurves, nbarsplits);
        for n = 1:nlatentcurves
            for b = 1:nbarsplits
                barvardata(n, b) = sum(lc.LatentCurve == n & lc.Microbiology == b);
            end
        end
        if ismember(barvartext(v), {'Pct Pseudomonas', 'Pct Staphylococcus', 'Pct One or Both'})
            barvardata = 100 * (barvardata ./ sum(barvardata, 2));
        end
        lc.Microbiology = [];
        
    elseif ismember(barvartext(v), {'Nbr of Interventions', 'Pct Nbr of Interventions'})
        intrcount = varfun(@max, amInterventions, 'InputVariables', {'Pred'}, 'GroupingVariables', {'SmartCareID'});
        nbarsplits = max(intrcount.GroupCount);
        lc = innerjoin(lc, intrcount, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, 'RightVariables', {'GroupCount'});
        barvardata = zeros(nlatentcurves, nbarsplits);
        for n = 1:nlatentcurves
            for b = 1:nbarsplits
                barvardata(n, b) = sum(lc.LatentCurve == n & lc.GroupCount == b);
            end
        end
        if ismember(barvartext(v), 'Pct Nbr of Interventions')
            barvardata = 100 * (barvardata ./ sum(barvardata, 2));
            
        end
        legendtext = {'1', '2', '3', '4'};
        lc.GroupCount = [];
    end
    
    ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
    bar(ax, barvardata, 'Stacked');
    ax.FontSize = 6;
    title(ax, barvartext{v}, 'FontSize', 8);
    legend(ax, legendtext, 'FontSize', 6);
    xlim(ax, [0.5 nlatentcurves + 0.5]);
    if ismember(barvartext(v), {'Pct Gender', 'Pct Nbr of Interventions','Pct Pseudomonas', 'Pct Staphylococcus', 'Pct One or Both'})
        ylim(ax, [0 135]);
    end
    xlabel(ax, 'Latent Curve Set', 'FontSize', 8);
    ylabel(ax, barvartext{v}, 'FontSize', 8);
    thisplot = thisplot + 1;    
end

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
close(f);

end

