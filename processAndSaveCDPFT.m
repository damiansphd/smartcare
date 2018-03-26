function processAndSaveCDPFT(inputFilename, outputFilename)
%
% load the PFT clinical data and parse it into a useful format
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
    cdPFT = cell(nlines-1, 9);
    cdPFTIdsAndDates = zeros(nlines-1,7);

    % do string manipulation line by line - faster than consuming the whole file into a string
    for r = 1:nlines-1
        row_str = fgetl(fid);
        tmp_row_str = row_str;
        %fprintf('%d: %s\n', r, row_str);

        % iterate through row string by string and store in appropriate data structure

        % ID
        [tmp_str, row_str] = strtok(row_str, ",");
        %fprintf('%d: %s\n', r, tmp_str);
        cdPFT{r,1} = str2num(tmp_str);
        cdPFTIdsAndDates(r,1) = str2num(tmp_str);

        % Hospital
        [cdPFT{r,2}, row_str] = strtok(row_str, ",");

        % Study Number
        [cdPFT{r,3}, row_str] = strtok(row_str, ",");

        % Lung Function ID
        [tmp_str, row_str] = strtok(row_str, ",");
        %fprintf('%d: %s\n', r, tmp_str);
        cdPFT{r,4} = str2num(tmp_str);
        cdPFTIdsAndDates(r,2) = str2num(tmp_str);

        % Lung Function Date
        [tmp_str, row_str] = strtok(row_str, ",");
        cdPFT{r,5} = tmp_str;
        % default any null values in array
        if isequal(tmp_str,'NULL')
            fprintf('Row %3d: NULL date - Details: %s\n', r+1, tmp_row_str);
            tmp_str = '12/31/2017';
        end
        %fprintf('%d: %s\n', r, tmp_str);
        cdPFTIdsAndDates(r,3) = datenum(tmp_str);

        % FEV1
        [tmp_str, row_str] = strtok(row_str, ",");
        % identify abnormally large values
        if (str2num(tmp_str) > 6)
            fprintf('Row %3d: Large FEV1 - Details: %s\n', r+1, tmp_row_str);
        end
        %fprintf('%d: %s\n', r, tmp_str);
        cdPFT{r,6} = str2num(tmp_str);
        cdPFTIdsAndDates(r,4) = str2num(tmp_str);

        % FEV1%
        [tmp_str, row_str] = strtok(row_str, ",");
        % identify abnormally large values
        if (str2num(tmp_str) > 120)
            fprintf('Row %3d: Large FEV1%% - Details: %s\n', r+1, tmp_row_str);
        end
        %fprintf('%d: %s\n', r, tmp_str);
        cdPFT{r,7} = str2num(tmp_str);
        cdPFTIdsAndDates(r,5) = str2num(tmp_str);

        % FVC1
        [tmp_str, row_str] = strtok(row_str, ",");
        % identify abnormally large values
        if (str2num(tmp_str) > 10)
            fprintf('Row %3d: Large FVC - Details: %s\n', r+1, tmp_row_str);
        end
        %fprintf('%d: %s\n', r, tmp_str);
        cdPFT{r,8} = str2num(tmp_str);
        cdPFTIdsAndDates(r,6) = str2num(tmp_str);

        %FVC1%
        [tmp_str, row_str] = strtok(row_str, ",");
        % identify abnormally large values
        if (str2num(tmp_str) > 120)
            fprintf('Row %3d: Large FVC1%% - Details: %s\n', r+1, tmp_row_str);
        end
        %fprintf('%d: %s\n', r, tmp_str);
        cdPFT{r,9} = str2num(tmp_str);
        cdPFTIdsAndDates(r,7) = str2num(tmp_str);

        if (round(r/1000) == r/1000)
            fprintf('Processed %5d rows\n', r);
        end
        fflush(stdout);
    end

end

% save processed data to the desired output file in matlab/octave format
fprintf('Saving processed data to file\n');
save(outputFilename, 'cdPFT', 'cdPFTIdsAndDates');

end

