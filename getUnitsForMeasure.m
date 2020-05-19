function [units] = getUnitsForMeasure(displaymeasure)

% getUnitsForMeasure - returns the units for a given measure

if ismember(displaymeasure, {'Clinical CRP'})
    units = 'mg/L';
elseif ismember(displaymeasure, {'Clinical FEV1', 'LungFunction'})
    units = 'percent predicted';
elseif ismember(displaymeasure, {'FEV1', 'FEV6', 'FEF2575', 'FEV075'})
    units = 'ltr';
elseif ismember(displaymeasure, {'Activity'})
    units = 'steps';
elseif ismember(displaymeasure, {'Calorie'})
    units = 'cal';
elseif ismember(displaymeasure, {'Cough', 'SleepActivity', 'Wellness'})
    units = 'percent';
elseif ismember(displaymeasure, {'MinsAsleep', 'MinsAwake'})
    units = 'mins';
elseif ismember(displaymeasure, {'O2Saturation'})
    units = 'percent';
elseif ismember(displaymeasure, {'PulseRate', 'RestingHR'})
    units = 'bpm';
elseif ismember(displaymeasure, {'Temperature'})
    units = sprintf('%sC', char(176));
elseif ismember(displaymeasure, {'Weight'})
    units = 'kg';
elseif ismember(displaymeasure, {'Prediction'})
    units = 'percent';
else
    fprintf('**** Unknown Measure ****\n');
    units = ' ';
end
    
end

