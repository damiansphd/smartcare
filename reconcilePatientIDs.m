clc; clear; close all;

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
clinicalmatfile = 'clinicaldata.mat';
fprintf('Loading clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
datamatfile = 'smartcaredataPreIDMismatchFix.mat';
fprintf('Loading old patient and measurement data\n');
load(fullfile(basedir, subfolder, datamatfile), 'patientid');

patientidold = patientid;

datamatfile = 'smartcaredata.mat';
fprintf('Loading new patient and measurement data\n');
load(fullfile(basedir, subfolder, datamatfile));

temppatidnew = patientid;
for n = 1:size(temppatidnew, 1)
    temppatidnew.Study_ID{n} = upper(temppatidnew.Study_ID{n});
end
temppatid    = patientidold;
for n = 1:size(temppatid, 1)
    temppatid.Study_ID{n} = upper(temppatid.Study_ID{n});
end

temp = outerjoin(temppatidnew, temppatid, 'LeftKeys', {'Study_ID'}, 'RightKeys', {'Study_ID'});

mismatchids = temp(temp.SmartCareID_temppatidnew ~= temp.SmartCareID_temppatid,:);
fprintf('\n');
fprintf('Potentially %d mismatched ids in previous dataset\n', size(mismatchids, 1));

for i = 1:size(mismatchids, 1)
    measurecount = sum(physdata.SmartCareID == mismatchids.SmartCareID_temppatidnew(i));
    measurecount2 = sum(ismember(physdata_original.UserID, mismatchids.Patient_ID_temppatidnew(i)));
    
    fprintf('For SmartCareID %3d (old id = %3d, measure count orig = %5d measure count pre-proc %5d\n', mismatchids.SmartCareID_temppatidnew(i), mismatchids.SmartCareID_temppatid(i), measurecount2, measurecount);

end

%cdAntibiotics(ismember(cdAntibiotics.ID, [193, 195, 196, 197, 198, 199, 201]),:)