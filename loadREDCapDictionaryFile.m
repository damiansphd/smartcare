function [redcapdict] = loadREDCapDictionaryFile(basedir, subfolder)

% loadREDCapDictionaryFile - loads the latest REDCap dictionary file

dictsubfolder = sprintf('%s/%s', subfolder, 'DataDictionary');
fnamematchstring = 'AnalysisOfRemoteMonitoringVirt_DataDictionary*';

[latestfname, filefound] = getLatestFileName(basedir, dictsubfolder, fnamematchstring);

if filefound
    fprintf('Latest filename found is %s\n', latestfname);
    fprintf('Loading...');
    
    opts       = detectImportOptions(fullfile(basedir, dictsubfolder, latestfname), 'FileType', 'Text', 'Delimiter', ',');
    redcapdict = readtable(fullfile(basedir, dictsubfolder, latestfname), opts);

    fprintf('%d rows...done\n', size(redcapdict, 1));
else
    fprintf('**** No matching files found ****\n');
    redcapdict = [];
end

end

