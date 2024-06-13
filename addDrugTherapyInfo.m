function amInterventions = addDrugTherapyInfo(amInterventions, cdDrugTherapy)

% addDrugTherapyInfo - adds a column to the interventions table to store
% what CFTR modulator therapy the patient was on at the time of the
% intervention (if any)

fprintf('Adding drug therapy info\n');

% add the new column with a default value of None
amInterventions.DrugTherapy(:) = {'None'};

for i = 1:size(amInterventions, 1)
    patdt = cdDrugTherapy(cdDrugTherapy.ID == amInterventions.SmartCareID(i), :);
    if size(patdt, 1) > 0
        % revised logic - assume it takes 14 days to see the effect of drug
        % therapy, so adjust drug therapy start date accordingly
        patdtidx = find((patdt.DrugTherapyStartDate + days(14)) < amInterventions.IVStartDate(i), 1, 'last');
        if size(patdtidx, 1) > 0
            amInterventions.DrugTherapy(i) = harmoniseDrugTherapyName(patdt.DrugTherapyType(patdtidx)); 
        end
    end
    fprintf('Intr %3d (%3d/%11s): %s\n', i, amInterventions.SmartCareID(i), datestr(amInterventions.IVStartDate(i),1), amInterventions.DrugTherapy{i});
end

fprintf('\n');

end

