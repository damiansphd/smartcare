function [clphysdata] = createInterpFEV1Measures(clphysdata, detaillog)

% createInterpFEV1Measures - function to add a new measure of interpolated
% FEV1 measures, but only interpolating points within a defined date gap
% < rename to be generic and edit code to use getColumnForMeasure, then run
% twice for both FEV1 and Weight from loadclimbdata>

% max gap to interpolate fev1 recordings between
maxgap = 4;

fprintf('Creating Interpolated FEV1 measurements with a max gap of %d days\n', maxgap);

tic
clphysdata = sortrows(clphysdata, {'RecordingType', 'SmartCareID', 'DateNum'}, 'ascend');

origfevidx  = ismember(clphysdata.RecordingType, {'FEV1Recording'});
fevphysdata = clphysdata(origfevidx, :);
fevphysdata.RecordingType(:) = {'InterpFEV1Recording'};

patlist = unique(fevphysdata.SmartCareID);

for p = 1:size(patlist)
    scid = patlist(p);
    
    pfevdata = fevphysdata(fevphysdata.SmartCareID == scid, :);
    i = 1;
    addrows = pfevdata(i, :);
    if detaillog
        fprintf('Patient %3d: Adding actual row (ScaledDateNum %3d, DateNum %3d, Date %19s FEV %.2f\n', scid, pfevdata.ScaledDateNum(i), ...
                            pfevdata.DateNum(i), datestr(pfevdata.Date_TimeRecorded(i), 31), pfevdata.FEV(i));
    end
    rowtoadd = addrows;
    
    for i = 2:size(pfevdata, 1)
        if pfevdata.DateNum(i) - pfevdata.DateNum(i - 1) <= maxgap
            range   = pfevdata.DateNum(i) - pfevdata.DateNum(i - 1);
            fromval = pfevdata.FEV(i - 1);
            toval   = pfevdata.FEV(i);
            diff    = toval - fromval;
            for d = 1:(range - 1) 
                rowtoadd.ScaledDateNum     = pfevdata.ScaledDateNum(i - 1) + d;
                rowtoadd.DateNum           = pfevdata.DateNum(i - 1) + d;
                rowtoadd.Date_TimeRecorded = pfevdata.Date_TimeRecorded(i - 1) + days(d);
                rowtoadd.FEV               = fromval + (diff * d / range);
                if detaillog
                    fprintf('Patient %3d: Interpolating row (ScaledDateNum %3d, DateNum %3d, Date %19s FEV %.3f\n', scid, rowtoadd.ScaledDateNum, ...
                            rowtoadd.DateNum, datestr(rowtoadd.Date_TimeRecorded, 31), rowtoadd.FEV);
                end
                addrows = [addrows; rowtoadd];
            end
        end
        rowtoadd = pfevdata(i, :);
        if detaillog
            fprintf('Patient %3d: Adding actual row (ScaledDateNum %3d, DateNum %3d, Date %19s FEV %.2f\n', scid, pfevdata.ScaledDateNum(i), ...
                        pfevdata.DateNum(i), datestr(pfevdata.Date_TimeRecorded(i), 31), pfevdata.FEV(i));
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

