
fprintf('Enter the data for the intervention and measure to be analysed\n');
intervention = input('Intervention Nbr ? ');
if intervention > ninterventions
    fprintf('Invalid selection\n');
    return;
end

measure = input('Measure ? ');
if measure > nmeasures
    fprintf('Invalid selection\n');
    return;
end

temp_meancurvedata = best_meancurvedata;
temp_meancurvesum = best_meancurvesum;
temp_meancurvecount = best_meancurvecount;
temp_meancurvemean = best_meancurvemean;
temp_meancurvestd = best_meancurvestd;

[temp_meancurvedata, temp_meancurvesum, temp_meancurvecount, temp_meancurvemean, temp_meancurvestd] = am4RemoveFromMean(temp_meancurvedata, temp_meancurvesum, ...
        temp_meancurvecount, temp_meancurvemean, temp_meancurvestd, amNormcube, amInterventions, intervention, ...
        max_offset, align_wind, nmeasures, curveaveragingmethod, smoothingmethod);

scid   = amInterventions.SmartCareID(intervention);
start  = amInterventions.IVScaledDateNum(intervention);
%offset = best_offsets(intervention);

nondaycols1 = 3;
Day1 = zeros(1,align_wind);
Day1 = array2table(Day1);
datawindowtable = table('Size',[1 nondaycols1], ...
    'VariableTypes', {'double', 'cell', 'double'}, ...
    'VariableNames', {'Offset', 'RowType', 'CalcValue'});
datawindowtable = [datawindowtable Day1];
for i = 1:align_wind
    datawindowtable.Properties.VariableNames{i+nondaycols1} = sprintf('D_%d',i);
end
rowtoadd1 = datawindowtable;
datawindowtable(1,:) = [];

nondaycols2 = 1;
Day2 = zeros(1,max_offset);
Day2 = array2table(Day2);
offsettable = table('Size',[1 nondaycols2], ...
    'VariableTypes', {'cell'}, ...
    'VariableNames', {'RowType'});
offsettable = [offsettable Day2];
for i = 1:max_offset
    offsettable.Properties.VariableNames{i+nondaycols2} = sprintf('O_%d',i-1);
end
rowtoadd2 = offsettable;
offsettable(1,:) = [];

for offset = 0:max_offset-1
    rowtoadd1.Offset = offset;
    
    rowtoadd1.RowType = 'Raw Data';
    rowtoadd1.CalcValue = 0;
    rowtoadd1(:,nondaycols1+1:nondaycols1+align_wind) = array2table(amDatacube(scid, start-align_wind:start-1, measure));
    datawindowtable = [datawindowtable ; rowtoadd1];

    rowtoadd1.RowType = 'Mu';
    rowtoadd1.CalcValue = 0;
    rowtoadd1(:,nondaycols1+1:nondaycols1+align_wind) = array2table(normmean(intervention, measure));
    datawindowtable = [datawindowtable ; rowtoadd1];

    rowtoadd1.RowType = 'Normalised Data';
    rowtoadd1.CalcValue = 0;
    rowtoadd1(:,nondaycols1+1:nondaycols1+align_wind) = array2table(amNormcube(scid, start-align_wind:start-1, measure));
    datawindowtable = [datawindowtable ; rowtoadd1];

    rowtoadd1.RowType = 'Mean Curve Data';
    rowtoadd1.CalcValue = 0;
    if smoothingmethod == 2
        tempmean = smooth(temp_meancurvemean(:,measure),3);
    else
        tempmean = temp_meancurvemean(:,measure);
    end
    rowtoadd1(:,nondaycols1+1:nondaycols1+align_wind) = array2table(reshape(tempmean(max_offset+1-offset:max_offset+align_wind-offset), [1 align_wind]));
    datawindowtable = [datawindowtable ; rowtoadd1];

    rowtoadd1.RowType = 'Sigma';
    rowtoadd1.CalcValue = 0;
    if sigmamethod == 4
        rowtoadd1(:,nondaycols1+1:nondaycols1+align_wind) = array2table(reshape(temp_meancurvestd(max_offset+1-offset:max_offset+align_wind-offset, measure), [1 align_wind]));
    else
        rowtoadd1(:,nondaycols1+1:nondaycols1+align_wind) = array2table(normstd(intervention, measure));
    end
    datawindowtable = [datawindowtable ; rowtoadd1];

    rowtoadd1.RowType = 'CalcObjFcn';
    dist = 0;
    for i = 1:align_wind
        if ~isnan(amNormcube(scid, start - i, m))
            if sigmamethod == 4
                thisdist = ((tempmean((max_offset + align_wind + 1) - i - offset) - amNormcube(scid, start-i, measure)) ^ 2) ...
                / (temp_meancurvestd((max_offset + align_wind + 1) - i - offset, measure) ^ 2);
            else
                thisdist = ((tempmean((max_offset + align_wind + 1) - i - offset) - amNormcube(scid, start-i, measure)) ^ 2) ...
                / (normstd(intervention, measure ^ 2));
            end
            dist = dist + thisdist;
        end
    end
    rowtoadd1.CalcValue = dist;
    rowtoadd1(:,nondaycols1+1:nondaycols1+align_wind) = array2table([0]);
    datawindowtable = [datawindowtable ; rowtoadd1];

    rowtoadd1.RowType = 'ObjFcn';
    rowtoadd1.CalcValue = hstgorig(measure, intervention,offset+1);
    rowtoadd1(:,nondaycols1+1:nondaycols1+align_wind) = array2table([0]);
    datawindowtable = [datawindowtable ; rowtoadd1];
    
    rowtoadd1.RowType = 'ExpObjFcn';
    rowtoadd1.CalcValue = exp(-1 * (hstgorig(m, j, offset+1) - min(hstgorig(m, j, offset+1))));
    rowtoadd1(:,nondaycols1+1:nondaycols1+align_wind) = array2table([0]);
    datawindowtable = [datawindowtable ; rowtoadd1];
    
    rowtoadd1.RowType = 'PosteriorProb';
    rowtoadd1.CalcValue = best_histogram(measure, intervention,offset+1);
    rowtoadd1(:,nondaycols1+1:nondaycols1+align_wind) = array2table([0]);
    datawindowtable = [datawindowtable ; rowtoadd1];

end

rowtoadd2.RowType = 'CalcObjFcn';
for offset = 0:max_offset-1
    rowtoadd2(:,nondaycols2+offset+1) = array2table(datawindowtable.CalcValue(datawindowtable.Offset==offset & ismember(datawindowtable.RowType, {rowtoadd2.RowType})));
end
offsettable = [offsettable ; rowtoadd2];

rowtoadd2.RowType = 'ObjFcn';
for offset = 0:max_offset-1
    rowtoadd2(:,nondaycols2+offset+1) = array2table(datawindowtable.CalcValue(datawindowtable.Offset==offset & ismember(datawindowtable.RowType, {rowtoadd2.RowType})));
end
offsettable = [offsettable ; rowtoadd2];

rowtoadd2.RowType = 'ExpObjFcn';
for offset = 0:max_offset-1
    rowtoadd2(:,nondaycols2+offset+1) = array2table(datawindowtable.CalcValue(datawindowtable.Offset==offset & ismember(datawindowtable.RowType, {rowtoadd2.RowType})));
end
offsettable = [offsettable ; rowtoadd2];

rowtoadd2.RowType = 'PosteriorProb';
for offset = 0:max_offset-1
    rowtoadd2(:,nondaycols2+offset+1) = array2table(datawindowtable.CalcValue(datawindowtable.Offset==offset & ismember(datawindowtable.RowType, {rowtoadd2.RowType})));
end
offsettable = [offsettable ; rowtoadd2];


for currinter = 1:ninterventions
    for m = 1:nmeasures
        pdoffset(m, currinter, :) = exp(-1 * (hstg(m, currinter, :) - max(hstg(m, currinter, :))));
        pdoffset(m, currinter, :) = pdoffset(m, currinter, :) / sum(pdoffset(m, currinter, :));
    end
end
