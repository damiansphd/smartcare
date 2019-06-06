function [modelrun, modelidx, ModelResultFiles] = amEMMCSelectModelRunFromDir(loadtype, lcmode, intrfilt)

% amEMMCSelectModelRunFromDir- allows you to load the saved variables from a
% historical model run. 


modelstring = amEMMCSelectModelVersion();
modelstring = sprintf('%s*', modelstring);

if isequal(intrfilt, 'IntrFilt')
    sintrmode = input('Enter Intervention Filtering mode ? ', 's');
    intrmode = str2double(sintrmode);
    if (isnan(intrmode) || intrmode < 1 || intrmode > 5)
        fprintf('Invalid choice - defaulting to 1\n');
        intrmode = 1;
    end
    %if intrmode == 1
    %    % for backward compatibility
    %    intrstring = '';
    %else
        intrstring = sprintf('in%d*', intrmode);
    %end
else
    intrstring = '';
end

if isequal(lcmode, 'LCSet')
    snbrlc = input('Enter number of latent curve sets to run for ? ', 's');
    nbrlc = str2double(snbrlc);
    if (isnan(nbrlc) || nbrlc < 1 || nbrlc > 5)
        fprintf('Invalid choice - defaulting to 1\n');
        nbrlc = 1;
    end
    lcstring = sprintf('nl%d*', nbrlc);
else
    lcstring = '';
end


basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
modelresultlisting = dir(fullfile(basedir, subfolder, sprintf('*%s%s%s.mat', modelstring, intrstring, lcstring)));
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

