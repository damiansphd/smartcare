function [physdata] = addBreatheRowsForLungFcn(physdata, brPatient)

% addBreatheRowsForLungFcn - adds the rows to physdata for Lung Function
% (in units of % Predicted) from the raw FEV1 (in litres) measurements

fprintf('Adding calculated percent predicted FEV1\n');

temprows = physdata(ismember(physdata.RecordingType, 'FEV1Recording'), :);
temprows = outerjoin(temprows, brPatient, 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'}, 'RightVariables', {'CalcPredictedFEV1'}, 'Type', 'left');
temprows.RecordingType(:) = {'LungFunctionRecording'};
temprows.CalcFEV1_ = 100 * temprows.FEV ./ temprows.CalcPredictedFEV1;
temprows.FEV(:) = 0.0;
temprows.CalcPredictedFEV1 = [];

physdata = [physdata; temprows];
fprintf('%d calculated measurements\n', size(temprows, 1));

end

