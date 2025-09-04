function [column] = getColumnForRawBreatheCaptureType(filetype)

% getColumnForRawBreatheCaptureType - returns the column name for the capture type
% from the input files for project breathe measurement data

switch filetype
    case {'Activity', 'Activities', 'Coughing', 'HeartRate', 'HeartRates', 'Oximeter', 'Oximeters', 'Sleep', 'Sleeps', ...
            'Spirometer', 'Spirometers', 'Temperature', 'Temperatures', 'Weight', 'Weights', 'Wellbeing', 'Wellbeings'}
        column = 'CaptureType';
    otherwise
        fprintf('*** Unknown filetype %s ***\n', filetype);
        column = '';
end
end

