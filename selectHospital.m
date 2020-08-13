function [hosprow, isValid] = selectHospital()

% selectHospital - choose which hospital to run for

isValid = true;
brhosp = getListOfBreatheHospitals();
nhospitals = size(brhosp, 1);

shospnbr = input('Enter Hospital to run for (1 = Papworth, 2 = Cardiff): ', 's');

hospnbr = str2double(shospnbr);

if (isnan(hospnbr) || hospnbr < 1 || hospnbr > nhospitals)
    fprintf('Invalid choice\n');
    hosprow = [];
    isValid = false;
    return;
end

hosprow = brhosp(hospnbr, :);

end

