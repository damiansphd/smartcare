function [abTreatments] = createListOfInterventions(ivandmeasurestable, physdata, offset)

% createListOfInterventions - creates the list of distinct IV Antiobiotic
% treatments in a structure to be used by the alignment model

% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(physdata);

abTreatments = ivandmeasurestable(ivandmeasurestable.DaysWithMeasures >= 20 & ivandmeasurestable.AvgMeasuresPerDay >= 3, {'SmartCareID', 'Hospital', 'IVStartDate', 'IVDateNum'});

% do inner join to reduce to only patients with enough data
abTreatments = innerjoin(patientoffsets, abTreatments);
abTreatments.IVScaledDateNum = datenum(abTreatments.IVStartDate) - offset + 1 - abTreatments.PatientOffset;
abTreatments.InitialOffset = abTreatments.SmartCareID * 0;

end

