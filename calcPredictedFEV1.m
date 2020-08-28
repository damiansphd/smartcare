function [predfev1] = calcPredictedFEV1(age, height, sex)

% calcPredictedFEV1 - returns the predicted fev1 from age (yrs), height (m)
% sex (Male, Female)

if ismember(sex, 'Male') || ismember(sex, 'male')
    predfev1 = (height * 0.01 * 4.3) - (age * 0.029) - 2.49;
elseif ismember(sex, 'Female') || ismember(sex, 'female')
    predfev1 = (height * 0.01 * 3.95) - (age * 0.025) - 2.6;
else
    fprintf('*** Unknown gender ***/n');
    predfev1 = -1;
end
    

end

