
clc; clear; close all;

basedir = setBaseDir();
clinicalmatfile = 'clinicaldata.mat';
subfolder = 'MatlabSavedVariables';
fprintf('Loading clinical data\n');
load(fullfile(basedir, subfolder, clinicalmatfile));
datamatfile = 'smartcaredata.mat';
fprintf('Loading measurement data\n');
load(fullfile(basedir, subfolder, datamatfile));

subfolder = 'DataFiles';
patientidxlsxfile = 'PatientIDs.xlsx';
patientidnew = readtable(fullfile(basedir, subfolder, patientidxlsxfile));
patientidnew.SmartCareID(:) = -1;

npatids = size(patientidnew, 1);

hospitals   = [{'BRISTOL' } ;
               {'BROMP'   } ;
               {'FRIMLEYP'} ;
               {'KINGSCOL'} ;
               {'LEEDS'   } ;
               {'PAP'     } ;
               {'SOUTHAM' }];
           
hospstdytxt = [{'BRISTOLSC'} ;
               {'Brompton'   } ;
               {'FPH'        } ;
               {'Kings'      } ;
               {'Leeds'      } ;
               {'Papworth'   } ;
               {'Wessex'     }];

nhospitals = size(hospitals, 1);
           
for p = 1:npatids
    for i = 1:nhospitals
        if strfind(patientidnew.Study_ID{p}, hospstdytxt{i})
            break
        end
    end
    % remove hospital study text
    scidstr = strrep(patientidnew.Study_ID{p}, hospstdytxt{i}, '  ');
    % remove zero padding
    scidstr = strrep(scidstr, '  000', '');
    scidstr = strrep(scidstr, '  00', '');
    scidstr = strrep(scidstr, '  0', '');
    % fix kings anomaly
    scidstr = strrep(scidstr, 'v2', '');
    % fix leeds anomalies
    scidstr = strrep(scidstr, '1642a', '1642');
    scidstr = strrep(scidstr, '1730', '173');
    scidstr = strrep(scidstr, '1523a', '01523a');
    
    
    fprintf('For patientID row %3d, found hospstdy text %9s - %12s to %6s ', p, hospstdytxt{i}, patientidnew.Study_ID{p}, scidstr);
    
    patrow = cdPatient(ismember(cdPatient.Hospital, hospitals(i)) & ismember(cdPatient.StudyNumber, scidstr), :);
    if size(patrow, 1) == 1
        fprintf('Hospital %8s, Study Number %6s, ID %3d\n', patrow.Hospital{1}, patrow.StudyNumber{1}, patrow.ID);
        patientidnew.SmartCareID(p) = patrow.ID;
    elseif size(patrow, 1) > 1
        fprintf('***** MULTIPLE MATCHES - INVESTIGATE ******\n');
    elseif size(patrow, 1) == 0
        fprintf('***** NO MATCHES - INVESTIGATE ******\n');
    else
        fprintf('***** SHOULD NOT GET HERE - INVESTIGATE ******\n');
    end
    
end

writetable(patientidnew, fullfile(basedir, 'DataFiles', sprintf('%s.xlsx', 'patientidnew')));

temppatidnew = patientidnew;
for n = 1:size(temppatidnew, 1)
    temppatidnew.Study_ID{n} = upper(temppatidnew.Study_ID{n});
end
temppatid    = patientid;
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

cdAntibiotics(ismember(cdAntibiotics.ID, [193, 195, 196, 197, 198, 199, 201]),:)
