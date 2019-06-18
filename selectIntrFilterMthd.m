function intrmode = selectIntrFilterMthd()

% selectIntrFiltMthd - enter the methodology for filtering interventions
%       1: No Filtering
%       2: Filter Sequential Interventions out

sintrmode = input('Enter Intervention Filtering mode ? ', 's');
intrmode = str2double(sintrmode);
if (isnan(intrmode) || intrmode < 1 || intrmode > 2)
    fprintf('Invalid choice - defaulting to 1\n');
    intrmode = 1;
end

end

