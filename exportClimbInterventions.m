


load(fullfile(basedir, subfolder, 'climbclinicaldata.mat'), 'clPatient');

temp = innerjoin(amInterventions, clPatient, 'LeftKeys', 'SmartCareID', 'RightKeys', 'ID', 'RightVariables', {'StudyNumber'});

writetable(temp, fullfile(basedir, 'ExcelFiles', 'ClimbInterventions.xlsx'));