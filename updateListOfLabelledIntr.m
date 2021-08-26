function [amlabintr] = updateListOfLabelledIntr(amintr, amlabintr)

% updateListOfLabelledIntr - updates the labelled intr table based on an
% the current interventions table


% first find the labelled interventions that are no longer in
% the list of interventions - just print out that these are being removed (and possibly
% save into a separate file) and then remove

oldlabintr = outerjoin(amlabintr, amintr, 'LeftKeys', {'SmartCareID', 'Hospital', 'IVStartDate', 'IVStopDate'}, ...
                        'RightKeys', {'SmartCareID', 'Hospital', 'IVStartDate', 'IVStopDate'}, ...
                        'RightVariables', {'Ex_Start'});
                    
delkeys = oldlabintr(isnan(oldlabintr.Ex_Start), {'SmartCareID', 'Hospital', 'IVStartDate', 'IVStopDate'});

if size(delkeys, 1) > 0
    fprintf('There are %d previously labelled interventions that are no longer in the list\n', size(delkeys, 1));

    for i = 1:size(delkeys, 1)
        fprintf('ID = %d : Hospital = %6s : IVStart = %11s : IVEnd = %11s\n', delkeys.SmartCareID(i), delkeys.Hospital{i}, ...
                    datestr(delkeys.IVStartDate(i), 1), datestr(delkeys.IVStopDate(i), 1));
        amlabintr(amlabintr.SmartCareID == delkeys.SmartCareID(i) & ismember(amlabintr.Hospital, delkeys.Hospital(i)) & ...
            amlabintr.IVStartDate == delkeys.IVStartDate(i) & amlabintr.IVStopDate == delkeys.IVStopDate(i), :) = [];
    end
end

% join between two tables (outer)
amintr.LowerBound1 = [];
amintr.UpperBound1 = [];
amintr.LowerBound2 = [];
amintr.UpperBound2 = [];
amintr.ConfidenceProb = [];
amintr.Ex_Start    = [];
amintr.Pred        = [];
amintr.RelLB1      = [];
amintr.RelUB1      = [];
amintr.RelLB2      = [];
amintr.RelUB2      = [];

amlabintr = outerjoin(amintr, amlabintr, 'LeftKeys', {'SmartCareID', 'Hospital', 'IVStartDate', 'IVStopDate'}, ...
                        'RightKeys', {'SmartCareID', 'Hospital', 'IVStartDate', 'IVStopDate'}, ...
                        'RightVariables', {'Sparse', 'NoSignal', 'IncludeInTestSet', 'LowerBound1', 'UpperBound1', 'LowerBound2', 'UpperBound2'});
                    
amlabintr.Sparse(~ismember(amlabintr.Sparse, {'Y', 'N'}))                     = 'N';
amlabintr.NoSignal(~ismember(amlabintr.NoSignal, {'Y', 'N'}))                 = 'N';
amlabintr.IncludeInTestSet(~ismember(amlabintr.IncludeInTestSet, {'Y', 'N'})) = 'N';
amlabintr.LowerBound1(isnan(amlabintr.LowerBound1)) = 0;
amlabintr.UpperBound1(isnan(amlabintr.UpperBound1)) = 0;
amlabintr.LowerBound2(isnan(amlabintr.LowerBound2)) = 0;
amlabintr.UpperBound2(isnan(amlabintr.UpperBound2)) = 0;

end

