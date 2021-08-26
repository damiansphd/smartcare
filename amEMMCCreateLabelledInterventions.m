function [amLabelledInterventions] = amEMMCCreateLabelledInterventions(amIntrDatacube, amLabelledInterventions, ...
    interfrom, interto, measures, normmean, max_offset, align_wind, study, nmeasures, labelmode, basetestlabelfilename)

% amEMMCCreateLabelledInterventions - plots measurement data and asks for lower
% and upper bounds for predicted exacerbation start in order to create a
% test data set that can be compared to model results going forward

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';

if ismember(study, 'CL')
    boundwindow = 10;
    datacomp    = 50;
elseif ismember(study, 'BR')
    boundwindow = 9;
    %datacomp    = 50;
else
    boundwindow = 9;
    datacomp    = 60;
end
    
if nmeasures <= 8
    plotsdown   = 4;
    plotsacross = 2;
elseif nmeasures <= 15
    plotsdown   = 5;
    plotsacross = 3;
elseif nmeasures <= 18
    plotsdown   = 6;
    plotsacross = 3;
else
    fprintf('Function cannot handle more than 18 measurement types\n');
    return;
end
days = (-1 * (max_offset + align_wind - 1): -1);
xl  = zeros(nmeasures + 1, 2);
yl  = zeros(nmeasures + 1, 2);

i = interfrom;
while i <= interto 
    
    % for label method 4, skip if not a new intervention to label
    if (labelmode == 4) && (amLabelledInterventions.LowerBound1(i) ~= 0)
        
        i = i + 1;
        continue;
    end
    
    scid = amLabelledInterventions.SmartCareID(i);
    fprintf('Intervention %2d: ID %3d, Date %s, Data Window Completeness = %.2f%%\n', i, scid, ...
        datestr(amLabelledInterventions.IVStartDate(i),29), amLabelledInterventions.DataWindowCompleteness(i));
    name = sprintf('%s_AM Labelling Data - Ex %d (ID %d Date %s)', study, i, scid, ...
        datestr(amLabelledInterventions.IVStartDate(i),29));
   
    [f, p] = createFigureAndPanel(name, 'portrait', 'a4');
    
    for m = 1:nmeasures
        if all(isnan(amIntrDatacube(i, :, m)))
            continue;
        end
        % initialise plot areas
        xl(m,:) = [min(days) max(days)];
        yl(m,:) = [min(amIntrDatacube(i, 1:max_offset + align_wind - 1, m) * 0.99) ...
              max(amIntrDatacube(i, 1:max_offset + align_wind - 1, m) * 1.01)];
        rangelimit = setMinYDisplayRangeForMeasure(measures.Name{m});
        if yl(m, 1) == yl(m, 2)    
            yl(m, 1) = yl(m, 1) - rangelimit * 0.5;
            yl(m, 2) = yl(m, 2) + rangelimit * 0.5;
        elseif yl(m, 2) - yl(m, 1) < rangelimit
            ylavg = (yl(m, 1) + yl(m, 2)) / 2;
            yl(m, 1) = ylavg - rangelimit * 0.5;
            yl(m, 2) = ylavg + rangelimit * 0.5;
        end
        
                    
        % create subplot and plot required data arrays
        ax(m) = subplot(plotsdown, plotsacross, m, 'Parent',p);
        ax(m).XGrid = 'on';
        
        [xl(m,:), yl(m,:)] = plotMeasurementData(ax(m), days, amIntrDatacube(i, :, m), xl(m,:), yl(m,:), measures(m,:), [0, 0.65, 1], ':', 1.0, 'o', 2.0, 'blue', 'green');
        [xl(m,:), yl(m,:)] = plotMeasurementData(ax(m), days, movmean(amIntrDatacube(i, :, m), 4, 'omitnan'), xl(m,:), yl(m,:), measures(m,:), [0, 0.65, 1], '-', 1.0, 'none', 2.0, 'blue', 'green');
        title(measures.DisplayName(m), 'FontSize', 6);
        [xl(m,:), yl(m,:)] = plotHorizontalLine(ax(m), normmean(i, m), xl(m,:), yl(m,:), 'blue', '--', 0.5); % plot mean
    end
    
    [sparse] = selectValFromRange('Sparse data example ? (1:No, 2:Yes) ', 1, 2);
    if sparse == 2
        amLabelledInterventions.Sparse(i) = 'Y';
    else
        amLabelledInterventions.Sparse(i) = 'N';
    end
    [nosignal] = selectValFromRange('No signal example ? (1:No, 2:Yes 3:Maybe) ', 1, 3);
    if nosignal == 2
        amLabelledInterventions.NoSignal(i) = 'Y';
    elseif nosignal == 3
        amLabelledInterventions.NoSignal(i) = 'M';
    else
        amLabelledInterventions.NoSignal(i) = 'N';
    end
    
    lower1 = selectLabBound('lowerbound1', (-1 * (max_offset + align_wind)) + 1, -1);    
    amLabelledInterventions.LowerBound1(i) = lower1;
    
    upper1 = selectLabBound('upperbound1', lower1 + 1, -1);    
    amLabelledInterventions.UpperBound1(i) = upper1;
    
    lower2 = selectLabBound('lowerbound2', upper1 + 1, 0);
    amLabelledInterventions.LowerBound2(i) = lower2;

    upper2 = selectLabBound('upperbound2', min(0, lower2 + 1), 0);        
    amLabelledInterventions.UpperBound2(i) = upper2;
    
    for m = 1:nmeasures
        if all(isnan(amIntrDatacube(i, :, m)))
            continue;
        end
        subplot(ax(m));
        ax(m).XGrid = 'off';
        [xl(m,:), yl(m,:)] = plotVerticalLine(ax(m), amLabelledInterventions.LowerBound1(i), xl(m,:), yl(m,:),  'red', '-', 0.5);
        [xl(m,:), yl(m,:)] = plotVerticalLine(ax(m), amLabelledInterventions.UpperBound1(i), xl(m,:), yl(m,:),  'red', '-', 0.5);
        if amLabelledInterventions.LowerBound2(i) ~= 0
            [xl(m,:), yl(m,:)] = plotVerticalLine(ax(m), amLabelledInterventions.LowerBound2(i), xl(m,:), yl(m,:),  'red', '-', 0.5);
            [xl(m,:), yl(m,:)] = plotVerticalLine(ax(m), amLabelledInterventions.UpperBound2(i), xl(m,:), yl(m,:),  'red', '-', 0.5);
        end
        hold on;
        fill(ax(m), [ amLabelledInterventions.LowerBound1(i) amLabelledInterventions.UpperBound1(i)    ...
                      amLabelledInterventions.UpperBound1(i) amLabelledInterventions.LowerBound1(i) ], ...
                      [yl(m,1) yl(m,1) yl(m,2) yl(m,2)], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        if amLabelledInterventions.LowerBound2(i) ~= 0        
            fill(ax(m), [ amLabelledInterventions.LowerBound2(i) amLabelledInterventions.UpperBound2(i)    ...
                          amLabelledInterventions.UpperBound2(i) amLabelledInterventions.LowerBound2(i) ], ...
                          [yl(m,1) yl(m,1) yl(m,2) yl(m,2)], 'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        end        
        hold off;
    end

    ub1 = amLabelledInterventions.UpperBound1(i);
    ub2 = amLabelledInterventions.UpperBound2(i);
    lb1 = amLabelledInterventions.LowerBound1(i);
    lb2 = amLabelledInterventions.LowerBound2(i);
    
    if ~ismember(study, 'BR')
        if ((amLabelledInterventions.DataWindowCompleteness(i) >= datacomp) ...
                && (((ub1 - lb1) + (ub2 - lb2)) <= boundwindow))
            amLabelledInterventions.IncludeInTestSet(i) = 'Y';
        else
            amLabelledInterventions.IncludeInTestSet(i) = 'N';
        end
    else
        if ((amLabelledInterventions.Sparse(i) == 'N') ...
                && (amLabelledInterventions.NoSignal(i) == 'N') ...
                && (((ub1 - lb1) + (ub2 - lb2)) <= boundwindow))
            amLabelledInterventions.IncludeInTestSet(i) = 'Y';
        else
            amLabelledInterventions.IncludeInTestSet(i) = 'N';
        end
    end
    
    [temp] = selectValFromRange('Re-do labelling (1:No, 2:Yes, 3:Exit) ', 1, 3);
    
    if temp == 1 || temp == 3
        % save plot and datestamped matlab variable file
        plotsubfolder = sprintf('Plots/%s', study);
        savePlotInDir(f, name, plotsubfolder);
        close(f);
        outputfilename = sprintf('%s%s.mat', basetestlabelfilename, datestr(clock(),30));
        save(fullfile(basedir, subfolder, outputfilename), 'amLabelledInterventions');
        i = i + 1;
    else
        amLabelledInterventions.LowerBound1(i) = 0;
        amLabelledInterventions.UpperBound1(i) = 0;
        amLabelledInterventions.LowerBound2(i) = 0;
        amLabelledInterventions.UpperBound2(i) = 0;
        close(f);
    end
    if temp == 3
        break;
    end
end

% save final matlab variable file
fprintf('Saving labelled interventions to a separate matlab file\n');
outputfilename = sprintf('%s.mat', basetestlabelfilename);
save(fullfile(basedir, subfolder, outputfilename), 'amLabelledInterventions');

        
end


