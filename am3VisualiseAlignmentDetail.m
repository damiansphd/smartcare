function [tempInterventions] = am3VisualiseAlignmentDetail(amDatacube, amInterventions, offsets, measures, max_offset, align_wind, nmeasures, run_type, study)

% am3VisualiseAlignmentDetail - creates a plot of horizontal bars showing 
% the alignment of the data window (including the best_offset) for all 
%interventions. Also indicates missing data in each of the horizontal bars

datatable = table('Size',[1 3], ...
    'VariableTypes', {'double',       'double',     'double'}, ...
    'VariableNames', {'Intervention', 'ScaledDateNum', 'Count'});

rowtoadd = datatable;

nInterventions = size(amInterventions,1);
tempInterventions = array2table(offsets);
tempInterventions.Intervention = [1:nInterventions]';
tempInterventions = sortrows(tempInterventions, {'offsets', 'Intervention'}, {'descend', 'ascend'});

for m = 1:nmeasures
    datatable(1:size(datatable,1),:) = [];
    for i = 1:nInterventions
        scid = amInterventions.SmartCareID(i);
        start = amInterventions.IVScaledDateNum(i);
        offset = offsets(i);

        fprintf('Intervention %2d, patient %3d, start %3d, best_offset %2d\n', i, scid, start, offset);
    
        rowtoadd.Intervention = i;
        rowtoadd.Count = 2;
        for d = 1:align_wind
            if start - d <= 0
              continue;
            end
            if ~isnan(amDatacube(scid, start - d, m))
                rowtoadd.ScaledDateNum = 0 - d - offset;
                datatable = [datatable ; rowtoadd];
            end
        end
        rowtoadd.Count = 1;
        for d = 1:max_offset
            if start -align_wind - d <= 0
                continue;
            end
            if ~isnan(amDatacube(scid, start -align_wind - d, m))
                rowtoadd.ScaledDateNum = 0 - align_wind - d - offset;
                datatable = [datatable ; rowtoadd];
            end
        end
   
    end

    temp = hsv;
    brightness = .75;
    colors(1,:)  = temp(8,:)  .* brightness;
    colors(2,:)  = temp(16,:)  .* brightness;

    title = sprintf('Data Window Alignment - %s', measures.DisplayName{m});
    f = figure('Name', title);
    p = uipanel('Parent',f,'BorderType','none'); 
    p.Title = title; 
    p.TitlePosition = 'centertop';
    p.FontSize = 20;
    p.FontWeight = 'bold'; 
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0.2, 0.2, 0.8, 0.8], 'PaperOrientation', 'landscape', ...
        'PaperUnits', 'normalized','PaperPosition',[0, 0, 1, 1], 'PaperType', 'a3');
    h = heatmap(p, datatable, 'ScaledDateNum', 'Intervention', 'Colormap', colors, 'MissingDataColor', 'white', ...
        'ColorVariable','Count','ColorMethod','max', 'MissingDataLabel', 'No data', 'ColorBarVisible', 'off');
    h.Title = ' ';
    h.XLabel = 'Days Prior to Intervention';
    h.YLabel = 'Intervention';
    h.YDisplayData = tempInterventions.Intervention;
    h.XLimits = {0-align_wind-max_offset,-1};
    h.CellLabelColor = 'none';
    h.GridVisible = 'on';

end

end

    
