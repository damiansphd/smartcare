function [clABTable] = getClimbAntibioticNameTable()

% getClimbAntibioticNameTable - returns a table with the antibiotic names and 
% they given the numeric codes

clABTable   = table('Size',[11 2], ...
    'VariableTypes', {'double',   'cell'}, ...
    'VariableNames', {'ID',   'Name'});

clABTable.ID(:) = 1:11;
clABTable.Name{1}  = 'Ceftazidime';
clABTable.Name{2}  = 'Tobramycin';
clABTable.Name{3}  = 'Ciprofloxacin';
clABTable.Name{4}  = 'Colistin';
clABTable.Name{5}  = 'Meropenem';
clABTable.Name{6}  = 'Impipenem';
clABTable.Name{7}  = 'Flucloxacillin';
clABTable.Name{8}  = 'Amoxycillin';
clABTable.Name{9}  = 'Coamoxyclav';
clABTable.Name{10} = 'Azithromycin';
clABTable.Name{11} = 'Cotrimoxazole';

end

