function [measures, nmeasures] = createMeasuresTable(physdata)

% creates the measures table
%
% Input:
% ------
% physdata      measurements data
% 
% Output:
% -------
% nmeasures     #recording types
% measures      table template of size (nmeasures, 7) with AlignWindStd, 
%   OvervallStd, Mask columns to be populated during alignment model execution

nmeasures = size(unique(physdata.RecordingType), 1);

measures = table('Size',[nmeasures 4], 'VariableTypes', {'double', 'cell', 'cell', 'cell'} ,'VariableNames', {'Index', 'Name', 'DisplayName', 'Column'});
measures.Index = [1:nmeasures]';
measures.Name = unique(physdata.RecordingType);
measures.DisplayName = replace(measures.Name, 'Recording', '');
%for i = 1:size(measures, 1)
%    idx = find(isstrprop(measures.DisplayName{i},'upper'));
%    if size(idx, 2) > 1
%        measures.DisplayName{i} = sprintf('%s %s', extractBefore(measures.DisplayName{i}, idx(2)), extractAfter(measures.DisplayName{i}, idx(2) - 1));
%    end
%end
measures.AlignWindStd = zeros(nmeasures, 1); % populate during model execution
measures.OverallStd = zeros(nmeasures, 1); % populate during model execution
measures.Mask = zeros(nmeasures, 1); % populate during model execution

for i = 1:size(measures,1)
     measures.Column(i) = cellstr(getColumnForMeasure(measures.Name{i}));
end


end

