function [modelrun, modelidx, ModelResultFiles] = amEMMCSelectModelRunFromDir(loadtype)

% amEMMCSelectModelRunFromDir- allows you to load the saved variables from a
% historical model run. 


modelstring = amEMMCSelectModelVersion();

if isequal(loadtype, 'LCSet')
    snbrlc = input('Enter number of latent curve sets to run for ? ', 's');
    nbrlc = str2double(snbrlc);
    if (isnan(nbrlc) || nbrlc < 1 || nbrlc > 5)
        fprintf('Invalid choice - defaulting to 1\n');
        nbrlc = 1;
    end
    lcstring = sprintf('*nl%d*', nbrlc);
else
    lcstring = '*';
end

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
modelresultlisting = dir(fullfile(basedir, subfolder, sprintf('*%s%s.mat', modelstring, lcstring)));
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

