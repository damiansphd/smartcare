function [redcapdata, redcapinstrcounts] = loadREDCapDataExportFile(basedir, subfolder, fnamematchstring, redcapdict, redcapidcol)

% loadREDCapDataExportFile - loads the latest REDCap data export file

datefields = redcapdict.Variable_FieldName(ismember(redcapdict.TextValidationTypeORShowSliderNumber, {'date_dmy'}));
ndatefields = size(datefields, 1);

datasubfolder = sprintf('%s/%s', subfolder, 'DataExportFiles');

[latestfname, filefound] = getLatestFileName(basedir, datasubfolder, fnamematchstring);

if filefound
    fprintf('Latest filename found is %s\n', latestfname);
    fprintf('Loading...\n');

    opts = detectImportOptions(fullfile(basedir, datasubfolder, latestfname), 'FileType', 'Text', 'Delimiter', ',');
    fprintf('Setting date field import format\n');
    for d = 1:ndatefields
        if any(ismember(opts.VariableNames, datefields(d)))
            opts.VariableTypes(:, ismember(opts.VariableNames, datefields(d)))   = {'datetime'};
            opts = setvaropts(opts, datefields(d), 'InputFormat', 'yyyy-MM-dd');
        else
            fprintf('Skipping date field %s\n', datefields{d});
        end
    end
    
    redcapdata = readtable(fullfile(basedir, datasubfolder, latestfname), opts);
    
    % the first column in the data export contains the REDCap identifier,
    % but it is named differently in ACE-CF vs Breathe REDCap data model
    redcapdata = sortrows(redcapdata, {'redcap_repeat_instrument', redcapidcol, 'redcap_repeat_instance'}, {'Ascend', 'Ascend', 'Ascend'});
    
    % Redcap has blank in the repeat_instrument for the singular instrument - in our case
    % patient_info - as it's not a repeating instrument. But as we use this
    % to index which table to populate, replace the blanks here
    redcapdata.redcap_repeat_instrument(ismember(redcapdata.redcap_repeat_instrument, '')) = {'patient_info'};
    
    fprintf('%d rows...done\n', size(redcapdata, 1));
    fprintf('\n');
    
    redcapinstrcounts = groupcounts(redcapdata, 'redcap_repeat_instrument');
    
    fprintf('Instrument breakdown:\n');
    fprintf('\n');
    
    fprintf('Instrument                Count \n');
    fprintf('------------------------  ----- \n');
    for n = 1:size(redcapinstrcounts, 1)
        fprintf('%-24s  %5d\n', redcapinstrcounts.redcap_repeat_instrument{n}, redcapinstrcounts.GroupCount(n));
    end
    
else
    fprintf('**** No matching files found ****\n');
    redcapdata = [];
    redcapinstrcounts = [];
end

fprintf('\n');

end

