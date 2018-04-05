function [cdCRPOut] = fixCDCRP(cdCRP)
% fixCDPFTData - fix anomalies in PFT data

tic
fprintf('Fixing CRP data anomalies\n');
fprintf('-------------------------\n');

% add column for numeric value of CRP level
% populate with < or > removed
idx1 = 
idx2 = 
idx = intersect(idx1,idx2);
updates = size(idx,1);

fprintf('Fixed %2d non-numeric values\n', updates);
fprintf('\n');

cdCRPOut = cdCRP;

end

