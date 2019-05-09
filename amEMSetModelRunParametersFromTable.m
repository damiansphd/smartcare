function [mversion, study, modelinputsmatfile, datademographicsfile, dataoutliersfile, ...
    sigmamethod, mumethod, curveaveragingmethod, smoothingmethod, offsetblockingmethod, ...
    measuresmask, runmode, randomseed, modelrun, imputationmode, confidencemode, printpredictions, ...
    max_offset, align_wind, ex_start, outprior, heldbackpct, confidencethreshold] ...
    = amEMSetModelRunParametersFromTable(amRunParameters)

% amEMSetModelRunParameters - sets the various run parameters for the model
% from a row in amRunParameters table

mversion             = amRunParameters.mversion{1};
study                = amRunParameters.study{1};
modelinputsmatfile   = amRunParameters.modelinputsmatfile{1};
datademographicsfile = amRunParameters.datademographicsfile{1};
dataoutliersfile     = amRunParameters.dataoutliersfile{1};
sigmamethod          = amRunParameters.sigmamethod;
mumethod             = amRunParameters.mumethod;
curveaveragingmethod = amRunParameters.curveaveragingmethod;
smoothingmethod      = amRunParameters.smoothingmethod;
offsetblockingmethod = amRunParameters.offsetblockingmethod;
measuresmask         = amRunParameters.measuresmask;
runmode              = amRunParameters.runmode;
randomseed           = amRunParameters.randomseed;
modelrun             = amRunParameters.modelrun;
imputationmode       = amRunParameters.imputationmode;
confidencemode       = amRunParameters.confidencemode;
printpredictions     = amRunParameters.printpredictions;
max_offset           = amRunParameters.max_offset;
align_wind           = amRunParameters.align_wind;
ex_start             = amRunParameters.ex_start;
outprior             = amRunParameters.outprior;
heldbackpct          = amRunParameters.heldbackpct;
confidencethreshold  = amRunParameters.confidencethreshold;

end