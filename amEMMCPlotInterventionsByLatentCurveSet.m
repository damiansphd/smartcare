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
        if d == prellastmday + 1
            intrarray(p, d) = 3;
        end
        
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

