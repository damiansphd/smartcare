function [mltable] = createAceCFSingleClinicalTable(mltablename, nrows)

% createAceCFSingleClinicalTable - creates a given clinical
% table for the ACE-CF study, based on the name parameter, with the number
% of rows specified

switch mltablename
    case 'acPatient'
        mltable = table('Size',[nrows 27], ...
                        'VariableTypes', {'double',          'cell',       'cell',          'cell',               'datetime',     'datetime',     'datetime', ...
                                          'datetime',        'datetime',   'double',        'cell',               'cell',         'double',       'double',  ...
                                          'double',          'double',     'cell',          'cell',               'cell',         'cell', ...
                                          'cell',            'double',     'double',        'double',             'double',       ...
                                          'double',          'double'}, ...
                        'VariableNames', {'ID',              'Hospital',   'StudyNumber',   'StudyNumber2',       'StudyDate',    'Prior6Mnth',   'Post6Mnth', ...
                                          'PatClinDate',     'DOB',        'Age',           'Sex',                'Ethnicity',    'Height',       'Weight',  ...
                                          'PredictedFEV1',   'FEV1SetAs',  'StudyEmail',    'CFGene1',            'CFGene2',      'Cohort', ...
                                          'GeneralComments', 'CalcAge',    'CalcAgeExact',  'CalcPredictedFEV1',  'CalcPredictedFEV1OrigAge', ...
                                          'CalcFEV1SetAs',   'CalcFEV1SetAsOrigAge'});
    
    case 'acPatDataUpdTo'
        mltable = table('Size', [nrows, 4], ...
                        'VariableTypes', {'double',  'cell',     'cell',         'datetime'}, ...
                        'VariableNames', {'ID',      'Hospital', 'StudyNumber',  'PatClinDate'});
                    
    case 'acDrugTherapy'
        mltable = table('Size',[nrows 7], ...
                        'VariableTypes', {'double', 'cell',     'cell',        'datetime',             'datetime',            'cell',            'cell'}, ...
                        'VariableNames', {'ID',     'Hospital', 'StudyNumber', 'DrugTherapyStartDate', 'DrugTherapyStopDate', 'DrugTherapyType', 'DrugTherapyComment',});

    case 'acAdmissions'
        mltable = table('Size',[nrows 8], ...
                        'VariableTypes', {'double', 'cell',     'cell',        'datetime', 'datetime',  'cell',    'cell',   'cell'}, ...
                        'VariableNames', {'ID',     'Hospital', 'StudyNumber', 'Admitted', 'Discharge', 'Planned', 'Reason', 'Comments'});

    case 'acAntibiotics'
        mltable = table('Size',[nrows 12], ...
                        'VariableTypes', {'double',    'cell',      'cell',        'cell',           'cell',       'cell', ...
                                          'datetime',  'datetime',  'cell',        'cell',           'cell',       'cell'}, ...
                        'VariableNames', {'ID',        'Hospital',  'StudyNumber', 'AntibioticName', 'Route',      'HomeIV_s', ...
                                          'StartDate', 'StopDate',  'Reason',      'ProtocolDef',   'Prescriber', 'Comments'});
                  
    case 'acClinicVisits'
        mltable = table('Size',[nrows 9], ...
                        'VariableTypes', {'double', 'cell',     'cell',        'datetime',       'cell',     'cell',    'cell',   'cell',   'cell'}, ...
                        'VariableNames', {'ID',     'Hospital', 'StudyNumber', 'AttendanceDate', 'Location', 'EncType', 'UEType', 'OVType', 'Comments'});

    case 'acOtherVisits'
        mltable = table('Size',[nrows 6], ...
                        'VariableTypes', {'double', 'cell',     'cell',        'datetime',       'cell',      'cell'}, ...
                        'VariableNames', {'ID',     'Hospital', 'StudyNumber', 'AttendanceDate', 'VisitType', 'Comments'});

    case 'acUnplannedContact'
        mltable = table('Size',[nrows 6], ...
                        'VariableTypes', {'double', 'cell',     'cell',        'datetime',    'cell',          'cell'}, ...
                        'VariableNames', {'ID',     'Hospital', 'StudyNumber', 'ContactDate', 'TypeOfContact', 'Comments'});

    case 'acPFT' 
        mltable = table('Size',[nrows 9], ...
                        'VariableTypes', {'double', 'cell',     'cell',        'datetime',         'double', 'cell',  'double', 'double',    'cell'}, ...
                        'VariableNames', {'ID',     'Hospital', 'StudyNumber', 'LungFunctionDate', 'FEV1',   'Units', 'FEV1_',  'CalcFEV1_', 'Comments'});

    case 'acCRP'
        mltable = table('Size',[nrows 9], ...
                        'VariableTypes', {'double', 'cell',     'cell',        'datetime', 'double', 'cell',  'cell',               'double',       'cell'}, ...
                        'VariableNames', {'ID',     'Hospital', 'StudyNumber', 'CRPDate',  'Level',  'Units', 'PatientAntibiotics', 'NumericLevel', 'Comments'});

    case 'acMicrobiology'
        mltable = table('Size',[nrows 7], ...
                        'VariableTypes', {'double', 'cell',     'cell',        'cell',         'datetime',         'cell',        'cell'}, ...
                        'VariableNames', {'ID',     'Hospital', 'StudyNumber', 'Microbiology', 'DateMicrobiology', 'NameIfOther', 'Comments'});

    case 'acHghtWght'
        mltable = table('Size',[nrows 10], ...
                        'VariableTypes', {'double', 'cell',     'cell',        'datetime', 'double', 'double',   'double', 'double',   'double',  'cell'}, ...
                        'VariableNames', {'ID',     'Hospital', 'StudyNumber', 'MeasDate', 'Height', 'H_ZScore', 'Weight', 'W_ZScore', 'BMI',     'Comments'});

    case 'acEndStudy'
        mltable = table('Size',[nrows 4], ...
                        'VariableTypes', {'double', 'cell',     'cell',        'cell'}, ...
                        'VariableNames', {'ID',     'Hospital', 'StudyNumber', 'EndOfStudyReason'});
    
    otherwise
        fprintf('**** Unknown table name ****');
        mltable = [];
        return;
end

end

