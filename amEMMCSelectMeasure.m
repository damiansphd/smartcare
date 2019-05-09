function [measure] = amEMMCSelectMeasure(measures, nmeasures)

% amEMMCSelectMeasure - select a given measure

fprintf('Available Measures\n');
fprintf('------------------\n');
for m = 1:nmeasures
    fprintf('%2d: %s\n', m, measures.DisplayName{m});
end
fprintf('\n');

smeasure = input(sprintf('Choose measure (1-%d) ? ', nmeasures), 's');

measure = str2double(smeasure);

if (isnan(measure) || measure < 1 || measure > nmeasures)
    fprintf('Invalid choice\n');
    measure = 0;
    return;
end

end

