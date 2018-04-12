clc; clear; close;

tic
fprintf('Loading Clinical data\n');
load('clinicaldata.mat');
fprintf('Loading SmartCare measurement data\n');
load('smartcaredata.mat');
toc
fprintf('\n');

tic
cdPatient = sortrows(cdPatient, {'ID'}, 'ascend');
physdata = sortrows(physdata, {'SmartCareID', 'RecordingType', 'DateNum'}, 'ascend');

fprintf('Calculating data demographics by patient\n');
tempdata = physdata;
tempdata(:,{'UserName', 'Date_TimeRecorded', 'FEV1', 'PredictedFEV'}) = [];

demofunc = @(x)[mean(x) std(x) min(x) max(x)];
demographicstable = varfun(demofunc, tempdata, 'GroupingVariables', {'SmartCareID', 'RecordingType'});

% example of how to access max FEV1_ for a given row
% demographicstable(3,:).Fun_FEV1_(4)

measurecounttable = demographicstable(:, {'SmartCareID','RecordingType', 'GroupCount'});

demographicstable = sortrows(demographicstable, {'RecordingType','SmartCareID'});
toc
fprintf('\n');

outputfilename = sprintf('datademographicsbypatient-%s.mat',datestr(clock(),30));

tic
timenow = datestr(clock(),30);
%outputfilename = 'datademographicsbypatient.mat';
outputfilename = sprintf('datademographicsbypatient-%s.mat',timenow);
fprintf('Saving output variables to matlab file %s\n', outputfilename);
save(outputfilename, 'measurecounttable', 'demographicstable');

%outputfilename = 'DataDemographicsByPatient.xlsx';
outputfilename = sprintf('DataDemographicsByPatient-%s.xlsx',timenow);
fprintf('Saving results to excel file %s\n', outputfilename);
writetable(measurecounttable, outputfilename, 'Sheet', 'MeasureCountByPatient');
writetable(demographicstable, outputfilename, 'Sheet', 'DataDemographicsByPatient');
toc