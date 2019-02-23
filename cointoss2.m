
% set beta prior parameters
a = 10;
b = 1;

plotsacross = 2;
plotsdown = 3;
plottitle = sprintf('Coin Toss Exercise 2');
[fig, pan] = createFigureAndPanel(plottitle, 'portrait', 'a4');

for scen = 1:1
    
    parray = 0;

    keepgoing = 1;
    ntosses = 10;
    while keepgoing
        p = betarnd(a,b);
        nheads = 0;
        ntails = 0;
        pd = makedist('Binomial', 'n', 1, 'p', p);
        for n = 1:ntosses
            result = random(pd);
            if result == 1
                nheads = nheads + 1;
            elseif result == 0
                ntails = ntails + 1;
            else
                fprintf('should never get here!!\n');
            end
        end
        if nheads == ntosses / 2 
            parray = [parray; p];
        end
        if size(parray,1) == 10000
            keepgoing = 0;
        end
        if size(parray,1)/1000 == round(size(parray,1)/1000)
            fprintf('%d\n', size(parray,1));
        end
    end
    ax(scen) = subplot(plotsdown,plotsacross,scen * 2 - 1,'Parent',pan);
    histogram(parray,20);
    name = sprintf('%d Tosses, %d Heads', scen * 10, round(ntosses/2));
    title(ax(scen), name);
    
    ax2(scen) = subplot(plotsdown,plotsacross,scen * 2,'Parent',pan);
    x = [0: 0.01: 1];
    y = betapdf(x, a, b);
    line(x, y, 'LineStyle', ':', 'Color', 'red', 'LineWidth', 2);
    y = betapdf(x, ntosses/2, ntosses/2);
    line(x, y, 'LineStyle', '--', 'Color', 'green', 'LineWidth', 2);
    y = betapdf(x, a + ntosses/2, b + ntosses/2);
    line(x, y, 'LineStyle', '-', 'Color', 'blue', 'LineWidth', 2);
    name = sprintf('Beta Distribution (a=%d, b=%d)', a + ntosses/2, b + ntosses/2);
    title(ax2(scen), name);
    
end      

% set beta prior parameters
a = 1;
b = 1;

for scen = 2:2
    
    parray = 0;

    keepgoing = 1;
    ntosses = 19;
    while keepgoing
        p = betarnd(a,b);
        nheads = 0;
        ntails = 0;
        pd = makedist('Binomial', 'n', 1, 'p', p);
        for n = 1:ntosses
            result = random(pd);
            if result == 1
                nheads = nheads + 1;
            elseif result == 0
                ntails = ntails + 1;
            else
                fprintf('should never get here!!\n');
            end
        end
        if nheads == 14 
            parray = [parray; p];
        end
        if size(parray,1) == 10000
            keepgoing = 0;
        end
        if size(parray,1)/1000 == round(size(parray,1)/1000)
            fprintf('%d\n', size(parray,1));
        end
    end
    ax(scen) = subplot(plotsdown,plotsacross,scen * 2 - 1,'Parent',pan);
    histogram(parray,20);
    name = sprintf('%d Tosses, %d Heads', ntosses, 14);
    title(ax(scen), name);
    
    ax2(scen) = subplot(plotsdown,plotsacross,scen * 2,'Parent',pan);
    x = [0: 0.01: 1];
    y = betapdf(x, a, b);
    line(x, y, 'LineStyle', ':', 'Color', 'red', 'LineWidth', 2);
    y = betapdf(x, 14, (ntosses-14));
    line(x, y, 'LineStyle', '--', 'Color', 'green', 'LineWidth', 2);
    y = betapdf(x, a + 14, b + (ntosses-14));
    line(x, y, 'LineStyle', '-', 'Color', 'blue', 'LineWidth', 2);
    name = sprintf('Beta Distribution (a=%d, b=%d)', a + 14, b + (ntosses-14));
    title(ax2(scen), name);
    ax2(scen).YLim = [0,10];
    
    
end

plotsubfolder = 'Plots';
savePlotInDir(fig, plottitle, plotsubfolder);
close(fig);



        
        
    