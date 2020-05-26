function [normstd] = calculateSigmaNormalisation(amInterventions, measures, demographicstable, ninterventions, nmeasures, sigmamethod, study)

% calculateSigmaNormalisation - populates an array of ninterventions by
% nmeasures with the multiplicative normalisation (sigma) values

exnormmeas   = getExNormMeasures(study);

normstd = zeros(ninterventions, nmeasures);
for i = 1:ninterventions
    for m = 1:nmeasures
        % this code block is for measures that should be normalised
        if ~ismember(measures.DisplayName(m), exnormmeas)
            if sigmamethod == 1
                normstd(i,m) = measures.AlignWindStd(m);
            elseif sigmamethod == 2
                normstd(i,m) = measures.OverallStd(m);
            elseif (sigmamethod == 3) || (sigmamethod == 4)
                scid = amInterventions.SmartCareID(i);
                column = getColumnForMeasure(measures.Name{m});
                ddcolumn = sprintf('Fun_%s',column);
                if size(find(demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m})),1) == 0
                    fprintf('Intervention %d: Could not find std for patient %d and measure %d so using overall std for measure instead\n', i, scid, m);
                    normstd(i,m) = measures.OverallStd(m);
                else
                    normstd(i,m) = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(2);
                    if normstd(i,m) == 0
                        fprintf('Intervention %d: Zero std for patient %d and measure %d so using overall std for measure instead\n', i, scid, m);
                        normstd(i,m) = measures.OverallStd(m);
                    end
                end
            else 
                %shouldn't get here...
                fprintf('Should never get to this branch of code\n');
            end
        else
            % for measures excluded from normalisation, set to unit
            % variance
            normstd(i,m) = 1;
        end
    end
end

end

