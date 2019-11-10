function plotMeasuresByHour(physdata, smartcareID, imagefilename, study)

% plotMeasuresByHour - for each measure, plot a histogram of number of 
% measures by hour recorded. For all data (if smartcareid = 0) or for a given
% patient (if smartcareid ~= 0)
% Use this to inform whether to adjust date offset 

if smartcareID ~= 0
    imagefilename = sprintf('%s - ID %d', imagefilename, smartcareID);
end

% index or rows for smartcare id (all or single patient)
if (smartcareID == 0)
    idxs = physdata.SmartCareID >= 0;
else
    idxs = physdata.SmartCareID == smartcareID;
end

tic
fprintf('Plot number of measures recorded by hour for each measure\n');
fprintf('---------------------------------------------------------\n');

[f, p] = createFigureAndPanel('Histograms of Measures by Hour', 'portrait', 'a4');
        
measures = unique(physdata.RecordingType);
nmeasures = size(measures, 1);
if nmeasures > 12
    plotsacross = 4;
else
    plotsacross = 3;
end
plotsdown = ceil(nmeasures/plotsacross);

for i = 1:nmeasures
    m = measures{i};
    idxm = ismember(physdata.RecordingType, m);
    idx = idxs & idxm;
    ax = subplot(plotsdown, plotsacross, i, 'Parent', p);
    %histogram(hour(datetime(physdata.Date_TimeRecorded(idx))));
    histogram(ax, hour(physdata.Date_TimeRecorded(idx)));
    t = title(ax, m, 'FontSize', 6);
end

basedir = setBaseDir();
subfolder = sprintf('Plots/%s', study);
if ~exist(strcat(basedir, subfolder), 'dir')
    mkdir(strcat(basedir, subfolder));
end
savePlotInDir(f, imagefilename, subfolder);
close(f);

toc
fprintf('\n'); 
