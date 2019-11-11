function [physdata, offset, physdata_predateoutlierhandling] = loadAndHarmoniseMeasVars(datamatfile, subfolder, studynbr, study)

% loadAndHarmoniseMeasVars - loads raw measurement variables and standardises
% their naming

tic
basedir = setBaseDir();
fprintf('Loading %s Study Measurement data\n', study);
physdata_original = [];

if studynbr == 1
    load(fullfile(basedir, subfolder, datamatfile), 'physdata', 'physdata_predateoutlierhandling', 'offset');
elseif studynbr == 2
    load(fullfile(basedir, subfolder, datamatfile), 'tmphysdata', 'tmoffset', 'tmphysdata_predateoutlierhandling');
    physdata       = tmphysdata;
    offset         = tmoffset;
    physdata_predateoutlierhandling = tmphysdata_predateoutlierhandling;
elseif studynbr == 3
    load(fullfile(basedir, subfolder, datamatfile), 'clphysdata', 'cloffset', 'clphysdata_predateoutlierhandling');
    physdata       = clphysdata;
    offset         = cloffset;
    physdata_predateoutlierhandling = clphysdata_predateoutlierhandling;
elseif studynbr == 4
    load(fullfile(basedir, subfolder, datamatfile), 'brphysdata', 'broffset', 'brphysdata_predateoutlierhandling');
    physdata       = brphysdata;
    offset         = broffset;
    physdata_predateoutlierhandling = brphysdata_predateoutlierhandling;
end
toc

end

