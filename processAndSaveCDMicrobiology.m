function processAndSaveCDMicrobiology(inputFilename, outputFilename)
%
% load the Microbiology clinical data and parse it into a useful format
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
    cdMicrobiology = cell(nlines-1, 7);
    cdMicrobiologyIdsAndDates = zeros(nlines-1,3);

    % do string manipulation line by line - faster than consuming the whole file into a string
    for r = 1:nlines-1
        row_str = fgetl(fid);
        tmp_row_str = row_str;
        %fprintf('%d: %s\n', r, row_str);

        % iterate through row string by string and store in appropriate data structure

        % ID
        [tmp_str, row_str] = strtok(row_str, ",");
        %fprintf('%d: %s\n', r, tmp_str);
        cdMicrobiology{r,1} = str2num(tmp_str);
        cdMicrobiologyIdsAndDates(r,1) = str2num(tmp_str);

        % Hospital
        [cdMicrobiology{r,2}, row_str] = strtok(row_str, ",");

        % Study Number
        [cdMicrobiology{r,3}, row_str] = strtok(row_str, ",");

        % Micro ID
        [tmp_str, row_str] = strtok(row_str, ",");
        %fprintf('%d: %s\n', r, tmp_str);
        cdMicrobiology{r,4} = str2num(tmp_str);
        cdMicrobiologyIdsAndDates(r,2) = str2num(tmp_str);

        % Microbiology
        [cdMicrobiology{r,5}, row_str] = strtok(row_str, ",");

        % Species
        [cdMicrobiology{r,6}, row_str] = strtok(row_str, ",");

        % Data Microbiology
        [tmp_str, row_str] = strtok(row_str, ",");
        cdMicrobiology{r,7} = tmp_str;
        % default any null values in array
        if isequal(tmp_str,'NULL')
            fprintf('Row: %3d: NULL Date - Details: %s\n', r+1, tmp_row_str);
            tmp_str = '1/1/0000';
        end
        %fprintf('%d: %s\n', r, tmp_str);

        cdMicrobiologyIdsAndDates(r,3) = datenum(tmp_str);

        if (round(r/1000) == r/1000)
            fprintf('Processed %5d rows\n', r);
        end
        fflush(stdout);
    end

end

% save processed data to the desired output file in matlab/octave format
fprintf('Saving processed data to file\n');
save(outputFilename, 'cdMicrobiology', 'cdMicrobiologyIdsAndDates');

end

