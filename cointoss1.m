
plotsacross = 2;
plotsdown = 3;
plottitle = sprintf('Coin Toss Exercise 1 - Uniform Prior, 10, 20, 30 tosses');
[fig, pan] = createFigureAndPanel(plottitle, 'portrait', 'a4');

for scen = 1:3
    
    parray = 0;

    keepgoing = 1;
    ntosses = scen * 10;
    while keepgoing
        p = rand;
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
    name = sprintf('%d Tosses', scen * 10);
    title(ax(scen), name);
    
    ax2(scen) = subplot(plotsdown,plotsacross,scen * 2,'Parent',pan);
    x = [0: 0.01: 1];
    y = betapdf(x, ntosses/2, ntosses/2);
    plot(x, y, 'LineStyle', '-', 'Color', 'blue', 'LineWidth', 2);
    name = sprintf('Beta Distribution (a=%d, b=%d)', ntosses/2, ntosses/2);
    title(ax2(scen), name);
    
end      

plotsubfolder = 'Plots';
savePlotInDir(fig, plottitle, plotsubfolder);


        
        
    