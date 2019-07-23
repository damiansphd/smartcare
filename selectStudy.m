function [studynbr, study, studyfullname] = selectStudy()

% selectStudy - choose which study to run for

nstudies = 3;

sstudynbr = input('Enter Study to run for (1 = SmartCare, 2 = TeleMed 3 = Climb): ', 's');

studynbr = str2double(sstudynbr);

if (isnan(studynbr) || studynbr < 1 || studynbr > nstudies)
    fprintf('Invalid choice\n');
    studynbr = -1;
    study = '**';
    return;
end


if studynbr == 1
    study = 'SC';
    studyfullname = 'SmartCare';
elseif studynbr == 2
    study = 'TM';
    studyfullname = 'TeleMed';
elseif studynbr == 3
    study = 'CL';
    studyfullname = 'Climb';
end


end

