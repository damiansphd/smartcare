clear; close all; clc;

RunParameterFiles = {  
            'SCRunParamFEV1Split.xlsx';
            };


nfiles = size(RunParameterFiles,1);
fprintf('Run parameter files available\n');
fprintf('-----------------------------\n');
for i = 1:nfiles
    fprintf('%d: %s\n', i, RunParameterFiles{i});
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
    runAlignmentModelEMFcnFEV1Split(amRunParameters(rp, :));
end




