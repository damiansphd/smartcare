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

detaillog = true;
max_offset = 25; % should not be greater than ex_start (set lower down) as this implies intervention before exacerbation !
align_wind = 20;

% remove temperature readings as insufficient datapoints for a number of
% the interventions
%idx = ismember(measures.DisplayName, {'Temperature'});
idx = ismember(measures.DisplayName, {'Temperature', 'Activity', 'LungFunction', 'O2Saturation', 'PulseRate', 'SleepActivity', 'Weight'});
amDatacube(:,:,measures.Index(idx)) = [];
amNormcube(:,:,measures.Index(idx)) = [];
measures(idx,:) = [];
nmeasures = size(measures,1);
measures.Index = [1:nmeasures]';
unaligned_profile = zeros(nmeasures, max_offset+align_wind);
problower = zeros(ninterventions, 1);
probupper = zeros(ninterventions, 1);

tic
fprintf('Running alignment with zero offset start\n');
for i=1:size(amInterventions,1)
        amInterventions.Offset(i) = 0;
end
best_initial_offsets = amInterventions.Offset;

run_type = 'Zero Offset Start';
[best_offsets, best_profile_pre, best_profile_post, best_histogram, best_qual] = amAlignCurves(amNormcube, amInterventions, measures, max_offset, align_wind, nmeasures, ninterventions, run_type, detaillog);
fprintf('%s - ErrFcn = %7.4f\n', run_type, best_qual);
% save the zero offset pre-profile to unaligned_profile so all plots show a
% consistent unaligned curve as the pre-profile.
unaligned_profile = best_profile_pre;
% plot and save aligned curves (pre and post)
amPlotAndSaveAlignedCurves(unaligned_profile, best_profile_post, best_offsets, best_qual, measures, max_offset, align_wind, nmeasures, run_type)
toc
fprintf('\n');

fprintf('Running alignment with random offset start\n');
niterations = 500;
%niterations = 0;
for j=1:niterations
    tic
    for i=1:ninterventions
        amInterventions.Offset(i) = floor(rand * max_offset);
    end
    initial_offsets = amInterventions.Offset;
    run_type = sprintf('Random Offset Start %d', j);
    [offsets, profile_pre, profile_post, histogram, qual] = amAlignCurves(amNormcube, amInterventions, measures, max_offset, align_wind, nmeasures, ninterventions, run_type, detaillog);
    fprintf('%s - ErrFcn = %7.4f\n', run_type, qual);
    if qual < best_qual
        % plot and save aligned curves (pre and post) if the result is best
        % so far
        amPlotAndSaveAlignedCurves(unaligned_profile, profile_post, offsets, qual, measures, max_offset, align_wind, nmeasures, run_type)
        fprintf('Best so far is random start %d\n', j);
        best_offsets = offsets;
        best_initial_offsets = initial_offsets;
        best_profile_pre = profile_pre;
        best_profile_post = profile_post;
        best_histogram = histogram;
        best_qual = qual; 
    end
    toc
end
fprintf('\n');

basedir = './';
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('alignmentmodelresults-obj%d.mat', round(best_qual*10000));
fprintf('Saving alignment model results to file %s\n', outputfilename);
save(fullfile(basedir, subfolder, outputfilename), 'best_initial_offsets', 'best_offsets', 'best_profile_pre', 'best_profile_post', 'unaligned_profile', 'best_histogram', 'best_qual');

tic
fprintf('Plotting prediction results\n');
% choose where to label exacerbation start on the best_profile
%ex_start = -25;
%best_offsets(43)

ex_start = input('Look at best start and enter exacerbation start: ');

hstgorig = best_histogram;
hstgorig(isnan(hstgorig)) = 0;

agghstg = zeros(ninterventions, max_offset);
for j = 1:ninterventions
        agghstg(j,:) = sum(hstgorig(:, j, :),1);
        normconst = norm(reshape(agghstg(j, :),[1 max_offset]),inf);
        if normconst == 0
            normconst = 1;
        end
        %agghstg(j,:) = agghstg(j,:) / norm(reshape(agghstg(j, :),[1 max_offset]),inf);
        agghstg(j,:) = agghstg(j,:) / normconst;
end
agghstg = 1 - agghstg;
agghstg = agghstg ./ sum(agghstg,2);
probthreshold = 0.75;
cumprob = 0;
for j = 1:ninterventions
    problower(j) = best_offsets(j);
    probupper(j) = best_offsets(j);
    for i = 0:max_offset - 1
        if best_offsets(j) + i >= max_offset
            probupper(j) = max_offset - 1;
        else
            probupper(j) = best_offsets(j) + i;
        end
        if best_offsets(j) - i <= 0
            problower(j) = 0;
        else
            problower(j) = best_offsets(j) - i;
        end
        cumprob = sum(agghstg(j,problower(j)+1:probupper(j)+1),2);
        if cumprob >= probthreshold
            fprintf('For intervention %2d: best_offset %2d 75%% confidence levels are lower = %2d upper = %2d\n', j, best_offsets(j), problower(j), probupper(j));
            break;
        end  
    end
end

% do l_1 normalisation of the histogram to obtain posterior probabilities,
% person x feature fixed
for m=1:nmeasures
    for j=1:ninterventions
        best_histogram(m, j, :) = best_histogram(m, j, :) / norm(reshape(best_histogram(m, j, :),[1 max_offset]),inf);
    end
end

plotsdown = 8;
plotsacross = 5;
mpos = [ 1 2 6 7 ; 3 4 8 9 ; 11 12 16 17 ; 13 14 18 19 ; 21 22 26 27 ; 23 24 28 29 ; 31 32 36 37 ; 33 34 38 39];
hpos = [ 5 ; 10 ; 15 ; 20 ; 25 ; 30 ; 35 ; 40];

days = [-1 * (max_offset + align_wind): 0];

for i=1:ninterventions
%for i = 43:43
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
        normcurrent = NaN(1,max_offset + align_wind + 1);
        %for j=1:max_offset + align_wind
        for j=0:max_offset + align_wind
            if start - j > 0
                current(max_offset + align_wind + 1 - j) = amDatacube(scid, start - j, m);    
                normcurrent(max_offset + align_wind + 1 - j) = amNormcube(scid, start - j, m);  
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
        pmmid50std  = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(6);
        ydisplaymin = min(min(current) * 0.9, pmmid50mean * 0.9);
        ydisplaymax = max(max(current) * 1.1, pmmid50mean * 1.1);
        yl = [ydisplaymin ydisplaymax];
        ylim(yl);
        title(measures.DisplayName{m}, 'FontSize', 8);
        xlabel('Days Prior', 'FontSize', 6);
        ylabel('Measure', 'FontSize', 6);
        hold on
        line( [ex_start + best_offsets(i) ex_start + best_offsets(i)] , yl, 'Color', 'red', 'LineStyle', ':', 'LineWidth', 1);
        fill([(ex_start + problower(i)) (ex_start + probupper(i)) (ex_start + probupper(i)) (ex_start + problower(i))], ...
            [ydisplaymin ydisplaymin ydisplaymax ydisplaymax], ...
            'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        line( [ex_start ex_start], [yl(1), yl(1) + ((yl(2)-yl(1)) * 0.1)], 'Color', 'black', 'LineStyle', ':', 'LineWidth', 1);
        line( [0 0] , yl, 'Color', 'magenta', 'LineStyle',':', 'LineWidth', 1);
        column = getColumnForMeasure(measures.Name{m});
        ddcolumn = sprintf('Fun_%s',column);
        %pmmid50mean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(5);
        line( xl,[pmmid50mean pmmid50mean], 'Color', 'blue', 'LineStyle', '--', 'LineWidth', 1);
        line( xl, [pmmid50mean - pmmid50std pmmid50mean - pmmid50std] , 'Color', 'blue', 'LineStyle', ':', 'LineWidth', 1)
        line( xl, [pmmid50mean + pmmid50std pmmid50mean + pmmid50std] , 'Color', 'blue', 'LineStyle', ':', 'LineWidth', 1)
        hold off;
    end
    %plot the histograms
    for m=1:nmeasures
        subplot(plotsdown, plotsacross, hpos(m,:),'Parent',p)
        scatter([0:max_offset-1],best_histogram(m,i,:),'o','MarkerFaceColor','g');
        set(gca,'fontsize',6);
        hold on;
        line( [best_offsets(i) best_offsets(i)] , [0 1],'Color','red', 'LineStyle',':','LineWidth',1);
        fill([problower(i) probupper(i) probupper(i) problower(i)], ...
            [0 0 1 1], ...
            'red', 'FaceAlpha', '0.1', 'EdgeColor', 'none');
        title(measures.DisplayName(m));
        xlim([0 max_offset-1]);
        ylim([0 1]);
        hold off;
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
