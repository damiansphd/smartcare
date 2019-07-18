function [deltable] = appendDeletedRows(delrows, deltable, reason)

% appendDeletedRows - appends a set of deleted measurement rows to the
% deleted table along with the reason for the deletion

delrows.Reason(:) = reason;
deltable = [deltable; delrows];

end

