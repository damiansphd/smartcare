function [clinprocdate, guidmapdate, isValid] = getLatestBreatheDatesForHosp(hosp)

% getLatestBreatheDatesForHosp - convenience function to centralise getting the
% latest breathe clinical and measurement filename date suffixes for a
% given hospital

isValid = true;

if (ismember(hosp, 'PAP'))
    clinprocdate = '20201124';
    guidmapdate  = '20201014';
elseif (ismember(hosp, 'CDF'))
    clinprocdate = '20201031';
    guidmapdate  = '20201031';
else
    fprintf('**** Unknown Hospital ****/n');
    isValid      = false;
    clinprocdate = '';
    guidmapdate  = '';
end

end

