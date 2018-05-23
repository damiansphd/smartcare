
function generateDataDemographicsByPatientFn(physdata, cdPatient)

% generateDataDemographicsByPatientFn - function that creates data
% demographics by patient and stores matlab variables and creates an excel
% file of results

tic
cdPatient = sortrows(cdPatient, {'ID'}, 'ascend');
%physdata = sortrows(physdata_predupehandling, {'SmartCareID', 'RecordingType', 'DateNum'}, 'ascend');

fprintf('Calculating data demographics by patient\n');
tempdata = physdata;
tempdata(:,{'UserName', 'ScaledDateNum', 'DateNum', 'Date_TimeRecorded', 'FEV1', 'PredictedFEV', 'ScalingRatio', 'CalcFEV1SetAs'}) = [];

demofunc = @(x)[mean(x)  std(x)  min(x)  max(x) mid50mean(x) mid50std(x) mid50min(x) mid50max(x)];
demographicstable = varfun(demofunc, tempdata, 'GroupingVariables', {'SmartCareID', 'RecordingType'});

tempdata(:,{'SmartCareID'}) = [];
overalltable = varfun(demofunc, tempdata, 'GroupingVariables', {'RecordingType'});

% example of how to access max FEV1_ for a given row
% demographicstable(3,:).Fun_FEV1_(4)

measurecounttable = demographicstable(:, {'SmartCareID','RecordingType', 'GroupCount'});

demographicstable = sortrows(demographicstable, {'RecordingType','SmartCareID'});
overalltable = sortrows(overalltable, {'RecordingType'});

toc
fprintf('\n');

%outputfilename = sprintf('datademographicsbypatient-%s.mat',datestr(clock(),30));

tic
timenow = datestr(clock(),30);

basedir = './';
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('datademographicsbypatient-%s.mat',timenow);
fprintf('Saving output variables to matlab file %s\n', outputfilename);
save(fullfile(basedir, subfolder, outputfilename), 'measurecounttable', 'demographicstable', 'overalltable');
outputfilename = sprintf('datademographicsbypatient.mat',timenow);
fprintf('Saving output variables to matlab file %s\n', outputfilename);
save(fullfile(basedir, subfolder, outputfilename), 'measurecounttable', 'demographicstable', 'overalltable');

basedir = './';
subfolder = 'ExcelFiles';
outputfilename = sprintf('DataDemographicsByPatient-%s.xlsx',timenow);
fprintf('Saving results to excel file %s\n', outputfilename);
writetable(measurecounttable, fullfile(basedir, subfolder, outputfilename), 'Sheet', 'MeasureCountByPatient');
writetable(demographicstable, fullfile(basedir, subfolder, outputfilename), 'Sheet', 'DataDemographicsByPatient');
writetable(overalltable, fullfile(basedir, subfolder, outputfilename), 'Sheet', 'OverallDataDemographics');
toc

end
