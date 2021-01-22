function [clinprocdate, guidmapdate, isValid] = getLatestBreatheDatesForHosp(hosp)

% getLatestBreatheDatesForHosp - convenience function to centralise getting the
% latest breathe clinical and measurement filename date suffixes for a
% given hospital

isValid = true;

if (ismember(hosp, 'PAP'))
    clinprocdate = '20201124';
    guidmapdate  = '20210112';
elseif (ismember(hosp, 'CDF'))
    clinprocdate = '20201130';
    guidmapdate  = '20210104';
else
    fprintf('**** Unknown Hospital ****/n');
    isValid      = false;
    clinprocdate = '';
    guidmapdate  = '';
end

end

