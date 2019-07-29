function [clphysdata] = createClimbMeasuresTable(nrows)

% createClimbMeasuresTable - creates empty copy of all the physdata
% measures table

clphysdata      = table('Size',[nrows 21], ...
    'VariableTypes', {'double',          'double',        'double',         'cell',          'cell',          'datetime', ...
                      'double',          'double',        'double',         'double',        'double',        'double', ...
                      'double',          'double',        'double',         'double',        'double',        'double', ...
                      'double',          'double',        'double'}, ...
    'VariableNames', {'SmartCareID',     'ScaledDateNum', 'DateNum',        'UserName',      'RecordingType', 'Date_TimeRecorded', ...
                      'FEV1',            'PredictedFEV',  'FEV1_',          'WeightInKg',    'O2Saturation',  'Pulse_BPM_', ...
                      'Rating',          'Temp_degC_',    'Activity_Steps', 'CalcFEV1SetAs', 'ScalingRatio',  'CalcFEV1_', ...
                      'NumSleepDisturb', 'BreathsPerMin', 'SputumColour'});

end

