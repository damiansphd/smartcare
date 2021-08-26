function [amDatacube, measures, nmeasures] = amEMMCPreprocessMeasures(amDatacube, amInterventions, measures, ...
    demographicstable, measuresmask, align_wind, npatients, ndays, ninterventions, nmeasures, study)

% amEMMCPreprocessMeasures - various bits of pre-processing to measures table
% and associated measurement data

% remove temperature readings as insufficient datapoints for a number of
% the interventions
if ismember(study, {'SC', 'TM'})
    idx = ismember(measures.DisplayName, {'Temperature'});
    amDatacube(:,:,measures.Index(idx)) = [];
    measures(idx,:) = [];
    nmeasures = size(measures,1);
    measures.Index = (1:nmeasures)';
end

% set the measures mask depending on option chosen
if measuresmask == 0
    % all
    measures.Mask(:) = 1;
elseif measuresmask == 1
    % all except activity
    idx = ~ismember(measures.DisplayName, {'Activity'});
    measures.Mask(idx) = 1;
elseif measuresmask == 2
    % cough, lung function and wellness
    idx = ismember(measures.DisplayName, {'Cough', 'LungFunction', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 3
    % all except activity and lung function
    idx = ~ismember(measures.DisplayName, {'Activity', 'LungFunction'});
    measures.Mask(idx) = 1;
elseif measuresmask == 4
    % all except activity and weight
    idx = ~ismember(measures.DisplayName, {'Activity', 'Weight'});
    measures.Mask(idx) = 1;
elseif measuresmask == 5
    % all except weight
    idx = ~ismember(measures.DisplayName, {'Weight'});
    measures.Mask(idx) = 1;
elseif measuresmask == 6
    % project breathe
    idx = ismember(measures.DisplayName, {'Calorie', 'Cough', 'FEV1', 'MinsAsleep', 'MinsAwake', ...
        'O2Saturation', 'PulseRate', 'RestingHR', 'Temperature', 'Weight', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 7
    % project breathe
    idx = ismember(measures.DisplayName, {'Cough', 'FEV1', 'MinsAwake', 'O2Saturation', ...
        'RestingHR', 'Temperature', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 8
    % project breathe
    idx = ismember(measures.DisplayName, {'Cough', 'FEF2575', 'MinsAsleep', 'O2Saturation', ...
        'RestingHR', 'Temperature', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 9
    % project climb
    idx = ismember(measures.DisplayName, {'Appetite', 'Cough', 'SleepActivity', ...
        'SputumVolume', 'Tiredness', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 10
    % project climb
    idx = ~ismember(measures.DisplayName, {'Activity', 'Temperature'});
    measures.Mask(idx) = 1;
elseif measuresmask == 11
    % project climb
    idx = ismember(measures.DisplayName, {'Appetite', 'Cough', 'O2Saturation', 'PulseRate', ...
        'SleepActivity', 'SputumVolume', 'Tiredness', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 12
    % project climb
    idx = ismember(measures.DisplayName, {'Appetite', 'Cough', 'FEV1', 'O2Saturation', 'PulseRate', ...
        'SleepActivity', 'SputumVolume', 'Tiredness', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 13
    % project breathe
    idx = ismember(measures.DisplayName, {'Cough', 'FEV1', 'MinsAsleep', ...
        'RestingHR', 'Temperature', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 14
    % project climb
    idx = ismember(measures.DisplayName, {'Appetite', 'Cough', 'FEV1', 'O2Saturation', 'PulseRate', ...
        'SleepActivity', 'SputumVolume', 'Temperature', 'Tiredness', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 15
    % project climb
    idx = ismember(measures.DisplayName, {'Appetite', 'Cough', 'FEV1', 'O2Saturation', 'PulseRate', ...
        'SleepActivity', 'SputumVolume', 'Temperature', 'Tiredness', 'Weight', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 16
    % project climb
    idx = ismember(measures.DisplayName, {'SputumVolume'});
    measures.Mask(idx) = 1;
elseif measuresmask == 17
    % project climb
    idx = ismember(measures.DisplayName, {'Appetite', 'Cough', 'O2Saturation', 'PulseRate', ...
        'SleepActivity', 'SputumVolume', 'Temperature', 'Tiredness', 'Weight', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 18
    % project climb
    idx = ismember(measures.DisplayName, {'Appetite', 'Cough', 'InterpFEV1', 'O2Saturation', 'PulseRate', ...
        'SleepActivity', 'SputumVolume', 'Temperature', 'Tiredness', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 19
    % project climb
    idx = ismember(measures.DisplayName, {'Appetite', 'Cough', 'InterpFEV1', 'O2Saturation', 'PulseRate', ...
        'SleepActivity', 'SputumVolume', 'Temperature', 'Tiredness', 'InterpWeight', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 20
    % project climb
    idx = ismember(measures.DisplayName, {'Appetite', 'Cough', 'O2Saturation', 'PulseRate', ...
        'SleepActivity', 'SputumVolume', 'Temperature', 'Tiredness', 'InterpWeight', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 21
    % project breathe
    idx = ismember(measures.DisplayName, {'Cough', 'FEV1', 'MinsAsleep', 'O2Saturation', ...
        'RestingHR', 'Temperature', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 22
    % project breathe
    idx = ismember(measures.DisplayName, {'RestingHR'});
    measures.Mask(idx) = 1;
elseif measuresmask == 23
    % project breathe
    idx = ismember(measures.DisplayName, {'Cough', 'FEV1', 'MinsAsleep', 'O2Saturation', ...
        'RestingHR', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 24
    % project breathe
    idx = ismember(measures.DisplayName, {'Cough', 'FEV1', 'MinsAsleep', 'MinsAwake', 'O2Saturation', ...
        'RestingHR', 'Wellness'});
    measures.Mask(idx) = 1;    
elseif measuresmask == 25
    % project breathe
    idx = ismember(measures.DisplayName, {'Cough', 'FEV1', 'MinsAsleep', 'MinsAwake', 'O2Saturation', ...
        'RestingHR', 'Temperature', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 26
    % project breathe
    idx = ismember(measures.DisplayName, {'Cough', 'LungFunction', 'MinsAsleep', ...
        'PulseRate', 'Temperature', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 27
    % project breathe
    idx = ismember(measures.DisplayName, {'Cough', 'LungFunction', 'MinsAsleep', 'O2Saturation', ...
        'PulseRate', 'Temperature', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 28
    % project breathe
    idx = ismember(measures.DisplayName, {'Cough', 'LungFunction', 'MinsAsleep', ...
        'RestingHR', 'Temperature', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 29
    % project breathe
    idx = ismember(measures.DisplayName, {'Cough', 'LungFunction', 'MinsAsleep', 'O2Saturation', ...
        'RestingHR', 'Temperature', 'Wellness'});
    measures.Mask(idx) = 1;
elseif measuresmask == 30
    % project breathe
    idx = ismember(measures.DisplayName, {'Cough', 'Wellness'});
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

