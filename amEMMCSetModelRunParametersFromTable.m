function [mversion, study, modelinputsmatfile, datademographicsfile, dataoutliersfile, labelledinterventionsfile, electivefile, ...
    sigmamethod, mumethod, curveaveragingmethod, smoothingmethod, datasmoothmethod, ...
    measuresmask, runmode, randomseed, intrmode, modelrun, imputationmode, confidencemode, printpredictions, ...
    max_offset, align_wind, outprior, heldbackpct, confidencethreshold, nlatentcurves, countthreshold, scenario] ...
    = amEMMCSetModelRunParametersFromTable(amRunParameters)

% amEMMCSetModelRunParameters - sets the various run parameters for the model
% from a row in amRunParameters table

mversion                  = amRunParameters.mversion{1};
study                     = amRunParameters.study{1};
modelinputsmatfile        = amRunParameters.modelinputsmatfile{1};
datademographicsfile      = amRunParameters.datademographicsfile{1};
dataoutliersfile          = amRunParameters.dataoutliersfile{1};
labelledinterventionsfile = amRunParameters.labelledinterventionsfile{1};
electivefile              = amRunParameters.electivefile{1};
sigmamethod               = amRunParameters.sigmamethod;
mumethod                  = amRunParameters.mumethod;
curveaveragingmethod      = amRunParameters.curveaveragingmethod;
smoothingmethod           = amRunParameters.smoothingmethod;
datasmoothmethod          = amRunParameters.datasmoothmethod;
measuresmask              = amRunParameters.measuresmask;
runmode                   = amRunParameters.runmode;
if runmode == 4 || runmode == 5 || runmode == 9
    randomseed            = amRunParameters.randomseed;
else
    randomseed            = 0;
end
intrmode                  = amRunParameters.intrmode;
modelrun                  = amRunParameters.modelrun;
imputationmode            = amRunParameters.imputationmode;
confidencemode            = amRunParameters.confidencemode;
printpredictions          = amRunParameters.printpredictions;
max_offset                = amRunParameters.max_offset;
align_wind                = amRunParameters.align_wind;
outprior                  = amRunParameters.outprior;
heldbackpct               = amRunParameters.heldbackpct;
confidencethreshold       = amRunParameters.confidencethreshold;
nlatentcurves             = amRunParameters.nlatentcurves;
countthreshold            = amRunParameters.countthreshold;
scenario                  = amRunParameters.scenario{1};

end