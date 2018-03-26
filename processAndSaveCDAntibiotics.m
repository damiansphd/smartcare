function processAndSaveCDAntibiotics(inputFilename, outputFilename)
%
% load the antibiotics clinical data and parse it into a useful format
% then save variables to a matlab/octave format file to make reusing faster
%

% open file, check it exists, and then skip through to get number of rows in test.txt
fid = fopen(inputFilename);

if (fid ~= -1)
    % iterate through file to get number of lines, then reopen file for parsing
    nlines = fskipl(fid, Inf);
    fclose(fid);
    fid = fopen(inputFilename);
else
    nlines = 0;
    file_contents = '';
    fprintf('Unable to open %s\n', inputFilename);
end

fprintf('File has %d lines\n',nlines);

if (nlines ~= 0)
    % skip first row (headers)
    row_str = fgetl(fid);

    % initialise output arrays
    cdAntibiotics = cell(nlines-1, 9);
    cdAntibioticsIdsAndDates = zeros(nlines-1,6);
    delarray = zeros(nlines-1,1);

    % do string manipulation line by line - faster than consuming the whole file into a string
    for r = 1:nlines-1
        row_str = fgetl(fid);
        tmp_row_str = row_str;
        %fprintf('%d: %s\n', r, row_str);

        % iterate through row string by string and store in appropriate data structure

        % ID
        [tmp_str, row_str] = strtok(row_str, ",");
        %fprintf('%d: %s\n', r, tmp_str);
        cdAntibiotics{r,1} = str2num(tmp_str);
        cdAntibioticsIdsAndDates(r,1) = str2num(tmp_str);

        % Hospital
        [cdAntibiotics{r,2}, row_str] = strtok(row_str, ",");

        % Study Number
        [cdAntibiotics{r,3}, row_str] = strtok(row_str, ",");

        % Antibiotics ID
        [tmp_str, row_str] = strtok(row_str, ",");
        %fprintf('%d: %s\n', r, tmp_str);
        cdAntibiotics{r,4} = str2num(tmp_str);
        cdAntibioticsIdsAndDates(r,2) = str2num(tmp_str);

        % Antibiotic Name
        [cdAntibiotics{r,5}, row_str] = strtok(row_str, ",");

        % Route
        [cdAntibiotics{r,6}, row_str] = strtok(row_str, ",");

        % harmonise Intravenous and Iv values for Route to be IV
        if isequal(cdAntibiotics{r,6}, 'Intravenous') || isequal(cdAntibiotics{r,6}, 'Iv')
            cdAntibiotics{r,6} = 'IV';
        end
        % harmonise PO values for Route to be Oral
        if isequal(cdAntibiotics{r,6}, 'PO')
            cdAntibiotics{r,6} = 'Oral';
        end
        % set numeric version of route (1 = IV, 2 = Oral, 3 = Other)
        if isequal(cdAntibiotics{r,6}, 'IV')
            cdAntibioticsIdsAndDates(r,3) = 1;
        elseif isequal(cdAntibiotics{r,6}, 'Oral')
            cdAntibioticsIdsAndDates(r,3) = 2;
        else
            cdAntibioticsIdsAndDates(r,3) = 3;
        end

        % Home IV's
        [cdAntibiotics{r,7}, row_str] = strtok(row_str, ",");
        % sometimes Route is NULL, but IV value is in Home IV column - if so, set value accordingly
        if isequal(cdAntibiotics{r,7},'IV') && isequal(cdAntibiotics{r,6},'NULL')
            cdAntibioticsIdsAndDates(r,3) = 1;
        end
                    
        % Start Date
        [tmp_str, row_str] = strtok(row_str, ",");
        cdAntibiotics{r,8} = tmp_str;
        % default any null values in array
        if isequal(tmp_str,'NULL')
            fprintf('Row %3d: NULL date - Details: %s\n', r+1, tmp_row_str);
            tmp_str = '1/1/0000';
        end
        %fprintf('%d: %s\n', r, tmp_str);
        cdAntibioticsIdsAndDates(r,4) = datenum(tmp_str);

        % End Date
        [tmp_str, row_str] = strtok(row_str, ",");
        cdAntibiotics{r,9} = tmp_str;
        % default any null values in array
        if isequal(tmp_str,'NULL')
            fprintf('Row %3d: NULL date - Details: %s\n', r+1, tmp_row_str);
            tmp_str = '1/1/0000';
        end
        %fprintf('%d: %s\n', r, tmp_str);
        cdAntibioticsIdsAndDates(r,5) = datenum(tmp_str);

        % Duration
        cdAntibioticsIdsAndDates(r,6) = cdAntibioticsIdsAndDates(r,5) - cdAntibioticsIdsAndDates(r,4);
        if (cdAntibioticsIdsAndDates(r,6) < 1)
            fprintf('Row %3d: Illogical Duration %4d (%6s - %6s) - Details: %s\n', r+1, cdAntibioticsIdsAndDates(r,6), datestr(cdAntibioticsIdsAndDates(r,4),1), datestr(cdAntibioticsIdsAndDates(r,5), 1),tmp_row_str);
            %delarray(r,1) = 1;
        end
        % identify long treatment durations
        if (cdAntibioticsIdsAndDates(r,6) > 50)
            fprintf('Row %3d: Long Duration %4d (%6s - %6s) - Details: %s\n', r+1, cdAntibioticsIdsAndDates(r,6), datestr(cdAntibioticsIdsAndDates(r,4),1), datestr(cdAntibioticsIdsAndDates(r,5), 1),tmp_row_str);
            %delarray(r,1) = 1;
        end

        if (round(r/1000) == r/1000)
            fprintf('Processed %5d rows\n', r);
        end
        fflush(stdout);
    end

    % remove residual rows with incorrect data - all are ongoing treatments or duplicates
    %idx = find(delarray==1);
    %cdAntibiotics(idx,:) = [];
    %cdAntibioticsIdsAndDates(idx,:) = [];

end

% save processed data to the desired output file in matlab/octave format
fprintf('Saving processed data to file\n');
save(outputFilename, 'cdAntibiotics', 'cdAntibioticsIdsAndDates');

end

