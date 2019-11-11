function [datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(studynbr, study)

% getRawDataFilenamesForStudy - return filenames for raw data files for
% measurement and clinical data

demographicsmatfile = sprintf('%sdatademographicsbypatient.mat', study);

if studynbr == 1
    clinicalmatfile = 'clinicaldata.mat';
    datamatfile     = 'smartcaredata.mat';
elseif studynbr == 2
    clinicalmatfile = 'telemedclinicaldata.mat';
    datamatfile     = 'telemeddata.mat';
elseif studynbr == 3
    clinicalmatfile = 'climbclinicaldata.mat';
    datamatfile     = 'climbdata.mat';
elseif studynbr == 4
    clinicalmatfile = 'breatheclinicaldata.mat';
    datamatfile     = 'breathedata.mat';
else
    fprintf('Invalid study\n');
    clinicalmatfile = 'unknown';
    datamatfile     = 'unknown';
    return;
end

end

