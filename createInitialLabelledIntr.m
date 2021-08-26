function [amLabelledInterventions] = createInitialLabelledIntr(amInterventions)

% createInitialLabelledIntr - creates an initial labelled intervention
% table from the current interventions table

amLabelledInterventions = amInterventions;
amLabelledInterventions.LowerBound1 = [];
amLabelledInterventions.UpperBound1 = [];
amLabelledInterventions.LowerBound2 = [];
amLabelledInterventions.UpperBound2 = [];
amLabelledInterventions.ConfidenceProb = [];
amLabelledInterventions.Ex_Start    = [];
amLabelledInterventions.Pred        = [];
amLabelledInterventions.RelLB1      = [];
amLabelledInterventions.RelUB1      = [];
amLabelledInterventions.RelLB2      = [];
amLabelledInterventions.RelUB2      = [];

amLabelledInterventions.Sparse(:)            = 'N';
amLabelledInterventions.NoSignal(:)          = 'N';
amLabelledInterventions.IncludeInTestSet(:)  = 'N';
amLabelledInterventions.LowerBound1(:)       = 0;
amLabelledInterventions.UpperBound1(:)       = 0;
amLabelledInterventions.LowerBound2(:)       = 0;
amLabelledInterventions.UpperBound2(:)       = 0;

end

