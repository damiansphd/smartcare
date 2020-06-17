function nivdays = calcDaysOnIVForPatient(pivdata, fromd, tod)

% calcDaysOnIVForPatient - calculate the number of days on ivs for a given
% period

nivdays = 0;
ndays = days(tod - fromd);

tmpdate = fromd;
for i = 1:ndays
    
    if any(pivdata.StartDate <= tmpdate & pivdata.StopDate >= tmpdate)
        nivdays = nivdays + 1;
        %fprintf('%d ', i);
    end
    tmpdate = tmpdate + days(1);
end

fprintf('%2d ', nivdays);

