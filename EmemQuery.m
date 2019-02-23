clear; clc; close all;

load('./MatlabSavedVariables/smartcaredata.mat');
load('./MatlabSavedVariables/clinicaldata.mat');

pdata = physdata_predateoutlierhandling;
npatients = size(cdPatient,1);
studyduration = 180;
outputdata = table('Size',[npatients 7], ...
    'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'double', 'double'} , ...
    'VariableNames', {'ID', 'StudyDuration', 'MeasuresDuration', 'DaysWithMeasures', 'NumMeasurements', 'SDAvMeasuresPerDay', 'MDAvMeasuresPerDay'});

for n = 1:size(cdPatient,1)
    outputdata.ID(n) = cdPatient.ID(n);
    outputdata.StudyDuration(n) = studyduration;
    if size(pdata.SmartCareID(pdata.SmartCareID == cdPatient.ID(n)),1) ~= 0
        outputdata.MeasuresDuration(n) = max(pdata.DateNum(pdata.SmartCareID == cdPatient.ID(n))) - min(pdata.DateNum(pdata.SmartCareID == cdPatient.ID(n)));
        outputdata.DaysWithMeasures(n) = size(unique(pdata.DateNum(pdata.SmartCareID == cdPatient.ID(n))),1);
        outputdata.NumMeasurements(n) = size(pdata.SmartCareID(pdata.SmartCareID == cdPatient.ID(n) & pdata.Date_TimeRecorded >= cdPatient.StudyDate(n) & pdata.Date_TimeRecorded <= (cdPatient.StudyDate(n) + days(studyduration))),1);
        outputdata.SDAvMeasuresPerDay(n) = outputdata.NumMeasurements(n)/studyduration;
        outputdata.MDAvMeasuresPerDay(n) = outputdata.NumMeasurements(n)/outputdata.MeasuresDuration(n);
    end
        
end

writetable(outputdata, './ExcelFiles/SmartCareQuery.xlsx');


