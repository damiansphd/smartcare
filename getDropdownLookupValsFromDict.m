function [ddlookup] = getDropdownLookupValsFromDict(datadict, fieldname)

% getDropdownLookupValsFromDict - returns the drop down lookup values and
% corresponding labels from a REDCap data dictionary for a given fieldname

fprintf('Extracting for %s...', fieldname);

dictrow = datadict(ismember(datadict.Variable_FieldName, fieldname), :);

if ~ismember(dictrow.FieldType, 'dropdown')
    fprintf('**** No drop down field of that name found ****\n');
    ddlookup = [];
else
    ddstring = dictrow.Choices_Calculations_ORSliderLabels{1};
    ddrows   = strsplit(ddstring, '|')';
    nrows = size(ddrows, 1);
    ddlookup = table('Size',[nrows 2], 'VariableTypes', { 'double', 'cell'}, 'VariableNames', {'ID', 'Name'});
    for i = 1:nrows
        rowsplit         = strsplit(ddrows{i}, ',');
        if size(rowsplit, 2) < 2
            fprintf('**** Badly formatted drop down string in data dictionary ****\n')
            ddlookup = [];
            return
        elseif size(rowsplit, 2) == 2
            ddlookup.ID(i)   = str2double(rowsplit{1});
            ddlookup.Name{i} = strtrim(rowsplit{2});
        else
            ddlookup.ID(i)   = str2double(rowsplit{1});
            tmpstring = strtrim(rowsplit{2});
            for n = 3:size(rowsplit, 2)
                tmpstring = strcat(tmpstring, {', '}, strtrim(rowsplit{n}));
            end
            ddlookup.Name{i} = strtrim(tmpstring{1});
        end
    end
    
end

fprintf('done\n');

end

