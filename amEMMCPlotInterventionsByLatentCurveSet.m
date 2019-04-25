function amEMMCPlotInterventionsByLatentCurveSet(pmPatients, pmAntibiotics, amInterventions, npatients, maxdays, plotname, plotsubfolder)

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
            intrarray(p, d) = 2 + ampredrows.LatentCurve(ampredidx);
        end
        if d == prellastmday + 1
            intrarray(p, d) = 5;
        end
    end
end

colors(1,:) = [1    1    1];
colors(2,:) = [0.85 0.85 0.85];   
colors(3,:) = [0    1    0];
colors(4,:) = [0    0    1];
colors(5,:) = [0    0    0];

plottitle = sprintf('%s - Intr vs LatentCurveSet', plotname);
[f, p] = createFigureAndPanel(plottitle, 'portrait', 'a4');

h = heatmap(p, intrarray, 'Colormap', colors);
h.Title = ' ';
h.XLabel = 'Days';
h.YLabel = 'Patients';
h.CellLabelColor = 'none';
h.GridVisible = 'off';
h.YDisplayLabels = num2cell(pmPatients.ID);

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
close(f);


end

