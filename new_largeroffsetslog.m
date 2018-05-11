clear; close all; clc;

tic
fprintf('Loading saved variables\n');
load('endtoendworkspace.mat');
load('largeroffsets_workspace.mat');
% added to load new data
load('newdata.mat');
toc
fprintf('\n');

tic
run_mode = 'new';
basedir = './';
subfolder = 'Plots';
if run_mode == 'new'
    % run with new data
    realcube = newrealcube;
    intrfin = newintrfin;
    prefix = 'New';
else
    realcube = safecube;
    prefix = 'Old';
end

[a b] = size(intrfin);
cubefin = NaN(300,650,6);
sum = zeros(6,1);
count = zeros(6,1);
meanwindow = 7;
max_offset = 25; % should not be greater than ex_start (set lower down) as this implies intervention before exacerbation !
align_wind = 20;
%align_wind = 23;
meanfin = NaN(300,6);

fprintf('Normalising measurement data\n');
for x=1:a
    for k=1:6
        sum(k) = 0;
        count(k) = 0;
    end
    for i=1:meanwindow
        for j=1:6
           if (intrfin.Start(x)-align_wind-i > 0) & (isnan(realcube(intrfin.ID(x),intrfin.Start(x)-align_wind-i,j)) == 0) & (count(j) < 3)
            	sum(j) = sum(j) + realcube(intrfin.ID(x),intrfin.Start(x)-align_wind-i,j);
                count(j) = count(j)+1;
           end
        end
    end
    for i=1:max_offset+align_wind
        for j=1:6
           if count(j) > 1
         
               meanfin(intrfin.ID(x),j) = sum(j)/count(j);
           else
               meanfin(intrfin.ID(x),j) = means{intrfin.ID(x),j};
           end
           if (intrfin.Start(x)-(max_offset+align_wind+1)+i > 0) & (isnan(realcube(intrfin.ID(x),intrfin.Start(x)-(max_offset+align_wind+1)+i,j)) == 0)
               if count(j) > 1
                   
                    cubefin(intrfin.ID(x),intrfin.Start(x)-(max_offset+align_wind+1)+i,j) = (realcube(intrfin.ID(x),intrfin.Start(x)-(max_offset+align_wind+1)+i,j)- sum(j)/count(j))/stdds{intrfin.ID(x),j};
               else
                    cubefin(intrfin.ID(x),intrfin.Start(x)-(max_offset+align_wind+1)+i,j) = (realcube(intrfin.ID(x),intrfin.Start(x)-(max_offset+align_wind+1)+i,j)- means{intrfin.ID(x),j})/stdds{intrfin.ID(x),j};
               end
           end
        end
    end
end
toc
fprintf('\n');

tic
cubefin(:,:,4:5) = []; %remove unwanted features
realcube(:,:,4:5) = [];
meanfin(:,4:5) = [];

%find the best possible alignment by randomising
%set the baseline alignment coming from (0,...,0) offset initialisation
for i=1:a
        intrfin.offset(i) = 0;
    end
[best_offsets, best_profile, best_profile2, best_histogram, best_qual] = new_flexible_align(cubefin,intrfin,max_offset,align_wind, run_mode);
fprintf('Baseline - zero offset start - ErrFcn = %6.1f\n', best_qual);
toc
fprintf('\n');

numiter = 20;
for j=1:numiter
    tic
    for i=1:a
        intrfin.offset(i) = floor(rand*max_offset);
    end
    [offsets, profile, profile2, histogram, qual] = new_flexible_align(cubefin,intrfin,max_offset,align_wind, run_mode);
    if qual < best_qual
        best_offsets = offsets;
        best_profile = profile;
        best_profile2 = profile2;
        best_histogram = histogram;
        best_qual = qual; 
    end
    fprintf('Random offset - start %d/%d - ErrFcn = %6.1f\n', j, numiter, qual);
    toc
end
fprintf('\n');

tic
close all;
fprintf('Plotting results\n');
% choose where to label exacerbation start on the best_profile
if run_mode == 'new'
    ex_start = -25;
else
    ex_start = -21;
end

% do l_1 normalisation of the histogram to obtain posterior probabilities,
% person x feature fixed
for i=1:4
    for j=1:a
        best_histogram(i,j,:) = best_histogram(i,j,:) / norm(reshape(best_histogram(i,j,:),[1 max_offset]),inf) ;
    end
end
pos = [ 1 2 6 7 ; 4 5 9 10; 11 12 16 17; 14 15 19 20];
%days = [1:max_offset+align_wind+1];
days = [-1*(max_offset+align_wind):0];

for i=1:a
%for i = 38:41
        f = figure ;
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
        p = uipanel('Parent',f,'BorderType','none'); 
        name = sprintf('%s Data - Exacerbation %d - ID %d Date %d', prefix, i, intrfin.ID(i), intrfin.Start(i));
        fprintf('%s - Best Offset = %d\n', name, best_offsets(i));
        p.Title = name;
        %p.Title = [num2str(i),' ; ID = ',num2str(intrfin.ID(i))]; 
        p.TitlePosition = 'centertop';
        p.FontSize = 20;
        p.FontWeight = 'bold'; 
        for k=1:4
            current = NaN(1,max_offset+align_wind+1);
            for j=1:max_offset+align_wind
                if intrfin.Start(i) - j > 0
                    current(max_offset+align_wind+1-j) = realcube(intrfin.ID(i),intrfin.Start(i)-j,k);
                end
            end
            subplot(4,5,pos(k,:),'Parent',p)   
            plot(days,current,'y-o',...
                'LineWidth',2,...
                'MarkerSize',5,...
                'MarkerEdgeColor','b',...
                'MarkerFaceColor','g');
            xlim([min(days) max(days)]);
            yl = ylim;
            xl = xlim;
            yl = [0.9*yl(1) 1.1*yl(2)];
            yl(1) = min(yl(1),0.9*meanfin(intrfin.ID(i),k));
            yl(2) = max(yl(2),1.1*meanfin(intrfin.ID(i),k));
            ylim(yl);
            title(tit(k));
            hold on
            %line( [ex_start+best_offsets(i) ex_start+best_offsets(i)] , yl,'Color','red','LineWidth',2);
            %line( [max_offset+align_wind+1 max_offset+align_wind+1] , yl,'Color','magenta','LineWidth',2);
            line( [ex_start+best_offsets(i) ex_start+best_offsets(i)] , yl, 'Color', 'red', 'LineStyle', ':', 'LineWidth', 2);
            line( [ex_start ex_start], [yl(1), yl(1)+(yl(2)-yl(1)) * 0.1], 'Color', 'black', 'LineStyle', ':', 'LineWidth', 2);
            line( [0 0] , yl, 'Color', 'magenta', 'LineStyle',':', 'LineWidth', 2);
            line( xl,[meanfin(intrfin.ID(i),k) meanfin(intrfin.ID(i),k)], 'Color', 'black', 'LineStyle', ':', 'LineWidth', 2);
            hold off;
        end
        %plot the histogram
        for k=1:4
            subplot(4,5,-2+k*5,'Parent',p)
            %scatter([max_offset:-1:1],best_histogram(k,i,:),'o','MarkerFaceColor','g');
            scatter([0:max_offset-1],best_histogram(k,i,:),'o','MarkerFaceColor','g');
            line( [best_offsets(i) +best_offsets(i)] , [0 1],'Color','red', 'LineStyle',':','LineWidth',2);
            title(tit(k));
            xlim([0 max_offset-1]);
            ylim([0 1]);
        end
        
        %filename = sprintf('%s Data - Exacerbation %d - ID %d Date %d.png', prefix, i, intrfin.ID(i), intrfin.Start(i));
        basedir = './';
        subfolder = 'Plots';
        filename = [name '.png'];
        saveas(f,fullfile(basedir, subfolder, filename));
        %saveas(f,['im',num2str(i),'.png']);
        close(f);
end
toc


