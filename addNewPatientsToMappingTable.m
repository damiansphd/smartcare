function [redcapidmap] = addNewPatientsToMappingTable(redcapdata, redcapidmap)

% addNewPatientsToMappingTable - add records to the mapping table for new
% patients

priormaxstudyid = max(redcapidmap.ID);

allredcapids   = unique(redcapdata.study_id);
priorredcapids = redcapidmap.redcap_id;

% apply a quick check to ensure no redcap ids have been removed from the
% data-set. Please note, you need at least 2 ids in the prior list for this
% to work correctly
illogicalids = setdiff(priorredcapids, allredcapids);
if size(illogicalids, 1) > 0
    fprintf('**** found some previously existing redcap ids that no longer exist - please investigate ****\n');
    return;
end

newredcapids = setdiff(allredcapids, priorredcapids);
if ismember(class(newredcapids), {'cell'})
    newredcapids = natsort(newredcapids);
else
    newredcapids = sort(newredcapids);
end
nnewids = size(newredcapids, 1);

newstudyids = priormaxstudyid + (1:nnewids)';

tmpidmap = table('Size',[nnewids 2], 'VariableTypes', { 'double', 'cell'}, 'VariableNames', {'ID', 'redcap_id'});
tmpidmap.ID  = newstudyids;
tmpidmap.redcap_id = newredcapids;

redcapidmap = [redcapidmap; tmpidmap];

end

