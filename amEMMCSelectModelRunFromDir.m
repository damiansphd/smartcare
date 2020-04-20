function [modelrun, modelidx, ModelResultFiles] = amEMMCSelectModelRunFromDir(study, loadtype, lcmode, intrfilt, tgapmode, tstlabelmode)

% amEMMCSelectModelRunFromDir- allows you to load the saved variables from a
% historical model run. 

studystring         = sprintf('%s*', study);

modelstring = amEMMCSelectModelVersion();
modelstring = sprintf('%s*', modelstring);

if isequal(intrfilt, 'IntrFilt')
    intrmode = selectIntrFilterMthd();
    intrstring = sprintf('in%d*', intrmode);
else
    intrstring = '';
end

if isequal(lcmode, 'LCSet')
    nbrlc = selectNbrLCSets();
    lcstring = sprintf('nl%d*', nbrlc);
else
    lcstring = '';
end

if isequal(tgapmode, 'TGap')
    treatgap = selectTreatmentGap();
    tgapstring = sprintf('gp%d*', treatgap);
else
    tgapstring = '';
end

if isequal(tstlabelmode, 'TstLbl')
    lblmthd = selectLabelMethodology();
    lblmthdstring = sprintf('lm%d*', lblmthd);
else
    lblmthdstring = '';
end


basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
modelresultlisting = dir(fullfile(basedir, subfolder, sprintf('%s%s%s%s%s%s.mat', studystring, modelstring, tgapstring, lblmthdstring, intrstring, lcstring)));
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

