function [abname] = getABNameFromCode(scode, clABNameTable)

% getABNameFromCode - returns the antibiotic name from a string code (or
% returns the string if the code is not 1-11

numcode = str2double(scode);

if (isnan(numcode) || numcode < 1 || numcode > size(clABNameTable, 1))
    abname = scode;
else
    abname = sprintf('%d:%s', numcode, clABNameTable.Name{numcode});
end

end

