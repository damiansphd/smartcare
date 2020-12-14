function [cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght, cdMedications, cdNewMeds, cdUnplannedContact] ...
            = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study)

% loadAndHarmoniseClinVars - loads clinical variables and standardises
% their naming

tic
basedir = setBaseDir();
fprintf('Loading %s Clinical data\n', study);

if ismember(study, 'SC')
    load(fullfile(basedir, subfolder, clinicalmatfile), 'cdPatient', 'cdMicrobiology', 'cdClinicVisits', 'cdPFT', 'cdAdmissions', ...
        'cdAntibiotics', 'cdCRP', 'cdEndStudy', 'cdOtherVisits', 'cdMedications', 'cdNewMeds');
    cdDrugTherapy      = [];
    cdHghtWght         = [];
    cdUnplannedContact = [];
elseif ismember(study, 'TM')
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
    cdDrugTherapy  = [];
    cdOtherVisits  = [];
    cdHghtWght     = [];
    cdMedications  = [];
    cdNewMeds      = [];
    cdUnplannedContact = [];
elseif ismember(study, 'CL')
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
    cdDrugTherapy  = [];
    cdMedications  = [];
    cdNewMeds      = [];
    cdUnplannedContact = [];
elseif ismember(study, 'BR')
    load(fullfile(basedir, subfolder, clinicalmatfile), 'brPatient', 'brDrugTherapy', 'brMicrobiology', 'brClinicVisits', 'brPFT', 'brAdmissions', ...
        'brAntibiotics', 'brCRP', 'brEndStudy', 'brOtherVisits', 'brHghtWght', 'brUnplannedContact');
    cdPatient      = brPatient;
    cdDrugTherapy  = brDrugTherapy;
    cdMicrobiology = brMicrobiology;
    cdClinicVisits = brClinicVisits;
    cdPFT          = brPFT;
    cdAdmissions   = brAdmissions;
    cdAntibiotics  = brAntibiotics;
    cdCRP          = brCRP;
    cdEndStudy     = brEndStudy;
    cdOtherVisits  = brOtherVisits;
    cdHghtWght     = brHghtWght;
    cdMedications  = [];
    cdNewMeds      = [];
    cdUnplannedContact = brUnplannedContact;
end

toc

end

