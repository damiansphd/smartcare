function [brPatient, brAdmissions, brAntibiotics, brClinicVisits, brOtherVisits, ...
    brCRP, brPFT, brMicrobiology, brHghtWght, brEndStudy] = createBreatheClinicalTables(nrows)

% createBreatheClinicalTables - creates empty copies of all the clinical
% tables for project breathe, with nrows rows in each

brPatient      = table('Size',[nrows 20], ...
    'VariableTypes', {'double',   'cell',          'cell',  'datetime', 'datetime', 'double', 'cell', ...
                      'double', 'double',        'double',    'double',       'cell',    'cell',    'cell',  'double', ...
                            'double',            'double',                   'double',        'double',               'double'}, ...
    'VariableNames', {'ID',   'Hospital',   'StudyNumber', 'StudyDate',      'DOB',    'Age',  'Sex', ...
                      'Height', 'Weight', 'PredictedFEV1', 'FEV1SetAs', 'StudyEmail', 'CFGene1', 'CFGene2', 'CalcAge', ...
                      'CalcAgeExact', 'CalcPredictedFEV1', 'CalcPredictedFEV1OrigAge', 'CalcFEV1SetAs', 'CalcFEV1SetAsOrigAge'});

brAdmissions   = table('Size',[nrows 5], ...
    'VariableTypes', {'double',   'cell',        'cell', 'datetime',  'datetime'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber', 'Admitted', 'Discharge'});

brAntibiotics  = table('Size',[nrows 9], ...
    'VariableTypes', {'double',   'cell',        'cell',           'cell',  'cell',     'cell',  'datetime',  'datetime',     'cell'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber', 'AntibioticName', 'Route', 'HomeIV_s', 'StartDate',  'StopDate', 'Comments'});

brClinicVisits = table('Size',[nrows 4], ...
    'VariableTypes', {'double',   'cell',        'cell',       'datetime'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber', 'AttendanceDate'});

brOtherVisits  = table('Size',[nrows 5], ...
    'VariableTypes', {'double',   'cell',        'cell',       'datetime',      'cell'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber', 'AttendanceDate', 'VisitType'});

brPFT          = table('Size',[nrows 7], ...
    'VariableTypes', {'double',   'cell',        'cell',         'datetime', 'double', 'double',    'double'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber', 'LungFunctionDate',   'FEV1',  'FEV1_', 'CalcFEV1_'});

brCRP          = table('Size',[nrows 8], ...
    'VariableTypes', {'double',   'cell',        'cell', 'datetime',  'cell',  'cell',               'cell',       'double'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber',  'CRPDate', 'Level', 'Units', 'PatientAntibiotics', 'NumericLevel'});

brMicrobiology = table('Size',[nrows 6], ...
    'VariableTypes', {'double',   'cell',        'cell',         'cell',         'datetime',        'cell'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber', 'Microbiology', 'DateMicrobiology', 'NameIfOther'});

brHghtWght = table('Size',[nrows 9], ...
    'VariableTypes', {'double',   'cell',        'cell', 'datetime', 'double', 'double',   'double',   'double', 'double'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber', 'MeasDate', 'Height', 'H_ZScore', 'Weight', 'W_ZScore',    'BMI'});

brEndStudy     = table('Size',[nrows 4], ...
    'VariableTypes', {'double',   'cell',        'cell',             'cell'}, ...
    'VariableNames', {'ID',   'Hospital', 'StudyNumber', 'EndOfStudyReason'});

end

