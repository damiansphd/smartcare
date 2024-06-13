function [redcaptablemap, redcapfieldmap, recordeventcolmap] = loadacecfREDCapFieldMapFile(basedir, subfolder, fnamematchstring)

% loadacecfREDCapFieldMapFile - loads the latest REDCap field mapping file

fmapsubfolder = sprintf('%s/%s', subfolder, 'FieldMapping');

[latestfname, filefound] = getLatestFileName(basedir, fmapsubfolder, fnamematchstring);

if filefound
    fprintf('Latest filename found is %s\n', latestfname);
    fprintf('Loading...');
    
    redcaptablemap    = readtable(fullfile(basedir, fmapsubfolder, latestfname), 'Sheet', 'Instrument_Table');
    redcapfieldmap    = readtable(fullfile(basedir, fmapsubfolder, latestfname), 'Sheet', 'Field_Column');
    recordeventcolmap = readtable(fullfile(basedir, fmapsubfolder, latestfname), 'Sheet', 'Record_Event_Col');

    fprintf('%d rows...done\n', size(redcapfieldmap, 1));
else
    fprintf('**** No matching files found ****\n');
    redcaptablemap    = [];
    redcapfieldmap    = [];
    recordeventcolmap = [];
end

end

