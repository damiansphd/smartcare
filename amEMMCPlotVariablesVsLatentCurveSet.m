function amEMMCPlotVariablesVsLatentCurveSet(amInterventions, pmPatients, pmPatientMeasStats, ivandmeasurestable, ...
        cdMicrobiology, cdAntibiotics, cdAdmissions, cdCRP, measures, plotname, plotsubfolder, ninterventions, nlatentcurves, study)
    
% amEMMCPlotVariablesVsLatentCurveSet - compact plots of various variables
% against latent curve set assigned to try and observe correlations
            
scattervartext = {'Stable FEV1',            'Box'; ...
                'BMI',                      'Box';  ...
                'Age',                      'Box';  ...
                'Duration of exacerbation', 'Box'; ...
                'Day of Year',              'Scatter'; ...
                'CRP Adm',                  'Box'; ...
                'CRP Stable',               'Box'};            
            
polarvartext = {'Day of Year'};

barvartext = {%'Gender'; ...
              'Pct Gender'; ...
              'Pct Nbr of IV Treatments'; ...
              'Pct Nbr of AB Treatments'; ...
              %'Nbr of Interventions'; ...
              'Pct Nbr of Interventions'; ...
              'Pct Pseudomonas'; ...
              'Pct Staphylococcus'; ...
              'Pct One or Both'; ...
              'Pct Mod Therapy'};

nscattervars   = size(scattervartext, 1);
scattervardata = zeros(ninterventions, nscattervars);

npolarvars     = size(polarvartext, 1);
polarvardata   = zeros(ninterventions, npolarvars);

nbarvars       = size(barvartext, 1);

nlccombs = (nlatentcurves * (nlatentcurves - 1)) / 2;
nkeycols = 1;
comb = -1 * ones((nscattervars + npolarvars + nbarvars),nlccombs);
comb = array2table(comb);
pvaltable = table('Size',[(nscattervars + npolarvars + nbarvars), nkeycols], 'VariableTypes', {'cell'}, 'VariableNames', {'VarName'});
pvaltable = [pvaltable, comb];
cnt = 1;
for i = 2:nlatentcurves
    for j = 1:i - 1
        pvaltable.Properties.VariableNames{nkeycols + cnt} = sprintf('LC%dvsLC%d',j, i);
        %fprintf('Comb %d: LC%dvsLC%d\n', cnt, j, i);
        cnt = cnt + 1;
    end
end

% Scatter plot variables
% 1) Robust Max FEV1
if ismember(study, {'SC', 'TM'})
    mfev1idx  = measures.Index(ismember(measures.DisplayName, 'LungFunction'));
elseif ismember(study, {'CL', 'BR'})
    mfev1idx  = measures.Index(ismember(measures.DisplayName, 'FEV1'));
else
    fprintf('**** Unknown Study ****\n');
    return
end
fev1max  = pmPatientMeasStats(pmPatientMeasStats.MeasureIndex == mfev1idx, {'PatientNbr', 'Study', 'ID', 'RobustMax'});
%lc = innerjoin(amInterventions, fev1max, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'}, 'LeftVariables', {'SmartCareID', 'IVStartDate', 'IVScaledDateNum', 'LatentCurve'}, 'RightVariables', {'RobustMax'});
lc = outerjoin(amInterventions, fev1max, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'}, 'LeftVariables', {'SmartCareID', 'IVStartDate', 'IVScaledDateNum', 'LatentCurve', 'DrugTherapy'}, 'RightVariables', {'RobustMax'});
lc(isnan(lc.SmartCareID), :) = [];
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
lc.PolarDays = (lc.DayOfYear ./ lc.DaysInYear) * 2 * pi; % polar plots are in radians
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
if nlatentcurves >= 1
    cmap = [ 0.4, 0.8, 0.2 ];
end
if nlatentcurves >= 2
    cmap(2,:) = [ 0, 0, 1 ];
end
if nlatentcurves >= 3
    cmap(3,:) = [ 1, 0, 0 ];
end
if nlatentcurves >= 4
    cmap(4,:) = [ 1 0 1 ];
end
if nlatentcurves >= 5
    fprintf('Add more colours to the palette\n');
    return;
end

plottitle = sprintf('%s - Variables vs Latent Curve Set', plotname);
[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');
colormap(f, cmap);
thisplot = 1;
for v = 1:nscattervars
    if ismember(scattervartext(v, 1), {'BMI'})
        compressrange = [0, 32];
    elseif ismember(scattervartext(v, 1), {'CRP Adm'})
        compressrange = [0, 100];
    elseif ismember(scattervartext(v, 1), {'CRP Stable'})
        compressrange = [0, 50];
    else
       compressrange = [-Inf, Inf];
    end
    ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
    if ismember(scattervartext(v, 2), 'Scatter')
        scatter(ax, lc.LatentCurve, scattervardata(:, v), pointsize, lc.LatentCurve, 'filled', 'MarkerFaceAlpha', 0.3);
    elseif ismember(scattervartext(v, 2), 'Box')
        boxplot(ax, scattervardata(:, v), lc.LatentCurve, 'Colors', cmap, 'ColorGroup', lc.LatentCurve, ...
            'Notch', 'off', 'DataLim', compressrange, 'ExtremeMode', 'compress', 'Jitter', 1, 'Symbol', 'x');
    else
        fprintf('Unknown plot type\n');
        return
    end
    ax.FontSize = 6;
    title(ax, scattervartext{v, 1}, 'FontSize', 8);
    xlim(ax, [0.5 nlatentcurves + 0.5]);
    xlabel(ax, 'Latent Curve Set', 'FontSize', 8);
    ylabel(ax, scattervartext{v, 1}, 'FontSize', 8);
    
    % store p-values for different combinations of comparisons
    pvaltable.VarName{thisplot} = scattervartext{v, 1};
    for i = 2:nlatentcurves
        for j = 1:i - 1
            [pval, h] = ranksum(scattervardata(lc.LatentCurve == j, v), scattervardata(lc.LatentCurve == i, v));
            pvaltable(thisplot, {sprintf('LC%dvsLC%d',j, i)}) = array2table(pval);
            if h == 1
                flagtext = ' *****';
            else
                flagtext = ' ';
            end
            fprintf('%24s : LC%dvsLC%d : p-value %5.3f%s\n', scattervartext{v, 1}, j, i, pval, flagtext);
        end
    end

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
        blc = lc;
        blc.PValCol(:) = 1;
        blc.PValCol(ismember(blc.Sex, 'Female')) = 2;
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
        blc = lc;
        blc.PValCol = blc.Microbiology;
        lc.Microbiology = [];
        
    elseif ismember(barvartext(v), {'Nbr of Interventions', 'Pct Nbr of Interventions'})
        intrcount = varfun(@max, amInterventions, 'InputVariables', {'Pred'}, 'GroupingVariables', {'SmartCareID'});
        nbarsplits = max(intrcount.GroupCount);
        blc = innerjoin(lc, intrcount, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, 'RightVariables', {'GroupCount'});
        barvardata = zeros(nlatentcurves, nbarsplits);
        for n = 1:nlatentcurves
            for b = 1:nbarsplits
                barvardata(n, b) = sum(blc.LatentCurve == n & blc.GroupCount == b);
            end
        end
        if ismember(barvartext(v), 'Pct Nbr of Interventions')
            barvardata = 100 * (barvardata ./ sum(barvardata, 2));
            
        end
        legendtext = {'1', '2', '3', '4'};
        blc.PValCol = blc.GroupCount;
        %lc.GroupCount = [];
    elseif ismember(barvartext(v), {'Nbr of IV Treatments', 'Pct Nbr of IV Treatments', 'Nbr of AB Treatments', 'Pct Nbr of AB Treatments'})
        if ismember(barvartext(v), {'Nbr of IV Treatments', 'Pct Nbr of IV Treatments'})
            tmpivandmeas = ivandmeasurestable(ivandmeasurestable.Type == 1 | ivandmeasurestable.Type == 3, :);
        else
            tmpivandmeas = ivandmeasurestable;
        end
        treatcount = varfun(@max, tmpivandmeas, 'InputVariables', {'DaysWithMeasures'}, 'GroupingVariables', {'SmartCareID'});
        nbarsplits = max(treatcount.GroupCount);
        blc = innerjoin(lc, treatcount, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, 'RightVariables', {'GroupCount'});
        barvardata = zeros(nlatentcurves, nbarsplits);
        for n = 1:nlatentcurves
            for b = 1:nbarsplits
                barvardata(n, b) = sum(blc.LatentCurve == n & blc.GroupCount == b);
            end
        end
        if ismember(barvartext(v), {'Pct Nbr of IV Treatments', 'Pct Nbr of AB Treatments'})
            barvardata = 100 * (barvardata ./ sum(barvardata, 2));
        end
        legendtext = {'1', '2', '3', '4', '5', '6', '7'};
        blc.PValCol = blc.GroupCount;
        %lc.GroupCount = [];
    elseif ismember(barvartext(v), {'Mod Therapy', 'Pct Mod Therapy'})
        nbarsplits = 5;
        barvardata = zeros(nlatentcurves, nbarsplits);
        for n = 1:nlatentcurves
            barvardata(n, 1) = sum(lc.LatentCurve == n & ismember(lc.DrugTherapy, 'None'));
            barvardata(n, 2) = sum(lc.LatentCurve == n & ismember(lc.DrugTherapy, 'Orkambi'));
            barvardata(n, 3) = sum(lc.LatentCurve == n & ismember(lc.DrugTherapy, 'Ivacaftor'));
            barvardata(n, 4) = sum(lc.LatentCurve == n & ismember(lc.DrugTherapy, 'Symkevi'));
            barvardata(n, 5) = sum(lc.LatentCurve == n & ismember(lc.DrugTherapy, 'Triple Therapy'));
        end
        if ismember(barvartext(v), {'Pct Mod Therapy'})
            barvardata = 100 * (barvardata ./ sum(barvardata, 2));
        end
        legendtext = {'None', 'Orkambi', 'Ivacaftor', 'Symkevi', 'Triple'};
        blc = lc;
        blc.PValCol(:) = 1;
        blc.PValCol(ismember(blc.DrugTherapy, 'Orkambi')) = 2;
        blc.PValCol(ismember(blc.DrugTherapy, 'Ivacaftor')) = 3;
        blc.PValCol(ismember(blc.DrugTherapy, 'Symkevi')) = 4;
        blc.PValCol(ismember(blc.DrugTherapy, 'Triple Therapy')) = 5;
        
    end
    
    ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', p);
    bar(ax, barvardata, 'Stacked');
    ax.FontSize = 6;
    title(ax, barvartext{v}, 'FontSize', 8);
    legend(ax, legendtext, 'FontSize', 6);
    xlim(ax, [0.5 nlatentcurves + 0.5]);
    if ismember(barvartext(v), {'Pct Gender', 'Pct Nbr of Interventions', ...
            'Pct Pseudomonas', 'Pct Staphylococcus', 'Pct One or Both'})
        ylim(ax, [0 135]);
    elseif ismember(barvartext(v), {'Pct Nbr of IV Treatments', 'Pct Nbr of AB Treatments', 'Pct Mod Therapy'})
        ylim(ax, [0 175]);
    end
    xlabel(ax, 'Latent Curve Set', 'FontSize', 8);
    ylabel(ax, barvartext{v}, 'FontSize', 8);
    
    % store p-values for different combinations of comparisons
    pvaltable.VarName{thisplot} = barvartext{v, 1};
    for i = 2:nlatentcurves
        for j = 1:i - 1
            [pval, h] = ranksum(blc.PValCol(blc.LatentCurve == j), blc.PValCol(blc.LatentCurve == i));
            pvaltable(thisplot, {sprintf('LC%dvsLC%d',j, i)}) = array2table(pval);
            if h == 1
                flagtext = ' *****';
            else
                flagtext = ' ';
            end
            fprintf('%24s : LC%dvsLC%d : p-value %5.3f%s\n', barvartext{v, 1}, j, i, pval, flagtext);
        end
    end
    blc = [];
    
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
    
    % store p-values for different combinations of comparisons
    pvaltable.VarName{thisplot} = polarvartext{v, 1};
    for i = 2:nlatentcurves
        for j = 1:i - 1
            [pval, h] = ranksum(polarvardata(lc.LatentCurve == j, v), polarvardata(lc.LatentCurve == i, v));
            pvaltable(thisplot, {sprintf('LC%dvsLC%d',j, i)}) = array2table(pval);
            if h == 1
                flagtext = ' *****';
            else
                flagtext = ' ';
            end
            fprintf('%24s : LC%dvsLC%d : p-value %5.3f%s\n', polarvartext{v, 1}, j, i, pval, flagtext);
        end
    end
    
    thisplot = thisplot + 1;    
    thisplot = thisplot + 1;    
end

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
close(f);

% save p-value table
basedir = setBaseDir();
xlfilename = sprintf('%s.xlsx', plottitle);
writetable(pvaltable, fullfile(basedir, plotsubfolder, xlfilename));

plottitle = sprintf('%s - Variables vs Latent Curve Set P2', plotname);
[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');
%colormap(f, cmap)

plotsdown   = 3; 
plotsacross = 3;
edges = 0:30.5:366;

for i = 1:nlatentcurves
    ax = subplot(plotsdown, plotsacross, i, 'Parent', p);
    histogram(ax, scattervardata(lc.LatentCurve == i, 5), edges, 'Orientation', 'horizontal', 'Normalization', 'probability', 'FaceColor', cmap(i, :));
    title(ax, sprintf('LC Set %d', i));
    xlabel(ax, 'Count');
    ylabel(ax, 'Day of Year');
end

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
close(f);
end

