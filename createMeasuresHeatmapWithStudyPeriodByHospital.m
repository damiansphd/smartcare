function createMeasuresHeatmapWithStudyPeriodByHospital(physdata, offset, cdPatient)

% createMeasuresHeatmapWithStudyPeriod - creates the Patient/Measures
% heatmap, and overlays study period start and end

basedir = setBaseDir();
subfolder = 'Plots';

temp = hsv;
brightness = .75;
%colors(1,:)  = [0 0 0];     % black for no measures
colors(1,:)  = temp(4,:)  .* brightness;
colors(2,:)  = temp(6,:)  .* brightness;
colors(3,:)  = temp(8,:)  .* brightness;
colors(4,:)  = temp(10,:) .* brightness;
colors(5,:)  = temp(12,:) .* brightness;
colors(6,:)  = temp(14,:) .* brightness;
colors(7,:)  = temp(16,:) .* brightness;
colors(8,:)  = temp(18,:) .* brightness;
colors(9,:)  = temp(20,:) .* brightness;
colors(10,:)  = [1 0 1];

% get the date scaling offset for each patient
patientoffsets = getPatientOffsets(physdata);

% create a table of counts of measures by patient/day (@max function here
% is irrelevant as we just want the group counts
pdcountmtable = varfun(@max, physdata(:, {'SmartCareID','ScaledDateNum'}), 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});

% extract study date and join with offsets to keep only those patients who
% have enough data (ie the patients left after outlier date handling
patientstudydate = sortrows(cdPatient(:,{'Hospital', 'ID', 'StudyDate'}), 'ID', 'ascend');
patientstudydate.Properties.VariableNames{'ID'} = 'SmartCareID';
patientstudydate = innerjoin(patientoffsets, patientstudydate);

% create a scaleddatenum to translate the study date to the same normalised
% scale as measurement data scaled date num
patientstudydate.ScaledDateNum = datenum(patientstudydate.StudyDate) - offset - patientstudydate.PatientOffset;

% add rows to the count table to mark the study start and end dates (use a count
% of 10 to allow it to be highlighted in a different colour on the heatmap
studyduration = 183;
fixedcount = ones(size(patientstudydate,1),1)*10;
fixedcount = array2table(fixedcount);
fixedcount.Properties.VariableNames{'fixedcount'} = 'GroupCount';
rowstoadd = [patientstudydate(:,{'SmartCareID', 'ScaledDateNum'}) fixedcount];   
pdcountmtable = [pdcountmtable ; rowstoadd];
rowstoadd.ScaledDateNum = rowstoadd.ScaledDateNum + studyduration;
pdcountmtable = [pdcountmtable ; rowstoadd];

filenameprefix = 'Heatmap of Measures with Study Period';
% loop over each hospital, and create a heatmap for each
figurearray = [];
page = 0;
hospitals = unique(patientstudydate.Hospital);

for a = 1:size(hospitals,1)
        
    % create count table for patients just from current hospital
    hospital = hospitals{a};
    hpatients = patientstudydate.SmartCareID(ismember(patientstudydate.Hospital, hospital));
    hpdcountmtable = pdcountmtable(ismember(pdcountmtable.SmartCareID, hpatients),:);
    
    % create different flavors of sort order
    % 1) total number of measures
    hpcountmtable = varfun(@sum, hpdcountmtable(:,{'SmartCareID', 'GroupCount'}), 'GroupingVariables', {'SmartCareID'});
    hpcountmtable = sortrows(hpcountmtable, 'sum_GroupCount', 'descend');
    ysortmostmeasures = hpcountmtable.SmartCareID;
    
    % 2) days with measurements
    hpcountmtable = varfun(@sum, hpdcountmtable(:,{'SmartCareID'}), 'GroupingVariables', {'SmartCareID'});
    hpcountmtable = sortrows(hpcountmtable, 'GroupCount', 'descend');
    ysortmostdays = hpcountmtable.SmartCareID;
    
    % 3) days with 4 or more measures
    hpcountmtable = varfun(@sum, hpdcountmtable(hpdcountmtable.GroupCount >=4,{'SmartCareID'}), 'GroupingVariables', {'SmartCareID'});
    hpcountmtable = sortrows(hpcountmtable, 'GroupCount', 'descend');
    ysort4mdays = hpcountmtable.SmartCareID;
    
    % create the min and max smartcareid to allow me to hide the dummy row below
    dispmin = min(hpdcountmtable.SmartCareID);
    dispmax = max(hpdcountmtable.SmartCareID);

    % add dummy rows to create a record for every day in the range of the data
    % so the heatmap is scaled correctly for missing days
    % but excluded from display limits so the row doesn't show on the heatmap
    dummymin = min(hpdcountmtable.ScaledDateNum);
    dummymax = max(hpdcountmtable.ScaledDateNum);
    dummymeasures = hpdcountmtable(1:dummymax-dummymin+1,:);
    dummymeasures.SmartCareID(:) = 0;
    dummymeasures.GroupCount(:) = 1;
    for i = 1:dummymax-dummymin+1
        dummymeasures.ScaledDateNum(i) = i+dummymin-1;
    end
    hpdcountmtable = [hpdcountmtable ; dummymeasures];

    % create the heatmap
    fprintf('Creating heatmap for hospital %s\n', hospital);
    figurearray(a) = figure('Name', sprintf('%s - %s', filenameprefix, hospital));
    p = uipanel('Parent',figurearray(a),'BorderType','none'); 
    p.Title = sprintf('%s - %s', filenameprefix, hospital); 
    p.TitlePosition = 'centertop';
    p.FontSize = 20;
    p.FontWeight = 'bold'; 
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0.2, 0.2, 0.8, 0.8], 'PaperOrientation', 'portrait', ...
        'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 0.5], 'PaperType', 'a4');
    h = heatmap(p, hpdcountmtable, 'ScaledDateNum', 'SmartCareID', 'Colormap', colors, 'MissingDataColor', 'black', ...
        'ColorVariable','GroupCount','ColorMethod','max', 'MissingDataLabel', 'No data');
    h.Title = ' ';
    h.XLabel = 'Days';
    h.YLabel = 'Patients';
    h.YDisplayData = ysort4mdays;
    %h.YLimits = {dispmin,dispmax};
    h.CellLabelColor = 'none';
    h.GridVisible = 'off';

end

% save results
fprintf('Saving files\n');
for a = 1:size(figurearray,2)
    imagefilename = sprintf('%s-%s', filenameprefix, hospitals{a});
    savePlotInDir(figurearray(a), imagefilename, subfolder);
    close(figurearray(a));
end
