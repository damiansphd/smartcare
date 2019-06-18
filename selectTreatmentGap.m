function treatgap = selectTreatmentGap()

% selectTreatmentGap - enter the gap between the end of a treatment and the
% start of the next. Used to define the list of interventions

streatgap = input('Enter gap in treatments (days) ? ', 's');
treatgap = str2double(streatgap);
if (isnan(treatgap) || treatgap < 1 || treatgap > 50)
    fprintf('Invalid choice - defaulting to 10\n');
    treatgap = 10;
end

end

