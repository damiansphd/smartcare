function [physdata, offset, physdata_predateoutlierhandling] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study)

% loadAndHarmoniseMeasVars - loads raw measurement variables and standardises
% their naming

tic
basedir = setBaseDir();
fprintf('Loading %s Study Measurement data\n', study);
%physdata_original = [];

if ismember(study, 'SC')
    load(fullfile(basedir, subfolder, datamatfile), 'physdata', 'physdata_predateoutlierhandling', 'offset');
elseif ismember(study, 'TM')
    load(fullfile(basedir, subfolder, datamatfile), 'tmphysdata', 'tmoffset', 'tmphysdata_predateoutlierhandling');
    physdata       = tmphysdata;
    offset         = tmoffset;
    physdata_predateoutlierhandling = tmphysdata_predateoutlierhandling;
elseif ismember(study, 'CL')
    load(fullfile(basedir, subfolder, datamatfile), 'clphysdata', 'cloffset', 'clphysdata_predateoutlierhandling');
    physdata       = clphysdata;
    offset         = cloffset;
    physdata_predateoutlierhandling = clphysdata_predateoutlierhandling;
elseif ismember(study, 'BR')
    load(fullfile(basedir, subfolder, datamatfile), 'brphysdata', 'broffset', 'brphysdata_predateoutlierhandling');
    physdata       = brphysdata;
    offset         = broffset;
    physdata_predateoutlierhandling = brphysdata_predateoutlierhandling;
elseif ismember(study, 'AC')
    load(fullfile(basedir, subfolder, datamatfile), 'acphysdata', 'acoffset', 'acphysdata_predateoutlierhandling');
    physdata       = acphysdata;
    offset         = acoffset;
    physdata_predateoutlierhandling = acphysdata_predateoutlierhandling;
elseif ismember(study, 'BE')
    load(fullfile(basedir, subfolder, datamatfile), 'bephysdata', 'beoffset', 'bephysdata_predateoutlierhandling');
    physdata       = bephysdata;
    offset         = beoffset;
    physdata_predateoutlierhandling = bephysdata_predateoutlierhandling;
end
toc

end

