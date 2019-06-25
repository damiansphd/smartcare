function [cdPatient, cdAdmissions, cdAntibiotics, cdClinicVisits, cdOtherVisits, ...
    cdCRP, cdPFT, cdMicrobiology, cdEndStudy] = createClimbClinicalTables(nrows)

% createClimbClinicalTables - creates empty copies of all the clinical
% tables.

cdPatient      = table('Size',[nrows 21], ...
    'VariableTypes', {'double',   'cell',   'cell', 'datetime', 'datetime', 'double',  'double', 'double', 'cell', ...
                      'double', 'double', 'double',   'double',     'cell',   'cell', 'double', ...
                      'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'ID',   'Hospital',   'StudyNumber', 'StudyDate', 'DOB', 'Age',  'AgeYy', 'AgeMm', 'Sex', ...
                      'Height', 'Weight', 'PredictedFEV1', 'FEV1SetAs', 'TooYoung', 'StudyEmail', 'CalcAge', ...
                      'CalcAgeExact', 'CalcPredictedFEV1', 'CalcPredictedFEV1OrigAge', 'CalcFEV1SetAs', 'CalcFEV1SetAsOrigAge'});

cdAdmissions   = table('Size',[nrows 6], ...
    'VariableTypes', {'double',   'cell',        'cell', 'datetime',  'datetime',   'cell'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber', 'Admitted', 'Discharge', 'Reason'});

cdAntibiotics  = table('Size',[nrows 8], ...
    'VariableTypes', {'double',   'cell',        'cell', 'cell',            'cell',     'cell',  'datetime',  'datetime'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber', 'AntibioticName', 'Route', 'HomeIV_s', 'StartDate',  'StopDate'});

cdClinicVisits = table('Size',[nrows 4], ...
    'VariableTypes', {'double',   'cell',        'cell',       'datetime'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber', 'AttendanceDate'});

cdOtherVisits  = table('Size',[nrows 5], ...
    'VariableTypes', {'double',   'cell',        'cell',       'datetime',      'cell'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber', 'AttendanceDate', 'VisitType'});

cdPFT          = table('Size',[nrows 10], ...
    'VariableTypes', {'double',   'cell',        'cell',         'datetime', 'double', 'double', 'double', 'double', 'double',           'double'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber', 'LungFunctionDate',   'FEV1',  'FEV1_',   'FVC1',  'FVC1_', 'CalcFEV1SetAs', 'CalcFEV1_'});

cdCRP          = table('Size',[nrows 8], ...
    'VariableTypes', {'double',   'cell',        'cell', 'datetime',  'cell',  'cell',               'cell',       'double'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber',  'CRPDate', 'Level', 'Units', 'PatientAntibiotics', 'NumericLevel'});

cdMicrobiology = table('Size',[nrows 5], ...
    'VariableTypes', {'double',   'cell',        'cell',         'cell',         'datetime'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber', 'Microbiology', 'DateMicrobiology'});

cdEndStudy     = table('Size',[nrows 4], ...
    'VariableTypes', {'double',   'cell',        'cell',             'cell'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber', 'EndOfStudyReason'});



end

