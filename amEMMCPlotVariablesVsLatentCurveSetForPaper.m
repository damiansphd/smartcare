function [wcxpvaltable] = amEMMCPlotVariablesVsLatentCurveSetForPaper(amInterventions, pmPatients, pmPatientMeasStats, ivandmeasurestable, ...
        cdMicrobiology, cdAntibiotics, cdAdmissions, cdCRP, measures, plotname, plotsubfolder, ninterventions, nlatentcurves, scenario, randomseed)
    
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
              'Pct One or Both'};

nscattervars   = size(scattervartext, 1);
scattervardata = zeros(ninterventions, nscattervars);

npolarvars     = size(polarvartext, 1);
polarvardata   = zeros(ninterventions, npolarvars);

nbarvars       = size(barvartext, 1);

nlccombs = nlatentcurves;
nkeycols = 1;
comb = -1 * ones((nscattervars),nlccombs);
comb = array2table(comb);
wcxpvaltable = table('Size',[(nscattervars), nkeycols], 'VariableTypes', {'cell'}, 'VariableNames', {'VarName'});
wcxpvaltable = [wcxpvaltable, comb];
for i = 1:nlccombs
    wcxpvaltable.Properties.VariableNames{nkeycols + i} = sprintf('Group%d_Median', i);
end
wcxpvaltable = [wcxpvaltable, comb];
for i = 1:nlccombs
    wcxpvaltable.Properties.VariableNames{nkeycols + nlccombs + i} = sprintf('Group%d_IQRange', i);
end
wcxpvaltable = [wcxpvaltable, comb];
for i = 1:nlccombs
    wcxpvaltable.Properties.VariableNames{nkeycols + (2 * nlccombs) + i} = sprintf('Group%d_pvalDiffMedian', i);
end

comb = -1 * ones((nbarvars),nlccombs);
comb = array2table(comb);
chisqvaltable = table('Size',[(nbarvars), nkeycols], 'VariableTypes', {'cell'}, 'VariableNames', {'VarName'});
chisqvaltable = [chisqvaltable, comb];
for i = 1:nlccombs
    chisqvaltable.Properties.VariableNames{nkeycols + i} = sprintf('Group%d_pvalDiffSeries', i);
end

lcsort = getLCSortOrder(amInterventions, nlatentcurves);
amInterventions.SortedLatentCurve = lcsort(amInterventions.LatentCurve);
amInterventions.Properties.VariableNames{'LatentCurve'} = 'OrigLatentCurve';
amInterventions.Properties.VariableNames{'SortedLatentCurve'} = 'LatentCurve';

% Scatter plot variables
% 1) Robust Max FEV1
mfev1idx  = measures.Index(ismember(measures.DisplayName, 'LungFunction'));
fev1max  = pmPatientMeasStats(pmPatientMeasStats.MeasureIndex == mfev1idx, {'PatientNbr', 'Study', 'ID', 'RobustMax'});
lc = innerjoin(amInterventions, fev1max, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'}, 'LeftVariables', {'SmartCareID', 'IVStartDate', 'IVScaledDateNum', 'LatentCurve'}, 'RightVariables', {'RobustMax'});
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

plottitle = sprintf('%s - Variables vs Latent Curve Set For Paper', plotname);
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
    
    % store median, inter-quartile range, and p-values for the numeric
    % series variables
    wcxpvaltable.VarName{v} = scattervartext{v, 1};
    for i = 1:nlatentcurves
        wcxpvaltable(v, {sprintf('Group%d_Median', i)}) = array2table(median(scattervardata(lc.LatentCurve == i, v)));
        wcxpvaltable(v, {sprintf('Group%d_IQRange', i)}) = array2table(iqr(scattervardata(lc.LatentCurve == i, v)));
        [pval, h] = ranksum(scattervardata(lc.LatentCurve == i, v), scattervardata(lc.LatentCurve ~= i, v));
        wcxpvaltable(v, {sprintf('Group%d_pvalDiffMedian', i)}) = array2table(pval);
        if h == 1
            flagtext = ' *****';
        else
            flagtext = ' ';
        end
        fprintf('%24s : Group%d Median %6.2f IQ Range %6.2f pvalDiffMedian : %5.3f%s\n', scattervartext{v, 1}, i, ...
            median(scattervardata(lc.LatentCurve == i, v)), ...
            iqr(scattervardata(lc.LatentCurve == i, v)), ...
            pval, flagtext);
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
    elseif ismember(barvartext(v), {'Pct Nbr of IV Treatments', 'Pct Nbr of AB Treatments'})
        ylim(ax, [0 150]);
    end
    xlabel(ax, 'Latent Curve Set', 'FontSize', 8);
    ylabel(ax, barvartext{v}, 'FontSize', 8);
    
    tempobs = blc(:,{'PValCol', 'LatentCurve'});
    uniquecats = unique(tempobs.PValCol);
    nuniquecats = size(uniquecats, 1);
    chisqvaltable.VarName{v} = strrep(barvartext{v, 1}, 'Pct ', '');
    for i = 1:nlatentcurves
        tempobsfreq = varfun(@mean, tempobs(tempobs.LatentCurve == i, :), 'GroupingVariables', 'PValCol');
        tempexpfreq = varfun(@mean, tempobs(tempobs.LatentCurve ~= i, :), 'GroupingVariables', 'PValCol');
        tempexpfreq.GroupCount = tempexpfreq.GroupCount * sum(tempobsfreq.GroupCount) / sum(tempexpfreq.GroupCount);
        
        freqtable = table('Size',[nuniquecats, 3], 'VariableTypes', {'double', 'double', 'double'}, 'VariableNames', {'Category', 'ObsFreq', 'ExpFreq'});
        freqtable.Category = uniquecats;
        for c = 1:size(tempobsfreq, 1)
            catidx  = freqtable.Category == tempobsfreq.PValCol(c);
            freqtable.ObsFreq(catidx)  = tempobsfreq.GroupCount(c);
        end
        for c = 1:size(tempexpfreq, 1)
            catidx  = freqtable.Category == tempexpfreq.PValCol(c);
            freqtable.ExpFreq(catidx)  = tempexpfreq.GroupCount(c);
        end
        [h, pval, ~] = chi2gof(uniquecats, 'freq', freqtable.ObsFreq', 'expected', freqtable.ExpFreq', 'ctrs', uniquecats);
        chisqvaltable(v, {sprintf('Group%d_pvalDiffSeries', i)}) = array2table(pval);
        if h == 1
            flagtext = ' *****';
        else
            flagtext = ' ';
        end
        fprintf('%24s : Group%d pvalDiffSeries : %5.3f%s\n', barvartext{v, 1}, i, ...
            pval, flagtext);
    end
    
    % store p-values for different combinations of comparisons
    %wcxpvaltable.VarName{thisplot} = barvartext{v, 1};
    %for i = 1:nlatentcurves
    %    [pval, h] = ranksum(blc.PValCol(blc.LatentCurve == i), blc.PValCol(blc.LatentCurve ~= i));
    %    wcxpvaltable(thisplot, {sprintf('Group%d_DiffMedian', i)}) = array2table(pval);
    %    if h == 1
    %        flagtext = ' *****';
    %    else
    %        flagtext = ' ';
    %    end
    %    fprintf('%24s : Group%d DiffMedian : p-value %5.3f%s\n', barvartext{v, 1}, i, pval, flagtext);
    %end
    
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
    %pvaltable.VarName{thisplot} = polarvartext{v, 1};
    %for i = 1:nlatentcurves
    %    [pval, h] = ranksum(polarvardata(lc.LatentCurve == i, v), polarvardata(lc.LatentCurve ~= i, v));
    %    pvaltable(thisplot, {sprintf('Group%d_pvalDiffMedian', i)}) = array2table(pval);
    %    if h == 1
    %        flagtext = ' *****';
    %    else
    %        flagtext = ' ';
    %    end
    %    fprintf('%24s : Group%d DiffMedian : p-value %5.3f%s\n', polarvartext{v, 1}, i, pval, flagtext);
    %end
    
    thisplot = thisplot + 1;    
    
end

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
savePlotInDirAsSVG(f, plottitle, plotsubfolder);
close(f);

% save p-value table
basedir = setBaseDir();
%xlfilename = sprintf('%s.xlsx', plottitle);
xlfilename = sprintf('P-Values nl%d_scen%s_rs%d.xlsx', nlatentcurves, scenario, randomseed);
writetable(wcxpvaltable, fullfile(basedir, plotsubfolder, xlfilename), 'Sheet', 'Numeric');
writetable(chisqvaltable, fullfile(basedir, plotsubfolder, xlfilename), 'Sheet', 'Non-Numeric');

plottitle = sprintf('%s - Variables vs Latent Curve Set For Paper P2', plotname);
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

