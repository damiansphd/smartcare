function [redcapdata, redcapinstrcounts] = loadREDCapDataExportFile(basedir, subfolder, redcapdict)

% loadREDCapDataExportFile - loads the latest REDCap data export file

datefields = redcapdict.Variable_FieldName(ismember(redcapdict.TextValidationTypeORShowSliderNumber, {'date_dmy'}));
ndatefields = size(datefields, 1);

datasubfolder = sprintf('%s/%s', subfolder, 'DataExportFiles');
fnamematchstring = 'AnalysisOfRemoteMoni_DATA*';

[latestfname, filefound] = getLatestFileName(basedir, datasubfolder, fnamematchstring);

if filefound
    fprintf('Latest filename found is %s\n', latestfname);
    fprintf('Loading...');

    opts = detectImportOptions(fullfile(basedir, datasubfolder, latestfname), 'FileType', 'Text', 'Delimiter', ',');
    for d = 1:ndatefields
        opts.VariableTypes(:, ismember(opts.VariableNames, datefields(d)))   = {'datetime'};
        opts = setvaropts(opts, datefields(d), 'InputFormat', 'yyyy-MM-dd');
    end
    redcapdata = readtable(fullfile(basedir, datasubfolder, latestfname), opts);
    
    redcapdata = sortrows(redcapdata, {'redcap_repeat_instrument', 'study_id', 'redcap_repeat_instance'}, {'Ascend', 'Ascend', 'Ascend'});
    
    % redcap has blank in the repeat_instrument for the singular instrument - in our case
    % patient_info - as it's not a repeating instrument. But as we use this
    % to index which table to populate, replace the blanks here
    redcapdata.redcap_repeat_instrument(ismember(redcapdata.redcap_repeat_instrument, '')) = {'patient_info'};
    
    fprintf('%d rows...done\n', size(redcapdata, 1));
    
    redcapinstrcounts = groupcounts(redcapdata, 'redcap_repeat_instrument');
    
    fprintf('Instrument breakdown\n');
    fprintf('   Instrument     Count \n');
    for n = 1:size(redcapinstrcounts, 1)
        fprintf('%-17s %5d\n', redcapinstrcounts.redcap_repeat_instrument{n}, redcapinstrcounts.GroupCount(n));
    end
    
else
    fprintf('**** No matching files found ****\n');
    redcapdata = [];
    redcapinstrcounts = [];
end


end

