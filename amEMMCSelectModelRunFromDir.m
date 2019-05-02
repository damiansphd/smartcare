function [modelrun, modelidx, modelresultlisting] = amEMMCSelectModelRunFromDir(loadtype)

% amEMMCSelectModelRunFromDir- allows you to load the saved variables from a
% historical model run. 


modelstring = amEMMCSelectModelVersion();

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
modelresultlisting = dir(fullfile(basedir, subfolder, sprintf('*%s*.mat', modelstring)));
ModelResultFiles = cell(size(modelresultlisting,1),1);
for a = 1:size(ModelResultFiles,1)
    ModelResultFiles{a} = strrep(modelresultlisting(a).name, '.mat', '');
end

nmodelruns = size(ModelResultFiles,1);
fprintf('Model Result files available\n');
fprintf('-----------------------------\n');
for i = 1:nmodelruns
    fprintf('%2d: %s\n', i, ModelResultFiles{i});
end
fprintf('\n');

smodelidx = input('Choose model result file to use ? ', 's');

modelidx = str2double(smodelidx);

if (isnan(modelidx) || modelidx < 1 || modelidx > nmodelruns)
    fprintf('Invalid choice\n');
    modelidx = 0;
    return;
end

if isequal(loadtype,'pd')
    modelrun = sprintf('%s-PDs',ModelResultFiles{modelidx});
else
    modelrun = ModelResultFiles{modelidx};
end

end

