function [studynbr, study, studyfullname] = selectStudy()

% selectStudy - choose which study to run for

nstudies = 6;

sstudynbr = input('Enter Study to run for (1 = SmartCare, 2 = TeleMed, 3 = Climb, 4 = Breathe, 5 = ACE-CF, 6 BronchEx): ', 's');

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
elseif studynbr == 5
    study = 'AC';
    studyfullname = 'ACE-CF';
elseif studynbr == 6
    study = 'BE';
    studyfullname = 'BronchEx';
end


end

