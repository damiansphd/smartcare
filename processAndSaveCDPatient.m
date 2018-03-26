function processAndSaveCDPatient(inputFilename, outputFilename)
%
% load the Patient clinical data and parse it into a useful format
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
    cdPatient = cell(nlines-1, 11);
    cdPatientIdsAndDates = zeros(nlines-1,9);

    % do string manipulation line by line - faster than consuming the whole file into a string
    for r = 1:nlines-1
        row_str = fgetl(fid);
        tmp_row_str = row_str;
        %fprintf('Row %3d: %s\n', r, row_str);

        % iterate through row string by string and store in appropriate data structure

        % ID
        [tmp_str, row_str] = strtok(row_str, ",");
        %fprintf('%d: %s\n', r, tmp_str);
        cdPatient{r,1} = str2num(tmp_str);
        cdPatientIdsAndDates(r,1) = str2num(tmp_str);

        % Hospital
        [cdPatient{r,2}, row_str] = strtok(row_str, ",");

        % Study Number
        [cdPatient{r,3}, row_str] = strtok(row_str, ",");

        % Study Date
        [tmp_str, row_str] = strtok(row_str, ",");
        cdPatient{r,4} = tmp_str;
        % default any null values in array
        if isequal(tmp_str,'NULL')
            fprintf('Row %3d: NULL date - Details: %s\n', r+1, tmp_row_str);
            tmp_str = '1/1/0000';
        end
        %fprintf('%d: %s\n', r, tmp_str);
        cdPatientIdsAndDates(r,2) = datenum(tmp_str);

        % D.O.B.
        [tmp_str, row_str] = strtok(row_str, ",");
        cdPatient{r,5} = tmp_str;
        % default any null values in array
        if isequal(tmp_str,'NULL')
            fprintf('Row %3d: NULL date - Details: %s\n', r+1, tmp_row_str);
            tmp_str = '1/1/0000';
        end
        %fprintf('%d: %s\n', r, tmp_str);
        cdPatientIdsAndDates(r,3) = datenum(tmp_str);

        % Age
        [tmp_str, row_str] = strtok(row_str, ",");
        % identify abnormal values
        if (str2num(tmp_str) < 16 || str2num(tmp_str) > 70)
            fprintf('Row %3d: Age Anomaly - Details: %s\n', r+1, tmp_row_str);
        end
        %fprintf('%d: %s\n', r, tmp_str);
        cdPatient{r,6} = str2num(tmp_str);
        cdPatientIdsAndDates(r,4) = str2num(tmp_str);

        % Sex
        [tmp_str, row_str] = strtok(row_str, ",");
        %fprintf('%d: %s\n', r, tmp_str);
        cdPatient{r,7} = tmp_str;
        if (isequal(tmp_str, 'Male'))
            cdPatientIdsAndDates(r,5) = 1;
        elseif (isequal(tmp_str, 'Female'))
            cdPatientIdsAndDates(r,5) = 2;
        else
            cdPatientIdsAndDates(r,5) = -1;
            printf('Row %3d: Unknown Sex - Details: %s\n', r+1, tmp_row_str);
        end

        % Height
        [tmp_str, row_str] = strtok(row_str, ",");
        % identify abnormal values
        if (str2num(tmp_str) <100 || str2num(tmp_str) > 220)
            fprintf('Row %3d: Height Anomaly - Details: %s\n', r+1, tmp_row_str);
        end
        %fprintf('%d: %s\n', r, tmp_str);
        cdPatient{r,8} = str2num(tmp_str);
        cdPatientIdsAndDates(r,6) = str2num(tmp_str);
        % correct for heights in m not cm
        if (str2num(tmp_str) < 2.2)
            cdPatientIdsAndDates(r,6) *= 100;
            cdPatient(r,8) = num2str(cdPatientIdsAndDates(r,6));
        end

        % Weight
        [tmp_str, row_str] = strtok(row_str, ",");
        % identify abnormal values
        if (str2num(tmp_str) < 40 || str2num(tmp_str) > 100)
            fprintf('Row %3d: Weight Anomaly - Details: %s\n', r+1, tmp_row_str);
        end
        %fprintf('%d: %s\n', r, tmp_str);
        cdPatient{r,9} = str2num(tmp_str);
        cdPatientIdsAndDates(r,7) = str2num(tmp_str);

        % Predicted FEV1
        [tmp_str, row_str] = strtok(row_str, ",");
        % identify abnormally large values
        if (str2num(tmp_str) > 6)
            fprintf('Row %3d: Predicted FEV1 Anomaly - Details: %s\n', r+1, tmp_row_str);
        end
        %fprintf('%d: %s\n', r, tmp_str);
        cdPatient{r,10} = str2num(tmp_str);
        cdPatientIdsAndDates(r,8) = str2num(tmp_str);

        % Set As FEV1
        [tmp_str, row_str] = strtok(row_str, ",");
        % identify abnormally large values
        if (str2num(tmp_str) > 6)
            fprintf('Row %3d: Set As FEV1 Anomaly - Details: %s\n', r+1, tmp_row_str);
        end
        %fprintf('%d: %s\n', r, tmp_str);
        cdPatient{r,11} = str2num(tmp_str);
        cdPatientIdsAndDates(r,9) = str2num(tmp_str);

        if (round(r/1000) == r/1000)
            fprintf('Processed %5d rows\n', r);
        end
        fflush(stdout);
    end

end

% save processed data to the desired output file in matlab/octave format
fprintf('Saving processed data to file\n');
save(outputFilename, 'cdPatient', 'cdPatientIdsAndDates');

end

