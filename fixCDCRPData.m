function [cdCRPOut] = fixCDCRPData(cdCRP)

% fixCDCRPData - fix anomalies in CRP data

tic
fprintf('Fixing CRP data anomalies\n');
fprintf('-------------------------\n');

% add column for numeric value of CRP level
% populate with < or > removed
numlevel = str2double(regexprep(cdCRP.Level, '[<>]',''));
numlevel = array2table(numlevel);
numlevel.Properties.VariableNames{1} = 'NumericLevel';
cdCRP = [cdCRP numlevel];

fprintf('Added column for numeric version of Level (remove < and >)\n');

cdCRPOut = cdCRP;

toc
fprintf('\n');

end

