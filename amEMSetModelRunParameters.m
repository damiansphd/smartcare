function [study, modelinputsmatfile, datademographicsfile, dataoutliersfile, sigmamethod, mumethod, curveaveragingmethod, ...
    smoothingmethod, offsetblockingmethod, measuresmask, runmode, modelrun, imputationmode, confidencemode, printpredictions] = amEMSetModelRunParameters

% amEMSetModelRunParameters - sets the various run parameters for the model

studynbr = input('Enter Study to run for (1 = SmartCare, 2 = TeleMed): ');
fprintf('\n');

if studynbr == 1
    study = 'SC';
    modelinputsmatfile = 'SCalignmentmodelinputs.mat';
    datademographicsfile = 'SCdatademographicsbypatient.mat';
    dataoutliersfile = 'SCdataoutliers.mat';
elseif studynbr == 2
    study = 'TM';
    modelinputsmatfile = 'TMalignmentmodelinputs.mat';
    datademographicsfile = 'TMdatademographicsbypatient.mat';
    dataoutliersfile = 'TMdataoutliers.mat';
else
    fprintf('Invalid choice\n');
    return;
end

fprintf('Methodology for multiplicative normalisation (sigma)\n');
fprintf('----------------------------------------------------\n');
fprintf('1: Std for Data Window across interventions by measure\n');
fprintf('2: Std across all data by measure\n');
fprintf('3: Std across all data by patient and measure\n');
fprintf('4: Std for each data point in the average curve\n');
sigmamethod = input('Choose methodology (1-4) ');
fprintf('\n');
if sigmamethod > 4
    fprintf('Invalid choice\n');
    return;
end
if isequal(sigmamethod,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('Methodology for additive normalisation (mu)\n');
fprintf('-------------------------------------------\n');
fprintf('1: Mean for 8 days prior to data window\n');
fprintf('2: Upper Quartile Mean for 20 days prior to data window\n');
fprintf('3: Exclude bottom quartile from Mean for 10 days prior to data window\n');
fprintf('4: Exclude bottom quartile and data outliers from Mean for 10 days prior to data window\n');
fprintf('5: same as 4) but for sequential interventions and not enough data points in mean window, use upper 50%% mean over all patient data\n');
mumethod = input('Choose methodology (1-5) ');
fprintf('\n');
if mumethod > 5
    fprintf('Invalid choice\n');
    return;
end
if isequal(mumethod,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('Methodology for duration of curve averaging\n');
fprintf('-------------------------------------------\n');
fprintf('1: Just data window (DO NOT USE)\n');
fprintf('2: Data window + data to the left\n');
curveaveragingmethod = input('Choose methodology (1-2) ');
fprintf('\n');
if curveaveragingmethod > 2
    fprintf('Invalid choice\n');
    return;
end
if isequal(curveaveragingmethod,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('Methodology for smoothing method during curve alignment\n');
fprintf('---------------------------------------------------\n');
fprintf('1: Raw data\n');
fprintf('2: Smoothed data (5 days)\n');
smoothingmethod = input('Choose methodology (1-2) ');
fprintf('\n');
if smoothingmethod > 2
    fprintf('Invalid choice\n');
    return;
end
if isequal(smoothingmethod,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('Methodology for offset blocking\n');
fprintf('-------------------------------\n');
fprintf('1: Disable offset blocking\n');
fprintf('2: Enable offset blocking ppts (DO NOT USE)\n');
offsetblockingmethod = input('Choose methodology (1-2) ');
fprintf('\n');
if offsetblockingmethod > 2
    fprintf('Invalid choice\n');
    return;
end
if isequal(offsetblockingmethod,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('Measures to include in alignment calculation\n');
fprintf('--------------------------------------------\n');
%fprintf('1: All\n');
fprintf('1: All exceot Activity\n');
fprintf('2: Cough, Lung Function, Wellness\n');
fprintf('3: All except Activity and Lung Function\n');
measuresmask = input('Choose measures (1-3) ');
fprintf('\n');
if measuresmask > 3
    fprintf('Invalid choice\n');
    return;
end
if isequal(measuresmask,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('Methodology for EM alignment\n');
fprintf('----------------------------\n');
fprintf('4: Uniform start, use prob distribution in alignment\n');
fprintf('5: Uniform start, use point mass of offset in alignment\n');
fprintf('6: Pick start state from other model runs\n');
runmode = input('Choose methodology (1-2) ');
fprintf('\n');
if runmode < 4 || runmode > 6
    fprintf('Invalid choice\n');
    return;
end
if isequal(runmode,'')
    fprintf('Invalid choice\n');
    return;
end

if runmode == 6
    modelrun = selectModelRunFromList('pd');
else
    modelrun = '';
end

fprintf('Run imputation ?\n');
fprintf('----------------\n');
fprintf('1: No\n');
fprintf('2: Yes - with 1%% of data points held back\n');
imputationmode = input('Choose run mode(1-2) ');
fprintf('\n');
if imputationmode > 2
    fprintf('Invalid choice\n');
    return;
end
if isequal(imputationmode,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('Confidence Bounds mode\n');
fprintf('----------------------\n');
fprintf('1: Contiguous bounds\n');
fprintf('2: Max probability bounds\n');
confidencemode = input('Choose confidence bounds mode(1-2) ');
fprintf('\n');
if confidencemode > 2
    fprintf('Invalid choice\n');
    return;
end
if isequal(confidencemode,'')
    fprintf('Invalid choice\n');
    return;
end

fprintf('\n');
printpredictions = input('Print predictions (1=Yes, 2=No) ? ');
if printpredictions > 2
    fprintf('Invalid choice\n');
    return;
end
if isequal(printpredictions,'')
    fprintf('Invalid choice\n');
    return;
end

end

