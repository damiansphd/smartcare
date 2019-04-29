clear; close all; clc;

basedir = setBaseDir();
subfolder = 'DataFiles';
runparamlisting = dir(fullfile(basedir, subfolder, sprintf('*RunParameters*.xlsx')));
RunParameterFiles = cell(size(runparamlisting,1),1);
for a = 1:size(RunParameterFiles,1)
    RunParameterFiles{a} = runparamlisting(a).name;
end

nfiles = size(RunParameterFiles,1);
fprintf('Run parameter files available\n');
fprintf('-----------------------------\n');
for i = 1:nfiles
    fprintf('%2d: %s\n', i, RunParameterFiles{i});
end
fprintf('\n');

fileidx = input('Choose file to use ? ');
if fileidx > nfiles
    fprintf('Invalid choice\n');
    return;
end
if isequal(fileidx,'')
    fprintf('Invalid choice\n');
    return;
end
fprintf('\n');

basedir = setBaseDir();
subfolder = 'DataFiles';
runparameterfile = RunParameterFiles{fileidx};

amRunParameters = readtable(fullfile(basedir, subfolder, runparameterfile));

for rp = 1:size(amRunParameters,1)
    runAlignmentModelEMMCFcn(amRunParameters(rp, :));
end




