function [clphysdata] = createInterpMeasure(clphysdata, rectype, detaillog)

% createInterpMeasure - function to add a new measure of interpolated
% measures, but only interpolating points within a defined date gap
% < rename to be generic and edit code to use getColumnForMeasure, then run
% twice for both FEV1 and Weight from loadclimbdata>

% max gap to interpolate fev1 recordings between
maxgap = 4;
newrectype = sprintf('Interp%s', rectype);
outputcolname = getColumnForMeasure(rectype);

fprintf('Creating interpolated %s with a max gap of %d days\n', rectype, maxgap);

tic
clphysdata = sortrows(clphysdata, {'RecordingType', 'SmartCareID', 'DateNum'}, 'ascend');

origmidx  = ismember(clphysdata.RecordingType, {rectype});
mphysdata = clphysdata(origmidx, :);
mphysdata.RecordingType(:) = {newrectype};

patlist = unique(mphysdata.SmartCareID);

for p = 1:size(patlist)
    scid = patlist(p);
    
    pmdata = mphysdata(mphysdata.SmartCareID == scid, :);
    i = 1;
    addrows = pmdata(i, :);
    if detaillog
        fprintf('Patient %3d: Adding actual row (ScaledDateNum %3d, DateNum %3d, Date %19s %s %.2f\n', scid, pmdata.ScaledDateNum(i), ...
                        pmdata.DateNum(i), datestr(pmdata.Date_TimeRecorded(i), 31), outputcolname, pmdata{i, {outputcolname}});
    end
    rowtoadd = addrows;
    
    for i = 2:size(pmdata, 1)
        if pmdata.DateNum(i) - pmdata.DateNum(i - 1) <= maxgap
            range   = pmdata.DateNum(i) - pmdata.DateNum(i - 1);
            fromval = pmdata{i - 1, {outputcolname}};
            toval   = pmdata{i, {outputcolname}};
            diff    = toval - fromval;
            for d = 1:(range - 1) 
                rowtoadd.ScaledDateNum       = pmdata.ScaledDateNum(i - 1) + d;
                rowtoadd.DateNum             = pmdata.DateNum(i - 1) + d;
                rowtoadd.Date_TimeRecorded   = pmdata.Date_TimeRecorded(i - 1) + days(d);
                rowtoadd{1, {outputcolname}} = fromval + (diff * d / range);
                if detaillog
                    fprintf('Patient %3d: Interpolating row (ScaledDateNum %3d, DateNum %3d, Date %19s %s %.3f\n', scid, rowtoadd.ScaledDateNum, ...
                                    rowtoadd.DateNum, datestr(rowtoadd.Date_TimeRecorded, 31), outputcolname, rowtoadd{1, {outputcolname}});
                end
                addrows = [addrows; rowtoadd];
            end
        end
        rowtoadd = pmdata(i, :);
        if detaillog
            fprintf('Patient %3d: Adding actual row (ScaledDateNum %3d, DateNum %3d, Date %19s %s %.2f\n', scid, pmdata.ScaledDateNum(i), ...
                            pmdata.DateNum(i), datestr(pmdata.Date_TimeRecorded(i), 31), outputcolname, pmdata{i, {outputcolname}});
        end
        addrows = [addrows; rowtoadd];
    end
    clphysdata = [clphysdata; addrows];
    if detaillog
        fprintf('\n');
    end
end

clphysdata = sortrows(clphysdata, {'SmartCareID', 'DateNum', 'RecordingType'}, 'ascend');
toc
fprintf('\n');

end

