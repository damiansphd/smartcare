function [clinprocdate, patientmasterdate, isValid] = getLatestBreatheDatesForHosp(hosp)

% getLatestBreatheDatesForHosp - convenience function to centralise getting the
% latest breathe clinical and measurement filename date suffixes for a
% given hospital

isValid = true;

if (ismember(hosp, 'PAP'))
    clinprocdate      = '20210228';
    patientmasterdate = '20210315';
elseif (ismember(hosp, 'CDF'))
    clinprocdate      = '20210305';
    patientmasterdate = '20210305';
else
    fprintf('**** Unknown Hospital ****/n');
    isValid      = false;
    clinprocdate = '';
    patientmasterdate  = '';
end

end

