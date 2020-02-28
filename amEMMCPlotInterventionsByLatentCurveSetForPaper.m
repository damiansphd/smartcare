function amEMMCPlotInterventionsByLatentCurveSetForPaper(pmPatients, amInterventions, ...
    ivandmeasurestable, npatients, maxdays, plotname, plotsubfolder, nlatentcurves, plotmode, studymarkermode, pfiltermode)

% amEMMCPlotInterventionsByLatentCurveSetForPaper - plots interventions and
% treatments over time for all patients, and colour codes the treatments by
% latent curve set. Use updated formatting for paper

tempintrcount = varfun(@max, amInterventions, 'InputVariables', {'Pred'}, 'GroupingVariables', {'SmartCareID'});
maxpatintr    = max(tempintrcount.GroupCount);

if plotmode == 1 % plot with days scaled to start of study for each patient
    plotmaxdays = maxdays;
    amInterventions.PStartdn     = amInterventions.IVScaledDateNum;
    amInterventions.PPred        = amInterventions.Pred;
    ivandmeasurestable = innerjoin(ivandmeasurestable, unique(amInterventions(:,{'SmartCareID', 'PatientOffset'})), 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'SmartCareID'}, 'RightVariables', {'PatientOffset'});
    ivandmeasurestable.IVScaledDateNum = ivandmeasurestable.IVDateNum - ivandmeasurestable.PatientOffset;
    ivandmeasurestable.IVScaledStopDateNum = ivandmeasurestable.IVStopDateNum - ivandmeasurestable.PatientOffset;
    ivandmeasurestable.PStartdn = ivandmeasurestable.IVScaledDateNum;
    ivandmeasurestable.PStopdn  = ivandmeasurestable.IVScaledStopDateNum;
    plottext                     = 'RelDays';
    widthperintr                 = 5;
    divider                      = 5;
    xdisplabels = cell(1, plotmaxdays + divider + (maxpatintr  * widthperintr));
    for i = 1:plotmaxdays
        if i/50 == round(i/50)
            xdisplabels{i} = num2str(i);
        else
            xdisplabels{i} = '';
        end
    end
    for i = plotmaxdays + 1: plotmaxdays + divider + (maxpatintr  * widthperintr)
        xdisplabels{i} = '';
    end
elseif plotmode == 2 % plot real days
    plotmaxdays = max(max(ivandmeasurestable.IVStopDateNum), max(pmPatients.LastMeasdn));
    amInterventions.PStartdn     = amInterventions.IVDateNum;
    amInterventions.PPred        = amInterventions.Pred + amInterventions.PatientOffset;
    ivandmeasurestable.PStartdn = ivandmeasurestable.IVDateNum;
    ivandmeasurestable.PStopdn  = ivandmeasurestable.IVStopDateNum;
    mindate     = amInterventions.IVStartDate(1) - days(amInterventions.IVDateNum(1));
    plottext                     = 'AbsDays';
    widthperintr                 = 10;
    divider                      = 10;
    xdisplabels = cell(1, plotmaxdays + divider + (maxpatintr  * widthperintr));
    for i = 1:plotmaxdays
        if i/50 == round(i/50)
            xdisplabels{i} = datestr(mindate + days(i), 1);
        else
            xdisplabels{i} = '';
        end
    end
    for i = plotmaxdays + 1: plotmaxdays + divider + (maxpatintr  * widthperintr)
        xdisplabels{i} = '';
    end
else
    fprintf('**** Unknown Plot Mode ****\n');
    return
end

if studymarkermode == 2
    plottext = sprintf('%sWithStudy', plottext);
end
if pfiltermode == 2
    plottext = sprintf('%sFilt', plottext);
end

intrarray = ones(npatients, (plotmaxdays + divider + (maxpatintr  * widthperintr)));

for p = 1:npatients
    
    if plotmode == 1
        prellastmday  = pmPatients.RelLastMeasdn(pmPatients.PatientNbr == p);
        prelfirstmday = 1;
    elseif plotmode == 2
        prellastmday  = pmPatients.LastMeasdn(pmPatients.PatientNbr == p);
        prelfirstmday = pmPatients.FirstMeasdn(pmPatients.PatientNbr == p);
    else
        return;
    end
    pabs         = ivandmeasurestable(ivandmeasurestable.SmartCareID == pmPatients.ID(pmPatients.PatientNbr == p),:);
    ampredrows   = amInterventions(amInterventions.SmartCareID == pmPatients.ID(pmPatients.PatientNbr == p), :);
    intrcnt = 1;
    
    for d = 1:plotmaxdays
        ampredidx     = find(ampredrows.PPred <= d & ampredrows.PStartdn >= d, 1, 'first');
        ampredidx2    = find(ampredrows.PPred >= d & ampredrows.PStartdn <= d, 1, 'first');
        treatidx      = find(pabs.PStartdn <= d & pabs.PStopdn >= d);
        
        if studymarkermode == 2
            % shade cells in study/measurement period
            if d >= prelfirstmday && d <= max(prellastmday, prelfirstmday + 183)
                intrarray(p, d) = 2;
            end
        end
        % for treatments
        if size(treatidx, 1) ~= 0 && ...
                (d >= pabs.PStartdn(treatidx) && ...
                 d <= pabs.PStopdn(treatidx))
            intrarray(p, d) = 3;  
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
            intrarray(p, (plotmaxdays + divider + ((intrcnt - 1) * widthperintr) + 1):(plotmaxdays + divider + (intrcnt * widthperintr))) = 3 + ampredrows.LatentCurve(ampredidx);
            intrcnt = intrcnt + 1;
        end
        % next for bad predictions
        if size(ampredidx2,1)~=0 && (d == ampredrows.PPred(ampredidx2))
            intrarray(p, (plotmaxdays + divider + ((intrcnt -1) * widthperintr) + 1):(plotmaxdays + divider + (intrcnt * widthperintr))) = 3 + ampredrows.LatentCurve(ampredidx2);
            intrcnt = intrcnt + 1;
        end
        
        
    end
end

intrcount = varfun(@max, amInterventions, 'InputVariables', {'Pred'}, 'GroupingVariables', {'SmartCareID'});
lc = outerjoin(pmPatients, intrcount, 'LeftKeys', {'ID'}, 'RightKeys', {'SmartCareID'}, 'RightVariables', {'GroupCount'});
lc.GroupCount(isnan(lc.GroupCount)) = 0;
lc = sortrows(lc, {'GroupCount', 'ID'}, {'descend', 'ascend'});
if pfiltermode == 2
    lc = lc(lc.GroupCount ~= 0, :);
end

colors(1,:) = [1     1     1];      % white = background
colors(2,:) = [0.980 0.945 0.921];  % pale cream = patient study/measurement period
colors(3,:) = [0.85  0.85  0.85];   % darker grey  = treatments 
colors(4,:) = [1     0     0];      % red   = latent curve set 1 (which is group 3 in the paper)
if nlatentcurves > 1
    colors(5,:) = [0    0    1];  % blue  = latent curve set 2 (which is group 2 in the paper)
end
if nlatentcurves > 2
    colors(6,:) = [0.4, 0.8, 0.2]; % dark green = latent curve set 3 (which is group 1 in the paper)
end
if nlatentcurves > 3
    colors(7,:) = [1    0    1];  % magenta = latent curve set 4
end

plottitle = sprintf('%s - Intr vs LCSet For Paper %s', plotname, plottext);

if pfiltermode == 2
    pghght = 7.5;
else
    pghght = 11;
end
pgwdth = 8.5;
fontname = 'Arial';

[f, p] = createFigureAndPanelForPaper('', pgwdth, pghght);

sp(1)    = uipanel('Parent', p, ...
                   'BorderType', 'none', ...
                   'OuterPosition', [0.0, 0.0, 1.0, 1.0]);

h = heatmap(sp(1), intrarray(lc.PatientNbr,:), 'Colormap', colors);
h.Title = ' ';
h.FontName = fontname;
h.FontSize = 8;
h.XLabel = 'Days';
h.YLabel = 'Patients';
h.CellLabelColor = 'none';
h.GridVisible = 'off';
h.ColorbarVisible = 'off';
h.YDisplayLabels = num2cell(lc.ID);
h.XDisplayLabels = xdisplabels;

% save plot
savePlotInDir(f, plottitle, plotsubfolder);
savePlotInDirAsSVG(f, plottitle, plotsubfolder);
close(f);

end

