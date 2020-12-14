function [brEligPat, brEligDT] = filterPrePostByDrugTherapy(brPrePostPat, brPrePostDT, minduration)

% filterPrePostByDrugTherapy - filters the list of patients, removing those
% who started CFTR modulator therapy within the analysis period

tempPatDT   = outerjoin(brPrePostPat, brPrePostDT, 'LeftKeys', {'ID'}, 'RightKeys', {'ID'}, 'RightVariables', {'DrugTherapyStartDate', 'DrugTherapyType', 'DrugTherapyComment'});

% first find patients not on cftr modulator therapies
notreatmentid = unique(tempPatDT.ID(isnat(tempPatDT.DrugTherapyStartDate)));
nnotreatpats = size(notreatmentid, 1);
fprintf('Total patients not on treatment = %d    ***\n', nnotreatpats);

% next get all patients who have changed modulator therapies within
% analysis window
excl6mid = unique(tempPatDT.ID((tempPatDT.DrugTherapyStartDate >= (tempPatDT.StudyDate - calmonths(minduration))) ...
                & (tempPatDT.DrugTherapyStartDate < (tempPatDT.StudyDate + calmonths(minduration)))));

% of remainder, find those who started a therapy before analysis window            
ontreatpre6mnochangeid = unique(tempPatDT.ID(~ismember(tempPatDT.ID, excl6mid) ...
                & (tempPatDT.DrugTherapyStartDate < (tempPatDT.StudyDate - calmonths(minduration)))));
nontreatpre6mnochange = size(ontreatpre6mnochangeid, 1);
fprintf('Total started earlier than %2dm pre study date = %d    ***\n', minduration, nontreatpre6mnochange);

% and those who only started a therapy after the analysis window
ontreatpost6mnochangeid = unique(tempPatDT.ID(~ismember(tempPatDT.ID, excl6mid) ...
                & ~ismember(tempPatDT.ID, ontreatpre6mnochangeid) ...
                & (tempPatDT.DrugTherapyStartDate >= (tempPatDT.StudyDate + calmonths(minduration)))));
nontreatpost6mnochange = size(ontreatpost6mnochangeid, 1);
fprintf('Total started/changed later than %2dm post study date = %d    ***\n', minduration, nontreatpost6mnochange);

eligid = [notreatmentid; ontreatpre6mnochangeid; ontreatpost6mnochangeid];
neligid = size(eligid, 1);
fprintf('Eligible patients with +/-%2dm criterion = %d    ***\n', minduration, neligid);

brEligPat = brPrePostPat(ismember(brPrePostPat.ID, eligid), :);
brEligDT = brPrePostDT(ismember(brPrePostDT.ID, eligid), :);

end

