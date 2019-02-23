

for b = 1:3
    
    parray = 0;

    keepgoing = 1;
    ntosses = b * 10;
    while keepgoing
        p = rand;
        nheads = 0;
        ntails = 0;
        pd = makedist('Binomial', 'n', 1, 'p', p);
        for a = 1:ntosses
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
    name = sprintf('Coin Toss Example - %d Tosses', b * 10);
    h = histogram(parray,20);
    plotsubfolder = 'Plots';
    savePlotInDir(h, name, plotsubfolder);
end            
        
        
    