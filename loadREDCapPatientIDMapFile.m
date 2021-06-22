function [redcapidmap] = loadREDCapPatientIDMapFile(basedir, subfolder)

% loadREDCapPatientIDMapFile - loads the latest REDCap patient id mapping
% file

idsubfolder = sprintf('%s/%s', subfolder, 'IDMappingFiles');
fnamematchstring = 'PatientIDMappingFile*';

[latestfname, filefound] = getLatestFileName(basedir, idsubfolder, fnamematchstring);

if filefound
    fprintf('Latest filename found is %s\n', latestfname);
    fprintf('Loading...');
    
    opts = detectImportOptions(fullfile(basedir, idsubfolder, latestfname));
    opts.VariableTypes(:, ismember(opts.VariableNames, {'redcap_id'}))   = {'char'};
    
    redcapidmap = readtable(fullfile(basedir, idsubfolder, latestfname), opts, 'Sheet', 'IDMap');

    fprintf('%d rows...done\n', size(redcapidmap, 1));
else
    fprintf('**** No matching files found ****\n');
    redcapidmap = [];
end

end

