function [exrelated] = checkTreatmentExRelated(reason, exacerbationreasons)

% checkTreatmentExRelated - return logical true/false if reason is in the
% list of exacerbation related treatment reasons

exrelated = ismember(reason, exacerbationreasons.Reason);

end

