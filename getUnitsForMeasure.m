function [units] = getUnitsForMeasure(displaymeasure)

% getUnitsForMeasure - returns the units for a given measure

if ismember(displaymeasure, {'Clinical CRP'})
    units = 'mg/L';
elseif ismember(displaymeasure, {'Clinical FEV1', 'LungFunction'})
    units = '% predicted';
elseif ismember(displaymeasure, {'Activity'})
    units = 'steps';
elseif ismember(displaymeasure, {'Cough', 'SleepActivity', 'Wellness'})
    units = '%';
elseif ismember(displaymeasure, {'O2Saturation'})
    units = '%';
elseif ismember(displaymeasure, {'PulseRate'})
    units = 'bpm';
elseif ismember(displaymeasure, {'Temperature'})
    units = sprintf('%sC', char(176));
elseif ismember(displaymeasure, {'Weight'})
    units = 'kg';
else
    fprintf('**** Unknown Measure ****');
    units = ' ';
end
    
end

