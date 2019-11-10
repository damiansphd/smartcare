function [physdata] = scaleDaysByPatient(physdata,doupdates)

% scaleDateByPatient - adds a new column to physdata for the scaled datenum 
% (relative to the first measurement date for each patient)

tic
fprintf('Scaling the date relative to the first measurement date for each patient\n');
fprintf('------------------------------------------------------------------------\n');
physdata = sortrows(physdata, {'SmartCareID', 'DateNum', 'RecordingType'}, 'ascend');

% get min and max measurement dates for each SmartCare ID
minDatesByPatient = varfun(@min, physdata(:,{'SmartCareID', 'DateNum'}), 'GroupingVariables', 'SmartCareID');
minDatesByPatient.GroupCount = [];
minDatesByPatient.Properties.VariableNames(2) = {'MinPatientDateNum'};

if doupdates
    physdata = innerjoin(physdata, minDatesByPatient);
    physdata.ScaledDateNum = physdata.DateNum - physdata.MinPatientDateNum +1;
    physdata.MinPatientDateNum = [];
    fprintf('Updates completed\n');
end
toc
fprintf('\n');

end

