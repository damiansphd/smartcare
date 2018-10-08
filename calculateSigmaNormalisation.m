function [normstd] = calculateSigmaNormalisation(amInterventions, measures, demographicstable, ninterventions, nmeasures, sigmamethod)

% calculateSigmaNormalisation - populates an array of ninterventions by
% nmeasures with the multiplicative normalisation (sigma) values

normstd = zeros(ninterventions, nmeasures);
for i = 1:ninterventions
    for m = 1:nmeasures
        if sigmamethod == 1
            normstd(i,m) = measures.AlignWindStd(m);
        elseif sigmamethod == 2
            normstd(i,m) = measures.OverallStd(m);
        elseif (sigmamethod == 3) || (sigmamethod == 4)
            scid = amInterventions.SmartCareID(i);
            column = getColumnForMeasure(measures.Name{m});
            ddcolumn = sprintf('Fun_%s',column);
            if size(find(demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m})),1) == 0
                fprintf('Could not find std for patient %d and measure %d so using overall std for measure instead\n', scid, m);
                normstd(i,m) = measures.OverallStd(m);
            else
                normstd(i,m) = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measures.Name{m}),{ddcolumn}}(2);
            end
        else 
            %shouldn't get here...
            fprintf('Should never get to this branch of code\n');
        end
    end
end

end

