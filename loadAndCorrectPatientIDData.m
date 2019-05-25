function [patientid] = loadAndCorrectPatientIDData(patientidfile)

% loadPatientIDData - loads patientidfile and corrects for incorrect 
% Patient_ID fields

tic
fprintf('Loading Patient ID file: %s\n', patientidfile);
fprintf('---------------------------------------\n');
patientid = readtable(patientidfile);
patientid.Properties.Description = 'Table containing mapping of UserID to SmartCareID';
patientid.Properties.VariableNames{3} = 'SmartCareID';
fprintf('Patient ID data has %d rows\n', size(patientid,1));

badids = table({'TKpptiCA5cASNKU0VSmx4' ;'Cujq-NEcld_Keu_W1-Nw5' ; 'Q0Wf614z94DSTy6nXjyw7';'0HeWh64M_zc5U512xqzAs4';'1au5biSTt0bNWgfl0Wltr5'}, ... 
               {'-TKpptiCA5cASNKU0VSmx4';'-Cujq-NEcld_Keu_W1-Nw5';'-Q0Wf614z94DSTy6nXjyw7';'0HeWh64M_zc5U5l2xqzAs4';'1au5biSTt0bNWgfI0WItr5'}, ...
               'VariableNames', {'Patient_ID','Correct_ID'});
idx = find(ismember(patientid(:,'Patient_ID'), badids(:,'Patient_ID')));
fprintf('Updating incorrect Patient IDs - %d rows\n', size(idx,1));
for i = 1:size(idx,1)
    patientid.Patient_ID{idx(i)} = badids.Correct_ID{i};
end

% hard code this one as it had a trailing ' at the end of the id causing
% mismatches - no longer needed, fixed in input s/s
%fprintf('Updating incorrect Patient ID: h503el8mUI5hP-fwcnonk6 \n');
%patientid.Patient_ID{23} = 'h503el8mUI5hP-fwcnonk6';
%toc

fprintf('\n');

end

