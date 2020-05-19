function [bound] = selectLabBound(typetext, fromrange, torange)

% selectLabBound - wrapper around range selection function for labelled
% bound selection

questext = sprintf('Enter %s for exacerbation start', typetext);
[bound] = selectValFromRange(questext, fromrange, torange);

end

