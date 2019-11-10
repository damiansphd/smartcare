function [column] = getColumnForRawBreatheCaptureType(filetype)

% getColumnForRawBreatheCaptureType - returns the column name for the capture type
% from the input files for project breathe measurement data

switch filetype
    case {'Activity', 'Coughing', 'HeartRate', 'Oximeter', 'Sleep', 'Spirometer', 'Temperature', 'Weight', 'Wellbeing'}
        column = 'CaptureType';
    otherwise
        fprintf('*** Unknown filetype %s ***\n', filetype);
        column = '';
end
end

