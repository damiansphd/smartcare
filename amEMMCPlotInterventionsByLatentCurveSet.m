function amEMMCPlotInterventionsByLatentCurveSet(pmPatients, pmAntibiotics, amInterventions, npatients, maxdays, plotname, plotsubfolder, nlatentcurves)

% amEMMCPlotInterventionsByLatentCurveSet - plots interventions and
% treatments over time for all patients, and colour codes the treatments by
% latent curve set.

intrarray = ones(npatients, maxdays);

for p = 1:npatients
    prellastmday = pmPatients.RelLastMeasdn(pmPatients.PatientNbr == p);
    pabs         = pmAntibiotics(pmAntibiotics.PatientNbr == p, :);
    ampredrows   = amInterventions(amInterventions.SmartCareID == pmPatients.ID(pmPatients.PatientNbr == p), :);
    
    for d = 1:maxdays
        ampredidx     = find(ampredrows.Pred <= d & ampredrows.IVScaledDateNum >= d, 1, 'first');
        ampredidx2    = find(ampredrows.Pred >= d & ampredrows.IVScaledDateNum <= d, 1, 'first');
        predtreatidx  = find(pabs.RelStartdn >= d, 1, 'first');
        treatidx   = find(pabs.RelStartdn <= d & pabs.RelStopdn >= d, 1, 'last');
        if size(treatidx, 1) ~= 0 && ...
                (d >= pabs.RelStartdn(treatidx) && ...
                 d <= pabs.RelStopdn(treatidx))
            intrarray(p, d) = 2;  
        end
        if size(ampredidx,1)~=0 && ...
                (d >= ampredrows.Pred(ampredidx) && ...
                 d < ampredrows.IVScaledDateNum(ampredidx))
            intrarray(p, d) = 3 + ampredrows.LatentCurve(ampredidx);
        end
        if size(ampredidx2,1)~=0 && ...
                (d == ampredrows.Pred(ampredidx2) && ...
                 d >= ampredrows.IVScaledDateNum(ampredidx2))
            intrarray(p, d) = 3 + ampredrows.LatentCurve(ampredidx2);
        end
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
colors(4,:) = [0    1    0];      % green = latent curve set 1
if nlatentcurves > 1
    colors(5,:) = [0    0    1];  % blue  = latent curve set 2
end
if nlatentcurves > 2
    colors(6,:) = [1    0    0];  % red   = latent curve set 3
end
if nlatentcurves > 3
    colors(7,:) = [1    0    1];  % magenta = latent curve set 4
end

plottitle = sprintf('%s - Intr vs LatentCurveSet', plotname);
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

