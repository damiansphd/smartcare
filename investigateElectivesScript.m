
tempintr = amInterventions(:, {'IntrNbr', 'SmartCareID', 'IVStartDate', 'IVStopDate', 'IVScaledDateNum', 'IVScaledStopDateNum', 'Offset'});

tempintr.LowerBound1 = amLabelledInterventions.LowerBound1;
tempintr.UpperBound1 = amLabelledInterventions.UpperBound1;
tempintr.LowerBound2 = amLabelledInterventions.LowerBound2;
tempintr.UpperBound2 = amLabelledInterventions.UpperBound2;

tempintr(tempintr.Offset == 24 | tempintr.UpperBound1 == -1, :)
