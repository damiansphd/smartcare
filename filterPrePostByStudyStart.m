function [brPrePostPat] = filterPrePostByStudyStart(brPrePostPat, minduration, cutoffd)

% filterPrePostByStudyStart - filters the list of patients, removing those who 
% haven't been on the study for long enough

brPrePostPat(brPrePostPat.StudyDate + calmonths(minduration) > brPrePostPat.PatClinDate, :) = [];
brPrePostPat(brPrePostPat.StudyDate + calmonths(minduration) > cutoffd, :) = [];

end

