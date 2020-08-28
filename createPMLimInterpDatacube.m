function [pmLimInterpDatacube] = createPMLimInterpDatacube(pmPatients, pmRawDatacube, npatients, nmeasures, maxgap)

% createPMLimInterpDatacube - creates the data cube with limited interpolation (gap of 1-3 days),
% and then replaces remaining missing data with zeros

pmLimInterpDatacube = pmRawDatacube;

for p = 1:npatients
    for m = 1:nmeasures
        pt1 = find(~isnan(pmLimInterpDatacube(p, :, m)), 1);
        for i = (pt1 + 1):(pmPatients.LastMeasdn(p) - pmPatients.FirstMeasdn(p) + 1)
            if ~isnan(pmLimInterpDatacube(p, i, m))
                % found next data point
                if (i - pt1) == 1
                    % consecutive data points - no gap - just bring forward
                    % last data point
                    %fprintf('%3d: Consecutive point\n', i);
                elseif (i - pt1) > 1 && (i - pt1) <= maxgap
                    % gap within interp range - interpolate points
                    %fprintf('%3d: Gap within range, interpolating from %d to %d\n', i, pt1+1, i-1);
                    diff  = pmLimInterpDatacube(p, i, m) - pmLimInterpDatacube(p, pt1, m);
                    range = i - pt1; 
                    for d = 1:(range - 1) 
                        pmLimInterpDatacube(p, pt1 + d, m) = pmLimInterpDatacube(p, pt1, m) + (diff * d / range);
                        %fprintf('%3d: New value %.2f\n', pt1 + d, pmLimInterpDatacube(p, pt1 + d, m));
                    end
                elseif (i - pt1) > 1 && (i - pt1) > maxgap
                    % gap outside interp range - just bring forward last
                    % data point
                    %fprintf('%3d: Point outside range - leaving %d to %d missing\n', i, pt1+1, i-1); 
                end
                pt1 = i;
            else
                % missing data point - skip
                %fprintf('%3d: Missing point\n', i);
                continue;
            end
        end
    end
end

end

