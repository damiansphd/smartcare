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
    load(fullfile(basedir, subfolder, datamatfile), 'tmphysdata', 'tmoffset');
    physdata       = tmphysdata;
    offset         = tmoffset;
elseif studynbr == 3
    load(fullfile(basedir, subfolder, datamatfile), 'clphysdata', 'cloffset');
    physdata       = clphysdata;
    offset         = cloffset;
end
toc

end

