function [outputdate, isValid] = ingestDateCell(inputcell, matlabexcelserialdatediff, row, notime)

% ingestDateCell - ingest a date cell from a spreadsheet, handling various
% diffrent potential formats

outputdate = datetime(0000, 01, 01);
isValid = true;
if ismember(class(inputcell), 'double')
        if ~isnan(inputcell)
            if inputcell ~= round(inputcell)
                fprintf('%3d: **** Non-integer serial date %.2f ****\n', row, inputcell);
            end
            %fprintf('Original Date: %.2f Updated Date = %s\n', tmpcv.Date(i), datestr(cdcvrow.AttendanceDate, 29));
            outputdate = datetime(matlabexcelserialdatediff + inputcell, 'ConvertFrom', 'datenum');
        else
            fprintf('%3d: **** Skipping row with invalid date %d ****\n', row, inputcell);
            isValid = false;
        end
    elseif ismember(class(inputcell), 'datetime')
        outputdate = dateshift(inputcell, 'start', 'day');
    elseif ismember(class(inputcell), 'cell')
        if ~ismember(inputcell, '')
            if strlength(inputcell{1}) == 10
                outputdate = datetime(inputcell, 'InputFormat', 'dd/MM/yyyy');
            elseif strlength(inputcell{1}) == 11
                outputdate = datetime(inputcell, 'InputFormat', 'dd-MMM-yyyy');
            elseif strlength(inputcell{1}) == 19
                outputdate = datetime(inputcell, 'InputFormat', 'dd/MM/yyyy HH:mm:ss');
            elseif strlength(inputcell{1}) == 20
                outputdate = datetime(inputcell, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');
            else
                fprintf('%3d: **** Invalid date format %s ****\n', row, inputcell{1});
                isValid = false;
            end    
        else
            fprintf('%3d: **** Invalid date format %s ****\n', row, inputcell{1});
            isValid = false;
        end
    else
        fprintf('%3d: **** Invalid date format ****\n', row);
        isValid = false;
end

if isValid && notime && ~isnat(outputdate)
    %fprintf('Orig Date %s ', datestr(outputdate, 29));
    outputdate = dateshift(outputdate, 'start', 'day');
    %fprintf('Rounded Date %s \n', datestr(outputdate, 29));
end
    
end

