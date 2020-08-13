function [clinicaldate, measdate, guidmapdate, isValid] = getLatestBreatheDatesForHosp(hosp)

% getLatestBreatheDatesForHosp - convenience function to centralise getting the
% latest breathe clinical and measurement filename date suffixes for a
% given hospital

isValid = true;

guidmapdate  = '20200807';

if (ismember(hosp, 'PAP'))
    clinicaldate = '20200410';
    measdate     = '20200413';
elseif (ismember(hosp, 'CDF'))
    clinicaldate = '20200701';
    measdate     = '20200701';
else
    fprintf('**** Unknown Hospital ****/n');
    isValid      = false;
    clinicaldate = '';
    measdate     = '';
    guidmapdate  = '';
end

end

