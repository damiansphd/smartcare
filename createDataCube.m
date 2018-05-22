function [datacube, normcube] = createDataCube(physdata, measures, demographicstable, npatients, ndays, nmeasures)

% createDataCube - populates a 3D array from the measurement data of
% appropriate size
datacube = NaN(npatients, ndays, nmeasures);

physdata = innerjoin(physdata, measures, 'LeftKeys', {'RecordingType'}, 'RightKeys', {'Name'});

for i=1:size(physdata,1)
    scid = physdata.SmartCareID(i);
    measure = physdata.RecordingType(i);
    scaleddn = physdata.ScaledDateNum(i);
    index = physdata.Index(i);
    column = physdata.Column{i};
    ddcolumn = sprintf('Fun_%s',column);
    mid50mean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(5);
    mid50std = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(6);
    %datacube(physdata.SmartCareID(i), physdata.ScaledDateNum(i), physdata.Index(i)) = physdata{i, {physdata.Column{i}}};
    datacube(scid, scaleddn, index) = physdata{i, {column}};
    normcube(scid, scaleddn, index) = (datacube(scid, scaleddn, index) - mid50mean)/mid50std;
   % if isequal(physdata.RecordingType(i), cellstr('ActivityRecording'))
   %     datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i), physdata.Index(i)) = physdata.Activity_Steps(i);
        
   % elseif isequal(physdata.RecordingType(i), cellstr('CoughRecording'))
   %     datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i), physdata.Index(i)) = physdata.Rating(i);
        
   % elseif isequal(physdata.RecordingType(i), cellstr('LungFunctionRecording'))
   %     datacube(physdata.SmartCareID(i), physdata.ScaledDateNum(i), physdata.Index(i)) = physdata.CalcFEV1_(i);
        
   % elseif isequal(physdata.RecordingType(i), cellstr('O2SaturationRecording'))
   %     datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i), physdata.Index(i)) = physdata.O2Saturation(i);
        
   % elseif isequal(physdata.RecordingType(i), cellstr('PulseRateRecording'))
   %     datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i), physdata.Index(i)) = physdata.Pulse_BPM_(i);
        
   % elseif isequal(physdata.RecordingType(i), cellstr('SleepActivityRecording'))
   %     datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i), physdata.Index(i)) = physdata.Rating(i);
        
   % elseif isequal(physdata.RecordingType(i), cellstr('TemperatureRecording'))
   %     datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i), physdata.Index(i)) = physdata.Temp_degC_(i);
        
   % elseif isequal(physdata.RecordingType(i), cellstr('WeightRecording'))
   %     datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i), physdata.Index(i)) = physdata.WeightInKg(i);
        
   % elseif isequal(physdata.RecordingType(i), cellstr('WellnessRecording'))
   %     datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i), physdata.Index(i)) = physdata.Rating(i);
        
   % end
    
    if (round(i/10000) == i/10000)
        fprintf('Processed %5d rows\n', i);
    end
end

end

