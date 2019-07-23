function [cdPatient, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, studynbr, study)

% loadAndHarmoniseClinVars - loads clinical variables and standardises
% their naming

tic
basedir = setBaseDir();
fprintf('Loading %s Clinical data\n', study);

if studynbr == 1
    load(fullfile(basedir, subfolder, clinicalmatfile), 'cdPatient', 'cdMicrobiology', 'cdClinicVisits', 'cdPFT', 'cdAdmissions', ...
        'cdAntibiotics', 'cdCRP', 'cdEndStudy', 'cdOtherVisits');
    cdHghtWght = [];
elseif studynbr == 2
    load(fullfile(basedir, subfolder, clinicalmatfile), 'tmPatient', 'tmMicrobiology', 'tmClinicVisits', 'tmPFT', 'tmAdmissions', ...
        'tmAntibiotics', 'tmCRP', 'tmEndStudy');
    cdPatient      = tmPatient;
    cdMicrobiology = tmMicrobiology;
    cdClinicVisits = tmClinicVisits;
    cdPFT          = tmPFT;
    cdAdmissions   = tmAdmissions;
    cdAntibiotics  = tmAntibiotics;
    cdCRP          = tmCRP;
    cdEndStudy     = tmEndStudy;
    cdOtherVisits  = [];
    cdHghtWght = [];
elseif studynbr == 3
    load(fullfile(basedir, subfolder, clinicalmatfile), 'clPatient', 'clMicrobiology', 'clClinicVisits', 'clPFT', 'clAdmissions', ...
        'clAntibiotics', 'clCRP', 'clEndStudy', 'clOtherVisits', 'clHghtWght');
    cdPatient      = clPatient;
    cdMicrobiology = clMicrobiology;
    cdClinicVisits = clClinicVisits;
    cdPFT          = clPFT;
    cdAdmissions   = clAdmissions;
    cdAntibiotics  = clAntibiotics;
    cdCRP          = clCRP;
    cdEndStudy     = clEndStudy;
    cdOtherVisits  = clOtherVisits;
    cdHghtWght     = clHghtWght;
end

toc

end
