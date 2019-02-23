function plotMeasuresByHour(physdata, smartcareID, imagefilename)

% plotMeasuresByHour - for each measure, plot a histogram of number of 
% measures by hour recorded. For all data (if smartcareid = 0) or for a given
% patient (if smartcareid ~= 0)
% Use this to inform whether to adjust date offset 


% index or rows for smartcare id (all or single patient)
if (smartcareID == 0)
    idxs = find(physdata.SmartCareID);
else
    idxs = find(physdata.SmartCareID == smartcareID);
end

tic
fprintf('Plot number of measures recorded by hour for each measure\n');
fprintf('---------------------------------------------------------\n');

f = figure('Name','MeasuresByHour');
set(gcf, 'Units', 'normalized', 'OuterPosition', [0.2, 0.2, 0.8, 0.8], 'PaperOrientation', 'portrait', 'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, .75], 'PaperType', 'a4');
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = 'Histograms of Measures by Hour'; 
p.TitlePosition = 'centertop';
p.FontSize = 20;
p.FontWeight = 'bold'; 
        
measures = unique(physdata.RecordingType);
for i = 1:size(measures,1)
    m = measures{i};
    idxm = find(ismember(physdata.RecordingType, m));
    idx = intersect(idxs,idxm);
    subplot(3,3,i,'Parent',p);
    histogram(hour(datetime(physdata.Date_TimeRecorded(idx))));
    t = title(sprintf('%s by Hour of Day',m), 'FontSize', 6);
end


subfolder = 'Plots';
savePlotInDir(f, imagefilename, subfolder);
close(f);

toc
fprintf('\n'); 
