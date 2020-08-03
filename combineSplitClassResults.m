function [tmpInterventions, nlatentcurves] = combineSplitClassResults(study, modelrun, basedir, subfolder)

% combineSplitClassResults - combines the results of the forced split runs
% for gender and age
    
if contains(modelrun, {'Age'})
    splittxt = 'Age';
elseif contains(modelrun, {'Gender'})
    splittxt = 'Gender';
end

scenario = extractBefore(extractAfter(modelrun, 'sc'), '_vs');

modelstring = sprintf('%s*%s*%s*', study, splittxt, scenario);

comblisting = dir(fullfile(basedir, subfolder, modelstring));

tmpInterventions = [];

for a = 1:size(comblisting,1)
    fprintf('Loading interventions from model run %s\n', comblisting(a).name);
    load(fullfile(basedir, subfolder, comblisting(a).name), 'amInterventions');
    amInterventions.LatentCurve(:) = a;
    tmpInterventions = [tmpInterventions; amInterventions];
end

tmpInterventions = sortrows(tmpInterventions, {'SmartCareID', 'IVStartDate'}, 'ascend');
tmpInterventions.IntrNbr(:) = [1:size(tmpInterventions, 1)];

nlatentcurves = size(comblisting,1);

end

