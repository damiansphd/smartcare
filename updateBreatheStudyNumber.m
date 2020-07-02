
%brPatient.StudyEmail{ismember(brPatient.StudyNumber, '4386')} = 'projectb.4386@gmail.com';

%brPatient.StudyNumber = brPatient.StudyEmail;

% save output files
tic
fprintf('\n');
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
outputfilename = 'breatheclinicaldata.mat';
fprintf('Saving output variables to file %s\n', outputfilename);
save(fullfile(basedir, subfolder,outputfilename), 'brPatient', 'brAdmissions', 'brAntibiotics', ...
    'brClinicVisits', 'brOtherVisits', 'brUnplannedContact', ...
    'brPFT', 'brCRP', 'brHghtWght', 'brMicrobiology', 'brEndStudy');
toc