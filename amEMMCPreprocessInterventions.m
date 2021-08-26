function [amInterventions, amIntrDatacube, ninterventions, intrkeepidx] = amEMMCPreprocessInterventions(amInterventions, ...
    amIntrDatacube, amElectiveTreatments, measures, nmeasures, max_offset, align_wind, ninterventions,  intrmode, study)

% amEMMCPreprocessInterventions - preprocess intervention data and associated
% measurement data

% add columns for Data Window Completeness
for i = 1:ninterventions
    actualpoints = 0;
    maxpoints = 0;
    for m = 1:nmeasures
        % exclude interpolated measures from calculation of data window
        % completeness
        if ~startsWith(measures.DisplayName(m), 'Interp')
            actualpoints = actualpoints + sum(~isnan(amIntrDatacube(i, max_offset:max_offset+align_wind-1, m)));
            maxpoints = maxpoints + align_wind;
        end
    end
    amInterventions.DataWindowCompleteness(i) = 100 * actualpoints/maxpoints;
    %if i >= 2
    %    if (amInterventions.SmartCareID(i) == amInterventions.SmartCareID(i-1) ...
    %            && amInterventions.IVDateNum(i) - amInterventions.IVStopDateNum(i-1) < (align_wind + meanwindow))
    %        amInterventions.SequentialIntervention(i) = 'Y';
    %    end
    %end
end

amInterventions = outerjoin(amInterventions, amElectiveTreatments, 'LeftKeys', {'SmartCareID', 'Hospital', 'IVScaledDateNum'}, ...
    'RightKeys', {'ID', 'Hospital', 'IVScaledDateNum'}, 'RightVariables', {'ElectiveTreatment'}, 'Type', 'left');
% delete dummy row
%amInterventions(isnan(amInterventions.SmartCareID), :) = [];

% remove any interventions where insufficient data in the data window
if ismember(study, {'BR'})
    %idx = amInterventions.AvgMeasuresPerDay < 2.5;
    idx = amInterventions.AvgMeasuresPerDay < 2;    
else
    if ismember(study, {'SC', 'TM'})
        compthresh = 35;
    elseif ismember(study, {'CL'})
        compthresh = 33;
    else
        compthresh = 35;
    end
    idx = amInterventions.DataWindowCompleteness < compthresh;
end

fprintf('Removing %d interventions below completeness threshold\n', sum(idx));
amInterventions(idx,:) = [];
amIntrDatacube(idx,:,:) = [];
ninterventions = size(amInterventions,1);

if intrmode == 1
    intrkeepidx = true(size(amInterventions, 1),1);
elseif intrmode == 2
    intrkeepidx = amInterventions.SequentialIntervention ~= 'Y';
    amInterventions(~intrkeepidx,:) = [];
    amIntrDatacube(~intrkeepidx,:,:) = [];
    ninterventions = size(amInterventions,1);
else
    fprintf('**** Unknown intrmode ****\n');
end
    
end

