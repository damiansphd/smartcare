function [smcolour, rwcolour] = getColourForMeasure(displaymeasure)

% getColorForMeasure - returns the RGB value of the colour for a given
% measure (to ensure consistent across plots

colours = lines(7);

if ismember(displaymeasure, {'Clinical CRP'})
    rwcolour = [0, 0.65, 1];
    smcolour = [0, 0.65, 1];
elseif ismember(displaymeasure, {'Clinical FEV1'})
    rwcolour = [0, 0.65, 1];
    smcolour = [0, 0.65, 1];
elseif ismember(displaymeasure, {'Cough'})
    rwcolour = [0, 0.647, 0.941];
    smcolour = [0, 0.447, 0.741];
elseif ismember(displaymeasure, {'LungFunction'})
    rwcolour = [0.95, 0.525, 0.298];
    smcolour = [0.85, 0.325, 0.098];
elseif ismember(displaymeasure, {'O2Saturation'})
    rwcolour = [0.989, 0.894, 0.425];
    smcolour = [0.929, 0.794, 0.325];
elseif ismember(displaymeasure, {'PulseRate'})
    rwcolour = [0.794, 0.484, 0.856];
    smcolour = [0.494, 0.184, 0.556];
elseif ismember(displaymeasure, {'SleepActivity'})
    rwcolour = [0.666, 0.874, 0.388];
    smcolour = [0.466, 0.674, 0.188];
elseif ismember(displaymeasure, {'Wellness'})
    rwcolour = [0.401, 0.845, 0.933];
    smcolour = [0.301, 0.745, 0.933];
elseif ismember(displaymeasure, {'Activity'})
    rwcolour = [0.935, 0.378, 0.484];
    smcolour = [0.635, 0.078, 0.184];
elseif ismember(displaymeasure, {'Temperature'})
    rwcolour = [0.9, 0.2, 0.6];
    smcolour = [0.777, 0.082, 0.42];
elseif ismember(displaymeasure, {'Weight'})
    rwcolour = [0.7, 0, 0];
    smcolour = [0.3, 0, 0];
else
    fprintf('**** Unknown Measure ****\n');
    rwcolour = [1, 1, 1];
end

end

