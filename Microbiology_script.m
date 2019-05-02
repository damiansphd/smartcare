
study = 'SC';
clinicalmatfile = 'clinicaldata.mat';
basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
fprintf('Loading clinical microbiology data\n');
load(fullfile(basedir, subfolder, clinicalmatfile), 'cdMicrobiology');

temp = array2table(unique(lower(cdMicrobiology.Microbiology)));

temp_staph = array2table(temp.Var1(contains(temp.Var1, 'staph')));
temp_pseud = array2table(temp.Var1(contains(temp.Var1, 'pseud')));
temp_other = array2table(temp.Var1(~contains(temp.Var1, {'staph','pseud'})));

subfolder = 'ExcelFiles';
outputfilename = 'Microbiology details.xlsx';
writetable(temp_pseud, fullfile(basedir, subfolder, outputfilename), 'Sheet', 'Pseudomonas');
writetable(temp_staph, fullfile(basedir, subfolder, outputfilename), 'Sheet', 'Staphylococcus');
writetable(temp_other, fullfile(basedir, subfolder, outputfilename), 'Sheet', 'Other');

