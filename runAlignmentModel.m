clear; close all; clc;

tic
basedir = './';
subfolder = 'MatlabSavedVariables';
modelinputsmatfile = 'alignmentmodelinputs.mat';
datademographicsfile = 'datademographicsbypatient.mat';
fprintf('Loading Alignment Model Inputs data\n');
load(fullfile(basedir, subfolder, modelinputsmatfile));
fprintf('Loading datademographics by patient\n');
load(fullfile(basedir, subfolder, datademographicsfile));
toc

detaillog = false;
max_offset = 25; % should not be greater than ex_start (set lower down) as this implies intervention before exacerbation !
align_wind = 20;

% remove temperature readings as insufficient datapoints for a number of
% the interventions
idx = ismember(measures.Name, 'TemperatureRecording');
amDatacube(:,:,measures.Index(idx)) = [];
amNormcube(:,:,measures.Index(idx)) = [];
measures(idx,:) = [];
nmeasures = size(measures,1);
measures.Index = [1:nmeasures]';

tic
fprintf('Running alignment with zero offset start\n');
for i=1:size(amInterventions,1)
        amInterventions.Offset(i) = 0;
end
run_type = 'Zero Offset Start';
[best_offsets, best_profile_pre, best_profile_post, best_histogram, best_qual] = amAlignCurves(amNormcube, amInterventions, measures, max_offset, align_wind, nmeasures, ninterventions, run_type, detaillog);
fprintf('%s - ErrFcn = %7.4f\n', run_type, best_qual);
toc
fprintf('\n');

fprintf('Running alignment with random offset start\n');
niterations = 20;
for j=1:niterations
    tic
    for i=1:ninterventions
        amInterventions.Offset(i) = floor(rand * max_offset);
    end
    run_type = sprintf('Random Offset Start %d', j);
    [offsets, profile_pre, profile_post, histogram, qual] = amAlignCurves(amNormcube, amInterventions, measures, max_offset, align_wind, nmeasures, ninterventions, run_type, detaillog);
    if qual < best_qual
        fprintf('Best so far is random start %d\n', j);
        best_offsets = offsets;
        best_profile_pre = profile_pre;
        best_profile_post = profile_post;
        best_histogram = histogram;
        best_qual = qual; 
    end
    fprintf('%s - ErrFcn = %7.4f\n', run_type, qual);
    toc
end
fprintf('\n');

tic
fprintf('Plotting results\n');
% choose where to label exacerbation start on the best_profile
ex_start = -25;

% do l_1 normalisation of the histogram to obtain posterior probabilities,
% person x feature fixed
for m=1:nmeasures
    for j=1:ninterventions
        best_histogram(m, j, :) = best_histogram(m, j, :) / norm(reshape(best_histogram(m, j, :),[1 max_offset]),inf) ;
    end
end

plotsdown = 8;
plotsacross = 5;
mpos = [ 1 2 6 7 ; 3 4 8 9 ; 11 12 16 17 ; 13 14 18 19 ; 21 22 26 27 ; 23 24 28 29 ; 31 32 36 37 ; 33 34 38 39];
hpos = [ 5 ; 10 ; 15 ; 20 ; 25 ; 30 ; 35 ; 40];

days = [-1 * (max_offset + align_wind): 0];

for i=1:ninterventions
%for i = 1:3
    scid = amInterventions.SmartCareID(i);
    start = amInterventions.IVScaledDateNum(i);
    name = sprintf('Alignment Model - Exacerbation %d - ID %d Date %s', i, scid, datestr(amInterventions.IVStartDate(i),29));
    f = figure('Name', name);
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0.45, 0, 0.35, 0.92], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a4');
    %set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    p = uipanel('Parent',f,'BorderType','none');
    fprintf('%s - Best Offset = %d\n', name, best_offsets(i));
    p.Title = name;
    p.TitlePosition = 'centertop';
    p.FontSize = 12;
    p.FontWeight = 'bold'; 
    for m = 1:nmeasures
        current = NaN(1,max_offset + align_wind + 1);
        for j=1:max_offset + align_wind
            if start - j > 0
                current(max_offset + align_wind + 1 - j) = amDatacube(scid, start - j, m);    
            end
        end
        if all(isnan(current))
            continue;
        end
        subplot(plotsdown, plotsacross, mpos(m,:), 'Parent',p)   
        plot(days, current, ...
            'Color', [0, 0.65, 1], ...
            'LineStyle', '-', ...
            'Marker', 'o', ...
            'LineWidth',1, ...
            'MarkerSize',3,...
            'MarkerEdgeColor','b',...
            'MarkerFaceColor','g');
        set(gca,'fontsize',6);
        xl = [min(days) max(days)];
        xlim(xl);
        column = getColumnForMeasure(measures.Name{m});
        ddcolumn = sprintf('Fun_%s',column);
        pmmid50mean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(5);
        ydisplaymin = min(min(current) * 0.9, pmmid50mean * 0.9);
        ydisplaymax = max(max(current) * 1.1, pmmid50mean * 1.1);
        yl = [ydisplaymin ydisplaymax];
        ylim(yl);
        title(measures.DisplayName{m}, 'FontSize', 8);
        xlabel('Days Prior', 'FontSize', 6);
        ylabel('Measure', 'FontSize', 6);
        hold on
        line( [ex_start + best_offsets(i) ex_start + best_offsets(i)] , yl, 'Color', 'red', 'LineStyle', ':', 'LineWidth', 1);
        line( [ex_start ex_start], [yl(1), yl(1) + ((yl(2)-yl(1)) * 0.1)], 'Color', 'black', 'LineStyle', ':', 'LineWidth', 1);
        line( [0 0] , yl, 'Color', 'magenta', 'LineStyle',':', 'LineWidth', 1);
        column = getColumnForMeasure(measures.Name{m});
        ddcolumn = sprintf('Fun_%s',column);
        pmmid50mean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(5);
        line( xl,[pmmid50mean pmmid50mean], 'Color', 'blue', 'LineStyle', '--', 'LineWidth', 1);
        hold off;
    end
    %plot the histograms
    for m=1:nmeasures
        subplot(plotsdown, plotsacross, hpos(m,:),'Parent',p)
        scatter([0:max_offset-1],best_histogram(m,i,:),'o','MarkerFaceColor','g');
        set(gca,'fontsize',6);
        line( [best_offsets(i) best_offsets(i)] , [0 1],'Color','red', 'LineStyle',':','LineWidth',1);
        title(measures.DisplayName(m));
        xlim([0 max_offset-1]);
        ylim([0 1]);
    end

    basedir = './';
    subfolder = 'Plots';
    filename = [name '.png'];
    saveas(f,fullfile(basedir, subfolder, filename));
    filename = [name '.svg'];
    saveas(f,fullfile(basedir, subfolder, filename));
    close(f);
end
toc
