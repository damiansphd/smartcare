function printSmartCareData(sc, rowstoshow)

% printSmartCareData - a convenience function to print formatted output for
% a set of smart care data rows

tic

% limit output to 10 rows for now
if size(sc,1) > rowstoshow
    nrows = rowstoshow;
    truncated = true;
else
    nrows = size(sc,1);
    truncated = false;
end

fprintf('\n');
fprintf('SmartCareID DateNum    UserName          RecordingType        Date_TimeRecorded  FEV1 PredFEV FEV1_  Weight O2Sat Pulse Rating Temp(C) SputumTaken Activity\n');
fprintf('___________ _______ ______________ ________________________ ____________________ ____ _______ _____ _______ _____ _____ ______ _______ ___________ ________\n');

for i = 1:nrows
    scId = string(sc.SmartCareID(i));
    scDatenum = string(sc.DateNum(i));
    scDaterec = datestr(sc.Date_TimeRecorded(i));
    scFev1 = ' '; scPredfev1 = ' '; scFev1_ = ' '; scWeight = ' '; scO2 = ' '; scPulse = ' '; scRating = ' '; scTemp = ' '; scSputum = ' '; scAct = ' ';
    switch sc.RecordingType{i}
        case 'ActivityRecording'
            scAct = sprintf('%5d',sc.Activity_Steps(i));
        case {'CoughRecording','SleepActivityRecording','WellnessRecording'}
            scRating = sprintf('%3d', sc.Rating(i));
        case 'LungFunctionRecording'
            scFev1 = sprintf('%1.1f',sc.FEV1(i));
            scPredfev1 = sprintf('%1.1f',sc.PredictedFEV(i));
            scFev1_ = sprintf('%1.1f',sc.FEV1_(i));
        case 'O2SaturationRecording'
            scO2 = sprintf('%3d',sc.O2Saturation(i));
        case 'PulseRateRecording'
            scPulse = sprintf('%3d',sc.Pulse_BPM_(i));
        case 'SputumSampleRecording'
            scSputum = string(sc.SputumSampleTaken_(i));
        case 'TemperatureRecording'
            scTemp = sprintf('%2.2f',sc.Temp_degC_(i));
        case 'WeightRecording'
            scWeight = sprintf('%3.2f',sc.WeightInKg(i));
        otherwise
            fprintf('Unknown measurement type\n');
    end
    
    
    fprintf('%11s %7s %14s %24s %19s %4s %7s %5s %7s %5s %5s %6s %7s %11s %8s\n', scId, scDatenum, sc.UserName{i}, sc.RecordingType{i}, scDaterec, scFev1, ...
          scPredfev1, scFev1_, scWeight, scO2, scPulse, scRating, scTemp, scSputum, scAct);

end

if truncated
    fprintf('**** %d additional rows not shown **** \n', size(sc,1) - rowstoshow);
end
fprintf('\n');
toc
fprintf('\n');





end

