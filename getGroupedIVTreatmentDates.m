function [groupedtreatmentdates] = getGroupedIVTreatmentDates(abset)
% getGroupedIVTreatmentDates - gets the start and end dates for a batch of
% antibiotic treatments (collapses multiple drugs and contiguous/overlapping
% treatments)

if size(abset,1) > 0
    abset = sortrows(unique(abset(:,{'StartDate', 'StopDate'})), {'StartDate', 'StopDate'});
    abset = varfun(@max, abset, 'GroupingVariables', 'StartDate');
    abset.Properties.VariableNames{'max_StopDate'} = 'StopDate';
    abset.GroupCount = [];

    groupedtreatmentdates = abset(1:1,:);
    rowtoadd = groupedtreatmentdates;
    groupedtreatmentdates = [];
    delidx = [];

    priorstartdate = abset.StartDate(1);
    priorstopdate = abset.StopDate(1);
    for a = 2:size(abset,1)
        if abset.StartDate(a) == priorstopdate
            rowtoadd.StartDate = priorstartdate;
            rowtoadd.StopDate = abset.StopDate(a);
            groupedtreatmentdates = [groupedtreatmentdates; rowtoadd];
            delidx = [delidx ; a-1 ; a];
            priorstopdate = abset.StopDate(a);
        elseif abset.StartDate(a) > priorstartdate & abset.StopDate(a) <= priorstopdate
            delidx = [delidx ; a ];
        else
            priorstartdate = abset.StartDate(a);
            priorstopdate = abset.StopDate(a);
        end    
    end
    
    abset(delidx,:) = [];
    if size(groupedtreatmentdates,1) > 0
        groupedtreatmentdates = varfun(@max, groupedtreatmentdates, 'GroupingVariables', 'StartDate');
        groupedtreatmentdates.Properties.VariableNames{'max_StopDate'} = 'StopDate';
        groupedtreatmentdates.GroupCount = [];
    end
    groupedtreatmentdates = sortrows([abset ; groupedtreatmentdates], {'StartDate','StopDate'}, 'ascend');
else
    groupedtreatmentdates = abset;
end

end

