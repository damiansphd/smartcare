function [phrowtoadd] = initialiseMeasurementRow(phrowtoadd, id, recordingdate, offset)

% initialiseMeasurementRow - convenience function to initialise measurement
% row during coversion from telemed to smartcare format

phrowtoadd.SmartCareID = id;
phrowtoadd.UserName = sprintf('PAP%d', id);
phrowtoadd.ScaledDateNum = 0;
phrowtoadd.RecordingType = {'To Be Populated'};
phrowtoadd.Date_TimeRecorded = recordingdate + seconds(1);
phrowtoadd.DateNum = ceil(datenum(recordingdate + seconds(1)) - offset);
phrowtoadd.FEV1 = NaN;
phrowtoadd.PredictedFEV = NaN;
phrowtoadd.FEV1_ = NaN;
phrowtoadd.WeightInKg = NaN;
phrowtoadd.O2Saturation = NaN;
phrowtoadd.Pulse_BPM_ = NaN;
phrowtoadd.Rating = NaN;
phrowtoadd.Temp_degC_ = NaN;
phrowtoadd.Activity_Steps = NaN;
phrowtoadd.CalcFEV1SetAs = NaN;
phrowtoadd.ScalingRatio = NaN;
phrowtoadd.CalcFEV1_ = NaN;

end

