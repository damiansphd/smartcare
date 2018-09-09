function compareModelRunToTestData(amLabelledInterventions, modelrun, modelidx, models)

% compareMultipleModelRunToTestData - compares the output of multiple model runs to
% the labelled test data (but doesn't plot results)

amLabelledInterventions = [array2table([1:size(amLabelledInterventions,1)]'), amLabelledInterventions];
amLabelledInterventions.Properties.VariableNames{'Var1'} = 'InterNbr';

testidx = amLabelledInterventions.IncludeInTestSet=='Y';

basedir = './';
subfolder = 'MatlabSavedVariables';

for midx = modelidx:size(models,1)
    if ~isequal(models{midx}, 'placeholder')
        load(fullfile(basedir, subfolder, sprintf('%s.mat', models{midx})));

        modeloffsets = offsets(testidx);
        testset = amLabelledInterventions(testidx,:);
        testsetsize = size(testset,1);
        testset_ex_start = testset.ExStart(1);

        diff_ex_start = testset_ex_start - ex_start;

        matchidx = ((modeloffsets >= (testset.LowerBound + diff_ex_start)) & (modeloffsets <= (testset.UpperBound + diff_ex_start)));
        if diff_ex_start < 0
            matchidx2 = (modeloffsets >= max_offset + diff_ex_start) & (testset.UpperBound == max_offset - 1);
        elseif diff_ex_start > 0
          matchidx2 = (modeloffsets <= min_offset + diff_ex_start) & (testset.LowerBound == min_offset);
        else
           matchidx2 = (modeloffsets == -10);
        end
        matchidx = matchidx | matchidx2;

        fprintf('For model %d: %s:\n', midx, models{midx});
        fprintf('%2d of %2d results match labelled test data\n', sum(matchidx), testsetsize);
        fprintf('\n');
    end
end
    
end

