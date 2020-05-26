function [normmean] = calculateMuNormalisation(amDatacube, amInterventions, measures, demographicstable, ...
    dataoutliers, align_wind, ninterventions, nmeasures, mumethod, study)

% calculateMuNormalisation - - populates an array of ninterventions by
% nmeasures with the additive normalisation (mu) values

invmeasarray = getInvertedMeasures(study);
exnormmeas   = getExNormMeasures(study);

normmean = zeros(ninterventions, nmeasures);
for i = 1:ninterventions
    if mumethod == 1
        meanwindow = 8;
    elseif mumethod == 2
        meanwindow = 20;        
    else
        meanwindow = 10;
    end
    scid   = amInterventions.SmartCareID(i);
    start = amInterventions.IVScaledDateNum(i);
    if (start - align_wind - meanwindow) <= 0
        meanwindow = start - align_wind - 1;
    end
    if meanwindow < 1
        meanwindow = 1;
    end
    for m = 1:nmeasures
        if ~ismember(measures.DisplayName(m), exnormmeas)
            % this code block is for measures that should be normalised
            if (start - align_wind - meanwindow) < 1
                meanwindowdata = 0;
            else
                meanwindowdata = amDatacube(scid, (start - align_wind - meanwindow): (start - 1 - align_wind), m);
            end
            % remove data outliers for mumethod 4 or 5
            if mumethod == 4 || mumethod == 5
                tmpdataoutliers = dataoutliers(dataoutliers.NStdDevOutlier==5 & dataoutliers.SmartCareID == scid & dataoutliers.MeasureID == m,:);
                ndel = 0;
                for d = 1:size(tmpdataoutliers,1)
                    if (start - align_wind - meanwindow) <= tmpdataoutliers.Day(d) && (start - 1 - align_wind) >= tmpdataoutliers.Day(d)
                        fprintf('For Invervention %d, excluding Data outlier (ID %d, Measure %d, Day %d) from meanwindow\n', i, scid, m, tmpdataoutliers.Day(d));
                        meanwindowdata(tmpdataoutliers.Day(d) - (start - align_wind - meanwindow) + 1 - ndel) = [];
                        ndel = ndel + 1;
                    end
                end
            end
            if ~ismember(measures.DisplayName(m), invmeasarray)
                meanwindowdata = sort(meanwindowdata(~isnan(meanwindowdata)), 'ascend');
            else
                meanwindowdata = sort(meanwindowdata(~isnan(meanwindowdata)), 'descend');
            end
            if size(meanwindowdata,2) >= 3
                if mumethod == 1
                    % take mean of mean window (8 days prior to data window -
                    % as long as there are 3 or more data points in the window
                    normmean(i, m) = mean(meanwindowdata(1:end));
                elseif mumethod == 2
                    % upper quartile mean of mean window method
                    percentile75 = round(size(meanwindowdata,2) * .75) + 1;
                    normmean(i, m) = mean(meanwindowdata(percentile75:end));
                else
                    % exclude bottom quartile from mean methods (3, 4, 5)
                    percentile25 = round(size(meanwindowdata,2) * .25) + 1;
                    normmean(i, m) = mean(meanwindowdata(percentile25:end));
                end
                % for mumethod 5, if the interventions is sequential, take the
                % max of mean calculated above and the overall upper 50% mean
                % over all patient/measurement data
                if mumethod == 5
                    if (amInterventions.SequentialIntervention(i) == 'Y')
                        if ~ismember(measures.DisplayName(m), invmeasarray)
                            alldata = sort(amDatacube(scid, ~isnan(amDatacube(scid, :, m)), m),'ascend');
                            percentile50 = round(size(alldata,2) * .5) + 1;
                            upper50mean = mean(alldata(percentile50:end));
                            if upper50mean > normmean(i,m)
                                fprintf('Sequential intervention, and using upper 50%% mean instead for intervention %d, measure %d\n', i, m);
                            end
                            normmean(i,m) = max(upper50mean, normmean(i,m));
                        else
                            alldata = sort(amDatacube(scid, ~isnan(amDatacube(scid, :, m)), m),'descend');
                            percentile50 = round(size(alldata,2) * .5) + 1;
                            upper50mean = mean(alldata(percentile50:end));
                            if upper50mean < normmean(i,m)
                                fprintf('Sequential intervention, and using upper 50%% mean instead for intervention %d, measure %d\n', i, m);
                            end
                            normmean(i,m) = min(upper50mean, normmean(i,m));
                        end 
                    end
                end
            else
                % if not enough data points in the mean window, use the
                % patients inter-quartile mean
                if size(find(demographicstable.SmartCareID(demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}))),1) > 0
                    % for mumethod 5, use the upper 50 percent mean over all
                    % patient/measurement data
                    if mumethod == 5
                        fprintf('Using upper 50%% mean for intervention %d, measure %d\n', i, m);
                        if ~ismember(measures.DisplayName(m), invmeasarray)
                            alldata = sort(amDatacube(scid, ~isnan(amDatacube(scid, :, m)), m),'ascend');
                        else
                            alldata = sort(amDatacube(scid, ~isnan(amDatacube(scid, :, m)), m),'descend');
                        end
                        percentile50 = round(size(alldata,2) * .5) + 1;
                        normmean(i,m) = mean(alldata(percentile50:end));
                    % else use inter quartile mean over all patient/measurement
                    % data
                    else
                        fprintf('Using inter-quartile mean for intervention %d, measure %d\n', i, m);
                        column = getColumnForMeasure(measures.Name{m});
                        ddcolumn = sprintf('Fun_%s',column);
                        normmean(i, m) = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(5);
                    end
                else
                    fprintf('No measures for intervention %d, measure %d\n', i, m);
                    normmean(i,m) = 0;
                end
            end
        else
            % for measures excluded from normalisation, set to zero mean
            normmean(i,m) = 0;
        end
    end
end

end

