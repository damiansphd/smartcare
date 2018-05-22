function [offsets, profile_pre, profile_post, hstg, qual] = amAlignCurves(normcube, abTreatments, max_offset, align_wind, nmeasures)

% alignCurves = function to align measurement curves prior to intervention

ninterventions = size(abTreatments,1);

meancurvesum   = zeros(max_offset + align_wind, nmeasures);
meancurvecount = zeros(max_offset + align_wind, nmeasures);

profile_pre    = zeros(nmeasures, max_offset+align_wind);
profile_post   = zeros(nmeasures, max_offset+align_wind);

hstg           = zeros(nmeasures, ninterventions, max_offset);

qual = 0;

for i = 1:ninteventions
    [meancurvesum, meancurvecount] = amAddToMean(meancurvesum, meancurvecount, normcube, max_offset, align_wind);
end

