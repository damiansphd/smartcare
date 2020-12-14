function [guidmap] = loadGUIDFileForHosp(study, hosprow, guidmapdate)

% loadGUIDFileForHosp - convenience function to load the guid to email
% mapping file for a given hospital and date

basedir = setBaseDir();

guidfile  = sprintf('%s PB Email to GUID map %s.xlsx', hosprow.Name{1}, guidmapdate);
fprintf('Loading mapping file %s\n', guidfile);

dfsubfolder = sprintf('DataFiles/%s/GUIDMapFiles', study);
guidmap = readtable(fullfile(basedir, dfsubfolder, guidfile));
guidmap.Properties.VariableNames{1} = 'StudyNumber';
    
end

