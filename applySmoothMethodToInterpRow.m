function [outputrow] = applySmoothMethodToInterpRow(interpdatarow, smfunction, smwindow, smlength, m, mfev1idx)

% applySmoothMethodToInterpRow - apply appropriate smoothing method to
% given interpolated data row (for use in predictive model)
%
% smfunction        Description
% ---------------   -----------
%       0           No smoothing
%       1           Mean for all measures
%       2           Median for all measures
%       3           Max for FEV1, mean for all others
%       4           Max for FEV1, none for all others
%
% smwindow          Description
% ---------------   -----------
%       1           Centered
%       2           Trailing
%
% smlength - number of days for window

if smfunction == 0
    outputrow = rawdatarow;
else
    if smwindow == 1
        width = smlength;
    elseif smwindow == 2
        width = [(smlength - 1) 0];
    end
    outputrow = interpdatarow;
    if smfunction == 1
        if smwindow == 1
            % for backward compatibility - can remove once prove results
            % match
            outputrow = smooth(interpdatarow, width);
        else
            outputrow = movmean(outputrow, width);
        end
    elseif smfunction == 2
        outputrow = movmedian(outputrow, width);
    elseif smfunction == 3
        % max smoothing for fev1
        if m == mfev1idx
            outputrow = movmax(outputrow, width);
        else
            if smwindow == 1
                % centered window - mean smoothing. For backward compatibility - can remove once prove results
                % match
                outputrow = smooth(interpdatarow, width);
            else
                % for trailing window - mean smoothing
                outputrow = movmean(outputrow, width);
            end
        end
    elseif smfunction == 4
        % max smoothing for fev1
        if m == mfev1idx
            outputrow = movmax(outputrow, width);
        else
            % no smoothing for other measures
            outputrow = interpdatarow;
        end     
    end
end

end

