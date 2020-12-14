function [brIntChkptPat] = calcPrePostNbrCFTRModInPeriod(brIntChkptPat, ...
    study, meastype, period1, period2, twindow, bestwind, cutoffd, plotsubfolder)

% calcNbrCFTRModInPeriod - calculates how many patients started CFTR
% modulator drugs during each period, broken into sub periods

twtext = sprintf('%dm', twindow);
bwtext = sprintf('%dm', bestwind);
pghght = 6;
pgwdth = 8.5;
plotsacross = 1;
plotsdown = 1;
npat = size(brIntChkptPat, 1);
nperiods = ceil((twindow)/bestwind);

name = sprintf('%s %s %s %s %s %s by %s', study, meastype, twtext, period1, twtext, period2, bwtext);
fprintf('1) %s\n', name);
[fig, pan] = createFigureAndPanelForPaper(name, pgwdth, pghght);
colname1 = sprintf('%s%s%s%s%sby%s', meastype, twtext, period1, twtext, period2, bwtext);
brIntChkptPat{:, {colname1}} = 0;

labeltext = cell((nperiods * 2) + 3, 1);
labeltext{1} = 'N/A';
labeltext{2}= sprintf('<%dPre', twindow);
for n = 1:nperiods
    labeltext{n + 2} = sprintf('>=%d<%d%s', twindow - ((n-1) * bestwind), (twindow - (n * bestwind)), period1);
end
for n = 1:nperiods
    labeltext{nperiods + n + 2} = sprintf('>=%d<%d%s', (n-1) * bestwind, n * bestwind, period2);
end
labeltext{(nperiods * 2) + 3} = sprintf('>=%d%s', twindow, period2);

for p = 1:npat
    
    bucket = 0;
    scid    = brIntChkptPat.ID(p);
    studyd  = brIntChkptPat.StudyDate(p);
    fromd = brIntChkptPat.StudyDate(p) - calmonths(twindow);
    tod   = brIntChkptPat.StudyDate(p) + calmonths(twindow);
    if tod > cutoffd
        tod = cutoffd;
    end
    
    fprintf('%2d: ID %d, Study Date %11s ', p, scid, datestr(studyd, 1));

    ppatdata = brIntChkptPat(brIntChkptPat.ID == scid, :);
    
    
    if isnat(ppatdata.DrugTherapyStartDate) || ppatdata.DrugTherapyStartDate >= cutoffd
        %bucket = labeltext(1);
        bucket = 0;
    elseif ppatdata.DrugTherapyStartDate < fromd
        %bucket = labeltext(2);
        bucket = 1;
    elseif ppatdata.DrugTherapyStartDate > tod
        %bucket = labeltext((nperiods * 2) + 2);
        bucket = (nperiods * 2) + 2;
    else
        for n = 1:nperiods * 2
            if (ppatdata.DrugTherapyStartDate >= (fromd + calmonths((n-1) * bestwind))) && (ppatdata.DrugTherapyStartDate < (fromd + calmonths(n * bestwind)))
                %bucket = labeltext(n + 2);
                bucket = n + 1;
            end 
        end
    end
    %fprintf('%s\n', bucket{1});
    if isnat(ppatdata.DrugTherapyStartDate)
        dtsstr = 'N/A        ';
    else
        dtsstr = datestr(ppatdata.DrugTherapyStartDate, 1);
    end
    fprintf(' DTSDate %s %d\n', dtsstr, bucket(1));
    brIntChkptPat{p, {colname1}} = bucket;
    
end

% plot histogram for each period
thisplot = 1;
ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', pan);
temp = categorical(labeltext(brIntChkptPat{:, {colname1}} + 1));
%h = histogram(ax, brIntChkptPat{:, {colname1}});
histogram(ax, temp, labeltext);
ax.FontSize = 8;
ax.FontName = 'Arial';
title(ax, name);
xlabel(ax, 'Time Period', 'FontSize', 8);
ylabel(ax, 'Count', 'FontSize', 8);

% save plot and close
if exist('fig', 'var')
    savePlotInDir(fig, name, plotsubfolder);
    close(fig);
end


%brIntChkptPat(brIntChkptPat{:, {colname1}} == 4, :) = [];

end
