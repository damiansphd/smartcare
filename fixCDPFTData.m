function [cdPFTOut] = fixCDPFTData(cdPFT)

% fixCDPFTData - fix anomalies in PFT data

tic
fprintf('Fixing PFT data anomalies\n');
fprintf('-------------------------\n');

% fix illogical FVC1 value
idx1 = find(cdPFT.ID == 66);
idx2 = find(cdPFT.FVC1 == 28);
idx = intersect(idx1,idx2);
updates = size(idx,1);
cdPFT.FVC1(idx) = 2.8;
fprintf('Fixed %2d illogical values\n', updates);

cdPFTOut = cdPFT;

toc
fprintf('\n');



end

