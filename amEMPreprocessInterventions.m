function [amInterventions, amIntrDatacube, ninterventions] = amEMPreprocessInterventions(amInterventions, ...
    amIntrDatacube, max_offset, align_wind, ninterventions, nmeasures)

% amEMPreprocessInterventions - preprocess intervention data and associated
% measurement data

% add columns for Data Window Completeness and Flag for Sequential
% Intervention to amInterventions table
for i = 1:ninterventions
    scid = amInterventions.SmartCareID(i);
    actualpoints = 0;
    maxpoints = 0;
    for m = 1:nmeasures
        actualpoints = actualpoints + sum(~isnan(amIntrDatacube(i, max_offset:max_offset+align_wind-1, m)));
        maxpoints = maxpoints + align_wind;
    end
    amInterventions.DataWindowCompleteness(i) = 100 * actualpoints/maxpoints;
    if i >= 2
        if (amInterventions.SmartCareID(i) == amInterventions.SmartCareID(i-1) ...
                && amInterventions.IVDateNum(i) - amInterventions.IVDateNum(i-1) < (max_offset + align_wind))
            amInterventions.SequentialIntervention(i) = 'Y';
        end
    end
end

% remove any interventions where insufficient data in the data window

idx = find(amInterventions.DataWindowCompleteness < 35);
amInterventions(idx,:) = [];
amIntrDatacube(idx,:,:) = [];
ninterventions = size(amInterventions,1);

end

