newrealcube= NaN(300,650,6);
[c d] = size(newphysdata);

for i=1:c
            if isequal(newphysdata.RecordingType(i), cellstr('ActivityRecording'))
                newrealcube(newphysdata.SmartCareID(i),newphysdata.DateNum(i),1) = newphysdata.Activity_Steps(i);
            elseif isequal(newphysdata.RecordingType(i), cellstr('CoughRecording'))
                newrealcube(newphysdata.SmartCareID(i),newphysdata.DateNum(i),2) = round(newphysdata.Rating(i)/10);
            elseif isequal(newphysdata.RecordingType(i), cellstr('LungFunctionRecording'))
                newrealcube(newphysdata.SmartCareID(i),newphysdata.DateNum(i),3) = newphysdata.CalcFEV1_(i);
            elseif isequal(newphysdata.RecordingType(i), cellstr('O2SaturationRecording'))
               newrealcube(newphysdata.SmartCareID(i),newphysdata.DateNum(i),4) = newphysdata.O2Saturation(i);
            elseif isequal(newphysdata.RecordingType(i), cellstr('PulseRateRecording'))
                newrealcube(newphysdata.SmartCareID(i),newphysdata.DateNum(i),5) = newphysdata.Pulse_BPM_(i);
            elseif isequal(newphysdata.RecordingType(i), cellstr('WellnessRecording'))
                newrealcube(newphysdata.SmartCareID(i),newphysdata.DateNum(i),6) = round(newphysdata.Rating(i)/10);
            end
end