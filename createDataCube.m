function [datacube] = createDataCube(physdata, measures, npatients, ndays, nmeasures)

% createDataCube - populates a 3D array from the measurement data of
% appropriate size
datacube = NaN(npatients, ndays, nmeasures);

physdata = innerjoin(physdata, measures, 'LeftKeys', {'RecordingType'}, 'RightKeys', {'Name'});

for i=1:size(physdata,1)
    scid = physdata.SmartCareID(i);
    scaleddn = physdata.ScaledDateNum(i);
    index = physdata.Index(i);
    column = physdata.Column{i}; % brphysdata features (FEV, Sleep, etc)
    
    % populate the datacube with measured values
    datacube(scid, scaleddn, index) = physdata{i, {column}};
    %if ~isnan(datacube(scid, scaleddn, index))
    %    pmmid50mean = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(5);
    %    pmstd = demographicstable{demographicstable.SmartCareID == scid & ismember(demographicstable.RecordingType, measure),{ddcolumn}}(2);
    %    if pmstd == 0
    %        pmstd = overalltable{ismember(overalltable.RecordingType, measure),{ddcolumn}}(2);
    %        fprintf('Zero std for patient %d and measure %s - using overall std %d\n', scid, physdata.RecordingType{i}, pmstd);
    %    end
    %    normcube(scid, scaleddn, index) = (datacube(scid, scaleddn, index) - pmmid50mean)/pmstd;
    %end
    if (round(i/10000) == i/10000)
        fprintf('Processed %5d rows\n', i);
    end
end

end

