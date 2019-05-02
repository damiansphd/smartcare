function [modelversion] = amEMMCSelectModelVersion()

% amEMMCSelectModelVersion - select a model version from list

fprintf('Pick Model Version\n');
fprintf('------------------\n');
fprintf(' 1: EMv4 Single Latent curve set\n');
fprintf(' 2: EMvFEV1Split Single Latent curve set\n');
fprintf(' 3: EMv5 Single Latent curve set\n');
fprintf(' 4: EM Multiple Latent Curve sets\n');

smodelset = input('Choose model set (1-4) ', 's');

modelset = str2double(smodelset);

if (isnan(modelset) || modelset < 1 || modelset > 4)
    fprintf('Invalid choice\n');
    return;
end

if modelset == 1
    modelversion = 'vEM4';
elseif modelset == 2
    modelversion = 'FEV1Split';
elseif modelset == 3
    modelversion = 'vEM5';
elseif modelset == 4
    modelversion = 'vEMMC';
else
    fprintf('Should not get here\n');
end

end

