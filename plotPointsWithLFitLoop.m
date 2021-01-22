function [brIntChkptPat, brIntChkptSum] = plotPointsWithLFitLoop(brIntChkptPat, brIntChkptSum, ...
    mdata1, mdata2, excldata, study, meastype, bestwind, gradtype, comptype, period1, period2, twindow, type, cutoffd, plotsubfolder, offset)

% plotPointsWithLFitLoop loops over all relevant patients and produces
% plots of best fit for different measures

exclwind = 20;
pghght = 11;
pgwdth = 8.5;
plotsacross = 2;
plotsdown = 6;
page = 1;
npat = size(brIntChkptPat, 1);
npages = ceil(npat/plotsdown);


basename = sprintf('%s %s %s %s %s vs %s', study, meastype, gradtype, comptype, period1, period2);
name = sprintf('%s - P%dof%d', basename, page, npages);
fprintf('1) %s\n', basename);
[fig, pan] = createFigureAndPanelForPaper(name, pgwdth, pghght);
colname1 = sprintf('%s%s%s%s', meastype, gradtype, comptype, period1);
colname2 = sprintf('%s%s%s%s', meastype, gradtype, comptype, period2);
brIntChkptPat{:, {colname1}} = 0.0;
brIntChkptPat{:, {colname2}} = 0.0;

if ismember(comptype, {'CvH'})
    colname3 = sprintf('%s%s%s%s', meastype, gradtype, comptype, 'StudyDateVal');
    brIntChkptPat{:, {colname3}} = 0.0;
end

thisplot = 1;
for p = 1:npat

    scid    = brIntChkptPat.ID(p);
    studyd  = brIntChkptPat.StudyDate(p);
    fromd = brIntChkptPat.StudyDate(p) - calmonths(twindow);
    tod   = brIntChkptPat.StudyDate(p) + calmonths(twindow);
    if tod > cutoffd
        tod = cutoffd;
    end
    
    fprintf('%2d: ID %d, Study Date %11s ', p, scid, datestr(studyd, 1));
    
    % get antibiotic courses to exclude data points during (and 20 days
    % prior).
    pexcldata = excldata(excldata.ID == scid, :);
    
    % FEV1 comparison - pre study vs during study
    pmdata1 = mdata1(mdata1.ID == scid, :);
    pmdata2 = mdata2(mdata2.ID == scid, :);
    
    if size(pmdata1, 1) == 0
        yl = [0.99 * min(pmdata2.Amount), 1.01 * max(pmdata2.Amount)];
    elseif size(pmdata2, 1) == 0
        yl = [0.99 * min(pmdata1.Amount), 1.01 * max(pmdata1.Amount)];
    else
        yl = [0.99 * min(min(pmdata1.Amount), min(pmdata2.Amount)), 1.01 * max(max(pmdata1.Amount), max(pmdata2.Amount))];
    end
    
    fprintf(': %s ', period1);
    ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', pan);
    brIntChkptPat{p, {colname1}} = plotPointsWithLFit(pmdata1, pexcldata, ax, yl, p, scid, fromd, studyd, ...
        exclwind, period1, meastype, bestwind, gradtype, twindow, offset);
     
    thisplot = thisplot + 1;
    
    fprintf(': %s\n', period2);
    ax = subplot(plotsdown, plotsacross, thisplot, 'Parent', pan);
    [brIntChkptPat{p, {colname2}}, studydateval] = plotPointsWithLFit(pmdata2, pexcldata, ax, yl, p, scid, studyd,   tod, ...
        exclwind, period2, meastype, bestwind, gradtype, twindow, offset);
    if ismember(comptype, {'CvH'})
        brIntChkptPat{p, {colname3}} = studydateval;
    end
    
    thisplot = thisplot + 1;
    if thisplot > plotsacross * plotsdown
        savePlotInDir(fig, name, plotsubfolder);
        close(fig);
        thisplot = 1;
        page = page + 1;
        name = sprintf('%s - P%dof%d', basename, page, npages);
        [fig, pan] = createFigureAndPanelForPaper('', pgwdth, pghght);
    end
end

if exist('fig', 'var')
    savePlotInDir(fig, name, plotsubfolder);
    close(fig);
end

% exclude those patients without enough measurements in either period
exidx = brIntChkptPat{:, {colname1}} == 0 | brIntChkptPat{:, {colname2}} == 0;
[~, pval] = ttest(brIntChkptPat{~exidx, {colname1}}, brIntChkptPat{~exidx, {colname2}});
brIntChkptSum.DataType(type)       = {sprintf('%s%s%s T-Test', meastype, gradtype, comptype)};
brIntChkptSum.n(type)              = sum(~exidx);
brIntChkptSum.Period1Mean(type)    = mean(brIntChkptPat{~exidx, {colname1}});
brIntChkptSum.Period2Mean(type)    = mean(brIntChkptPat{~exidx, {colname2}});
brIntChkptSum.Period1StdErr(type)  = std(brIntChkptPat{~exidx, {colname1}}) / (sum(~exidx) ^ 0.5);
brIntChkptSum.Period2StdErr(type)  = std(brIntChkptPat{~exidx, {colname2}}) / (sum(~exidx) ^ 0.5);
brIntChkptSum.pVal(type)           = pval;

end

