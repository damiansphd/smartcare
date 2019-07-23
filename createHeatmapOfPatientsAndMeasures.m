function [f] = createHeatmapOfPatientsAndMeasures(patientmeasures, colors, title)

% createHeatmapOfPatientsAndMeasures - given a table of SmartCareID's and 
% ScaledDateNum's corresponding to measurements, creates a heatmap to 
% visualise the data


dispmin = min(patientmeasures.SmartCareID);
dispmax = max(patientmeasures.SmartCareID);

% add dummy rows to create a record for every day in the range of the data
% so the heatmap is scaled correctly for missing days
% but excluded from display limits so the row doesn't show on the heatmap
dummyrows = max(patientmeasures.ScaledDateNum);
dummymeasures = table('Size',[dummyrows 2], 'VariableTypes', {'int32', 'int32'}, 'VariableNames', {'SmartCareID', 'ScaledDateNum'});
dummymeasures.SmartCareID(:) = 0;
for i = 1:dummyrows
    dummymeasures.ScaledDateNum(i) = i;
end
patientmeasures = [patientmeasures;dummymeasures];


% create and format heatmap
[f, p] = createFigureAndPanel(title, 'portrait', 'a4');
h = heatmap(p, patientmeasures, 'ScaledDateNum', 'SmartCareID', 'Colormap', colors, 'MissingDataColor', 'white');
h.Title = ' ';
h.XLabel = 'Days';
h.YLabel = 'Patients';
h.YLimits = {dispmin,dispmax};
h.CellLabelColor = 'none';
h.GridVisible = 'off';

end
