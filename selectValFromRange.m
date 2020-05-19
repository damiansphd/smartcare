function [value] = selectValFromRange(questext, fromrange, torange)

% selectValFromRange - allows you to select a value from a range

valid = false;

while ~valid
    svalue = input(sprintf('%s (%d:%d) ? ', questext, fromrange, torange), 's');

    value = str2double(svalue);

    if (isnan(value) || value < fromrange || value > torange)
        fprintf('Invalid choice\n');
        valid = false;
    else
        valid = true;
    end
end

end


