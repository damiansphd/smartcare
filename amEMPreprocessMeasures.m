function [amDatacube, measures, nmeasures] = amEMPreprocessMeasures(amDatacube, amInterventions, measures, demographicstable, measuresmask, align_wind, npatients, ndays, ninterventions)

% amEMPreprocessMeasures - various bits of pre-processing to measures table
% and associated measurement data

% remove temperature readings as insufficient datapoints for a number of
% the interventions
idx = ismember(measures.DisplayName, {'Temperature'});
amDatacube(:,:,measures.Index(idx)) = [];
measures(idx,:) = [];
nmeasures = size(measures,1);
measures.Index = [1:nmeasures]';

% set the measures mask depending on option chosen
if measuresmask == 1
    %measures.Mask(:) = 1;
    idx = ~ismember(measures.DisplayName, {'Activity'});
    measures.Mask(idx) = 1;
elseif measuresmask == 2
    idx = ismember(measures.DisplayName, {'Cough', 'LungFunction', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 3
    idx = ~ismember(measures.DisplayName, {'Activity', 'LungFunction'});
    measures.Mask(idx) = 1;
else
    % shouldn't ever get here - but default to just cough if it ever
    % happens
    idx = ismember(measures.DisplayName, {'Cough'});
end

% calculate the overall & alignment window std for each measure and store in measures
% table. Also the overall min, max and range values by measure (across all
% patients and days)

for m = 1:nmeasures
    %tempdata = zeros(ninterventions * align_wind, 1);
    tempdata = 0;
    for i = 1:ninterventions
        scid   = amInterventions.SmartCareID(i);
        start = amInterventions.IVScaledDateNum(i);
        periodstart = start - align_wind;
        if periodstart < 1
            periodstart = 1;
        end
        tempdata = [tempdata; reshape(amDatacube(scid, periodstart:(start - 1), m), start - periodstart, 1)];  
        %tempdata( ((i-1) * align_wind) + 1 : (i * align_wind) ) = reshape(amDatacube(scid, (start - align_wind):(start - 1), m), align_wind, 1);
    end
    tempdata(1) = [];
    
    measures.AlignWindStd(m) = std(tempdata(~isnan(tempdata)));
    tempdata = reshape(amDatacube(:, :, m), npatients * ndays, 1);
    measures.OverallStd(m) = std(tempdata(~isnan(tempdata)));
    [measures.OverallMin(m), measures.OverallMax(m)] = getMeasureOverallMinMax(demographicstable, measures.Name{m});
    measures.OverallRange(m) = measures.OverallMax(m) - measures.OverallMin(m);
end

end

