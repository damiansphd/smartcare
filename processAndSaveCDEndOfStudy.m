function processAndSaveCDEndOfStudy(inputFilename, outputFilename)
%
% load the End of Study clinical data and parse it into a useful format
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
	%fprintf('0: %s\n', row_str);

    % initialise output arrays
    cdEndOfStudy = cell(nlines-1, 5);
    cdEndOfStudyIdsAndDates = zeros(nlines-1,3);

    % do string manipulation line by line - faster than consuming the whole file into a string
    for r = 1:nlines-1
        row_str = fgetl(fid);
		% file contains some blank End Of Study IDs - find cases of empty field and replace with single space
		row_str = regexprep(row_str, ',,', ', ,');
        tmp_row_str = row_str;
        %fprintf('%d: %s\n', r, row_str);

        % iterate through row string by string and store in appropriate data structure

        % ID
        [tmp_str, row_str] = strtok(row_str, ",");
        %fprintf('%d: %s\n', r, tmp_str);
        cdEndOfStudy{r,1} = str2num(tmp_str);
        cdEndOfStudyIdsAndDates(r,1) = str2num(tmp_str);

        % Hospital
        [cdEndOfStudy{r,2}, row_str] = strtok(row_str, ",");

        % Study Number
        [cdEndOfStudy{r,3}, row_str] = strtok(row_str, ",");

        % End Of Study ID
        [tmp_str, row_str] = strtok(row_str, ",");
        %fprintf('%d: %s\n', r, tmp_str);
        cdEndOfStudy{r,4} = tmp_str;
		if ~isequal(tmp_str,' ')
			cdEndOfStudyIdsAndDates(r,2) = str2num(tmp_str);
		else
			cdEndOfStudyIdsAndDates(r,2) = 0;
		end

        % End Of Study Reason
        [tmp_str, row_str] = strtok(row_str, ",");
		% strip white spaces 
		tmp_str = strtrim(tmp_str);
        cdEndOfStudy{r,5} = tmp_str;
		%fprintf('%d: %s\n', r, tmp_str);
        % create numeric version for reason
        if isequal(tmp_str,'Completed study') || isequal(tmp_str, 'Completed Study')
			cdEndOfStudyIdsAndDates(r,3) = 1;
		elseif isequal(tmp_str, 'Withdrew consent')
			cdEndOfStudyIdsAndDates(r,3) = 2;
		elseif isequal(tmp_str, 'Lost to follow up')
			cdEndOfStudyIdsAndDates(r,3) = 3;
		elseif isequal(tmp_str, 'Died')
			cdEndOfStudyIdsAndDates(r,3) = 4;
		else
            fprintf('Row %3d: Invalid reason - Details: %s\n', r+1, tmp_row_str);
        end

        if (round(r/1000) == r/1000)
            fprintf('Processed %5d rows\n', r);
        end
        fflush(stdout);
    end
end

% save processed data to the desired output file in matlab/octave format
fprintf('Saving processed data to file\n');
save(outputFilename, 'cdEndOfStudy', 'cdEndOfStudyIdsAndDates');

end

