function [datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study)

% getRawDataFilenamesForStudy - return filenames for raw data files for
% measurement and clinical data

demographicsmatfile = sprintf('%sdatademographicsbypatient.mat', study);

if ismember(study, 'SC')
    clinicalmatfile = 'clinicaldata.mat';
    datamatfile     = 'smartcaredata.mat';
elseif ismember(study, 'TM')
    clinicalmatfile = 'telemedclinicaldata.mat';
    datamatfile     = 'telemeddata.mat';
elseif ismember(study, 'CL')
    clinicalmatfile = 'climbclinicaldata.mat';
    datamatfile     = 'climbdata.mat';
elseif ismember(study, 'BR')
    clinicalmatfile = 'breatheclinicaldata.mat';
    datamatfile     = 'breathedata.mat';
else
    fprintf('Invalid study\n');
    clinicalmatfile = 'unknown';
    datamatfile     = 'unknown';
    return;
end

end

