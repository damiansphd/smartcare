function [splittbl, splittxt, ntiles, isValid] = createIDSplitList(cdPatient, amInterventions)

% createIDSplitList - choose either gender or age to split by and create 
% the split table accordingly

isValid = true;
nsplitmthd = 3;
ssplitmthd = input('Choose what to split by (1 = Age, 2 = Gender, 3 = Drug Therapy): ', 's');
splitmthd = str2double(ssplitmthd);

if (isnan(splitmthd) || splitmthd < 1 || splitmthd > nsplitmthd)
    fprintf('Invalid choice\n');
    splittbl = [];
    splittxt  = 'N/A';
    ntiles     = 0;
    isValid    = false;
    return;
end

splittbl = outerjoin(amInterventions, cdPatient, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'}, ...
    'LeftVariables', {'SmartCareID', 'DrugTherapy'}, 'RightVariables', {'Age', 'Sex'}, 'Type', 'left');
splittbl = sortrows(splittbl, {'SmartCareID'}, 'ascend');


if splitmthd == 1
    splittbl.NTile(:) = 0;
    %medage = median(splittbl.Age);
    %splittbl.NTile(splittbl.Age <= medage) = 1;
    %splittbl.NTile(splittbl.Age >  medage) = 2;
    splittbl.NTile(splittbl.Age < 6) = 1;
    splittbl.NTile(splittbl.Age >=  6) = 2;
    splittxt = 'Age';
    ntiles = 2;
elseif splitmthd == 2
    splittbl.NTile(:) = 0;
    splittbl.NTile(ismember(splittbl.Sex, 'Female')) = 1;
    splittbl.NTile(ismember(splittbl.Sex, 'Male')) = 2;
    splittxt = 'Gender';
    ntiles = 2;
elseif splitmthd == 3
    splittbl.NTile(:) = 0;
    splittbl.NTile(ismember(splittbl.DrugTherapy, {'None'})) = 1;
    splittbl.NTile(ismember(splittbl.DrugTherapy, {'Ivacaftor', 'Orkambi', 'Symkevi', 'Triple Therapy'})) = 2;
    splittxt = 'DrugTherapy';
    ntiles = 2;
else
    fprintf('Should never get here');
    splittbl = [];
    splittxt  = 'N/A';
    ntiles     = 0;
    isValid = false;
end

end

