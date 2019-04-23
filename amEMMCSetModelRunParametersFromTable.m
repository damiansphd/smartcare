function [mversion, study, modelinputsmatfile, datademographicsfile, dataoutliersfile, labelledinterventionsfile, ...
    sigmamethod, mumethod, curveaveragingmethod, smoothingmethod, ...
    measuresmask, runmode, modelrun, imputationmode, confidencemode, printpredictions, ...
    max_offset, align_wind, outprior, heldbackpct, confidencethreshold, nlatentcurves] ...
    = amEMMCSetModelRunParametersFromTable(amRunParameters)

% amEMMCSetModelRunParameters - sets the various run parameters for the model
% from a row in amRunParameters table

mversion                  = amRunParameters.mversion{1};
study                     = amRunParameters.study{1};
modelinputsmatfile        = amRunParameters.modelinputsmatfile{1};
datademographicsfile      = amRunParameters.datademographicsfile{1};
dataoutliersfile          = amRunParameters.dataoutliersfile{1};
labelledinterventionsfile = amRunParameters.labelledinterventionsfile{1};
sigmamethod               = amRunParameters.sigmamethod;
mumethod                  = amRunParameters.mumethod;
curveaveragingmethod      = amRunParameters.curveaveragingmethod;
smoothingmethod           = amRunParameters.smoothingmethod;
measuresmask              = amRunParameters.measuresmask;
runmode                   = amRunParameters.runmode;
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

end