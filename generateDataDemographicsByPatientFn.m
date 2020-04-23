
function generateDataDemographicsByPatientFn(physdata, cdPatient, study)

% generateDataDemographicsByPatientFn - function that creates data
% demographics by patient and stores matlab variables and creates an excel
% file of results

tic
cdPatient = sortrows(cdPatient, {'ID'}, 'ascend');
%physdata = sortrows(physdata_predupehandling, {'SmartCareID', 'RecordingType', 'DateNum'}, 'ascend');

fprintf('Calculating data demographics by patient\n');
tempdata = physdata;
tempdata(:,{'UserName', 'ScaledDateNum', 'DateNum', 'Date_TimeRecorded'}) = [];
if ismember(study, {'SC'})
    tempdata(:,{'FEV1', 'PredictedFEV', 'ScalingRatio', 'CalcFEV1SetAs'}) = [];
elseif ismember(study, {'BR'})
    tempdata(:,{'CaptureType'}) = [];
elseif ismember(study, {'CL'})
    % no need to remove any columns for climb;
end

%if any(ismember(tempdata.Properties.VariableNames', {'SputumColour'}))
%    tempdata.SputumColour = [];
%end

demofunc = @(x)[mean(x) std(x) min(x) max(x) mid50mean(x) mid50std(x) mid50min(x) mid50max(x) ...
    xb25mean(x) xb25std(x) xb25min(x) xb25max(x) xu25mean(x) xu25std(x) xu25min(x) xu25max(x)];
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

tic
timenow = datestr(clock(),30);

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = sprintf('%sdatademographicsbypatient-%s.mat', study, timenow);
fprintf('Saving output variables to matlab file %s\n', outputfilename);
save(fullfile(basedir, subfolder, outputfilename), 'measurecounttable', 'demographicstable', 'overalltable');
outputfilename = sprintf('%sdatademographicsbypatient.mat', study);
fprintf('Saving output variables to matlab file %s\n', outputfilename);
save(fullfile(basedir, subfolder, outputfilename), 'measurecounttable', 'demographicstable', 'overalltable');

basedir = setBaseDir();
subfolder = 'ExcelFiles';
outputfilename = sprintf('%sDataDemographicsByPatient-%s.xlsx',study, timenow);
fprintf('Saving results to excel file %s\n', outputfilename);
writetable(measurecounttable, fullfile(basedir, subfolder, outputfilename), 'Sheet', 'MeasureCountByPatient');
writetable(demographicstable, fullfile(basedir, subfolder, outputfilename), 'Sheet', 'DataDemographicsByPatient');
writetable(overalltable, fullfile(basedir, subfolder, outputfilename), 'Sheet', 'OverallDataDemographics');
toc
fprintf('\n');

end
