function [type, doplot] = setTypeForQSCombPlot(filename)

% setTypeForQSCombPlot - set the type for the QS Combination plot

if contains(filename, {'ScenR3.13f', 'ScenR4.13f', 'ScenR4.13g', 'CLScen1.1', 'CLScen1.2', 'BRScen1.1', 'BRScen1.2', 'BRScen1.3'})
    type = 1;
    doplot = true;
elseif contains(filename, {'ScenM1.1', 'ScenM2.1', 'ScenM3.1', 'ScenM3.2'})
    type = 2;
    doplot = true;
elseif contains(filename, {'ScenM3.4', 'ScenM3.5', 'ScenM3.6'})
    type = 3;
    doplot = true;
else
    type = -1;
    doplot = false;
end

end
