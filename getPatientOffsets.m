function [patientoffsettable] = getPatientOffsets(physdata)

% gets the patient offset table
% Convenience function to return offsets for each 
% patient 0 i.e the difference between the actual date and the scaled date
      
physdata.PatientOffset =  physdata.DateNum - physdata.ScaledDateNum;
patientoffsettable = unique(physdata(:,{'SmartCareID','PatientOffset'}));

end

