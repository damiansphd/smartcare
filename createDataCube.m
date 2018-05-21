function [datacube] = createDataCube(physdata, npatients, ndays, nmeasures)

% createDataCube - populates a 3D array from the measurement data of
% appropriate size
datacube = NaN(npatients, ndays, nmeasures);

for i=1:size(physdata,1);
    if isequal(physdata.RecordingType{i}, 'ActivityRecording')
        datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i),1) = physdata.Activity_Steps(i);
        
    elseif isequal(physdata.RecordingType{i}, 'CoughRecording')
        datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i),2) = physdata.Rating(i);
        
    elseif isequal(physdata.RecordingType{i}, 'LungFunctionRecording')
        datacube(physdata.SmartCareID(i), physdata.ScaledDateNum(i),3) = physdata.CalcFEV1_(i);
        
    elseif isequal(physdata.RecordingType{i}, 'O2SaturationRecording')
        datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i),4) = physdata.O2Saturation(i);
        
    elseif isequal(physdata.RecordingType{i}, 'PulseRateRecording')
        datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i),5) = physdata.Pulse_BPM_(i);
        
    elseif isequal(physdata.RecordingType{i}, 'SleepActivityRecording')
        datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i),6) = physdata.Rating(i);
        
    elseif isequal(physdata.RecordingType{i}, 'TemperatureRecording')
        datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i),7) = physdata.Temp_degC_(i);
        
    elseif isequal(physdata.RecordingType{i}, 'WeightRecording')
        datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i),8) = physdata.WeightInKg(i);
        
    elseif isequal(physdata.RecordingType{i}, 'WellnessRecording')
        datacube(physdata.SmartCareID(i),physdata.ScaledDateNum(i),9) = physdata.Rating(i);
        
    end
    
end

end

