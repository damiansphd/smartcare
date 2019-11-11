function [studynbr, study, studyfullname] = selectStudy()

% selectStudy - choose which study to run for

nstudies = 4;

sstudynbr = input('Enter Study to run for (1 = SmartCare, 2 = TeleMed, 3 = Climb, 4 = Breathe): ', 's');

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
elseif studynbr == 4
    study = 'BR';
    studyfullname = 'Breathe';
end


end

