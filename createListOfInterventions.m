function [interventions] = createListOfInterventions(ivandmeasurestable, physdata, offset)

% createListOfInterventions - creates the list of distinct IV Antiobiotic
% treatments in a structure to be used by the alignment model

% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(physdata);
maxmeasdate = max(physdata.ScaledDateNum);


interventions = ivandmeasurestable(ivandmeasurestable.DaysWithMeasures >= 15 & ivandmeasurestable.AvgMeasuresPerDay >= 2, ...
    {'SmartCareID', 'Hospital', 'IVStartDate', 'IVDateNum', 'IVStopDate', 'IVStopDateNum', 'Route', 'Type', 'SequentialIntervention', 'DaysWithMeasures', 'AvgMeasuresPerDay'});


% do inner join to reduce to only patients with enough data
interventions = innerjoin(patientoffsets, interventions);
interventions.IVScaledDateNum     = datenum(interventions.IVStartDate) - offset + 1 - interventions.PatientOffset;
interventions.IVScaledStopDateNum = datenum(interventions.IVStopDate)  - offset + 1 - interventions.PatientOffset;
interventions.Offset(:) = 0;
interventions.LatentCurve(:) = 0;

% remove interventions after the end of measurement period
interventions(interventions.IVScaledDateNum>maxmeasdate, :) = [];

end

