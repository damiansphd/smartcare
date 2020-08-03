function [splittbl, splittxt, ntiles, isValid] = createIDSplitList(pmPatients)

% createIDSplitList - choose either gender or age to split by and create 
% the split table accordingly

isValid = true;
nsplitmthd = 2;
ssplitmthd = input('Choose what to split by (1 = Age, 2 = Gender): ', 's');
splitmthd = str2double(ssplitmthd);

if (isnan(splitmthd) || splitmthd < 1 || splitmthd > nsplitmthd)
    fprintf('Invalid choice\n');
    splittbl = [];
    splittxt  = 'N/A';
    ntiles     = 0;
    isValid    = false;
    return;
end

if splitmthd == 1
    splittbl  = pmPatients(:, {'PatientNbr', 'Study', 'ID', 'Age'});
    splittbl = sortrows(splittbl, {'Age'}, 'ascend');
    splittbl.NTile(:) = 0;
    %medage = median(splittbl.Age);
    %splittbl.NTile(splittbl.Age <= medage) = 1;
    %splittbl.NTile(splittbl.Age >  medage) = 2;
    splittbl.NTile(splittbl.Age < 6) = 1;
    splittbl.NTile(splittbl.Age >=  6) = 2;
    splittbl = sortrows(splittbl, {'Study', 'ID'}, 'ascend');
    splittxt = 'Age';
    ntiles = 2;
elseif splitmthd == 2
    splittbl  = pmPatients(:, {'PatientNbr', 'Study', 'ID', 'Sex'});
    splittbl.NTile(:) = 0;
    splittbl.NTile(ismember(splittbl.Sex, 'Female')) = 1;
    splittbl.NTile(ismember(splittbl.Sex, 'Male'))   = 2;
    splittbl = sortrows(splittbl, {'Study', 'ID'}, 'ascend');
    splittxt = 'Gender';
    ntiles = 2;
else
    fprintf('Should never get here');
    splittbl = [];
    splittxt  = 'N/A';
    ntiles     = 0;
    isValid = false;
end

end

