function [measuremin, measuremax] = getMeasureOverallMinMax(demographicstable, measure)

% getMeasureMinMax - returns the min and max value for a measure across all
% patients and days

column = getColumnForMeasure(measure);
ddcolumn = sprintf('Fun_%s',column);

tempmin = demographicstable{ismember(demographicstable.RecordingType, measure),{ddcolumn}}(:,3);
tempmax = demographicstable{ismember(demographicstable.RecordingType, measure),{ddcolumn}}(:,4);


measuremin = min(tempmin(~isnan(tempmin)));
measuremax = max(tempmax(~isnan(tempmax)));

end

