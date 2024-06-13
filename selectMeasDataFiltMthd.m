function measdatafiltmode = selectMeasDataFiltMthd()

% selectMeasDataFiltMthd - enter the methodology for filtering measurement
% data
%       1: Filter (out) measurement data after last patient clinical data
%       update date
%       2: Keep all measurement data since study start

fprintf('Select filter method for measurement data\n');
fprintf('-----------------------------------------\n');
fprintf('1: Filter (out) measurement data after last patient clinical data update date\n');
fprintf('2: No filtering\n');
fprintf('\n');

smeasdatafiltmode = input('Enter Measurement Data Filtering method ? ', 's');
measdatafiltmode = str2double(smeasdatafiltmode);
if (isnan(measdatafiltmode) || measdatafiltmode < 1 || measdatafiltmode > 2)
    fprintf('Invalid choice - defaulting to 1\n');
    measdatafiltmode = 1;
end
fprintf('\n');

end

