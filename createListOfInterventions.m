function [interventions] = createListOfInterventions(ivandmeasurestable, physdata, offset)

% creates the list of distinct IV Antiobiotic treatments in a structure to be used by the alignment model
% 
% - filters treatments containing too much missing data
% - adds new columns to be populated during model run
% 
% Input:
% ------
% ivandmeasurestable      list of oral & IV treatments
% physdata, offset        measurements data
% 
% Output:
% -------
% table with final treatment list

% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(physdata);
maxmeasdate = max(physdata.ScaledDateNum);


%interventions = ivandmeasurestable(ivandmeasurestable.DaysWithMeasures >= 15 & ivandmeasurestable.AvgMeasuresPerDay >= 2, ...
%    {'SmartCareID', 'Hospital', 'IVStartDate', 'IVDateNum', 'IVStopDate', 'IVStopDateNum', 'Route', 'Type', 'SequentialIntervention', 'DaysWithMeasures', 'AvgMeasuresPerDay'});

% now we are looking more precisely at only the select measures we use for
% the data window (25 days), we can use total measures >= 50 - which really
% means on average 2 measurements per day (and 2 come from fitbit
% automatically - so still very generous on data completeness
interventions = ivandmeasurestable(ivandmeasurestable.TotalMeasures >= 50, ...
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

