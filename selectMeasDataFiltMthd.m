function [datefiltmode, cohortfiltmode, filtfilesuffix] = selectMeasDataFiltMthd()

% selectMeasDataFiltMthd - enter the methodology for filtering measurement
% data
%
%   Date Filtering
%       1: Only include measurement data during official study period
%       2: Include all measurement data after study start date
%     
%   Cohort Filtering
%       1: Only include measurement data for signal cohort
%       2: Only include measurement data for breathe only cohort
%       3: Include measurement data for both cohorts
%

fprintf('Select filter method for measurement data\n');
fprintf('-----------------------------------------\n');

fprintf('Date filtering\n');
fprintf('--------------\n');

fprintf('1: Only include measurement data during official study period\n');
fprintf('2: Include all measurement data after study start date\n');
sdatefiltmode = input('Enter Measurement Data Filtering method ? ', 's');
datefiltmode = str2double(sdatefiltmode);
if (isnan(datefiltmode) || datefiltmode < 1 || datefiltmode > 2)
    fprintf('Invalid choice - defaulting to 1\n');
    datefiltmode = 1;
end
fprintf('\n');

if datefiltmode == 1
    datefilesuffix = 'studyperiod';
elseif datefiltmode == 2
    datefilesuffix = 'alldata';
else
    datefilesuffix = 'unknownfiltmthd';
end

fprintf('Cohort filtering\n');
fprintf('----------------\n');

fprintf('1: Only include measurement data for signal cohort\n');
fprintf('2: Only include measurement data for breathe only cohort\n');
fprintf('3: Include measurement data for both cohorts\n');
fprintf('\n');

scohortfiltmode = input('Enter Measurement Data Filtering method ? ', 's');
cohortfiltmode = str2double(scohortfiltmode);
if (isnan(cohortfiltmode) || cohortfiltmode < 1 || cohortfiltmode > 3)
    fprintf('Invalid choice - defaulting to 1\n');
    cohortfiltmode = 1;
end
fprintf('\n');

if cohortfiltmode == 1
    cohortfilesuffix = 'signalcohort';
elseif cohortfiltmode == 2
    cohortfilesuffix = 'breathecohort';
elseif cohortfiltmode == 3
    cohortfilesuffix = 'bothcohorts';
else
    cohortfilesuffix = 'unknownfiltmthd';
end

filtfilesuffix = sprintf('%s-%s', datefilesuffix, cohortfilesuffix);

end

