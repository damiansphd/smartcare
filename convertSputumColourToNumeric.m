function [rawmeasdata, sputumcolouridx] = convertSputumColourToNumeric(rawmeasdata)

% convertSputumColourToNumeric - create an index table of all sputum
% colours in the measurement file and update measures to be the index
% reference

rawmeasdata.Colour = lower(rawmeasdata.Colour);

% for now remove all sputum colour measurements until get a scale from
% Claire
%idx = ismember(rawmeasdata.Colour, 'null');
idx = true(size(rawmeasdata, 1), 1);
fprintf('Removing %d Null measurements\n', sum(idx));
rawmeasdata(idx, :) = [];

sputumcolouridx = array2table(unique(lower(rawmeasdata.Colour)));
sputumcolouridx.Properties.VariableNames({'Var1'}) = {'Colour'};
sputumcolouridx.Idx(:) = 1:size(sputumcolouridx, 1);

rawmeasdata = innerjoin(rawmeasdata, sputumcolouridx, 'LeftKeys', {'Colour'}, 'RightKeys', {'Colour'}, 'RightVariables', {'Idx'});
rawmeasdata.Colour = [];
rawmeasdata.Properties.VariableNames({'Idx'}) = {'Colour'};

end

