function lcsort = getLCSortOrder(amInterventions, nlatentcurves)

% getLCSortOrder - returns the latent curve sets sorted from largest
% population to smallest

lccount = zeros(nlatentcurves, 1);

for l = 1:nlatentcurves
    lccount(l) = sum(amInterventions.LatentCurve == l);
end

[~, lcsort] = sort(lccount, 'descend');

end

