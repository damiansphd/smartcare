function amEMMCPlotInterventionsByLatentCurveSet(pmPatients, amInterventions, ...
    amInterventionsFull, npatients, maxdays, plotname, plotsubfolder, nlatentcurves, plotmode)

% amEMMCPlotInterventionsByLatentCurveSet - plots interventions and
% treatments over time for all patients, and colour codes the treatments by
% latent curve set.

tempintrcount = varfun(@max, amInterventions, 'InputVariables', {'Pred'}, 'GroupingVariables', {'SmartCareID'});
maxpatintr    = max(tempintrcount.GroupCount);

if plotmode == 1 % plot with days scaled to start of study for each patient
    plotmaxdays = maxdays;
    amInterventions.PStartdn     = amInterventions.IVScaledDateNum;
    amInterventions.PPred        = amInterventions.Pred;
    amInterventionsFull.PStartdn = amInterventionsFull.IVScaledDateNum;
    amInterventionsFull.PStopdn  = amInterventionsFull.IVScaledStopDateNum;
    plottext                     = 'RelDays';
    widthperintr                 = 5;
    xdisplabels = cell(1, plotmaxdays + (maxpatintr  * widthperintr));
    for i = 1:plotmaxdays
        if i/50 == round(i/50)
            xdisplabels{i} = num2str(i);
        else
            xdisplabels{i} = '';
        end
    end
    for i = plotmaxdays + 1: plotmaxdays + (maxpatintr  * widthperintr)
        xdisplabels{i} = '';
    end
elseif plotmode == 2 % plot real days
    plotmaxdays = max(amInterventionsFull.IVStopDateNum);
    amInterventions.PStartdn     = amInterventions.IVDateNum;
    amInterventions.PPred        = amInterventions.Pred + amInterventions.PatientOffset;
    amInterventionsFull.PStartdn = amInterventionsFull.IVDateNum;
    amInterventionsFull.PStopdn  = amInterventionsFull.IVStopDateNum;
    mindate     = amInterventions.IVStartDate(1) - days(amInterventions.IVDateNum(1));
    plottext                     = 'AbsDays';
    widthperintr                 = 10;
    xdisplabels = cell(1, plotmaxdays + (maxpatintr  * widthperintr));
    for i = 1:plotmaxdays
        if i/50 == round(i/50)
            xdisplabels{i} = datestr(mindate + days(i), 1);
        else
            xdisplabels{i} = '';
        end
    end
    for i = plotmaxdays + 1: plotmaxdays + (maxpatintr  * widthperintr)
        xdisplabels{i} = '';
    end
else
    fprintf('**** Unknown Plot Mode ****\n');
    return
end

intrarray = ones(npatients, (plotmaxdays + (maxpatintr  * widthperintr)));

for p = 1:npatients
    if plotmode == 1
        prellastmday = pmPatients.RelLastMeasdn(pmPatients.PatientNbr == p);
    elseif plotmode == 2
        prellastmday = pmPatients.LastMeasdn(pmPatients.PatientNbr == p);
    else
        return;
    end
    pabs         = amInterventionsFull(amInterventionsFull.SmartCareID == pmPatients.ID(pmPatients.PatientNbr == p),:);
    ampredrows   = amInterventions(amInterventions.SmartCareID == pmPatients.ID(pmPatients.PatientNbr == p), :);
    intrcnt = 1;
    
    for d = 1:plotmaxdays
        ampredidx     = find(ampredrows.PPred <= d & ampredrows.PStartdn >= d, 1, 'first');
        ampredidx2    = find(ampredrows.PPred >= d & ampredrows.PStartdn <= d, 1, 'first');
        treatidx      = find(pabs.PStartdn <= d & pabs.PStopdn >= d);
        % for treatments
        if size(treatidx, 1) ~= 0 && ...
                (d >= pabs.PStartdn(treatidx) && ...
                 d <= pabs.PStopdn(treatidx))
            intrarray(p, d) = 2;  
        end
        % for good predictions (before treatment date)
        if size(ampredidx,1)~=0 && ...
                (d >= ampredrows.PPred(ampredidx) && ...
                 d < ampredrows.PStartdn(ampredidx))
            intrarray(p, d) = 3 + ampredrows.LatentCurve(ampredidx);
        end
        % to plot a single day for bad predictions (on or after treatment
        % date)
        if size(ampredidx2,1)~=0 && ...
                (d == ampredrows.PPred(ampredidx2) && ...
                 d >= ampredrows.PStartdn(ampredidx2))
            intrarray(p, d) = 3 + ampredrows.LatentCurve(ampredidx2);
        end
        % populate rhs colour boxes for sequence of interventions - first
        % good predictions
        if size(ampredidx,1)~=0 && (d == ampredrows.PPred(ampredidx) || (d == 1 && ampredrows.PPred(ampredidx) < 1))
            intrarray(p, (plotmaxdays + ((intrcnt -1) * widthperintr) + 1):(plotmaxdays + (intrcnt * widthperintr))) = 3 + ampredrows.LatentCurve(ampredidx);
            intrcnt = intrcnt + 1;
        end
        % next for bad predictions
        if size(ampredidx2,1)~=0 && (d == ampredrows.PPred(ampredidx2))
            intrarray(p, (plotmaxdays + ((intrcnt -1) * widthperintr) + 1):(plotmaxdays + (intrcnt * widthperintr))) = 3 + ampredrows.LatentCurve(ampredidx2);
            intrcnt = intrcnt + 1;
        end
        % plot vertical black line to indicate end of measurement period
        if d == prellastmday + 1
            intrarray(p, d) = 3;
        end
        
    end
end

ylabels = {'Dummy'};
intrcount = varfun(@max, amInterventions, 'InputVariables', {'Pred'}, 'GroupingVariables', {'SmartCareID'});
lc = outerjoin(pmPatients, intrcount, 'LeftKeys', {'ID'}, 'RightKeys', {'SmartCareID'}, 'RightVariables', {'GroupCount'});
lc.GroupCount(isnan(lc.GroupCount)) = 0;
lc = sortrows(lc, {'GroupCount', 'ID'}, {'descend', 'ascend'});

lcintrcount = varfun(@max, amInterventions, 'InputVariables', {'Pred'}, 'GroupingVariables', {'SmartCareID', 'LatentCurve'});
maxinterventions = max(lc.GroupCount);

tabletext = {'Details'};

for i = maxinterventions:-1:0
    npi = sum(lc.GroupCount == i);
    pi = lc(lc.GroupCount == i,:);
    fprintf('%d Patients with %d Predicted Interventions\n', npi, i);
    rowstring = sprintf('%d Patients with %d Predicted Interventions', npi, i);
    tabletext = [tabletext; rowstring];
    nnpi = 0;
    for n = i:-1:2
        fprintf('\t%2d with %d of the same latent curve\n', sum(ismember(lcintrcount.SmartCareID, pi.ID) & lcintrcount.GroupCount == n), n);
        rowstring = sprintf('     %2d with %d of the same latent curve', sum(ismember(lcintrcount.SmartCareID, pi.ID) & lcintrcount.GroupCount == n), n);
        tabletext = [tabletext; rowstring];
        nnpi = nnpi + sum(ismember(lcintrcount.SmartCareID, pi.ID) & lcintrcount.GroupCount == n);
    end
    if i >= 2
        fprintf('\t%2d with %d of the same latent curve\n', npi - nnpi, 1);
        rowstring = sprintf('     %2d with %d of the same latent curve', npi - nnpi, 1);
        tabletext = [tabletext; rowstring];
    elseif i == 1
        singleintr = amInterventions(ismember(amInterventions.SmartCareID, pi.ID), :);
        fprintf('\tSet 1: %d   Set 2:%d   Set 3: %d\n', sum(singleintr.LatentCurve == 1), sum(singleintr.LatentCurve == 2), sum(singleintr.LatentCurve == 3));
        rowstring = sprintf('     Set 1: %d   Set 2:%d   Set 3: %d', sum(singleintr.LatentCurve == 1), sum(singleintr.LatentCurve == 2), sum(singleintr.LatentCurve == 3));
        tabletext = [tabletext; rowstring];
    end
    
end

colors(1,:) = [1    1    1];      % white = background
colors(2,:) = [0.85 0.85 0.85];   % grey  = treatments 
colors(3,:) = [0    0    0];      % black = end of patient measurement period
colors(4,:) = [0.4, 0.8, 0.2];      % dark green = latent curve set 1
if nlatentcurves > 1
    colors(5,:) = [0    0    1];  % blue  = latent curve set 2
end
if nlatentcurves > 2
    colors(6,:) = [1    0    0];  % red   = latent curve set 3
end
if nlatentcurves > 3
    colors(7,:) = [1    0    1];  % magenta = latent curve set 4
end

plottitle = sprintf('%s - Intr vs LCSet %s', plotname, plottext);
[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');

sp(1)    = uipanel('Parent', p, ...
                   'BorderType', 'none', ...
                   'OuterPosition', [0.0, 0.15, 1.0, 0.85]);

h = heatmap(sp(1), intrarray(lc.PatientNbr,:), 'Colormap', colors);
h.Title = ' ';
h.XLabel = 'Days';
h.YLabel = 'Patients';
h.CellLabelColor = 'none';
h.GridVisible = 'off';
h.ColorbarVisible = 'off';
h.YDisplayLabels = num2cell(lc.ID);
h.XDisplayLabels = xdisplabels;

sp(2)    = uicontrol('Parent', p, ... 
                'Units', 'normalized', ...
                'OuterPosition', [0.3, 0.0, 0.4, 0.15], ...
                'Style', 'text', ...
                'FontName', 'FixedWidth', ...
                'FontSize', 6, ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'left', ...
                'String', tabletext);

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
close(f);


    

end

