function [units] = getUnitsForMeasure(displaymeasure)

% getUnitsForMeasure - returns the units for a given measure

if ismember(displaymeasure, {'Clinical CRP Level'})
    units = 'mg/L';
elseif ismember(displaymeasure, {'Clinical FEV1'})
    units = '%';
elseif ismember(displaymeasure, {'Activity'})
    units = 'Steps';
elseif ismember(displaymeasure, {'Cough', 'Sleep Activity', 'Wellness'})
    units = 'Rating';
elseif ismember(displaymeasure, {'Lung Function'})
    units = '%';
elseif ismember(displaymeasure, {'O2 Saturation'})
    units = '%';
elseif ismember(displaymeasure, {'Pulse Rate'})
    units = 'bpm';
elseif ismember(displaymeasure, {'Temperature'})
    units = 'deg C';
elseif ismember(displaymeasure, {'Weight'})
    units = 'Kg';
else
    fprintf('**** Unknown Measure ****');
    units = ' ';
end
    
end

