function nec = calcEmergContForPatient(pecdata, fromd, tod)

% calcEmergContForPatient - calculate the number emergency contacts for a given
% period
nec = 0;
ndays = days(tod - fromd);

tmpdate = fromd;
for i = 1:ndays
    
    if any(pecdata.Date == tmpdate)
        nec = nec + 1;
        fprintf('%d ', i);
    end
    tmpdate = tmpdate + days(1);
end

fprintf('%2d ', nec);

